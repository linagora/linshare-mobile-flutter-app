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
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/model/file/upload_request_entry_presentation_file.dart';
import 'package:linshare_flutter_app/presentation/model/item_selection_type.dart';
import 'package:linshare_flutter_app/presentation/model/upload_request_group_tab.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_request_inside_active_closed_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_request_inside_archived_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_request_inside_created_action.dart';
import 'package:linshare_flutter_app/presentation/redux/online_thunk_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/ui_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/functionality_state.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/util/router/route_paths.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/context_menu_builder.dart';
import 'package:linshare_flutter_app/presentation/view/downloading_file/downloading_file_builder.dart';
import 'package:linshare_flutter_app/presentation/view/header/more_action_bottom_sheet_header_builder.dart';
import 'package:linshare_flutter_app/presentation/view/modal_sheets/confirm_modal_sheet_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/edit_upload_request/edit_upload_request_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/edit_upload_request/edit_upload_request_type.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_group_add_recipient/add_recipient_destination.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_group_add_recipient/add_recipients_upload_request_group_arguments.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:redux/src/store.dart';
import 'package:redux_thunk/redux_thunk.dart';

import 'package:share/share.dart' as share_library;

abstract class UploadRequestInsideViewModel extends BaseViewModel {

  final AppNavigation appNavigation;
  final DeviceManager deviceManager;
  final DownloadUploadRequestEntriesInteractor downloadUploadRequestEntriesInteractor;
  final UpdateMultipleUploadRequestStateInteractor updateMultipleUploadRequestStateInteractor;
  final RemoveMultipleUploadRequestEntryInteractor removeMultipleUploadRequestEntryInteractor;
  final DownloadMultipleUploadRequestEntryIOSInteractor downloadMultipleUploadRequestEntryIOSInteractor;
  final CopyMultipleFilesFromUploadRequestEntriesToMySpaceInteractor entriesToMySpaceInteractor;
  final SearchUploadRequestEntriesInteractor searchUploadRequestEntriesInteractor;
  final SearchRecipientsUploadRequestInteractor searchRecipientsUploadRequestInteractor;

  UploadRequestInsideViewModel(
      Store<AppState> store,
      this.appNavigation,
      this.deviceManager,
      this.downloadUploadRequestEntriesInteractor,
      this.updateMultipleUploadRequestStateInteractor,
      this.removeMultipleUploadRequestEntryInteractor,
      this.downloadMultipleUploadRequestEntryIOSInteractor,
      this.entriesToMySpaceInteractor,
      this.searchUploadRequestEntriesInteractor,
      this.searchRecipientsUploadRequestInteractor,
  ) : super(store);

  void updateUploadRequestStatus(
      BuildContext context,
      {
        required List<UploadRequest> uploadRequests,
        required UploadRequestStatus status,
        required String title,
        required String titleButtonConfirm,
        required UploadRequestGroupTab currentTab,
        ItemSelectionType itemSelectionType = ItemSelectionType.single,
        bool? optionalCheckbox,
        String? optionalTitle,
        Function? onUpdateSuccess,
        Function? onUpdateFailed
      }
  ) {
    appNavigation.popBack();
    if (itemSelectionType == ItemSelectionType.multiple) {
      cancelAllSelectionRecipients(currentTab);
    }

    if (uploadRequests.isNotEmpty) {
      ConfirmModalSheetBuilder(appNavigation)
          .key(Key('update_upload_request_recipients_confirm_modal'))
          .title(title)
          .cancelText(AppLocalizations.of(context).cancel)
          .optionalCheckbox(optionalTitle)
          .onConfirmAction(titleButtonConfirm, (optionalCheckboxValue) {
        appNavigation.popBack();
        if (itemSelectionType == ItemSelectionType.multiple) {
          cancelAllSelectionRecipients(currentTab);
        }

        store.dispatch(_updateUploadRequestStatusAction(
          uploadRequests,
          currentTab,
          status,
          copyToMySpace: optionalCheckboxValue,
          onUpdateSuccess: onUpdateSuccess,
          onUpdateFailed: onUpdateFailed));
      }).show(context);
    }
  }

