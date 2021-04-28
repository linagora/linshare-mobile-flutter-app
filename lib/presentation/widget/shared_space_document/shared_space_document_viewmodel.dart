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
//

import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:data/data.dart';
import 'package:dio/dio.dart';
import 'package:domain/domain.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/model/file/presentation_file.dart';
import 'package:linshare_flutter_app/presentation/model/file/selectable_element.dart';
import 'package:linshare_flutter_app/presentation/model/file/work_group_document_presentation_file.dart';
import 'package:linshare_flutter_app/presentation/model/file/work_group_folder_presentation_file.dart';
import 'package:linshare_flutter_app/presentation/model/item_selection_type.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/shared_space_destination_picker_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/shared_space_document_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/ui_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_file_action.dart';
import 'package:linshare_flutter_app/presentation/redux/online_thunk_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/shared_space_document_destination_picker_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/shared_space_document_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/ui_state.dart';
import 'package:linshare_flutter_app/presentation/util/local_file_picker.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/util/router/route_paths.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/context_menu_builder.dart';
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
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_document_type.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_document_ui_type.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_node_details/shared_space_node_details_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_node_versions/shared_space_node_versions_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/destination_type.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/upload_file_arguments.dart';
import 'package:open_file/open_file.dart' as open_file;
import 'package:permission_handler/permission_handler.dart';
import 'package:redux/src/store.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:share/share.dart' as share_library;

class SharedSpaceDocumentNodeViewModel extends BaseViewModel {
  final AppNavigation _appNavigation;
  final LocalFilePicker _localFilePicker;
  final VerifyNameInteractor _verifyNameInteractor;
  final GetAllChildNodesInteractor _getAllChildNodesInteractor;
  final CreateSharedSpaceFolderInteractor _createSharedSpaceFolderInteractor;
  final GetSorterInteractor _getSorterInteractor;
  final SaveSorterInteractor _saveSorterInteractor;
  final SortInteractor _sortInteractor;
  final RenameSharedSpaceNodeInteractor _renameSharedSpaceNodeInteractor;
  final SearchWorkGroupNodeInteractor _searchWorkGroupNodeInteractor;
  final DownloadWorkGroupNodeInteractor _downloadWorkGroupNodeInteractor;
  final DownloadPreviewWorkGroupDocumentInteractor _downloadPreviewWorkGroupDocumentInteractor;
  final DownloadMultipleNodeIOSInteractor _downloadMultipleNodeIOSInteractor;
  final CopyMultipleFilesToMySpaceInteractor _copyMultipleToMySpaceInteractor;
  final CopyMultipleFilesToSharedSpaceInteractor _copyMultipleFilesToSharedSpaceInteractor;
  final RemoveMultipleSharedSpaceNodesInteractor _removeMultipleSharedSpaceNodesInteractor;

  StreamSubscription _storeStreamSubscription;

  SearchQuery _searchQuery = SearchQuery('');

  SearchQuery get searchQuery => _searchQuery;

  List<WorkGroupNode> _workGroupNodesList;
  SharedSpaceDocumentArguments _documentArguments;

  SharedSpaceDocumentNodeViewModel(
    Store<AppState> store,
    this._appNavigation,
    this._localFilePicker,
    this._verifyNameInteractor,
    this._getAllChildNodesInteractor,
    this._createSharedSpaceFolderInteractor,
    this._getSorterInteractor,
    this._saveSorterInteractor,
    this._sortInteractor,
    this._renameSharedSpaceNodeInteractor,
    this._searchWorkGroupNodeInteractor,
    this._downloadWorkGroupNodeInteractor,
    this._downloadPreviewWorkGroupDocumentInteractor,
    this._downloadMultipleNodeIOSInteractor,
    this._copyMultipleToMySpaceInteractor,
    this._copyMultipleFilesToSharedSpaceInteractor,
    this._removeMultipleSharedSpaceNodesInteractor,
  ) : super(store) {
    _storeStreamSubscription = store.onChange.listen((event) {
      event.sharedSpaceState.viewState.fold((failure) => null, (success) {
        if (success is SearchWorkGroupNodeNewQuery && event.uiState.searchState.searchStatus == SearchStatus.ACTIVE) {
          _search(success.searchQuery);
        } else if (success is DisableSearchViewState) {
          store.dispatch(SharedSpaceDocumentSetSearchResultAction(_workGroupNodesList));
          _searchQuery = SearchQuery('');
        }
      });
    });
  }

