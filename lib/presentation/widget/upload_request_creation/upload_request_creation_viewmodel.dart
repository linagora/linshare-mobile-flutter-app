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

import 'package:dartz/dartz.dart';
import 'package:domain/domain.dart';
import 'package:linshare_flutter_app/presentation/model/file_size_type.dart';
import 'package:linshare_flutter_app/presentation/model/nolitication_language.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_request_group_action.dart';
import 'package:linshare_flutter_app/presentation/redux/online_thunk_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/upload_file_viewmodel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:redux/src/store.dart';
import 'package:rxdart/rxdart.dart';

class UploadRequestCreationViewModel extends BaseViewModel {

  final AppNavigation _appNavigation;

  // main stuff
  final AddNewUploadRequestInteractor _addNewUploadRequestInteractor;
  final GetAllUploadRequestGroupsInteractor _getAllUploadRequestGroupsInteractor;

  // auto complete
  final GetAutoCompleteSharingInteractor _getAutoCompleteSharingInteractor;
  final GetAutoCompleteSharingWithDeviceContactInteractor _getAutoCompleteSharingWithDeviceContactInteractor;
  late StreamSubscription _autoCompleteResultListSubscription;
  ContactSuggestionSource _contactSuggestionSource = ContactSuggestionSource.linShareContact;

  final BehaviorSubject<bool> _enableCreateButton = BehaviorSubject.seeded(false);
  StreamView<bool> get enableCreateButton => _enableCreateButton;

  final BehaviorSubject<List<AutoCompleteResult>> _autoCompleteResultListObservable = BehaviorSubject.seeded([]);
  StreamView<List<AutoCompleteResult>> get autoCompleteResultListObservable => _autoCompleteResultListObservable;
  
  final BehaviorSubject<String> _emailSubjectObservable = BehaviorSubject.seeded('');
  StreamView<String> get emailSubjectObservable => _emailSubjectObservable;

  UploadRequestCreationViewModel(Store<AppState> store, this._appNavigation,
      this._addNewUploadRequestInteractor,
      this._getAllUploadRequestGroupsInteractor,
      this._getAutoCompleteSharingInteractor,
      this._getAutoCompleteSharingWithDeviceContactInteractor)
      : super(store) {

    _autoCompleteResultListSubscription = Rx.combineLatest2(_autoCompleteResultListObservable, _emailSubjectObservable, (List<AutoCompleteResult> shareMails, String emailSubject) {
      return (shareMails.isNotEmpty && emailSubject.isNotEmpty);
    }).listen((event) {
      event ? _enableCreateButton.add(true) : _enableCreateButton.add(false);
    });

    Future.delayed(Duration(milliseconds: 500), () => _checkContactPermission());
  }

  void backToUploadRequestGroup() {
    _appNavigation.popBack();
  }

  void performCreateUploadRequest(
      UploadRequestCreationType creationType,
      int maxFileCount,
      int maxFileSize,
      DateTime expirationDate,
      {String? emailMessage,
      DateTime? activationDate,
      DateTime? notificationDate,
      int? maxDepositSize,
      bool? canDelete,
      bool? canClose,
      String? locale,
      bool? protectedByPassword,
      bool? enableNotification}) {
    final listEmails = _autoCompleteResultListObservable.value?.map((e) => e.getSuggestionMail()).toList() ?? [];
    final emailSubject = _emailSubjectObservable.value.toString();
    final addUploadRequest = AddUploadRequest(
        listEmails,
        emailSubject,
        emailMessage,
        activationDate,
        expirationDate,
        maxFileCount,
        maxFileSize,
        notificationDate,
        maxDepositSize = FileSizeType.GB.toByte(50),
        canDelete = true,
        canClose = true,
        locale = NotificationLanguage.FRENCH.text,
        protectedByPassword = true,
        enableNotification = true);
    store.dispatch(_addNewUploadRequest(creationType, addUploadRequest));
  }

  OnlineThunkAction _addNewUploadRequest(UploadRequestCreationType creationType, AddUploadRequest addUploadRequest) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _addNewUploadRequestInteractor.execute(creationType, addUploadRequest).then((result) =>
          result.fold(
              (failure) => store.dispatch(UploadRequestCreationAction(
                  Left<Failure, Success>(AddNewUploadRequestFailure(UploadRequestCreateFailed())))),
              (success) {
                  getUploadRequestCreatedStatus();
                  getUploadRequestActiveClosedStatus();
                  backToUploadRequestGroup();
              }));
    });
  }

  void getUploadRequestCreatedStatus() {
    store.dispatch(OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(StartUploadRequestGroupLoadingAction());
      store.dispatch(UploadRequestGroupGetAllCreatedAction(
          await _getAllUploadRequestGroupsInteractor.execute([UploadRequestStatus.CREATED])));
    }));
  }

  void getUploadRequestActiveClosedStatus() {
    store.dispatch(OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(StartUploadRequestGroupLoadingAction());
      store.dispatch(UploadRequestGroupGetAllActiveClosedAction(
          await _getAllUploadRequestGroupsInteractor
              .execute([UploadRequestStatus.ENABLED, UploadRequestStatus.CLOSED])));
    }));
  }

  void updateEmailSubjectObservable(String newData) {
    _emailSubjectObservable.add(newData);
  }

  void addUserEmail(AutoCompleteResult autoCompleteResult) {
    final newAutoCompleteResultList = _autoCompleteResultListObservable.value;
    if (newAutoCompleteResultList != null) {
      newAutoCompleteResultList.add(autoCompleteResult);
      _autoCompleteResultListObservable.add(newAutoCompleteResultList);
    }
  }

  void removeUserEmail(int index) {
    final newAutoCompleteResultList = _autoCompleteResultListObservable.value;
    if (newAutoCompleteResultList != null) {
      newAutoCompleteResultList.removeAt(index);
      _autoCompleteResultListObservable.add(newAutoCompleteResultList);
    }
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

  void _checkContactPermission() async {
    final permissionStatus = await Permission.contacts.status;
    if (permissionStatus.isGranted) {
      _contactSuggestionSource = ContactSuggestionSource.all;
    } else if (!permissionStatus.isPermanentlyDenied) {
      final requestedPermission = await Permission.contacts.request();
      _contactSuggestionSource = requestedPermission == PermissionStatus.granted
          ? ContactSuggestionSource.all
          : _contactSuggestionSource;
    }
  }

  @override
  void onDisposed() {
    _autoCompleteResultListSubscription.cancel();
    super.onDisposed();
  }
}