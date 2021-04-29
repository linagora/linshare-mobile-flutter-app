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

import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/network_connectivity_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/ui_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/util/router/route_paths.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/upload_file_manager.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:connectivity/connectivity.dart';

class InitializeViewModel extends BaseViewModel {
  final GetCredentialInteractor _getCredentialInteractor;
  final AppNavigation _appNavigation;
  final DynamicUrlInterceptors _dynamicUrlInterceptors;
  final RetryAuthenticationInterceptors _retryInterceptors;
  final UploadFileManager _uploadFileManager;
  final Connectivity _connectivity;
  final GetBiometricSettingInteractor _getBiometricSettingInteractor;
  final DisableBiometricInteractor _disableBiometricInteractor;

  InitializeViewModel(
    Store<AppState> store,
    this._getCredentialInteractor,
    this._appNavigation,
    this._dynamicUrlInterceptors,
    this._retryInterceptors,
    this._uploadFileManager,
    this._connectivity,
    this._getBiometricSettingInteractor,
    this._disableBiometricInteractor,
  ) : super(store) {
    FlutterDownloader.initialize(debug: kDebugMode);
    _getNetworkConnectivityState();
    store.dispatch(_getCredentialAction());
    registerReceivingSharingIntent();
  }

  void _getNetworkConnectivityState() async {
    store.dispatch(SetNetworkConnectivityStateAction(await _connectivity.checkConnectivity()));
  }

  void registerReceivingSharingIntent() {
    _uploadFileManager.getReceivingSharingStream().listen((listShareMedia) {
      if (listShareMedia != null && listShareMedia.isNotEmpty) {
        _uploadFileManager.setPendingFiles(listShareMedia
            .map((element) => Uri.decodeFull(element.path))
            .toList());
      }
    });
  }

  ThunkAction<AppState> _getCredentialAction() {
    return (Store<AppState> store) async {
      await _getCredentialInteractor.execute().then((result) => result.fold(
          (left) => store.dispatch(_getCredentialFailureAction(left)),
          (right) => store.dispatch(_getCredentialSuccessAction((right)))));
    };
  }

  ThunkAction<AppState> _getCredentialSuccessAction(CredentialViewState success) {
    return (Store<AppState> store) async {
      _dynamicUrlInterceptors.changeBaseUrl(success.baseUrl.origin);
      _retryInterceptors.setPermanentToken(success.token);
      store.dispatch(_getBiometricSetting());
    };
  }

  ThunkAction<AppState> _getCredentialFailureAction(CredentialFailure failure) {
    return (Store<AppState> store) async {
      store.dispatch(_resetBiometricSetting());
      store.dispatch(SetCurrentView(RoutePaths.loginRoute));
      await _appNavigation.pushAndRemoveAll(RoutePaths.loginRoute);
    };
  }

  ThunkAction<AppState> _getBiometricSetting() {
    return (Store<AppState> store) async {
      await _getBiometricSettingInteractor.execute().then((result) => result.fold(
        (left) {
          store.dispatch(_resetBiometricSetting());
          store.dispatch(initializeHomeView(_appNavigation));
        },
        (right) {
          if (right is GetBiometricSettingViewState && right.biometricState == BiometricState.enabled) {
            _appNavigation.pushAndRemoveAll(RoutePaths.biometricAuthenticationLogin);
          } else {
            store.dispatch(_resetBiometricSetting());
            store.dispatch(initializeHomeView(_appNavigation));
          }
        }));
    };
  }

  ThunkAction<AppState> _resetBiometricSetting() {
    return (Store<AppState> store) async {
      await _disableBiometricInteractor.execute();
    };
  }

  @override
  void onDisposed() {
    super.onDisposed();
  }
}