  void initial(SharedSpaceDocumentArguments arguments) {
    _documentArguments = arguments;
    store.dispatch(_documentArguments.documentUIType == SharedSpaceDocumentUIType.sharedSpace
        ? UpdateSharedSpaceDocumentArgumentsAction(arguments)
        : UpdateSharedSpaceDestinationArgumentsAction(arguments));
  }

  void getSorterAndAllWorkGroupNode() {
    store.dispatch(OnlineThunkAction((Store<AppState> store) async {
      final defaultSorter = Sorter.fromOrderScreen(OrderScreen.sharedSpaceDocument);

      _showLoading();

      await Future.wait([
        _getSorterInteractor.execute(OrderScreen.sharedSpaceDocument),
        _getAllChildNodesInteractor.execute(
            getSharedSpaceId(args: _documentArguments),
            parentId: getWorkGroupNodeId(args: _documentArguments))
      ]).then((response) async {
        final sorter = response[0]
            .map((result) => result is GetSorterSuccess ? result.sorter : defaultSorter)
            .getOrElse(() => defaultSorter);

        response[1].fold((failure) {
          _workGroupNodesList = [];

          store.dispatch(_documentArguments.documentUIType == SharedSpaceDocumentUIType.sharedSpace
              ? SharedSpaceDocumentGetSorterAndAllWorkGroupNodeAction(Left(failure), sorter)
              : SharedSpaceDestinationGetSorterAndAllNodeAction(Left(failure), sorter));
        }, (success) {
          _workGroupNodesList = success is GetChildNodesViewState ? success.workGroupNodes : [];

          store.dispatch(_documentArguments.documentUIType == SharedSpaceDocumentUIType.sharedSpace
              ? SharedSpaceDocumentGetSorterAndAllWorkGroupNodeAction(Right(success), sorter)
              : SharedSpaceDestinationGetSorterAndAllNodeAction(Right(success), sorter));
        });
      });

      store.dispatch(_sortFilesAction(getSorter()));
    }));
  }

