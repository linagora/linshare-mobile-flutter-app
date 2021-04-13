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
import 'package:linshare_flutter_app/presentation/redux/actions/add_shared_space_members_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/my_space_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/network_connectivity_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/received_share_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/share_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/shared_space_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/shared_space_document_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_file_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/add_shared_space_members_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/my_space_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/network_connectivity_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/received_share_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/share_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/shared_space_document_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/shared_space_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/upload_file_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_toast.dart';
import 'package:redux/redux.dart';

class ToastMessageHandler {
  final Store<AppState> _store = getIt<Store<AppState>>();
  final appToast = getIt<AppToast>();
  StreamSubscription _streamSubscription;

  void setup(BuildContext context) {
    _streamSubscription = _store.onChange.listen((event) {
      _handleMySpaceToastMessage(context, event.mySpaceState);
      _handleUploadToastMessage(context, event.uploadFileState);
      _handleShareDocumentToastMessage(context, event.shareState);
      _handleSharedSpaceToastMessage(context, event.sharedSpaceState);
      _handleSharedSpaceDocumentToastMessage(context, event.sharedSpaceDocumentState);
      _handleNetworkStateToastMessage(context, event.networkConnectivityState);
      _handleReceivedShareToastMessage(context, event.receivedShareState);
      _handleAddSharedSpaceMembersToastMessage(context, event.addSharedSpaceMembersState);
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
        appToast.showToast(AppLocalizations.of(context).file_is_successfully_shared);
        _cleanShareViewState();
      } else if (success is ShareAfterUploadSuccess) {
        appToast.showToast(_buildSharingMessage(context, success.recipients));
        _cleanUploadViewState();
        _cleanShareViewState();
      }
    });
  }

  void _handleAddSharedSpaceMembersToastMessage(BuildContext context, AddSharedSpaceMembersState addSharedSpaceMembersState) {
    addSharedSpaceMembersState.viewState.fold((failure) {
      if (failure is AddSharedSpaceMemberFailure) {
        appToast.showErrorToast(AppLocalizations.of(context).shared_space_member_could_not_be_added);
        _cleanAddSharedSpaceMembersViewState();
      }
    }, (success) {
      if (success is AddSharedSpaceMemberViewState) {
        appToast.showToast(AppLocalizations.of(context).shared_space_member_has_been_added);
        _cleanAddSharedSpaceMembersViewState();
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
      } else if (failure is RemoveAllSharedSpaceNodesFailureViewState) {
        appToast.showErrorToast(AppLocalizations.of(context).files_could_not_be_deleted);
      } else if (failure is CopyToMySpaceFailure) {
        appToast.showErrorToast(AppLocalizations.of(context).the_file_could_not_be_copied);
      } else if (failure is CopyMultipleToMySpaceAllFailure) {
        appToast.showErrorToast(AppLocalizations.of(context).cannot_copy_files_to_my_space);
      } else if (failure is CopyToSharedSpaceFailure || failure is CopyMultipleFilesToSharedSpaceAllFailureViewState) {
        appToast.showErrorToast(AppLocalizations.of(context).cannot_copy_file_to_shared_space);
      } else if (failure is NoWorkGroupDocumentPreviewAvailable) {
        appToast.showErrorToast(AppLocalizations.of(context).no_preview_available);
      }
    }, (success) {
      if (success is RemoveSharedSpaceNodeViewState) {
        appToast.showToast(AppLocalizations.of(context).the_file_has_been_successfully_deleted);
      } else if (success is RemoveAllSharedSpaceNodesSuccessViewState) {
        appToast.showToast(AppLocalizations.of(context).files_have_been_successfully_deleted);
      } else if (success is RemoveSomeSharedSpaceNodesSuccessViewState) {
        appToast.showToast(AppLocalizations.of(context).some_items_could_not_be_deleted);
      } else if (success is CopyToMySpaceViewState) {
        appToast.showToast(AppLocalizations.of(context).the_file_has_been_copied_successfully);
      } else if (success is CopyMultipleToMySpaceAllSuccessViewState) {
        appToast.showToast(AppLocalizations.of(context).all_items_have_been_copied_to_my_space);
      } else if (success is CopyMultipleToMySpaceHasSomeFilesViewState) {
        appToast.showToast(AppLocalizations.of(context).some_items_have_been_copied_to_my_space);
      } else  if (success is CopyToSharedSpaceViewState || success is CopyMultipleFilesToSharedSpaceAllSuccessViewState) {
        appToast.showToast(AppLocalizations.of(context).the_file_is_copied_to_a_shared_space);
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

  void _cleanNetworkConnectivityViewState() {
    _store.dispatch(CleanNetworkConnectivityStateAction());
  }

  void _cleanReceivedShareViewState() {
    _store.dispatch(CleanReceivedShareStateAction());
  }

  void _cleanAddSharedSpaceMembersViewState() {
    _store.dispatch(CleanAddSharedSpaceMembersStateAction());
  }

  void cancelSubscription() {
    if (_streamSubscription != null) {
      _streamSubscription.cancel();
    }
  }
}