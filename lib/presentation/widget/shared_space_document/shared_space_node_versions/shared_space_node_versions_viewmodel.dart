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

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:data/data.dart';
import 'package:dio/dio.dart';
import 'package:domain/domain.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/model/file/work_group_document_presentation_file.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/shared_space_document_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/shared_space_node_versions_action.dart';
import 'package:linshare_flutter_app/presentation/redux/online_thunk_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/util/router/route_paths.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/context_menu_builder.dart';
import 'package:linshare_flutter_app/presentation/view/downloading_file/downloading_file_builder.dart';
import 'package:linshare_flutter_app/presentation/view/header/context_menu_header_builder.dart';
import 'package:linshare_flutter_app/presentation/view/modal_sheets/confirm_modal_sheet_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/destination_picker/destination_picker_action/copy_destination_picker_action.dart';
import 'package:linshare_flutter_app/presentation/widget/destination_picker/destination_picker_action/negative_destination_picker_action.dart';
import 'package:linshare_flutter_app/presentation/widget/destination_picker/destination_picker_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_node_versions/shared_space_node_versions_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/destination_type.dart';
import 'package:open_file/open_file.dart' as open_file;
import 'package:permission_handler/permission_handler.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:share/share.dart' as share_library;

class SharedSpaceNodeVersionsViewModel extends BaseViewModel {
  final AppNavigation _appNavigation;
  final GetAllChildNodesInteractor _getAllChildNodesInteractor;
  final RestoreWorkGroupDocumentVersionInteractor _restoreWorkGroupDocumentVersionInteractor;
  final DownloadPreviewWorkGroupDocumentInteractor _downloadPreviewWorkGroupDocumentInteractor;
  final RemoveSharedSpaceNodeInteractor _removeSharedSpaceNodeInteractor;
  final DownloadNodeIOSInteractor _downloadNodeIOSInteractor;
  final DeviceManager _deviceManager;
  final DownloadWorkGroupNodeInteractor _downloadWorkGroupNodeInteractor;
  final CopyToMySpaceInteractor _copyToMySpaceInteractor;

  late SharedSpaceRole sharedSpaceRole;
  late SharedSpaceNodeVersionsArguments nodeVersionArguments;

  SharedSpaceNodeVersionsViewModel(
    Store<AppState> store,
    this._appNavigation,
    this._getAllChildNodesInteractor,
    this._restoreWorkGroupDocumentVersionInteractor,
    this._downloadPreviewWorkGroupDocumentInteractor,
    this._removeSharedSpaceNodeInteractor,
    this._downloadNodeIOSInteractor,
    this._deviceManager,
    this._downloadWorkGroupNodeInteractor,
    this._copyToMySpaceInteractor,
  ) : super(store);

  void initState(SharedSpaceNodeVersionsArguments arguments) {
    nodeVersionArguments = arguments;
    sharedSpaceRole = arguments.sharedSpaceRole;
    getAllVersions(arguments.workGroupNode);
  }

  void backToMyWorkGroupNodesList() {
    _appNavigation.popBack();
  }

  void getAllVersions(WorkGroupNode workGroupNode) {
    store.dispatch(_getSharedSpaceNodeVersionsAction(workGroupNode));
  }

