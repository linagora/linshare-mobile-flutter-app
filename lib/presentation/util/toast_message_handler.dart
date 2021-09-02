// LinShare is an open source filesharing software, part of the LinPKI software
// suite, developed by Linagora.
//
// Copyright (C) 2021 LINAGORA
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

import 'package:domain/domain.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/add_recipients_upload_request_group_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/delete_shared_space_members_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/my_space_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/network_connectivity_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/received_share_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/share_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/shared_space_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/shared_space_document_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/shared_space_node_versions_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_file_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_request_group_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_request_group_active_closed_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_request_group_archived_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_request_group_created_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_request_inside_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/add_recipients_upload_request_group_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/delete_shared_space_members_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/my_space_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/network_connectivity_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/received_share_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/share_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/shared_space_document_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/shared_space_node_versions_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/shared_space_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/upload_file_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/upload_request_group_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/upload_request_inside_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_toast.dart';
import 'package:redux/redux.dart';

class ToastMessageHandler {
  final Store<AppState> _store = getIt<Store<AppState>>();
  final appToast = getIt<AppToast>();
  late StreamSubscription _streamSubscription;

  void setup(BuildContext context) {
    _streamSubscription = _store.onChange.listen((event) {
      _handleMySpaceToastMessage(context, event.mySpaceState);
      _handleUploadToastMessage(context, event.uploadFileState);
      _handleShareDocumentToastMessage(context, event.shareState);
      _handleSharedSpaceToastMessage(context, event.sharedSpaceState);
      _handleSharedSpaceDocumentToastMessage(context, event.sharedSpaceDocumentState);
      _handleNetworkStateToastMessage(context, event.networkConnectivityState);
      _handleReceivedShareToastMessage(context, event.receivedShareState);
      _handleDeleteSharedSpaceMembersToastMessage(context, event.deleteSharedSpaceMembersState);
      _handleSharedSpaceNodeVersionsToastMessage(context, event.sharedSpaceNodeVersionsState);
      _handleAddRecipientUploadRequestGroupToastMessage(context, event.addRecipientsUploadRequestGroupState);
      _handleUploadRequestGroupToastMessage(context, event.uploadRequestGroupState);
      _handleUploadRequestInsideToastMessage(context, event.uploadRequestInsideState);
    });
  }

  void _handleMySpaceToastMessage(BuildContext context, MySpaceState mySpaceState) {
    mySpaceState.viewState.fold((failure) {
      if (failure is CopyToSharedSpaceFailure || failure is CopyMultipleFilesToSharedSpaceAllFailureViewState) {
        appToast.showErrorToast(AppLocalizations.of(context).cannot_copy_file_to_shared_space);
        _cleanMySpaceViewState();
      } else if (failure is RemoveDocumentFailure) {
        appToast.showErrorToast(AppLocalizations.of(context).the_file_could_not_be_deleted);
        _cleanMySpaceViewState();
      } else if (failure is RemoveMultipleDocumentsAllFailureViewState) {
        appToast.showErrorToast(AppLocalizations.of(context).some_items_could_not_be_deleted);
        _cleanMySpaceViewState();
      } else if (failure is NoDocumentPreviewAvailable) {
        appToast.showErrorToast(AppLocalizations.of(context).no_preview_available);
        _cleanMySpaceViewState();
      } else if (failure is RenameDocumentFailure) {
        appToast.showErrorToast(AppLocalizations.of(context).the_file_could_not_be_renamed);
      } else if (failure is CopyToMySpaceFailure) {
        appToast.showErrorToast(AppLocalizations.of(context).the_file_could_not_be_copied);
        _cleanMySpaceViewState();
      } else if (failure is DuplicateMultipleToMySpaceAllFailure) {
        appToast.showErrorToast(AppLocalizations.of(context).files_could_not_be_duplicated);
        _cleanMySpaceViewState();
      } else if (failure is MakeAvailableOfflineDocumentFailure || failure is CannotAvailableOfflineDocument
          || failure is DisableAvailableOfflineDocumentFailure) {
        appToast.showErrorToast(AppLocalizations.of(context).file_cannot_be_switched_to_offline_mode);
        _cleanMySpaceViewState();
      }
    }, (success) {
      if (success is CopyToSharedSpaceViewState || success is CopyMultipleFilesToSharedSpaceAllSuccessViewState) {
        appToast.showToast(AppLocalizations.of(context).the_file_is_copied_to_a_shared_space);
        _cleanMySpaceViewState();
      } else if (success is CopyMultipleFilesToSharedSpaceHasSomeFilesFailedViewState) {
        appToast.showToast(AppLocalizations.of(context).some_items_could_not_be_copied_to_shared_space);
        _cleanMySpaceViewState();
      } else if (success is RemoveDocumentViewState) {
        appToast.showToast(AppLocalizations.of(context).the_file_has_been_successfully_deleted);
        _cleanMySpaceViewState();
      } else if (success is RemoveMultipleDocumentsAllSuccessViewState) {
        appToast.showToast(AppLocalizations.of(context).some_items_are_successfully_deleted);
        _cleanMySpaceViewState();
      } else if (success is RemoveMultipleDocumentsHasSomeFilesFailedViewState) {
        appToast.showToast(AppLocalizations.of(context).some_items_could_not_be_deleted);
        _cleanMySpaceViewState();
      } else if (success is RenameDocumentViewState) {
        appToast.showToast(AppLocalizations.of(context).the_file_has_been_successfully_renamed);
      } else if (success is CopyToMySpaceViewState) {
        appToast.showToast(AppLocalizations.of(context).the_file_has_been_copied_successfully);
        _cleanMySpaceViewState();
      } else if (success is DuplicateMultipleToMySpaceAllSuccessViewState) {
        appToast.showToast(AppLocalizations.of(context).files_have_been_successfully_duplicated);
        _cleanMySpaceViewState();
      } else if (success is DuplicateMultipleToMySpaceHasSomeFilesViewState) {
        appToast.showToast(AppLocalizations.of(context).some_files_could_not_be_duplicated);
        _cleanMySpaceViewState();
      } else if (success is MakeAvailableOfflineDocumentViewState) {
        appToast.showToast(AppLocalizations.of(context).files_will_be_made_available_for_offline_use);
        _cleanMySpaceViewState();
      } else if (success is DisableAvailableOfflineDocumentViewState) {
        appToast.showToast(AppLocalizations.of(context).files_will_no_longer_be_usable_without_be_network);
        _cleanMySpaceViewState();
      }
    });
  }

