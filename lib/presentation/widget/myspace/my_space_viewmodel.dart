// LinShare is an open source filesharing software, part of the LinPKI software
// suite, developed by Linagora.
//
// Copyright (C) 2020 LINAGORA
//
// This program is free software: you can redistribute it and/or modify it under the
// terms of the GNU Affero General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later version,
// provided you comply with the Additional Terms applicable for LinShare software by
// Linagora pursuant to Section 7 of the GNU Affero General Public License,
// subsections (b), (c), and (e), pursuant to which you must notably (i) retain the
// display in the interface of the “LinShare™” trademark/logo, the "Libre & Free" mention,
// the words “You are using the Free and Open Source version of LinShare™, powered by
// Linagora © 2009–2020. Contribute to Linshare R&D by subscribing to an Enterprise
// offer!”. You must also retain the latter notice in all asynchronous messages such as
// e-mails sent with the Program, (ii) retain all hypertext links between LinShare and
// http://www.linshare.org, between linagora.com and Linagora, and (iii) refrain from
// infringing Linagora intellectual property rights over its trademarks and commercial
// brands. Other Additional Terms apply, see
// <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf>
// for more details.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for
// more details.
// You should have received a copy of the GNU Affero General Public License and its
// applicable Additional Terms for LinShare along with this program. If not, see
// <http://www.gnu.org/licenses/> for the GNU Affero General Public License version
//  3 and <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf> for
//  the Additional Terms applicable to LinShare software.

import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:domain/domain.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/model/file/document_presentation_file.dart';
import 'package:linshare_flutter_app/presentation/model/file/selectable_element.dart';
import 'package:linshare_flutter_app/presentation/model/item_selection_type.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/my_space_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/ui_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_file_action.dart';
import 'package:linshare_flutter_app/presentation/redux/online_thunk_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/my_space_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/ui_state.dart';
import 'package:linshare_flutter_app/presentation/util/local_file_picker.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/util/router/route_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/validator_failure_extension.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/context_menu_builder.dart';
import 'package:linshare_flutter_app/presentation/view/dialog/loading_dialog.dart';
import 'package:linshare_flutter_app/presentation/view/downloading_file/downloading_file_builder.dart';
import 'package:linshare_flutter_app/presentation/view/header/context_menu_header_builder.dart';
import 'package:linshare_flutter_app/presentation/view/header/more_action_bottom_sheet_header_builder.dart';
import 'package:linshare_flutter_app/presentation/view/header/simple_bottom_sheet_header_builder.dart';
import 'package:linshare_flutter_app/presentation/view/modal_sheets/confirm_modal_sheet_builder.dart';
import 'package:linshare_flutter_app/presentation/view/modal_sheets/edit_text_modal_sheet_builder.dart';
import 'package:linshare_flutter_app/presentation/view/order_by/order_by_dialog_bottom_sheet.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/destination_picker/destination_picker_action/copy_destination_picker_action.dart';
import 'package:linshare_flutter_app/presentation/widget/destination_picker/destination_picker_action/negative_destination_picker_action.dart';
import 'package:linshare_flutter_app/presentation/widget/destination_picker/destination_picker_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_document_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/upload_file_arguments.dart';
import 'package:open_file/open_file.dart' as open_file;
import 'package:permission_handler/permission_handler.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:share/share.dart' as share_library;

import 'document_details/document_details_arguments.dart';