  OnlineThunkAction _updateUploadRequestStatusAction(
      List<UploadRequest> uploadRequests,
      UploadRequestGroupTab currentTab,
      UploadRequestStatus status,
      {
        bool? copyToMySpace,
        Function? onUpdateSuccess,
        Function? onUpdateFailed
      }
  ) {
    return OnlineThunkAction((Store<AppState> store) async {
      await updateMultipleUploadRequestStateInteractor
        .execute(uploadRequests.map((uploadRequest) => uploadRequest.uploadRequestId).toList(), status, copyToMySpace: copyToMySpace)
        .then((result) => result.fold(
          (failure) {
            handleOnFailureAction(currentTab, failure);
            onUpdateFailed?.call();
          },
          (success) {
            handleOnSuccessAction(currentTab, success);
            onUpdateSuccess?.call();
          }));
    });
  }

  void removeFiles(
      BuildContext context,
      List<UploadRequestEntry> entries,
      {
        required UploadRequestGroupTab currentTab,
        ItemSelectionType itemSelectionType = ItemSelectionType.single,
        Function? onActionSuccess,
        Function? onActionFailed,
      }
  ) {
    appNavigation.popBack();
    if (itemSelectionType == ItemSelectionType.multiple) {
      cancelAllSelectionEntries(currentTab);
    }

    if (entries.isNotEmpty) {
      final deleteTitle = AppLocalizations.of(context).are_you_sure_you_want_to_delete_multiple(entries.length, entries.first.name);

      ConfirmModalSheetBuilder(appNavigation)
          .key(Key('remove_upload_request_entry_confirm_modal'))
          .title(deleteTitle)
          .cancelText(AppLocalizations.of(context).cancel)
          .onConfirmAction(AppLocalizations.of(context).delete, (_) {
        appNavigation.popBack();
        if (itemSelectionType == ItemSelectionType.multiple) {
          cancelAllSelectionEntries(currentTab);
        }

        store.dispatch(_removeFileAction(
            entries,
            currentTab,
            onActionSuccess: onActionSuccess,
            onActionFailed: onActionFailed));
      }).show(context);
    }
  }

  OnlineThunkAction _removeFileAction(List<UploadRequestEntry> entries, UploadRequestGroupTab currentTab,
      {Function? onActionSuccess, Function? onActionFailed}) {
    return OnlineThunkAction((Store<AppState> store) async {
      await removeMultipleUploadRequestEntryInteractor
        .execute(entries)
        .then((result) => result.fold(
          (failure) {
            handleOnFailureAction(currentTab, failure);
            onActionFailed?.call();
          },
          (success) {
            handleOnSuccessAction(currentTab, success);
            onActionSuccess?.call();
          }));
    });
  }

  void downloadEntries(
      List<UploadRequestEntry> entries,
      {
        required UploadRequestGroupTab currentTab,
        ItemSelectionType itemSelectionType = ItemSelectionType.single
      }
  ) {
    appNavigation.popBack();
    if (itemSelectionType == ItemSelectionType.multiple) {
      cancelAllSelectionEntries(currentTab);
    }
    store.dispatch(_downloadEntriesAction(currentTab, entries));
  }

  OnlineThunkAction _downloadEntriesAction(UploadRequestGroupTab currentTab, List<UploadRequestEntry> entries) {
    return OnlineThunkAction((Store<AppState> store) async {
      final needRequestPermission = await deviceManager.isNeedRequestStoragePermissionOnAndroid();
      if(Platform.isAndroid && needRequestPermission) {
        final status = await Permission.storage.status;
        switch (status) {
          case PermissionStatus.granted:
            _dispatchHandleDownloadAction(currentTab, entries);
            break;
          case PermissionStatus.permanentlyDenied:
            appNavigation.popBack();
            break;
          default:
            {
              final requested = await Permission.storage.request();
              switch (requested) {
                case PermissionStatus.granted:
                  _dispatchHandleDownloadAction(currentTab, entries);
                  break;
                default:
                  appNavigation.popBack();
                  break;
              }
            }
        }
      } else {
        _dispatchHandleDownloadAction(currentTab, entries);
      }
    });
  }

  void _dispatchHandleDownloadAction(UploadRequestGroupTab currentTab, List<UploadRequestEntry> entries) {
    store.dispatch(_handleDownloadEntries(currentTab, entries));
  }