  void _handleUploadToastMessage(BuildContext context, UploadFileState uploadFileState) {
    uploadFileState.viewState.fold((failure) {
      if (failure is FilePickerFailure
          || failure is FileUploadFailure
          || failure is WorkGroupDocumentUploadFailure) {
        appToast.showToast(AppLocalizations.of(context).upload_failure_text);
      }

      if (failure is TooBigFilesMySpaceFailure) {
        appToast.showErrorToast(AppLocalizations.of(context).tooBigFiles(
          failure.tooBigFiles.length,
          filesize(failure.maxFileSize),
          failure.tooBigFiles.first.fileName
        ));
      }

      if (failure is NotEnoughQuotaMySpaceFailure) {
        appToast.showErrorToast(AppLocalizations.of(context).notEnoughQuota(filesize(failure.quota)));
      }
      _cleanUploadViewState();
    }, (success) {
      if (success is FileUploadSuccess || success is WorkGroupDocumentUploadSuccess) {
        appToast.showToast(AppLocalizations.of(context).upload_success_text);
        _cleanUploadViewState();
      }
    });
  }

  void _handleShareDocumentToastMessage(BuildContext context, ShareState shareState) {
    shareState.viewState.fold((failure) {
      if (failure is ShareDocumentFailure) {
        appToast.showErrorToast(AppLocalizations.of(context).file_could_not_be_share);
        _cleanShareViewState();
      }
    }, (success) {
      if (success is ShareDocumentViewState) {
        appToast.showToast(AppLocalizations.of(context).file_has_been_successfully_shared(success.sharedRecipients.length));
        _cleanShareViewState();
      } else if (success is ShareAfterUploadSuccess) {
        appToast.showToast(_buildSharingMessage(context, success.recipients));
        _cleanUploadViewState();
        _cleanShareViewState();
      }
    });
  }

  String _buildSharingMessage(BuildContext context, List<AutoCompleteResult> recipients) {
    final shareSinglePerson = recipients.length == 1;
    if (shareSinglePerson) {
      return AppLocalizations.of(context).sharing_single_after_uploaded_success(
          recipients.first.getSuggestionDisplayName()
      );
    } else {
      return AppLocalizations.of(context).sharing_multiple_after_uploaded_success(
          recipients.length
      );
    }
  }