class MySpaceViewModel extends BaseViewModel {
  final LocalFilePicker _localFilePicker;
  final AppNavigation _appNavigation;
  final GetAllDocumentInteractor _getAllDocumentInteractor;
  final DownloadFileInteractor _downloadFileInteractor;
  final CopyMultipleFilesToSharedSpaceInteractor _copyMultipleFilesToSharedSpaceInteractor;
  final RemoveMultipleDocumentsInteractor _removeMultipleDocumentsInteractor;
  final DownloadMultipleFileIOSInteractor _downloadMultipleFileIOSInteractor;
  final SearchDocumentInteractor _searchDocumentInteractor;
  final SortInteractor _sortInteractor;
  final GetSorterInteractor _getSorterInteractor;
  final SaveSorterInteractor _saveSorterInteractor;
  final DownloadPreviewDocumentInteractor _downloadPreviewDocumentInteractor;
  final RenameDocumentInteractor _renameDocumentInteractor;
  final DuplicateMultipleFilesInMySpaceInteractor _duplicateMultipleFilesInteractor;
  final VerifyNameInteractor _verifyNameInteractor;
  StreamSubscription _storeStreamSubscription;
  List<Document> _documentList = [];

  SearchQuery _searchQuery = SearchQuery('');
  SearchQuery get searchQuery  => _searchQuery;

  MySpaceViewModel(Store<AppState> store,
      this._localFilePicker,
      this._appNavigation,
      this._getAllDocumentInteractor,
      this._downloadFileInteractor,
      this._copyMultipleFilesToSharedSpaceInteractor,
      this._removeMultipleDocumentsInteractor,
      this._downloadMultipleFileIOSInteractor,
      this._searchDocumentInteractor,
      this._downloadPreviewDocumentInteractor,
      this._sortInteractor,
      this._getSorterInteractor,
      this._saveSorterInteractor,
      this._renameDocumentInteractor,
      this._verifyNameInteractor,
      this._duplicateMultipleFilesInteractor
  ) : super(store) {
    _storeStreamSubscription = store.onChange.listen((event) {
      event.mySpaceState.viewState.fold(
         (failure) => null,
         (success) {
            if (success is SearchDocumentNewQuery && event.uiState.searchState.searchStatus == SearchStatus.ACTIVE) {
              _search(success.searchQuery);
            } else if (success is DisableSearchViewState) {
              store.dispatch((MySpaceSetSearchResultAction(_documentList)));
              _searchQuery = SearchQuery('');
            } else if (success is RemoveDocumentViewState ||
                success is RemoveMultipleDocumentsAllSuccessViewState ||
                success is RemoveMultipleDocumentsHasSomeFilesFailedViewState) {
              getAllDocument();
            }
      });
    });
  }

  void openSearchState() {
    store.dispatch(EnableSearchStateAction(SearchDestination.mySpace));
    store.dispatch((MySpaceSetSearchResultAction([])));
  }

  void _search(SearchQuery searchQuery) {
    _searchQuery = searchQuery;
    if (searchQuery.value.isNotEmpty) {
      store.dispatch(_searchDocumentAction(_documentList, searchQuery));
    } else {
      store.dispatch(MySpaceSetSearchResultAction([]));
    }
  }

  ThunkAction<AppState> _searchDocumentAction(List<Document> documentList, SearchQuery searchQuery) {
    return (Store<AppState> store) async {
      await _searchDocumentInteractor.execute(documentList, searchQuery).then((result) => result.fold(
              (failure) {
                if (_isInSearchState()) {
                  store.dispatch(MySpaceSetSearchResultAction([]));
                }
              },
              (success) {
                if (_isInSearchState()) {
                  store.dispatch(MySpaceSetSearchResultAction(success is SearchDocumentSuccess ? success.documentList : []));
                }
              })
      );
    };
  }