  OnlineThunkAction _handleDownloadEntries(UploadRequestGroupTab currentTab, List<UploadRequestEntry> entries) {
    return OnlineThunkAction((Store<AppState> store) async {
      await downloadUploadRequestEntriesInteractor.execute(entries).then((result) =>
        result.fold(
          (failure) => handleOnFailureAction(currentTab, failure),
          (success) => handleOnSuccessAction(currentTab, success)));
    });
  }

  void openMoreActionEntryBottomMenu(
      BuildContext context,
      List<UploadRequestEntry> entries,
      List<Widget> actionTiles,
      Widget footerAction
  ) {
    ContextMenuBuilder(context)
      .addHeader(MoreActionBottomSheetHeaderBuilder(
        context,
        Key('more_action_menu_header'),
        entries.map((element) => UploadRequestEntryPresentationFile.fromUploadRequestEntry(element))
          .toList())
      .build())
      .addTiles(actionTiles)
      .addFooter(footerAction)
      .build();
  }

  void exportFiles(
      BuildContext context,
      List<UploadRequestEntry> entries,
      {
        required UploadRequestGroupTab currentTab,
        ItemSelectionType itemSelectionType = ItemSelectionType.single
      }
  ) {
    appNavigation.popBack();
    if (itemSelectionType == ItemSelectionType.multiple) {
      cancelAllSelectionEntries(currentTab);
    }

    final cancelToken = CancelToken();
    _showDownloadingFileDialog(context, entries, cancelToken);
    store.dispatch(_exportFileAction(currentTab, entries, cancelToken));
  }

  void _showDownloadingFileDialog(BuildContext context, List<UploadRequestEntry> entries, CancelToken cancelToken) {
    final downloadMessage = entries.length <= 1
        ? AppLocalizations.of(context).downloading_file(entries.first.name)
        : AppLocalizations.of(context).downloading_files(entries.length);

    showCupertinoDialog(
        context: context,
        builder: (_) => DownloadingFileBuilder(cancelToken, appNavigation)
          .key(Key('downloading_file_dialog'))
          .title(AppLocalizations.of(context).preparing_to_export)
          .content(downloadMessage)
          .actionText(AppLocalizations.of(context).cancel)
          .build());
  }

  OnlineThunkAction _exportFileAction(UploadRequestGroupTab currentTab, List<UploadRequestEntry> entries, CancelToken cancelToken) {
    return OnlineThunkAction((Store<AppState> store) async {
      await downloadMultipleUploadRequestEntryIOSInteractor
        .execute(entries, cancelToken)
        .then((result) => result.fold(
          (failure) => store.dispatch(_exportFileFailureAction(currentTab, failure)),
          (success) => store.dispatch(_exportFileSuccessAction(currentTab, success))));
    });
  }

  ThunkAction<AppState> _exportFileSuccessAction(UploadRequestGroupTab currentTab, Success success) {
    return (Store<AppState> store) async {
      appNavigation.popBack();
      if (success is DownloadEntryIOSViewState) {
        await share_library.Share.shareFiles([success.filePath]);
      } else if (success is DownloadEntryIOSAllSuccessViewState) {
        await share_library.Share.shareFiles(success.resultList
          .map((result) => ((result.getOrElse(() => IdleState()) as DownloadEntryIOSViewState).filePath))
          .toList());
      } else if (success is DownloadEntryIOSHasSomeFilesFailureViewState) {
        await share_library.Share.shareFiles(success.resultList
          .map((result) => result.fold(
            (failure) => '',
            (success) => ((success as DownloadEntryIOSViewState).filePath)))
          .toList());
      }
    };
  }

  ThunkAction<AppState> _exportFileFailureAction(UploadRequestGroupTab currentTab, Failure failure) {
    return (Store<AppState> store) async {
      if (failure is DownloadEntryIOSFailure && !(failure.downloadFileException is CancelDownloadFileException)) {
        appNavigation.popBack();
      }
      handleOnFailureAction(currentTab,  failure);
    };
  }

  void copyToMySpace(List<UploadRequestEntry> entries,
      {required UploadRequestGroupTab currentTab, ItemSelectionType itemSelectionType = ItemSelectionType.single}
  ) {
    appNavigation.popBack();
    if (itemSelectionType == ItemSelectionType.multiple) {
      cancelAllSelectionEntries(currentTab);
    }

    store.dispatch(_copyToMySpaceAction(currentTab, entries));
  }