  void getAllWorkGroupNode() {
    store.dispatch(OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(_documentArguments.documentUIType == SharedSpaceDocumentUIType.sharedSpace
          ? StartSharedSpaceDocumentLoadingAction()
          : StartSharedSpaceDestinationLoadingAction());

      await _getAllChildNodesInteractor
          .execute(getSharedSpaceId(), parentId: getWorkGroupNodeId())
          .then((result) => result.fold(
              (failure) {
                _workGroupNodesList = [];
                store.dispatch(_documentArguments.documentUIType == SharedSpaceDocumentUIType.sharedSpace
                    ? SharedSpaceDocumentGetAllWorkGroupNodeAction(Left(failure))
                    : SharedSpaceDestinationGetAllNodeAction(Left(failure)));
                },
              (success) {
                _workGroupNodesList = success is GetChildNodesViewState ? success.workGroupNodes : [];
                if (isInSearchState()) {
                  _search(_searchQuery);
                } else {
                  store.dispatch(_documentArguments.documentUIType == SharedSpaceDocumentUIType.sharedSpace
                      ? SharedSpaceDocumentGetAllWorkGroupNodeAction(Right(success))
                      : SharedSpaceDestinationGetAllNodeAction(Right(success)));
                }
          }));

      store.dispatch(_sortFilesAction(getSorter()));
    }));
  }

  ThunkAction<AppState> _sortFilesAction(Sorter sorter) {
    return (Store<AppState> store) async {
      await Future.wait([
        _saveSorterInteractor.execute(sorter),
        _sortInteractor.execute(_workGroupNodesList, sorter)
      ]).then((response) async {
        _workGroupNodesList = response[1]
            .map((result) =>
                result is GetChildNodesViewState ? result.workGroupNodes : [])
            .getOrElse(() => []);

        store.dispatch(_documentArguments.documentUIType == SharedSpaceDocumentUIType.sharedSpace
            ? SharedSpaceDocumentSortWorkGroupNodeAction(_workGroupNodesList, sorter)
            : SharedSpaceDestinationSortNodeAction(_workGroupNodesList, sorter));
      });
    };
  }

  void _sortFiles(Sorter sorter) {
    final newSorter = getSorter() == sorter ? sorter.getSorterByOrderType(sorter.orderType) : sorter;
    _appNavigation.popBack();
    store.dispatch(_sortFilesAction(newSorter));
  }

  void previewWorkGroupDocument(BuildContext context, WorkGroupDocument workGroupDocument) {
    _appNavigation.popBack();
    final canPreviewDocument = Platform.isIOS
        ? workGroupDocument.mediaType.isIOSSupportedPreview()
        : workGroupDocument.mediaType.isAndroidSupportedPreview();
    if (canPreviewDocument || workGroupDocument.hasThumbnail) {
      final cancelToken = CancelToken();
      store.dispatch(_showPrepareToPreviewFileDialog(context, workGroupDocument, cancelToken));

      var downloadPreviewType = DownloadPreviewType.original;
      if (workGroupDocument.mediaType.isImageFile()) {
        downloadPreviewType = DownloadPreviewType.image;
      } else if (!canPreviewDocument) {
        downloadPreviewType = DownloadPreviewType.thumbnail;
      }

      store.dispatch(_handleDownloadPreviewWorkGroupDocument(workGroupDocument, downloadPreviewType, cancelToken));
    }
  }

  ThunkAction<AppState> _showPrepareToPreviewFileDialog(BuildContext context, WorkGroupDocument workGroupDocument, CancelToken cancelToken) {
    return (Store<AppState> store) async {
      await showCupertinoDialog(
          context: context,
          builder: (_) => DownloadingFileBuilder(cancelToken, _appNavigation)
              .key(Key('prepare_to_preview_file_dialog'))
              .title(AppLocalizations.of(context).preparing_to_preview_file)
              .content(AppLocalizations.of(context).downloading_file(workGroupDocument.name))
              .actionText(AppLocalizations.of(context).cancel)
              .build());
    };
  }

  OnlineThunkAction _handleDownloadPreviewWorkGroupDocument(WorkGroupDocument workGroupDocument, DownloadPreviewType downloadPreviewType, CancelToken cancelToken) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _downloadPreviewWorkGroupDocumentInteractor
          .execute(workGroupDocument, downloadPreviewType, cancelToken)
          .then((result) => result.fold(
              (failure) {
                if (failure is DownloadPreviewWorkGroupDocumentFailure && !(failure.downloadPreviewException is CancelDownloadFileException)) {
                  store.dispatch(SharedSpaceDocumentAction(Left(NoWorkGroupDocumentPreviewAvailable())));
                }},
              (success) {
                if (success is DownloadPreviewWorkGroupDocumentViewState) {
                  _openDownloadedPreviewWorkGroupDocument(workGroupDocument, success);
                }
              }));
    });
  }

  void _openDownloadedPreviewWorkGroupDocument(WorkGroupDocument workGroupDocument, DownloadPreviewWorkGroupDocumentViewState viewState) async {
    _appNavigation.popBack();

    final openResult = await open_file.OpenFile.open(
        Uri.decodeFull(viewState.filePath.path),
        type: Platform.isAndroid ? workGroupDocument.mediaType.mimeType : null,
        uti: Platform.isIOS ? workGroupDocument.mediaType.getDocumentUti().value : null);

    if (openResult.type != open_file.ResultType.done) {
      store.dispatch(SharedSpaceDocumentAction(Left(NoWorkGroupDocumentPreviewAvailable())));
    }
  }

  void openAddNewFileOrFolderMenu(BuildContext context, List<Widget> actionTiles) {
    store.dispatch(_handleAddNewFileOrFolderMenuAction(context, actionTiles));
  }

  void openCreateFolderModal(BuildContext context) {
    _appNavigation.popBack();

    EditTextModalSheetBuilder()
        .key(Key('create_new_folder_modal'))
        .title(AppLocalizations.of(context).create_new_folder)
        .cancelText(AppLocalizations.of(context).cancel)
        .setTextController(TextEditingController.fromValue(
          TextEditingValue(
              text: AppLocalizations.of(context).new_folder,
              selection: TextSelection(
                  baseOffset: 0, extentOffset: AppLocalizations.of(context).new_folder.length)),
        ))
        .onConfirmAction(AppLocalizations.of(context).create,
            (value) => store.dispatch(_createNewFolderAction(context, value)))
        .setErrorString((value) => _getErrorString(context, getWorkGroupNode(), value))
        .show(context);
  }

  OnlineThunkAction _createNewFolderAction(BuildContext context, String newName) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _createSharedSpaceFolderInteractor
          .execute(
            getSharedSpaceId(),
            CreateSharedSpaceNodeFolderRequest(newName, getWorkGroupNodeId()))
          .then((result) => getAllWorkGroupNode());
    });
  }

  void openUploadFileMenu(BuildContext context, List<Widget> actionTiles) {
    _appNavigation.popBack();
    store.dispatch(_handleUploadFileMenuAction(context, actionTiles));
  }

  void openFilePickerByType(FileType fileType) {
    _appNavigation.popBack();
    store.dispatch(_pickFileAction(fileType));
  }

  ThunkAction<AppState> _pickFileAction(FileType fileType) {
    return (Store<AppState> store) async {
      await _localFilePicker
        .pickFiles(fileType: fileType)
        .then((result) => result.fold(
          (failure) => store.dispatch(UploadFileAction(Left(failure))),
          (success) => store.dispatch(_pickFileSuccessAction(success))));
    };
  }

  ThunkAction<AppState> _pickFileSuccessAction(FilePickerSuccessViewState success) {
    return (Store<AppState> store) async {
      store.dispatch(UploadFileAction(Right(success)));

      await _appNavigation.push(RoutePaths.uploadDocumentRoute,
        arguments: UploadFileArguments(success.pickedFiles,
          shareType: ShareType.none,
          workGroupDocumentUploadInfo: WorkGroupDocumentUploadInfo(
            getSharedSpaceNodeNested(),
            getWorkGroupNode(),
            getSharedSpaceDocumentType()
          )
        )
      );
    };
  }

  void openSearchState() {
    store.dispatch(EnableSearchStateAction(SearchDestination.sharedSpace));
    clearWorkGroupNodeListAction();
  }

  ThunkAction<AppState> _handleAddNewFileOrFolderMenuAction(BuildContext context, List<Widget> actionTiles) {
    return (Store<AppState> store) async {
      ContextMenuBuilder(context, areTilesHorizontal: true)
          .addHeader(SimpleBottomSheetHeaderBuilder(
                  Key('add_new_file_or_folders_bottom_sheet_header_builder'))
              .addLabel(AppLocalizations.of(context).add_new_file_or_folder)
              .build())
          .addTiles(actionTiles)
          .build();
    };
  }

  ThunkAction<AppState> _handleUploadFileMenuAction(BuildContext context, List<Widget> actionTiles) {
    return (Store<AppState> store) async {
      ContextMenuBuilder(context)
          .addHeader(SimpleBottomSheetHeaderBuilder(
                  Key('file_picker_bottom_sheet_header_builder'))
              .addLabel(AppLocalizations.of(context).upload_file_title)
              .build())
          .addTiles(actionTiles)
          .build();
    };
  }

  void openWorkGroupNodeContextMenu(BuildContext context, WorkGroupNode workGroupNode, List<Widget> actionTiles, {Widget footerAction}) {
    ContextMenuBuilder(context)
        .addHeader(ContextMenuHeaderBuilder(
          Key('work_group_node_context_menu_header'),
          workGroupNode is WorkGroupFolder
              ? WorkGroupFolderPresentationFile.fromWorkGroupFolder(workGroupNode)
              : WorkGroupDocumentPresentationFile.fromWorkGroupDocument(workGroupNode))
        .build())
        .addTiles(actionTiles)
        .addFooter(footerAction)
        .build();
  }

  void exportFiles(BuildContext context, List<WorkGroupNode> workGroupNodes,
      {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    _appNavigation.popBack();
    if (itemSelectionType == ItemSelectionType.multiple) {
      cancelSelection();
    }
    final cancelToken = CancelToken();
    _showDownloadingFileDialog(context, workGroupNodes, cancelToken);
    store.dispatch(_exportFileAction(workGroupNodes, cancelToken));
  }

  void _showDownloadingFileDialog(BuildContext context,
      List<WorkGroupNode> workGroupNodes, CancelToken cancelToken) {
    final downloadMessage = workGroupNodes.length <= 1
        ? AppLocalizations.of(context)
            .downloading_file(workGroupNodes.first.name)
        : AppLocalizations.of(context).downloading_files(workGroupNodes.length);

    showCupertinoDialog(
        context: context,
        builder: (_) => DownloadingFileBuilder(cancelToken, _appNavigation)
            .key(Key('downloading_file_dialog'))
            .title(AppLocalizations.of(context).preparing_to_export)
            .content(downloadMessage)
            .actionText(AppLocalizations.of(context).cancel)
            .build());
  }

  OnlineThunkAction _exportFileAction(List<WorkGroupNode> workGroupNodes, CancelToken cancelToken) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _downloadMultipleNodeIOSInteractor
          .execute(workGroupNodes: workGroupNodes, cancelToken: cancelToken)
          .then((result) => result.fold(
              (failure) => store.dispatch(_exportFileFailureAction(failure)),
              (success) => store.dispatch(_exportFileSuccessAction(success))));
    });
  }

  ThunkAction<AppState> _exportFileSuccessAction(Success success) {
    return (Store<AppState> store) async {
      _appNavigation.popBack();

      if (success is DownloadNodeIOSViewState) {
        await share_library.Share.shareFiles(
            [Uri.decodeFull(success.filePath.path)]);
      } else if (success is DownloadNodeIOSAllSuccessViewState) {
        await share_library.Share.shareFiles(success.resultList
            .map((result) => Uri.decodeFull(
                ((result.getOrElse(() => null) as DownloadNodeIOSViewState)
                    .filePath
                    .path)))
            .toList());
      } else if (success is DownloadNodeIOSHasSomeFilesFailureViewState) {
        await share_library.Share.shareFiles(success.resultList
            .map((result) => result.fold(
                (failure) => null,
                (success) => Uri.decodeFull(
                    ((success as DownloadNodeIOSViewState).filePath.path))))
            .toList());
      }
    };
  }

  ThunkAction<AppState> _exportFileFailureAction(Failure failure) {
    return (Store<AppState> store) async {
      if (failure is DownloadNodeIOSFailure && !(failure.downloadFileException is CancelDownloadFileException)) {
        _appNavigation.popBack();
      }
      store.dispatch(SharedSpaceDocumentAction(Left(failure)));
    };
  }

  void downloadNodes(List<WorkGroupNode> nodes,
      {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    store.dispatch(_downloadNodeAction(nodes, itemSelectionType: itemSelectionType));
    _appNavigation.popBack();
    if (itemSelectionType == ItemSelectionType.multiple) {
      cancelSelection();
    }
  }

  OnlineThunkAction _downloadNodeAction(List<WorkGroupNode> nodes,
      {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    return OnlineThunkAction((Store<AppState> store) async {
      final status = await Permission.storage.status;
      switch (status) {
        case PermissionStatus.granted:
          _dispatchHandleDownloadAction(nodes, itemSelectionType: itemSelectionType);
          break;
        case PermissionStatus.permanentlyDenied:
          _appNavigation.popBack();
          break;
        default:
          {
            final requested = await Permission.storage.request();
            switch (requested) {
              case PermissionStatus.granted:
                _dispatchHandleDownloadAction(nodes, itemSelectionType: itemSelectionType);
                break;
              default:
                _appNavigation.popBack();
                break;
            }
          }
      }
    });
  }

  void _dispatchHandleDownloadAction(List<WorkGroupNode> nodes,
      {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    store.dispatch(_handleDownloadNodes(nodes));
  }

  OnlineThunkAction _handleDownloadNodes(List<WorkGroupNode> nodes) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _downloadWorkGroupNodeInteractor.execute(nodes).then((result) =>
          result.fold(
              (failure) => store.dispatch(SharedSpaceDocumentAction(Left(failure))),
              (success) => store.dispatch(SharedSpaceDocumentAction(Right(success)))));
    });
  }

  void copyTo(BuildContext context, List<WorkGroupNode> nodes, List<DestinationType> availableDestinationTypes,
      {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    _appNavigation.popBack();
    if (itemSelectionType == ItemSelectionType.multiple) {
      cancelSelection();
    }

    final cancelAction = NegativeDestinationPickerAction(context, label: AppLocalizations.of(context).cancel.toUpperCase());
    cancelAction.onDestinationPickerActionClick((_) => _appNavigation.popBack());

    final copyAction = CopyDestinationPickerAction(context);
    copyAction.onDestinationPickerActionClick((data) {
      if (data == DestinationType.mySpace) {
        copyToMySpace(nodes);
      } else if (data is SharedSpaceDocumentArguments) {
        _appNavigation.popBack();
        store.dispatch(_copyToWorkgroupAction(nodes, data));
      }
    });

    _appNavigation.push(RoutePaths.destinationPicker,
        arguments: DestinationPickerArguments(
            actionList: [copyAction, cancelAction],
            operator: Operation.copyTo,
            availableDestinationTypes: availableDestinationTypes));
  }

  void copyToMySpace(List<WorkGroupNode> workGroupNodes) {
    _appNavigation.popBack();
    store.dispatch(_copyToMySpaceAction(workGroupNodes));
  }

  OnlineThunkAction _copyToMySpaceAction(List<WorkGroupNode> workGroupNodes) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _copyMultipleToMySpaceInteractor
          .execute(workGroupNodes: workGroupNodes)
          .then((result) => result.fold(
              (failure) => store.dispatch(SharedSpaceDocumentAction(Left(failure))),
              (success) => store.dispatch(SharedSpaceDocumentAction(Right(success)))));
    });
  }

  OnlineThunkAction _copyToWorkgroupAction(List<WorkGroupNode> nodes, SharedSpaceDocumentArguments sharedSpaceDocumentArguments) {
    return OnlineThunkAction((Store<AppState> store) async {
      final parentNodeId = sharedSpaceDocumentArguments.workGroupFolder != null
          ? sharedSpaceDocumentArguments.workGroupFolder.workGroupNodeId
          : null;

      await _copyMultipleFilesToSharedSpaceInteractor
          .execute(
              copyRequests: nodes.map((node) => node.toCopyRequest()).toList(),
              destinationSharedSpaceId: sharedSpaceDocumentArguments.sharedSpaceNode.sharedSpaceId,
              destinationParentNodeId: parentNodeId)
          .then((result) => result.fold(
              (failure) => store.dispatch(SharedSpaceDocumentAction(Left(failure))),
              (success) => store.dispatch(SharedSpaceDocumentAction(Right(success)))));

      getAllWorkGroupNode();
    });
  }

  void openRenameWorkGroupNodeModal(BuildContext context, WorkGroupNode workGroupNode) {
    _appNavigation.popBack();

    final nodeName = workGroupNode is WorkGroupDocument
        ? AppLocalizations.of(context).file
        : AppLocalizations.of(context).folder;

    EditTextModalSheetBuilder()
        .key(Key('rename_work_group_node_modal'))
        .title(AppLocalizations.of(context).rename_node(nodeName.toLowerCase()))
        .cancelText(AppLocalizations.of(context).cancel)
        .onConfirmAction(AppLocalizations.of(context).rename,
            (value) => store.dispatch(_renameWorkGroupNodeAction(context, value, workGroupNode)))
        .setErrorString(
            (value) => _getErrorString(context, workGroupNode, value))
        .setTextController(TextEditingController.fromValue(
          TextEditingValue(
              text: workGroupNode.name,
              selection: TextSelection(baseOffset: 0, extentOffset: workGroupNode.name.length)),
        ))
        .show(context);
  }

  String _getErrorString(BuildContext context, WorkGroupNode workGroupNode, String value) {
    final listName = workGroupNode is WorkGroupDocument
        ? _workGroupNodesList.whereType<WorkGroupDocument>().map((node) => node.name).toList()
        : _workGroupNodesList.whereType<WorkGroupFolder>().map((node) => node.name).toList();

    return _verifyNameInteractor.execute(value, [
      EmptyNameValidator(),
      DuplicateNameValidator(listName),
      SpecialCharacterValidator(),
      if (workGroupNode is WorkGroupDocument) LastDotValidator()
    ]).fold((failure) {
      if (failure is VerifyNameFailure) {
        final nodeName = workGroupNode is WorkGroupDocument
            ? AppLocalizations.of(context).file
            : AppLocalizations.of(context).folder;
        if (failure.exception is EmptyNameException) {
          return AppLocalizations.of(context).node_name_not_empty(nodeName);
        } else if (failure.exception is DuplicatedNameException) {
          return AppLocalizations.of(context).node_name_already_exists(nodeName);
        } else if (failure.exception is SpecialCharacterException) {
          return AppLocalizations.of(context).node_name_contain_special_character(nodeName);
        } else if (failure.exception is LastDotException) {
          return AppLocalizations.of(context).node_name_contain_last_dot(nodeName);
        } else {
          return null;
        }
      } else {
        return null;
      }
    }, (success) => null);
  }

  OnlineThunkAction _renameWorkGroupNodeAction(BuildContext context, String newName, WorkGroupNode workGroupNode) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _renameSharedSpaceNodeInteractor
          .execute(workGroupNode.sharedSpaceId, workGroupNode.workGroupNodeId,
              RenameWorkGroupNodeRequest(newName, workGroupNode.type))
          .then((result) => getAllWorkGroupNode());
      });
  }

  void removeWorkGroupNode(BuildContext context, List<WorkGroupNode> workGroupNodes,
      {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    _appNavigation.popBack();
    if (itemSelectionType == ItemSelectionType.multiple) {
      cancelSelection();
    }

    if (workGroupNodes != null && workGroupNodes.isNotEmpty) {
      final deleteTitle = AppLocalizations.of(context).are_you_sure_you_want_to_delete_multiple(workGroupNodes.length, workGroupNodes.first.name);

      ConfirmModalSheetBuilder(_appNavigation)
          .key(Key('delete_work_group_node_confirm_modal'))
          .title(deleteTitle)
          .cancelText(AppLocalizations.of(context).cancel)
          .onConfirmAction(AppLocalizations.of(context).delete, () {
        _appNavigation.popBack();
        if (itemSelectionType == ItemSelectionType.multiple) {
          cancelSelection();
        }
        store.dispatch(_removeWorkGroupNodeAction(workGroupNodes));
      }).show(context);
    }
  }

  ThunkAction<AppState> _removeWorkGroupNodeAction(List<WorkGroupNode> workGroupNodes) {
    return (Store<AppState> store) async {
      await _removeMultipleSharedSpaceNodesInteractor
          .execute(workGroupNodes)
          .then((result) => result.fold(
              (failure) => store.dispatch(SharedSpaceDocumentAction(Left(failure))),
              (success) => store.dispatch(SharedSpaceDocumentAction(Right(success)))));

      getAllWorkGroupNode();
    };
  }

  void openPopupMenuSorter(BuildContext context, Sorter currentSorter) {
    ContextMenuBuilder(context)
        .addHeader(SimpleBottomSheetHeaderBuilder(Key('order_by_menu_header'))
            .addLabel(AppLocalizations.of(context).order_by)
            .build())
        .addTiles(OrderByDialogBottomSheetBuilder(context, currentSorter)
            .onSelectSorterAction(
                (sorterSelected) => _sortFiles(sorterSelected))
            .build())
        .build();
  }

  void toggleSelectAllDocuments() {
    if (getSharedSpaceDocumentState().isAllSharedSpaceDocumentSelected()) {
      store.dispatch(SharedSpaceUnSelectAllWorkGroupNodeAction());
    } else {
      store.dispatch(SharedSpaceSelectAllWorkGroupNodeAction());
    }
  }

  void clearWorkGroupNodeListAction() {
    store.dispatch(_documentArguments.documentUIType == SharedSpaceDocumentUIType.sharedSpace
      ? ClearWorkGroupListSharedSpaceDocumentAction()
      : ClearNodeListSharedSpaceDestinationAction());
  }

  void cancelSelection() {
    store.dispatch(SharedSpaceClearSelectedWorkGroupNodeAction());
  }

  void selectItem(SelectableElement<WorkGroupNode> selectedWorkGroupNode) {
    store.dispatch(SharedSpaceDocumentSelectWorkGroupNodeAction(selectedWorkGroupNode));
  }

  bool isInSearchState() {
    return store.state.uiState.isInSearchState();
  }

  SharedSpaceDocumentState getSharedSpaceDocumentState() {
    return store.state.sharedSpaceDocumentState;
  }

  SharedSpaceDocumentDestinationPickerState getSharedSpaceDocumentDestinationState() {
    return store.state.sharedSpaceDocumentDestinationPickerState;
  }

  void _showLoading() {
    store.dispatch(_documentArguments.documentUIType == SharedSpaceDocumentUIType.sharedSpace
        ? StartSharedSpaceDocumentLoadingAction()
        : StartSharedSpaceDestinationLoadingAction());
  }

  bool isRootFolder() {
    return _documentArguments.documentUIType == SharedSpaceDocumentUIType.sharedSpace
        ? getSharedSpaceDocumentState().documentType == SharedSpaceDocumentType.root
        : getSharedSpaceDocumentDestinationState().documentType == SharedSpaceDocumentType.root;
  }

  Sorter getSorter() {
    return _documentArguments.documentUIType == SharedSpaceDocumentUIType.sharedSpace
        ? getSharedSpaceDocumentState().sorter
        : getSharedSpaceDocumentDestinationState().sorter;
  }

  WorkGroupNode getWorkGroupNode() {
    return _documentArguments.documentUIType == SharedSpaceDocumentUIType.sharedSpace
        ? getSharedSpaceDocumentState().workGroupNode
        : getSharedSpaceDocumentDestinationState().workGroupNode;
  }

  SharedSpaceNodeNested getSharedSpaceNodeNested() {
    return _documentArguments.documentUIType == SharedSpaceDocumentUIType.sharedSpace
        ? getSharedSpaceDocumentState().sharedSpaceNodeNested
        : getSharedSpaceDocumentDestinationState().sharedSpaceNodeNested;
  }

  SharedSpaceDocumentType getSharedSpaceDocumentType() {
    return _documentArguments.documentUIType == SharedSpaceDocumentUIType.sharedSpace
        ? getSharedSpaceDocumentState().documentType
        : getSharedSpaceDocumentDestinationState().documentType;
  }

  SharedSpaceId getSharedSpaceId({SharedSpaceDocumentArguments args}) {
    if (args != null) {
      return isRootFolder() ? args.sharedSpaceNode.sharedSpaceId : args.workGroupFolder.sharedSpaceId;
    }
    return isRootFolder() ? getSharedSpaceNodeNested().sharedSpaceId : getWorkGroupNode().sharedSpaceId;
  }

  WorkGroupNodeId getWorkGroupNodeId({SharedSpaceDocumentArguments args}) {
    if (args != null) {
      return isRootFolder() ? null : args.workGroupFolder.workGroupNodeId;
    }
    return isRootFolder() ? null : getWorkGroupNode().workGroupNodeId;
  }

  void _search(SearchQuery searchQuery) {
    _searchQuery = searchQuery;
    if (searchQuery.value.isNotEmpty) {
      store.dispatch(_searchWorkGroupNodeAction(_workGroupNodesList, searchQuery));
    } else {
      store.dispatch(SharedSpaceDocumentSetSearchResultAction([]));
    }
  }

  ThunkAction<AppState> _searchWorkGroupNodeAction(List<WorkGroupNode> workGroupNodeList, SearchQuery searchQuery) {
    return (Store<AppState> store) async {
      await _searchWorkGroupNodeInteractor
          .execute(workGroupNodeList, searchQuery)
          .then((result) => result.fold((failure) {
                if (isInSearchState()) {
                  store.dispatch(SharedSpaceDocumentSetSearchResultAction([]));
                }
              }, (success) {
                if (isInSearchState()) {
                  store.dispatch(SharedSpaceDocumentSetSearchResultAction(
                      success is SearchWorkGroupNodeSuccess
                          ? success.workGroupNodesList
                          : []));
                }
              }));
    };
  }

  void openMoreActionBottomMenu(BuildContext context, List<WorkGroupNode> workGroupNodes, List<Widget> actionTiles, Widget footerAction) {
    ContextMenuBuilder(context)
        .addHeader(MoreActionBottomSheetHeaderBuilder(
          context,
          Key('more_action_menu_header'),
          workGroupNodes.map<PresentationFile>((element)
          {
            if (element is WorkGroupFolder) {
              return WorkGroupFolderPresentationFile.fromWorkGroupFolder(element);
            } else {
              return WorkGroupDocumentPresentationFile.fromWorkGroupDocument(element);
            }
          }).toList()).build())
        .addTiles(actionTiles)
        .addFooter(footerAction)
        .build();
  }

  void goToWorkGroupNodeDetails(WorkGroupNode workGroupNode) {
    _appNavigation.popBack();
    _appNavigation.push(
      RoutePaths.sharedSpaceNodeDetails,
      arguments: SharedSpaceNodeDetailsArguments(workGroupNode),
    );
  }

  void goToWorkGroupNodeVersions(WorkGroupNode workGroupNode) {
    _appNavigation.popBack();
    _appNavigation.push(
      RoutePaths.sharedSpaceNodeVersions,
      arguments: SharedSpaceNodeVersionsArguments(workGroupNode),
    );
  }

  @override
  void onDisposed() {
    clearWorkGroupNodeListAction();
    cancelSelection();
    store.dispatch(DisableSearchStateAction());
    _storeStreamSubscription.cancel();
    _searchQuery = SearchQuery('');
    super.onDisposed();
  }
}