  void _handleSharedSpaceToastMessage(BuildContext context, SharedSpaceState sharedSpaceState) {
    sharedSpaceState.viewState.fold((failure) {
      if (failure is RemoveSharedSpaceFailure) {
        appToast.showErrorToast(AppLocalizations.of(context).shared_spaces_could_not_be_deleted(1));
        _cleanSharedSpaceViewState();
      } else if (failure is RemoveAllSharedSpacesFailureViewState) {
        appToast.showErrorToast(AppLocalizations.of(context).shared_spaces_could_not_be_deleted(2));
        _cleanSharedSpaceViewState();
      } else if (failure is RemoveSharedSpaceNotFoundFailure) {
        _cleanSharedSpaceViewState();
      }
    }, (success) {
      if (success is RemoveSharedSpaceViewState) {
        appToast.showToast(AppLocalizations.of(context).shared_space_has_been_deleted);
        _cleanSharedSpaceViewState();
      } else if (success is RemoveAllSharedSpacesSuccessViewState) {
        appToast.showToast(AppLocalizations.of(context).all_shared_spaces_have_been_deleted);
        _cleanSharedSpaceViewState();
      } else if (success is RemoveSomeSharedSpacesSuccessViewState) {
        appToast.showToast(AppLocalizations.of(context).some_items_could_not_be_deleted);
        _cleanSharedSpaceViewState();
      }
    });
  }

  void _handleSharedSpaceDocumentToastMessage(BuildContext context, SharedSpaceDocumentState sharedSpaceDocumentState) {
    sharedSpaceDocumentState.viewState.fold((failure) {
      if (failure is RemoveSharedSpaceNodeFailure) {
        appToast.showErrorToast(AppLocalizations.of(context).the_file_could_not_be_deleted);
        _cleanSharedSpaceDocumentViewState();
      } else if (failure is RemoveAllSharedSpaceNodesFailureViewState) {
        appToast.showErrorToast(AppLocalizations.of(context).files_could_not_be_deleted);
        _cleanSharedSpaceDocumentViewState();
      } else if (failure is CopyToMySpaceFailure) {
        appToast.showErrorToast(AppLocalizations.of(context).the_file_could_not_be_copied);
        _cleanSharedSpaceDocumentViewState();
      } else if (failure is CopyMultipleToMySpaceAllFailure) {
        appToast.showErrorToast(AppLocalizations.of(context).cannot_copy_files_to_my_space);
        _cleanSharedSpaceDocumentViewState();
      } else if (failure is CopyToSharedSpaceFailure || failure is CopyMultipleFilesToSharedSpaceAllFailureViewState) {
        appToast.showErrorToast(AppLocalizations.of(context).cannot_copy_file_to_shared_space);
        _cleanSharedSpaceDocumentViewState();
      } else if (failure is NoWorkGroupDocumentPreviewAvailable) {
        appToast.showErrorToast(AppLocalizations.of(context).no_preview_available);
        _cleanSharedSpaceDocumentViewState();
      } else if (failure is MakeAvailableOfflineSharedSpaceDocumentFailure || failure is CannotAvailableOfflineSharedSpaceDocument
        || failure is DisableAvailableOfflineSharedSpaceDocumentFailure) {
        appToast.showErrorToast(AppLocalizations.of(context).file_cannot_be_switched_to_offline_mode);
        _cleanSharedSpaceDocumentViewState();
      }
    }, (success) {
      if (success is RemoveSharedSpaceNodeViewState) {
        appToast.showToast(AppLocalizations.of(context).the_file_has_been_successfully_deleted);
        _cleanSharedSpaceDocumentViewState();
      } else if (success is RemoveAllSharedSpaceNodesSuccessViewState) {
        appToast.showToast(AppLocalizations.of(context).files_have_been_successfully_deleted);
        _cleanSharedSpaceDocumentViewState();
      } else if (success is RemoveSomeSharedSpaceNodesSuccessViewState) {
        appToast.showToast(AppLocalizations.of(context).some_items_could_not_be_deleted);
        _cleanSharedSpaceDocumentViewState();
      } else if (success is CopyToMySpaceViewState) {
        appToast.showToast(AppLocalizations.of(context).the_file_has_been_copied_successfully);
        _cleanSharedSpaceDocumentViewState();
      } else if (success is CopyMultipleToMySpaceAllSuccessViewState) {
        appToast.showToast(AppLocalizations.of(context).all_items_have_been_copied_to_my_space);
        _cleanSharedSpaceDocumentViewState();
      } else if (success is CopyMultipleToMySpaceHasSomeFilesViewState) {
        appToast.showToast(AppLocalizations.of(context).some_items_have_been_copied_to_my_space);
        _cleanSharedSpaceDocumentViewState();
      } else  if (success is CopyToSharedSpaceViewState || success is CopyMultipleFilesToSharedSpaceAllSuccessViewState) {
        appToast.showToast(AppLocalizations.of(context).the_file_is_copied_to_a_shared_space);
        _cleanSharedSpaceDocumentViewState();
      } else if (success is MakeAvailableOfflineSharedSpaceDocumentViewState) {
        appToast.showToast(AppLocalizations.of(context).files_will_be_made_available_for_offline_use);
        _cleanSharedSpaceDocumentViewState();
      } else if (success is DisableAvailableOfflineSharedSpaceDocumentViewState) {
        appToast.showToast(AppLocalizations.of(context).files_will_no_longer_be_usable_without_be_network);
        _cleanSharedSpaceDocumentViewState();
      }
    });
  }