  void downloadFileClick(List<DocumentId> documentIds, {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    store.dispatch(_handleDownloadFile(documentIds, itemSelectionType: itemSelectionType));
  }

  ThunkAction<AppState> _handleDownloadFile(List<DocumentId> documentIds, {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    return (Store<AppState> store) async {
      final status = await Permission.storage.status;
      switch (status) {
        case PermissionStatus.granted: _download(documentIds, itemSelectionType: itemSelectionType);
        break;
        case PermissionStatus.permanentlyDenied:
          _appNavigation.popBack();
          break;
        default: {
          final requested = await Permission.storage.request();
          switch (requested) {
            case PermissionStatus.granted: _download(documentIds, itemSelectionType: itemSelectionType);
            break;
            default: _appNavigation.popBack();
            break;
          }
        }
      }
    };
  }

  void _download(List<DocumentId> documentIds, {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    store.dispatch(_downloadFileAction(documentIds));
    _appNavigation.popBack();
    if (itemSelectionType == ItemSelectionType.multiple) {
      cancelSelection();
    }
  }

  void exportFile(BuildContext context, List<Document> documents, {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    _appNavigation.popBack();
    if (itemSelectionType == ItemSelectionType.multiple) {
      cancelSelection();
    }
    final cancelToken = CancelToken();
    _showDownloadingFileDialog(context, documents, cancelToken);
    store.dispatch(_exportFileAction(documents, cancelToken));
  }

  void shareDocuments(List<Document> documents, {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    _appNavigation.popBack();
    if (itemSelectionType == ItemSelectionType.multiple) {
      cancelSelection();
    }
    _appNavigation.push(RoutePaths.uploadDocumentRoute,
        arguments: UploadFileArguments(
            [],
            shareType: ShareType.quickShare,
            documents: documents));
  }

  void clickOnCopyToAWorkGroup(BuildContext context, List<Document> documents, {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    store.dispatch(OnlineThunkAction((Store<AppState> store) async {
      _copyToAWorkgroup(context, documents, itemSelectionType: itemSelectionType);
    }));
  }

  void _copyToAWorkgroup(BuildContext context, List<Document> documents, {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    _appNavigation.popBack();
    if (itemSelectionType == ItemSelectionType.multiple) {
      cancelSelection();
    }

    final cancelAction = NegativeDestinationPickerAction(context,
        label: AppLocalizations.of(context).cancel.toUpperCase());
    cancelAction.onDestinationPickerActionClick((_) => _appNavigation.popBack());

    final copyAction = CopyDestinationPickerAction(context);
    copyAction.onDestinationPickerActionClick((data) {
      _appNavigation.popBack();
      if (data is SharedSpaceDocumentArguments) {
        store.dispatch(_copyToWorkgroupAction(documents, data));
      }
    });

    _appNavigation.push(RoutePaths.destinationPicker,
        arguments: DestinationPickerArguments(
            actionList: [copyAction, cancelAction],
            operator: Operation.copyFromMySpace));
  }

  ThunkAction<AppState> _copyToWorkgroupAction(List<Document> documents, SharedSpaceDocumentArguments sharedSpaceDocumentArguments) {
    return (Store<AppState> store) async {
      final parentNodeId = sharedSpaceDocumentArguments.workGroupFolder != null
          ? sharedSpaceDocumentArguments.workGroupFolder.workGroupNodeId
          : null;
      await _copyMultipleFilesToSharedSpaceInteractor.execute(
          copyRequests: documents.map((document) => document.toCopyRequest()).toList(),
          destinationSharedSpaceId: sharedSpaceDocumentArguments.sharedSpaceNode.sharedSpaceId,
          destinationParentNodeId: parentNodeId)
      .then((result) => result.fold(
              (failure) => store.dispatch(MySpaceAction(Left(failure))),
              (success) => store.dispatch(MySpaceAction(Right(success)))));
    };
  }

  void removeDocument(BuildContext context, List<Document> documents,
      {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    _appNavigation.popBack();
    if (itemSelectionType == ItemSelectionType.multiple) {
      cancelSelection();
    }

    if (documents != null && documents.isNotEmpty) {
      final deleteTitle = AppLocalizations.of(context)
          .are_you_sure_you_want_to_delete_multiple(documents.length, documents.first.name);

      ConfirmModalSheetBuilder(_appNavigation)
          .key(Key('delete_document_confirm_modal'))
          .title(deleteTitle)
          .cancelText(AppLocalizations.of(context).cancel)
          .onConfirmAction(AppLocalizations.of(context).delete, () {
        _appNavigation.popBack();
        if (itemSelectionType == ItemSelectionType.multiple) {
          cancelSelection();
        }
        store.dispatch(_removeDocumentAction(documents.map((document) => document.documentId).toList()));
      }).show(context);
    }
  }

  OnlineThunkAction _removeDocumentAction(List<DocumentId> documentIds) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _removeMultipleDocumentsInteractor.execute(documentIds: documentIds)
          .then((result) => result.fold(
              (failure) => store.dispatch(MySpaceAction(Left(failure))),
              (success) => store.dispatch(MySpaceAction(Right(success)))));
    });
  }

  void renameDocument(BuildContext context, Document document) {
    _appNavigation.popBack();

    EditTextModalSheetBuilder()
        .key(Key('rename_modal_sheet'))
        .title(AppLocalizations.of(context).rename_node(AppLocalizations.of(context).file.toLowerCase()))
        .cancelText(AppLocalizations.of(context).cancel)
        .onConfirmAction(AppLocalizations.of(context).rename,
            (value) => store.dispatch(_renameWorkGroupNodeAction(context, value, document)))
        .setErrorString((value) => _getErrorString(context, document, value))
        .setTextController(
          TextEditingController.fromValue(
            TextEditingValue(
                text: document.name,
                selection: TextSelection(
                    baseOffset: 0,
                    extentOffset: document.name.length
                )
            ),
          ))
        .show(context);
  }

  void goToDocumentDetails(Document document) {
    _appNavigation.popBack();
    _appNavigation.push(
      RoutePaths.documentDetails,
      arguments: DocumentDetailsArguments(document),
    );
  }

  void duplicateDocuments(List<Document> documents, {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    _appNavigation.popBack();
    if (itemSelectionType == ItemSelectionType.multiple) {
      cancelSelection();
    }

    store.dispatch(_duplicateAction(documents));
  }

  OnlineThunkAction _duplicateAction(List<Document> documents) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _duplicateMultipleFilesInteractor
        .execute(documents: documents)
        .then((result) => result.fold(
            (failure) => store.dispatch(MySpaceAction(Left(failure))),
            (success) => store.dispatch(MySpaceAction(Right(success)))));

      getAllDocument();
    });
  }

  OnlineThunkAction _renameWorkGroupNodeAction(BuildContext context, String newName, Document document) {
    _appNavigation.popBack();

    return OnlineThunkAction((Store<AppState> store) async {
      await _renameDocumentInteractor
        .execute(document.documentId, RenameDocumentRequest(newName))
        .then((result) => result.fold(
            (failure) => store.dispatch(MySpaceAction(Left(failure))),
            (success) => store.dispatch(MySpaceAction(Right(success)))));

      getAllDocument();
    });
  }

  String _getErrorString(BuildContext context, Document document, String value) {
    final listName = _documentList.map((doc) => doc.name).toList();

    return _verifyNameInteractor.execute(value, [
              EmptyNameValidator(),
              DuplicateNameValidator(listName),
              SpecialCharacterValidator(),
              LastDotValidator()
            ])
        .fold(
            (failure) {
              if (failure is VerifyNameFailure) {
                return failure.getMessage(context);
              } else {
                return null;
              }},
            (success) => null
    );
  }

  void getAllDocument() {
    store.dispatch(_getAllDocumentAction());
  }

  void openFilePickerByType(BuildContext context, FileType fileType) {
    _appNavigation.popBack();
    store.dispatch(_pickFileAction(context, fileType));
  }

  void openContextMenu(BuildContext context, Document document, List<Widget> actionTiles, {Widget footerAction}) {
    store.dispatch(_handleContextMenuAction(context, document, actionTiles, footerAction: footerAction));
  }

  void openUploadFileMenu(BuildContext context, List<Widget> actionTiles) {
    store.dispatch(_handleUploadFileMenuAction(context, actionTiles));
  }
  
  void onClickPreviewFile(BuildContext context, Document document) {
    store.dispatch(OnlineThunkAction((Store<AppState> store) async {
      _previewDocument(context, document);
    }));
  }

  void _previewDocument(BuildContext context, Document document) {
    _appNavigation.popBack();
    final canPreviewDocument = Platform.isIOS ? document.mediaType.isIOSSupportedPreview() : document.mediaType.isAndroidSupportedPreview();
    if (canPreviewDocument || document.hasThumbnail) {
      final cancelToken = CancelToken();
      _showPrepareToPreviewFileDialog(context, document, cancelToken);

      var downloadPreviewType = DownloadPreviewType.original;
      if (document.mediaType.isImageFile()) {
        downloadPreviewType = DownloadPreviewType.image;
      } else if (!canPreviewDocument) {
        downloadPreviewType = DownloadPreviewType.thumbnail;
      }
      store.dispatch(_handleDownloadPreviewDocument(document, downloadPreviewType, cancelToken));
    }
  }

  OnlineThunkAction _handleDownloadPreviewDocument(Document document, DownloadPreviewType downloadPreviewType, CancelToken cancelToken) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _downloadPreviewDocumentInteractor
          .execute(document, downloadPreviewType, cancelToken)
          .then((result) => result.fold(
              (failure) {
                _appNavigation.popBack();
                if (failure is DownloadPreviewDocumentFailure && !(failure.downloadPreviewException is CancelDownloadFileException)) {
                  store.dispatch(MySpaceAction(Left(NoDocumentPreviewAvailable())));
                }
              },
              (success) {
                if (success is DownloadPreviewDocumentViewState) {
                  _openDownloadedPreviewDocument(document, success);
                }
          }));
    });
  }