  OnlineThunkAction _copyToMySpaceAction(UploadRequestGroupTab currentTab, List<UploadRequestEntry> entries) {
    return OnlineThunkAction((Store<AppState> store) async {
      await entriesToMySpaceInteractor.execute(entries)
        .then((result) => result.fold(
          (failure) => handleOnFailureAction(currentTab, failure),
          (success) => handleOnSuccessAction(currentTab, success)));
    });
  }

  ThunkAction<AppState> searchUploadRequestEntriesAction(
      UploadRequestGroupTab currentTab,
      List<UploadRequestEntry> entries,
      SearchQuery searchQuery
  ) {
    return (Store<AppState> store) async {
      await searchUploadRequestEntriesInteractor.execute(entries, searchQuery)
        .then((result) => result.fold(
          (failure) {
            if (isInSearchState()) {
              handleOnFailureSearchEntriesAction(currentTab);
            }
          },
          (success) {
            if (isInSearchState()) {
              handleOnSuccessSearchEntriesAction(currentTab, success);
            }
          }));
    };
  }

  ThunkAction<AppState> searchRecipientsUploadRequestAction(
      UploadRequestGroupTab currentTab,
      List<UploadRequest> uploadRequests,
      SearchQuery searchQuery
  ) {
    return (Store<AppState> store) async {
      await searchRecipientsUploadRequestInteractor.execute(uploadRequests, searchQuery)
        .then((result) => result.fold(
          (failure) {
            if (isInSearchState()) {
              handleOnFailureSearchRecipientsAction(currentTab);
            }
          },
          (success) {
            if (isInSearchState()) {
              handleOnSuccessSearchRecipientsAction(currentTab, success);
            }
          }));
    };
  }

  void handleOnSuccessSearchRecipientsAction(UploadRequestGroupTab currentTab, Success success) {
    final uploadRequests = success is SearchRecipientsUploadRequestSuccess
        ? success.uploadRequestList
        : <UploadRequest>[];

    switch(currentTab) {
      case UploadRequestGroupTab.ACTIVE_CLOSED:
        store.dispatch(ActiveClosedUploadRequestSetSearchResultAction(uploadRequests));
        break;
      case UploadRequestGroupTab.PENDING:
        store.dispatch(CreatedUploadRequestSetSearchResultAction(uploadRequests));
        break;
      case UploadRequestGroupTab.ARCHIVED:
        store.dispatch(ArchivedUploadRequestSetSearchResultAction(uploadRequests));
        break;
    }
  }

  void handleOnFailureSearchRecipientsAction(UploadRequestGroupTab currentTab) {
    switch(currentTab) {
      case UploadRequestGroupTab.ACTIVE_CLOSED:
        store.dispatch(ActiveClosedUploadRequestSetSearchResultAction([]));
        break;
      case UploadRequestGroupTab.PENDING:
        store.dispatch(CreatedUploadRequestSetSearchResultAction([]));
        break;
      case UploadRequestGroupTab.ARCHIVED:
        store.dispatch(ArchivedUploadRequestSetSearchResultAction([]));
        break;
    }
  }

  void handleOnSuccessSearchEntriesAction(UploadRequestGroupTab currentTab, Success success) {
    final entries = success is SearchUploadRequestEntriesSuccess
        ? success.uploadRequestEntriesList
        : <UploadRequestEntry>[];

    switch(currentTab) {
      case UploadRequestGroupTab.ACTIVE_CLOSED:
        store.dispatch(ActiveClosedUploadRequestEntrySetSearchResultAction(entries));
        break;
      case UploadRequestGroupTab.PENDING:
        store.dispatch(CreatedUploadRequestEntrySetSearchResultAction(entries));
        break;
      case UploadRequestGroupTab.ARCHIVED:
        store.dispatch(ArchivedUploadRequestEntrySetSearchResultAction(entries));
        break;
    }
  }

  void handleOnFailureSearchEntriesAction(UploadRequestGroupTab currentTab) {
    switch(currentTab) {
      case UploadRequestGroupTab.ACTIVE_CLOSED:
        store.dispatch(ActiveClosedUploadRequestEntrySetSearchResultAction([]));
        break;
      case UploadRequestGroupTab.PENDING:
        store.dispatch(CreatedUploadRequestEntrySetSearchResultAction([]));
        break;
      case UploadRequestGroupTab.ARCHIVED:
        store.dispatch(ArchivedUploadRequestEntrySetSearchResultAction([]));
        break;
    }
  }