  void _handleNetworkStateToastMessage(BuildContext context, NetworkConnectivityState networkConnectivityState) {
    networkConnectivityState.viewState.fold((failure) {
      return SizedBox.shrink();
    }, (success) {
      if (success is NoInternetConnectionState) {
        appToast.showErrorToast(AppLocalizations.of(context).can_not_proceed_while_offline);
        _cleanNetworkConnectivityViewState();
      }
    });
  }

  void _handleReceivedShareToastMessage(BuildContext context, ReceivedShareState receivedShareState) {
    receivedShareState.viewState.fold((failure) {
      if (failure is CopyToMySpaceFailure) {
        appToast.showErrorToast(AppLocalizations.of(context).the_file_could_not_be_copied);
        _cleanReceivedShareViewState();
      } else if (failure is CopyMultipleToMySpaceFromReceivedSharesAllFailure) {
        appToast.showErrorToast(AppLocalizations.of(context).cannot_copy_files_to_my_space);
        _cleanReceivedShareViewState();
      } else if (failure is NoReceivedSharePreviewAvailable) {
        appToast.showErrorToast(AppLocalizations.of(context).no_preview_available);
        _cleanReceivedShareViewState();
      }
    }, (success) {
      if (success is CopyToMySpaceViewState) {
        appToast.showToast(AppLocalizations.of(context).the_file_has_been_copied_successfully);
        _cleanReceivedShareViewState();
      } else if (success is CopyMultipleToMySpaceFromReceivedSharesAllSuccessViewState) {
        appToast.showToast(AppLocalizations.of(context).all_items_have_been_copied_to_my_space);
        _cleanReceivedShareViewState();
      } else if (success is CopyMultipleToMySpaceFromReceivedSharesHasSomeFilesViewState) {
        appToast.showToast(AppLocalizations.of(context).some_items_have_been_copied_to_my_space);
        _cleanReceivedShareViewState();
      }
    });
  }

  void _handleDeleteSharedSpaceMembersToastMessage(BuildContext context, DeleteSharedSpaceMembersState deleteSharedSpaceMembersState) {
    deleteSharedSpaceMembersState.viewState.fold((failure) {
      if (failure is DeleteSharedSpaceMemberFailure) {
        appToast.showErrorToast(AppLocalizations.of(context).user_could_not_be_removed);
        _cleanDeleteSharedSpaceMembersViewState();
      }
    }, (success) {
      if (success is DeleteSharedSpaceMemberViewState) {
        appToast.showToast(AppLocalizations.of(context).user_is_successfully_removed);
        _cleanDeleteSharedSpaceMembersViewState();
      }
    });
  }

  void _handleSharedSpaceNodeVersionsToastMessage(BuildContext context, SharedSpaceNodeVersionsState sharedSpaceNodeVersionsState) {
    sharedSpaceNodeVersionsState.viewState.fold(
      (failure) {
        if (failure is NoWorkGroupDocumentPreviewAvailable) {
          appToast.showErrorToast(AppLocalizations.of(context).no_preview_available);
          _cleanSharedSpaceNodeVersionsViewState();
        }},
      (success) => {});
  }

  void _handleAddRecipientUploadRequestGroupToastMessage(BuildContext context, AddRecipientsUploadRequestGroupState addRecipientsUploadRequestGroupState) {
    addRecipientsUploadRequestGroupState.viewState.fold(
      (failure) {},
      (success) => {
        if (success is AddRecipientsToUploadRequestGroupViewState) {
          appToast.showToast(AppLocalizations.of(context).recipients_have_been_successfully_added),
          _cleanAddRecipientUploadRequestGroupViewState()
        }
      });
  }