  void _openDownloadedPreviewDocument(Document document, DownloadPreviewDocumentViewState viewState) async {
    _appNavigation.popBack();

    final openResult = await open_file.OpenFile.open(
        Uri.decodeFull(viewState.filePath.path),
        type: Platform.isAndroid ? document.mediaType.mimeType : null,
        uti:  Platform.isIOS ? document.mediaType.getDocumentUti().value : null);

    if (openResult.type != open_file.ResultType.done) {
      store.dispatch(MySpaceAction(Left(NoDocumentPreviewAvailable())));
    }
  }

  ThunkAction<AppState> _handleUploadFileMenuAction(BuildContext context, List<Widget> actionTiles) {
    return (Store<AppState> store) async {
      ContextMenuBuilder(context)
          .addHeader(SimpleBottomSheetHeaderBuilder(Key('file_picker_bottom_sheet_header_builder'))
              .addLabel(AppLocalizations.of(context).upload_file_title)
              .build())
          .addTiles(actionTiles)
          .build();
    };
  }

  void _showDownloadingFileDialog(BuildContext context, List<Document> documents, CancelToken cancelToken) {
    final downloadMessage = documents.length <= 1
        ? AppLocalizations.of(context).downloading_file(documents.first.name)
        : AppLocalizations.of(context).downloading_files(documents.length);

    showCupertinoDialog(
        context: context,
        builder: (_) => DownloadingFileBuilder(cancelToken, _appNavigation)
            .key(Key('downloading_file_dialog'))
            .title(AppLocalizations.of(context).preparing_to_export)
            .content(downloadMessage)
            .actionText(AppLocalizations.of(context).cancel)
            .build());
  }

