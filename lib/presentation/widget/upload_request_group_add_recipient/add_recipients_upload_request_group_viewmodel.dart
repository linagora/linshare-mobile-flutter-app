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

import 'package:dartz/dartz.dart';
import 'package:domain/domain.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/model/upload_request_group_tab.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/add_recipients_upload_request_group_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_request_group_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_request_inside_active_closed_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_request_inside_archived_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_request_inside_created_action.dart';
import 'package:linshare_flutter_app/presentation/redux/online_thunk_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/view/dialog/permission_dialog.dart';
import 'package:linshare_flutter_app/presentation/view/modal_sheets/confirm_modal_sheet_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/upload_file_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_group_add_recipient/add_recipient_destination.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:redux/redux.dart';

import 'add_recipients_upload_request_group_arguments.dart';

class AddRecipientsUploadRequestGroupViewModel extends BaseViewModel {
  final AppNavigation _appNavigation;
  final GetAutoCompleteSharingWithDeviceContactInteractor
      _getAutoCompleteSharingWithDeviceContactInteractor;
  final GetAutoCompleteSharingInteractor _getAutoCompleteSharingInteractor;
  final AddRecipientsToUploadRequestGroupInteractor _addRecipientsToUploadRequestGroupInteractor;
  final GetAllUploadRequestsInteractor _getAllUploadRequestsInteractor;

  ContactSuggestionSource _contactSuggestionSource = ContactSuggestionSource.linShareContact;

  AddRecipientsUploadRequestGroupViewModel(
      Store<AppState> store,
      this._appNavigation,
      this._getAutoCompleteSharingInteractor,
      this._getAutoCompleteSharingWithDeviceContactInteractor,
      this._addRecipientsToUploadRequestGroupInteractor,
      this._getAllUploadRequestsInteractor)
      : super(store);

  void initState(AddRecipientsUploadRequestGroupArgument argument) {
    store.dispatch(_getAllUploadRequests(argument.uploadRequestGroup.uploadRequestGroupId));
  }

  void backToUploadRequest() {
    store.dispatch(CleanAddRecipientsUploadRequestGroupAction());
    _appNavigation.popBack();
  }

  Future<List<AutoCompleteResult>> getAutoCompleteSharing(String pattern) async {
    if (_contactSuggestionSource == ContactSuggestionSource.all) {
      return await _getAutoCompleteSharingWithDeviceContactInteractor
          .execute(AutoCompletePattern(pattern), AutoCompleteType.SHARING)
          .then(
            (viewState) => viewState.fold(
              (failure) => <AutoCompleteResult>[],
              (success) => (success as AutoCompleteViewState).results,
            ),
          );
    }
    return await _getAutoCompleteSharingInteractor
        .execute(AutoCompletePattern(pattern), AutoCompleteType.SHARING)
        .then(
          (viewState) => viewState.fold(
            (failure) => <AutoCompleteResult>[],
            (success) => (success as AutoCompleteViewState).results,
          ),
        );
  }

  void addRecipientToList(AutoCompleteResult autoCompleteResult) {
    store.dispatch(
        AddRecipientsUploadRequestGroupAction(GenericUser(autoCompleteResult.getSuggestionMail())));
  }

  void removeRecipientFromList(GenericUser recipient) {
    store.dispatch(RemoveRecipientsUploadRequestGroupAction(recipient.mail));
  }

  void sendRecipientsList(
      BuildContext context,
      AddRecipientDestination destination,
      UploadRequestGroupTab tab,
      UploadRequestGroupId uploadRequestGroupId,
      List<GenericUser> recipientsList
  ) {
    final addRecipientTitle = AppLocalizations.of(context).confirm_add_recipients_title;

    ConfirmModalSheetBuilder(_appNavigation)
        .key(Key('add_recipients_confirm_modal'))
        .title(addRecipientTitle)
        .cancelText(AppLocalizations.of(context).cancel)
        .onConfirmAction(AppLocalizations.of(context).add, (_) {
            store.dispatch(_sendRecipientsAction(destination, tab, uploadRequestGroupId, recipientsList));
            _appNavigation.popBack();
    }).show(context);
  }

  OnlineThunkAction _sendRecipientsAction(
      AddRecipientDestination destination,
      UploadRequestGroupTab tab,
      UploadRequestGroupId uploadRequestGroupId,
      List<GenericUser> recipientsList
  ) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _addRecipientsToUploadRequestGroupInteractor
          .execute(uploadRequestGroupId, recipientsList)
          .then((result) => result.fold(
              (failure) {
                if (destination == AddRecipientDestination.fromInside) {
                  _handleOnFailureUploadRequestInsideAction(tab, failure);
                } else if (destination == AddRecipientDestination.fromGroup) {
                  store.dispatch(UploadRequestGroupAction(Left(failure)));
                }
                backToUploadRequest();
              },
              (success) {
                if (destination == AddRecipientDestination.fromInside) {
                  _handleOnSuccessUploadRequestInsideAction(tab, success);
                } else if (destination == AddRecipientDestination.fromGroup) {
                  store.dispatch(UploadRequestGroupAction(Right(success)));
                }
                backToUploadRequest();
              }));
    });
  }

  void _handleOnSuccessUploadRequestInsideAction(UploadRequestGroupTab currentTab, Success success) {
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

  void _handleOnFailureUploadRequestInsideAction(UploadRequestGroupTab currentTab, Failure failure) {
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

  void checkContactPermission(BuildContext context) async {
    final permissionStatus = await Permission.contacts.status;
    if (permissionStatus.isGranted) {
      _contactSuggestionSource = ContactSuggestionSource.all;
    } else if (!permissionStatus.isPermanentlyDenied) {
      final confirmExplanation =
          await PermissionDialog.showPermissionExplanationDialog(
              context,
              Center(
                child: Icon(Icons.warning, color: Colors.orange, size: 40),
              ),
              AppLocalizations.of(context).explain_contact_permission) ??
          false;
      if (!confirmExplanation) {
        return;
      }
      final requestedPermission = await Permission.contacts.request();
      _contactSuggestionSource = requestedPermission == PermissionStatus.granted
          ? ContactSuggestionSource.all
          : _contactSuggestionSource;
    }
  }

  OnlineThunkAction _getAllUploadRequests(UploadRequestGroupId uploadRequestGroupId) {
    return OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(StartAddRecipientsUploadRequestGroupLoadingAction());

      await _getAllUploadRequestsInteractor
          .execute(uploadRequestGroupId)
          .then((result) => result.fold((failure) {
                if (failure is UploadRequestFailure) {
                  store.dispatch(AddRecipientsUploadRequestGroupViewStateAction(Left(failure)));
                }
              }, (success) {
                if (success is UploadRequestViewState) {
                  store.dispatch(
                      AddCurrentRecipientsSetUploadRequestGroupViewStateAction(Right(success)));
                }
              }));
    });
  }

  @override
  void onDisposed() {
    store.dispatch(CleanAddRecipientsUploadRequestGroupAction());
    super.onDisposed();
  }
}