  bool isInSearchState() => store.state.uiState.isInSearchState();

  void handleOnSuccessAction(UploadRequestGroupTab currentTab, Success success) {
    switch(currentTab) {
      case UploadRequestGroupTab.ACTIVE_CLOSED:
        store.dispatch(ActiveClosedUploadRequestInsideAction(Right(success)));
        break;
      case UploadRequestGroupTab.PENDING:
        store.dispatch(CreatedUploadRequestInsideAction(Right(success)));
        break;
      case UploadRequestGroupTab.ARCHIVED:
        store.dispatch(ArchivedUploadRequestInsideAction(Right(success)));
        break;
    }
  }

  void handleOnFailureAction(UploadRequestGroupTab currentTab, Failure failure) {
    switch(currentTab) {
      case UploadRequestGroupTab.ACTIVE_CLOSED:
        store.dispatch(ActiveClosedUploadRequestInsideAction(Left(failure)));
        break;
      case UploadRequestGroupTab.PENDING:
        store.dispatch(CreatedUploadRequestInsideAction(Left(failure)));
        break;
      case UploadRequestGroupTab.ARCHIVED:
        store.dispatch(ArchivedUploadRequestInsideAction(Left(failure)));
        break;
    }
  }

  void cancelAllSelectionRecipients(UploadRequestGroupTab currentTab) {
    switch(currentTab) {
      case UploadRequestGroupTab.ACTIVE_CLOSED:
        store.dispatch(ClearActiveClosedUploadRequestSelectionAction());
        break;
      case UploadRequestGroupTab.PENDING:
        store.dispatch(ClearCreatedUploadRequestSelectionAction());
        break;
      case UploadRequestGroupTab.ARCHIVED:
        store.dispatch(ClearArchivedUploadRequestSelectionAction());
        break;
    }
  }

  void cancelAllSelectionEntries(UploadRequestGroupTab currentTab) {
    switch(currentTab) {
      case UploadRequestGroupTab.ACTIVE_CLOSED:
        store.dispatch(ActiveClosedUploadRequestClearSelectedEntryAction());
        break;
      case UploadRequestGroupTab.PENDING:
        store.dispatch(CreatedUploadRequestClearSelectedEntryAction());
        break;
      case UploadRequestGroupTab.ARCHIVED:
        store.dispatch(ArchivedUploadRequestClearSelectedEntryAction());
        break;
    }
  }

  void clearUploadRequestListAction(UploadRequestGroupTab currentTab) {
    switch(currentTab) {
      case UploadRequestGroupTab.ACTIVE_CLOSED:
        store.dispatch(ClearActiveClosedUploadRequestEntriesListAction());
        store.dispatch(ClearActiveClosedUploadRequestsListAction());
        break;
      case UploadRequestGroupTab.PENDING:
        store.dispatch(ClearCreatedUploadRequestEntriesListAction());
        store.dispatch(ClearCreatedUploadRequestsListAction());
        break;
      case UploadRequestGroupTab.ARCHIVED:
        store.dispatch(ClearArchivedUploadRequestEntriesListAction());
        store.dispatch(ClearArchivedUploadRequestsListAction());
        break;
    }
  }

  void goToEditUploadRequestRecipient(UploadRequest uploadRequest, UploadRequestGroupTab tab) {
    final uploadRequestFunctionalities = store.state.functionalityState.getAllEnabledUploadRequest();
    appNavigation.popBack();
    appNavigation.push(RoutePaths.editUploadRequest, arguments: EditUploadRequestArguments(
        EditUploadRequestType.recipients,
        tab,
        uploadRequestFunctionalities,
        uploadRequest: uploadRequest)
    );
  }

  void goToAddRecipients(UploadRequestGroup request, UploadRequestGroupTab tab) {
    appNavigation.push(
      RoutePaths.addRecipientsUploadRequestGroup,
      arguments: AddRecipientsUploadRequestGroupArgument(request, AddRecipientDestination.fromInside, tab));
  }

  @override
  void onDisposed() {
    super.onDisposed();
  }
}