  void _showPrepareToPreviewFileDialog(BuildContext context, Document document, CancelToken cancelToken) {
    showCupertinoDialog(
        context: context,
        builder: (_) => DownloadingFileBuilder(cancelToken, _appNavigation)
            .key(Key('prepare_to_preview_file_dialog'))
            .title(AppLocalizations.of(context).preparing_to_preview_file)
            .content(AppLocalizations.of(context).downloading_file(document.name))
            .actionText(AppLocalizations.of(context).cancel)
            .build());
  }

  void _showPickingFileProgress(BuildContext context, String message) {
    showCupertinoDialog(
        context: context,
        builder: (_) => LoadingDialogBuilder(
            Key('picking_file_progress_dialog'),
            message)
          .build()
    );
  }

  ThunkAction<AppState> _handleContextMenuAction(
      BuildContext context,
      Document document,
      List<Widget> actionTiles,
      {Widget footerAction}) {
    return (Store<AppState> store) async {
      ContextMenuBuilder(context)
          .addHeader(ContextMenuHeaderBuilder(
            Key('context_menu_header'),
            DocumentPresentationFile.fromDocument(document)).build())
          .addTiles(actionTiles)
          .addFooter(footerAction)
          .build();
      store.dispatch(MySpaceAction(Right(ContextMenuItemViewState(document))));
    };
  }