  void _handleUploadRequestGroupToastMessage(BuildContext context, UploadRequestGroupState requestGroupState) {
    requestGroupState.viewState.fold((failure) {
      if (failure is UpdateUploadRequestGroupStateFailure) {
        appToast.showErrorToast(AppLocalizations.of(context).upload_request_could_not_be_updated);
        _cleanUploadRequestGroupViewState();
      } else if (failure is UpdateUploadRequestGroupAllFailureViewState) {
        appToast.showErrorToast(AppLocalizations.of(context).some_upload_requests_could_not_be_updated);
        _cleanUploadRequestGroupViewState();
      }
    }, (success) {
      if (success is UpdateUploadRequestGroupStateViewState) {
        appToast.showToast(AppLocalizations.of(context).upload_request_has_been_updated);
        _cleanUploadRequestGroupViewState();
      } else if (success is UpdateUploadRequestGroupAllSuccessViewState) {
        appToast.showToast(AppLocalizations.of(context).some_upload_requests_have_been_updated);
        _cleanUploadRequestGroupViewState();
      } else if (success is UpdateUploadRequestGroupHasSomeGroupsFailedViewState) {
        appToast.showToast(AppLocalizations.of(context).some_upload_requests_could_not_be_updated);
        _cleanUploadRequestGroupViewState();
      }
    });
  }

  void _handleUploadRequestInsideToastMessage(BuildContext context, UploadRequestInsideState uploadRequestInsideState) {
    uploadRequestInsideState.viewState.fold((failure) {
      if (failure is CopyToMySpaceFailure) {
        appToast.showErrorToast(AppLocalizations.of(context).the_file_could_not_be_copied);
        _cleanUploadRequestInsideViewState();
      } else if (failure is CopyMultipleToMySpaceFromUploadRequestEntriesAllFailure) {
        appToast.showErrorToast(AppLocalizations.of(context).cannot_copy_files_to_my_space);
        _cleanUploadRequestInsideViewState();
      }
    }, (success) {
      if (success is CopyToMySpaceViewState) {
        appToast.showToast(AppLocalizations.of(context).the_file_has_been_copied_successfully);
        _cleanUploadRequestInsideViewState();
      } else if (success is CopyMultipleToMySpaceFromUploadRequestEntriesAllSuccessViewState) {
        appToast.showToast(AppLocalizations.of(context).all_items_have_been_copied_to_my_space);
        _cleanUploadRequestInsideViewState();
      } else if (success is CopyMultipleToMySpaceFromUploadRequestEntriesHasSomeFilesViewState) {
        appToast.showToast(AppLocalizations.of(context).some_items_have_been_copied_to_my_space);
        _cleanUploadRequestInsideViewState();
      }
    });
  }

  void _cleanAddRecipientUploadRequestGroupViewState() {
    _store.dispatch(CleanAddRecipientsUploadRequestGroupAction());
  }

  void _cleanUploadRequestInsideViewState() {
    _store.dispatch(CleanUploadRequestInsideAction());
  }


  void _cleanMySpaceViewState() {
    _store.dispatch(CleanMySpaceStateAction());
  }

  void _cleanUploadViewState() {
    _store.dispatch(CleanUploadStateAction());
  }

  void _cleanShareViewState() {
    _store.dispatch(CleanShareStateAction());
  }

  void _cleanSharedSpaceViewState() {
    _store.dispatch(CleanSharedSpaceStateAction());
  }

  void _cleanSharedSpaceDocumentViewState() {
    _store.dispatch(CleanSharedSpaceDocumentStateAction());
  }

  void _cleanSharedSpaceNodeVersionsViewState() {
    _store.dispatch(CleanSharedSpaceNodeVersionsStateAction());
  }

  void _cleanNetworkConnectivityViewState() {
    _store.dispatch(CleanNetworkConnectivityStateAction());
  }

  void _cleanReceivedShareViewState() {
    _store.dispatch(CleanReceivedShareStateAction());
  }

  void _cleanDeleteSharedSpaceMembersViewState() {
    _store.dispatch(CleanDeleteSharedSpaceMembersStateAction());
  }

  void _cleanUploadRequestGroupViewState() {
    _store.dispatch(CleanUploadRequestGroupAction());
    _store.dispatch(CleanCreatedUploadRequestGroupAction());
    _store.dispatch(CleanArchivedUploadRequestGroupAction());
    _store.dispatch(CleanActiveClosedUploadRequestGroupAction());
  }

  void cancelSubscription() {
    if (_streamSubscription != null) {
      _streamSubscription.cancel();
    }
  }
}