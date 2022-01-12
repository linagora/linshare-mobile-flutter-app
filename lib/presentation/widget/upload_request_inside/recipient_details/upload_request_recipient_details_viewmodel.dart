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

import 'package:domain/domain.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_request_recipient_details_action.dart';
import 'package:linshare_flutter_app/presentation/redux/online_thunk_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/recipient_details/upload_request_recipient_details_arguments.dart';
import 'package:redux/redux.dart';
import 'package:rxdart/rxdart.dart';

class UploadRequestRecipientDetailsViewModel extends BaseViewModel {
  final AppNavigation _appNavigation;
  final GetUploadRequestInteractor _getUploadRequestInteractor;
  final GetUploadRequestActivitiesInteractor _getUploadRequestActivitiesInteractor;

  final BehaviorSubject<bool> _isDisplayFullMessages = BehaviorSubject.seeded(false);
  StreamView<bool> get isDisplayFullMessages => _isDisplayFullMessages;

  UploadRequestRecipientDetailsViewModel(
    Store<AppState> store,
    this._appNavigation,
    this._getUploadRequestInteractor,
    this._getUploadRequestActivitiesInteractor,
  ) : super(store);

  void initState(UploadRequestRecipientDetailsArguments arguments) {
    store.dispatch(_getUploadRequestAction(arguments.uploadRequest));
    store.dispatch(_getUploadRequestActivitiesAction(arguments.uploadRequest.uploadRequestId));
  }

  void backToUploadRequest() {
    _appNavigation.popBack();
  }

  OnlineThunkAction _getUploadRequestAction(UploadRequest uploadRequest) {
    return OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(StartUploadRequestRecipientDetailsLoadingAction());
      store.dispatch(UploadRequestRecipientDetailsGetUploadRequestAction(
          await _getUploadRequestInteractor.execute(uploadRequest.uploadRequestId)));
    });
  }

  OnlineThunkAction _getUploadRequestActivitiesAction(UploadRequestId uploadRequestId) {
    return OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(UploadRequestRecipientDetailsGetAllActivitiesAction(
          await _getUploadRequestActivitiesInteractor.execute(uploadRequestId)));
    });
  }

  void toggleDisplayMessages() {
    final currentStatusMessage = _isDisplayFullMessages.value;
    currentStatusMessage == true ? _isDisplayFullMessages.add(false) : _isDisplayFullMessages.add(true);
  }

  @override
  void onDisposed() {
    store.dispatch(CleanUploadRequestRecipientDetailsStateAction());
    super.onDisposed();
  }
}