  void getSorterAndAllDocumentAction() {
    store.dispatch(_getSorterAndAllDocumentAction());
  }

  OnlineThunkAction _getSorterAndAllDocumentAction() {
    return OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(StartMySpaceLoadingAction());

      await Future.wait([
        _getSorterInteractor.execute(OrderScreen.mySpace),
        _getAllDocumentInteractor.execute()
      ]).then((response) async {
        response[0].fold((failure) {
          store.dispatch(MySpaceGetSorterAction(Sorter.fromOrderScreen(OrderScreen.mySpace)));
        }, (success) {
          store.dispatch(MySpaceGetSorterAction(success is GetSorterSuccess
              ? success.sorter
              : Sorter.fromOrderScreen(OrderScreen.mySpace)));
        });
        response[1].fold((failure) {
          store.dispatch(MySpaceGetAllDocumentAction(Left(failure)));
          _documentList = [];
        }, (success) {
          store.dispatch(MySpaceGetAllDocumentAction(Right(success)));
          _documentList =
              success is MySpaceViewState ? success.documentList : [];
        });
      });

      store.dispatch(_sortFilesAction(store.state.mySpaceState.sorter));
    });
  }

  OnlineThunkAction _getAllDocumentAction() {
    return OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(StartMySpaceLoadingAction());

      await _getAllDocumentInteractor.execute().then((result) =>
          result.fold((failure) {
            store.dispatch(MySpaceGetAllDocumentAction(Left(failure)));
            _documentList = [];
            store.dispatch(_sortFilesAction(store.state.mySpaceState.sorter));
          }, (success) {
            store.dispatch(MySpaceGetAllDocumentAction(Right(success)));
            _documentList =
                success is MySpaceViewState ? success.documentList : [];
            store.dispatch(_sortFilesAction(store.state.mySpaceState.sorter));
          }));
    });
  }

  ThunkAction<AppState> _downloadFileAction(List<DocumentId> documentIds) {
    return (Store<AppState> store) async {
      await _downloadFileInteractor.execute(documentIds).then((result) => result.fold(
        (failure) => store.dispatch(MySpaceAction(Left(failure))),
        (success) => store.dispatch(MySpaceAction(Right(success)))));
    };
  }

  ThunkAction<AppState> _exportFileAction(List<Document> documents, CancelToken cancelToken) {
    return (Store<AppState> store) async {
      await _downloadMultipleFileIOSInteractor.execute(documents: documents, cancelToken: cancelToken).then(
          (result) => result.fold(
              (failure) => store.dispatch(_exportFileFailureAction(failure)),
              (success) => store.dispatch(_exportFileSuccessAction(success))));
    };
  }

  ThunkAction<AppState> _exportFileSuccessAction(Success success) {
    return (Store<AppState> store) async {
      _appNavigation.popBack();
      store.dispatch(MySpaceAction(Right(success)));
      if (success is DownloadFileIOSViewState) {
        await share_library.Share.shareFiles([Uri.decodeFull(success.filePath.path)]);
      } else if (success is DownloadFileIOSAllSuccessViewState) {
        await share_library.Share.shareFiles(success.resultList
            .map((result) => Uri.decodeFull(
                ((result.getOrElse(() => null) as DownloadFileIOSViewState).filePath.path)))
            .toList());
      } else if (success is DownloadFileIOSHasSomeFilesFailureViewState) {
        await share_library.Share.shareFiles(success.resultList
            .map((result) => result.fold(
                (failure) => null,
                (success) => Uri.decodeFull(((success as DownloadFileIOSViewState).filePath.path))))
            .toList());
      }
    };
  }

  ThunkAction<AppState> _exportFileFailureAction(Failure failure) {
    return (Store<AppState> store) async {
      if (failure is DownloadFileIOSFailure &&
          !(failure.downloadFileException is CancelDownloadFileException)) {
        _appNavigation.popBack();
      }
      store.dispatch(MySpaceAction(Left(failure)));
    };
  }

  ThunkAction<AppState> _pickFileAction(BuildContext context, FileType fileType) {
    return (Store<AppState> store) async {
      _showPickingFileProgress(context, AppLocalizations.of(context).upload_prepare_text);
      await _localFilePicker.pickFiles(fileType: fileType)
         .then((result) {
           _appNavigation.popBack();
           result.fold(
              (failure) => store.dispatch(UploadFileAction(Left(failure))),
              (success) => store.dispatch(_pickFileSuccessAction(success)));
         });
    };
  }

  ThunkAction<AppState> _pickFileSuccessAction(FilePickerSuccessViewState success) {
    return (Store<AppState> store) async {
      store.dispatch(UploadFileAction(Right(success)));
      await _appNavigation.push(RoutePaths.uploadDocumentRoute,
          arguments: UploadFileArguments(success.pickedFiles));
    };
  }

  void selectItem(SelectableElement<Document> selectedDocument) {
    store.dispatch(MySpaceSelectDocumentAction(selectedDocument));
  }

  void toggleSelectAllDocuments() {
    if (store.state.mySpaceState.isAllDocumentsSelected()) {
      store.dispatch(MySpaceUnselectAllDocumentsAction());
    } else {
      store.dispatch(MySpaceSelectAllDocumentsAction());
    }
  }

  void cancelSelection() {
    store.dispatch(MySpaceClearSelectedDocumentsAction());
  }

  void openMoreActionBottomMenu(BuildContext context, List<Document> documents, List<Widget> actionTiles, Widget footerAction) {
    ContextMenuBuilder(context)
        .addHeader(MoreActionBottomSheetHeaderBuilder(
          context,
          Key('more_action_menu_header'),
          documents.map((element) => DocumentPresentationFile.fromDocument(element)).toList()).build())
        .addTiles(actionTiles)
        .addFooter(footerAction)
        .build();
  }

  bool _isInSearchState() {
    return store.state.uiState.isInSearchState();
  }

  void openPopupMenuSorter(BuildContext context, Sorter currentSorter) {
    ContextMenuBuilder(context)
        .addHeader(SimpleBottomSheetHeaderBuilder(Key('order_by_menu_header'))
            .addLabel(AppLocalizations.of(context).order_by)
            .build())
        .addTiles(OrderByDialogBottomSheetBuilder(context, currentSorter)
            .onSelectSorterAction((sorterSelected) => _sortFiles(sorterSelected))
            .build())
        .build();
  }

  void _sortFiles(Sorter sorter) {
    final newSorter = store.state.mySpaceState.sorter == sorter ? sorter.getSorterByOrderType(sorter.orderType) : sorter;
    _appNavigation.popBack();
    store.dispatch(_sortFilesAction(newSorter));
  }

  ThunkAction<AppState> _sortFilesAction(Sorter sorter) {
    return (Store<AppState> store) async {
      await Future.wait([
        _saveSorterInteractor.execute(sorter),
        _sortInteractor.execute(_documentList, sorter)
      ]).then((response) => response[1].fold((failure) {
            _documentList = [];
            store.dispatch(MySpaceSortDocumentAction(_documentList, sorter));
          }, (success) {
            _documentList =
                success is MySpaceViewState ? success.documentList : [];
            store.dispatch(MySpaceSortDocumentAction(_documentList, sorter));
          }));
    };
  }

  @override
  void onDisposed() {
    cancelSelection();
    _storeStreamSubscription.cancel();
    super.onDisposed();
  }
}