  OnlineThunkAction _getSharedSpaceNodeVersionsAction(WorkGroupNode workGroupNode) {
    return OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(StartSharedSpaceNodeVersionsLoadingAction());

      store.dispatch(SharedSpaceNodeVersionsSetWorkGroupNodeVersionsAction(
          await _getAllChildNodesInteractor.execute(
            workGroupNode.sharedSpaceId,
            parentId: workGroupNode.workGroupNodeId)));
    });
  }

  void openContextMenu(
    BuildContext context,
    WorkGroupDocument document,
    List<Widget> actionTiles,
    {Widget? footerAction}
  ) {
    ContextMenuBuilder(context)
        .addHeader(ContextMenuHeaderBuilder(Key('context_menu_header'),
                WorkGroupDocumentPresentationFile.fromWorkGroupDocument(document))
            .build())
        .addTiles(actionTiles)
        .addFooter(footerAction ?? SizedBox.shrink())
        .build();
  }

  void restoreAction(WorkGroupDocument document, WorkGroupNode parentNode) {
    store.dispatch(_restoreDocumentAction(document, parentNode));
    _appNavigation.popBack();
  }

  OnlineThunkAction _restoreDocumentAction(WorkGroupDocument document, WorkGroupNode parentNode) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _restoreWorkGroupDocumentVersionInteractor
          .execute(document.toCopyRequest(), document.sharedSpaceId, parentId: document.parentWorkGroupNodeId)
          .then((result) => result.fold((failure) {
                store.dispatch(SharedSpaceNodeVersionsAction(Left(failure)));
              }, (success) {
                store.dispatch(SharedSpaceNodeVersionsAction(Right(success)));
              }));
      store.dispatch(_getSharedSpaceNodeVersionsAction(parentNode));
    });
  }

  void closeDialogMenuContext() {
    _appNavigation.popBack();
  }

  void previewAction(BuildContext context, WorkGroupDocument document) {
    final canPreviewDocument = Platform.isIOS
      ? document.mediaType.isIOSSupportedPreview()
      : document.mediaType.isAndroidSupportedPreview();

    if (canPreviewDocument || (document.hasThumbnail != null && document.hasThumbnail)) {
      final cancelToken = CancelToken();
      store.dispatch(_showPrepareToPreviewFileDialog(context, document, cancelToken));

      var downloadPreviewType = DownloadPreviewType.original;
      if (document.mediaType.isImageFile()) {
        downloadPreviewType = DownloadPreviewType.image;
      } else if (!canPreviewDocument) {
        downloadPreviewType = DownloadPreviewType.thumbnail;
      }

      store.dispatch(_handleDownloadPreviewDocument(document, downloadPreviewType, cancelToken));
    } else {
      store.dispatch(SharedSpaceNodeVersionsAction(Left(NoWorkGroupDocumentPreviewAvailable())));
    }
  }

  ThunkAction<AppState> _showPrepareToPreviewFileDialog(BuildContext context, WorkGroupDocument document, CancelToken cancelToken) {
    return (Store<AppState> store) async {
      await showCupertinoDialog(
        context: context,
        builder: (_) => DownloadingFileBuilder(cancelToken, _appNavigation)
          .key(Key('prepare_to_preview_file_dialog'))
          .title(AppLocalizations.of(context).preparing_to_preview_file)
          .content(AppLocalizations.of(context).downloading_file(document.name))
          .actionText(AppLocalizations.of(context).cancel)
          .build());
    };
  }

  OnlineThunkAction _handleDownloadPreviewDocument(WorkGroupDocument document, DownloadPreviewType downloadPreviewType, CancelToken cancelToken) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _downloadPreviewWorkGroupDocumentInteractor
        .execute(document, downloadPreviewType, cancelToken)
        .then((result) => result.fold(
          (failure) {
            if (failure is DownloadPreviewWorkGroupDocumentFailure && !(failure.downloadPreviewException is CancelDownloadFileException)) {
              store.dispatch(SharedSpaceNodeVersionsAction(Left(NoWorkGroupDocumentPreviewAvailable())));
            }},
          (success) {
            if (success is DownloadPreviewWorkGroupDocumentViewState) {
              _openDownloadedPreviewDocument(document, success);
            }
          }));
    });
  }

  void _openDownloadedPreviewDocument(WorkGroupDocument document, DownloadPreviewWorkGroupDocumentViewState viewState) async {
    _appNavigation.popBack();

    final openResult = await open_file.OpenFile.open(
      viewState.filePath,
      type: Platform.isAndroid ? document.mediaType.mimeType : null,
      uti: Platform.isIOS ? document.mediaType.getDocumentUti().value : null);

    if (openResult.type != open_file.ResultType.done) {
      store.dispatch(SharedSpaceNodeVersionsAction(Left(NoWorkGroupDocumentPreviewAvailable())));
    }
  }

  void removeNodeVersion(BuildContext context, WorkGroupDocument document, bool finalVersion) {
    _appNavigation.popBack();

    ConfirmModalSheetBuilder(_appNavigation)
      .key(Key('delete_node_version_confirm_modal'))
      .title(AppLocalizations.of(context).are_you_sure_want_to_remove_this_version)
      .cancelText(AppLocalizations.of(context).cancel)
      .onConfirmAction(AppLocalizations.of(context).delete, (_) {
            _appNavigation.popBack();
            if (finalVersion) {
              store.dispatch(_removeFinalNodeVersionAction(nodeVersionArguments.workGroupNode));
            } else {
              store.dispatch(_removeNodeVersionAction(document));
            }
        })
      .show(context);
  }

  ThunkAction<AppState> _removeNodeVersionAction(WorkGroupDocument document) {
    return (Store<AppState> store) async {
      await _removeSharedSpaceNodeInteractor
        .execute(document.sharedSpaceId, document.workGroupNodeId)
        .then((result) => result.fold(
          (failure) => store.dispatch(SharedSpaceNodeVersionsAction(Left(failure))),
          (success) => store.dispatch(SharedSpaceNodeVersionsAction(Right(success)))));

      getAllVersions(nodeVersionArguments.workGroupNode);
    };
  }

  ThunkAction<AppState> _removeFinalNodeVersionAction(WorkGroupNode workGroupNode) {
    return (Store<AppState> store) async {
      await _removeSharedSpaceNodeInteractor
        .execute(workGroupNode.sharedSpaceId, workGroupNode.workGroupNodeId)
        .then((result) => result.fold(
          (failure) => store.dispatch(SharedSpaceNodeVersionsAction(Left(failure))),
          (success) {
            store.dispatch(SharedSpaceDocumentAction(Right(success)));
            _appNavigation.popBack();
          }));
    };
  }

  void exportFile(BuildContext context, WorkGroupDocument document) {
    _appNavigation.popBack();
    final cancelToken = CancelToken();
    _showDownloadingFileDialog(context, document, cancelToken);
    store.dispatch(_exportFileAction(document, cancelToken));
  }

  void _showDownloadingFileDialog(
      BuildContext context,
      WorkGroupDocument document,
      CancelToken cancelToken
  ) {
    showCupertinoDialog(
      context: context,
      builder: (_) => DownloadingFileBuilder(cancelToken, _appNavigation)
        .key(Key('downloading_file_dialog'))
        .title(AppLocalizations.of(context).preparing_to_export)
        .content(AppLocalizations.of(context).downloading_file(document.name))
        .actionText(AppLocalizations.of(context).cancel)
        .build());
  }

  OnlineThunkAction _exportFileAction(WorkGroupDocument document, CancelToken cancelToken) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _downloadNodeIOSInteractor
        .execute(document, cancelToken)
        .then((result) => result.fold(
          (failure) => store.dispatch(_exportFileFailureAction(failure)),
          (success) => store.dispatch(_exportFileSuccessAction(success))));
    });
  }

  ThunkAction<AppState> _exportFileSuccessAction(Success success) {
    return (Store<AppState> store) async {
      _appNavigation.popBack();

      if (success is DownloadNodeIOSViewState) {
        await share_library.Share.shareFiles([success.filePath]);
      } else if (success is DownloadNodeIOSAllSuccessViewState) {
        await share_library.Share.shareFiles(success.resultList
          .map((result) => ((result.getOrElse(() => IdleState()) as DownloadNodeIOSViewState).filePath))
          .toList());
      } else if (success is DownloadNodeIOSHasSomeFilesFailureViewState) {
        await share_library.Share.shareFiles(success.resultList
          .map((result) => result.fold(
            (failure) => '',
            (success) => ((success as DownloadNodeIOSViewState).filePath)))
          .toList());
      }
    };
  }

  ThunkAction<AppState> _exportFileFailureAction(Failure failure) {
    return (Store<AppState> store) async {
      if (failure is DownloadNodeIOSFailure && !(failure.downloadFileException is CancelDownloadFileException)) {
        _appNavigation.popBack();
      }
      store.dispatch(SharedSpaceNodeVersionsAction(Left(failure)));
    };
  }

  void downloadFile(WorkGroupDocument document) {
    _appNavigation.popBack();
    store.dispatch(_downloadFileAction(document));
  }

  OnlineThunkAction _downloadFileAction(WorkGroupDocument document) {
    return OnlineThunkAction((Store<AppState> store) async {
      final needRequestPermission = await _deviceManager.isNeedRequestStoragePermissionOnAndroid();
      if(Platform.isAndroid && needRequestPermission) {
        final status = await Permission.storage.status;
        switch (status) {
          case PermissionStatus.granted:
            store.dispatch(_handleDownloadFileAction(document));
            break;
          case PermissionStatus.permanentlyDenied:
            _appNavigation.popBack();
            break;
          default:
            {
              final requested = await Permission.storage.request();
              switch (requested) {
                case PermissionStatus.granted:
                  store.dispatch(_handleDownloadFileAction(document));
                  break;
                default:
                  _appNavigation.popBack();
                  break;
              }
            }
        }
      } else {
        store.dispatch(_handleDownloadFileAction(document));
      }
    });
  }

  OnlineThunkAction _handleDownloadFileAction(WorkGroupDocument document) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _downloadWorkGroupNodeInteractor
        .execute([document])
        .then((result) => result.fold(
          (failure) => store.dispatch(SharedSpaceNodeVersionsAction(Left(failure))),
          (success) => store.dispatch(SharedSpaceNodeVersionsAction(Right(success)))));
    });
  }

  void copyTo(BuildContext context, WorkGroupDocument document, List<DestinationType> availableDestinationTypes) {
    _appNavigation.popBack();

    final cancelAction = NegativeDestinationPickerAction(context, label: AppLocalizations.of(context).cancel.toUpperCase());
    cancelAction.onDestinationPickerActionClick((_) => _appNavigation.popBack());

    final copyAction = CopyDestinationPickerAction(context);
    copyAction.onDestinationPickerActionClick((data) {
      if (data == DestinationType.mySpace) {
        copyToMySpace(document);
      }
    });

    _appNavigation.push(RoutePaths.destinationPicker,
      arguments: DestinationPickerArguments(
        actionList: [copyAction, cancelAction],
        operator: Operation.copyTo,
        availableDestinationTypes: availableDestinationTypes));
  }

  void copyToMySpace(WorkGroupDocument document) {
    _appNavigation.popBack();
    store.dispatch(_copyToMySpaceAction(document));
  }

  OnlineThunkAction _copyToMySpaceAction(WorkGroupDocument document) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _copyToMySpaceInteractor
        .execute(CopyRequest(
            document.workGroupNodeId.uuid,
            SpaceType.SHARED_SPACE,
            contextUuid: document.sharedSpaceId.uuid))
        .then((result) => result.fold(
          (failure) => store.dispatch(SharedSpaceNodeVersionsAction(Left(failure))),
          (success) => store.dispatch(SharedSpaceNodeVersionsAction(Right(success)))));
    });
  }

  @override
  void onDisposed() {
    store.dispatch(RemoveAllSharedSpaceNodeVersionsStateAction());
    super.onDisposed();
  }
}