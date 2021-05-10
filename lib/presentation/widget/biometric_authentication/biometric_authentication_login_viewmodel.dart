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

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/biometric_authentication_login_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/util/router/route_paths.dart';
import 'package:linshare_flutter_app/presentation/widget/authentication/authentication_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/biometric_authentication/biometric_authentication_arguments.dart';
import 'package:redux/redux.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/list_biometric_kind_extension.dart';

class BiometricAuthenticationLoginViewModel extends BaseViewModel {
  final AppNavigation _appNavigation;
  final AuthenticationBiometricInteractor _authenticationBiometricInteractor;
  final DisableBiometricInteractor _disableBiometricInteractor;
  final DeletePermanentTokenInteractor deletePermanentTokenInteractor;
  final GetAvailableBiometricInteractor _getAvailableBiometricInteractor;

  BiometricAuthenticationArguments _biometricAuthenticationArguments;

  BiometricAuthenticationLoginViewModel(
    Store<AppState> store,
    this._appNavigation,
    this._authenticationBiometricInteractor,
    this._getAvailableBiometricInteractor,
    this.deletePermanentTokenInteractor,
    this._disableBiometricInteractor
  ) : super(store);

  void setBiometricAuthenticationArguments(BiometricAuthenticationArguments arguments) {
    _biometricAuthenticationArguments = arguments;
  }

  void gotoSignIn() {
    store.dispatch((Store<AppState> store) async {
      await Future.wait([
        deletePermanentTokenInteractor.execute(),
        _disableBiometricInteractor.execute()
      ]);
    });
    _appNavigation.pushAndRemoveAll(RoutePaths.loginRoute);
  }

  void getAvailableBiometric(BuildContext context) {
    store.dispatch((Store<AppState> store) async {

      await _getAvailableBiometricInteractor.execute().then((response) => response.fold(
        (failure) => store.dispatch(SetBiometricAuthenticationAction([])),
        (success) => store.dispatch(SetBiometricAuthenticationAction(success is GetAvailableBiometricViewState ? success.biometricKinds : []))
      ));

      authenticationBiometric(context);
    });
  }

  void authenticationBiometric(BuildContext context) {
    store.dispatch((Store<AppState> store) async {
      final localizedReason = AppLocalizations.of(context).biometric_authentication_localized_reason(
          store.state.biometricAuthenticationLoginState.biometricKindList.getBiometricKind(context));

      final androidSetting = AndroidSettingArgument(AppLocalizations.of(context).cancel, AppLocalizations.of(context).biometric_authentication);
      final iosSetting = IOSSettingArgument(AppLocalizations.of(context).cancel);

      await _authenticationBiometricInteractor.execute(localizedReason, androidSettingArgument: androidSetting, iosSettingArgument: iosSetting)
        .then((result) => result.fold(
            (failure) => store.dispatch(SetAuthenticationBiometricStateAction(AuthenticationBiometricState.unauthenticated)),
            (success) {
          if (success is AuthenticationBiometricViewState) {
            store.dispatch(SetAuthenticationBiometricStateAction(success.authenticationState));
            if (success.authenticationState == AuthenticationBiometricState.authenticated) {
              _appNavigation.pushAndRemoveAll(
                  RoutePaths.authentication,
                  arguments: AuthenticationArguments(_biometricAuthenticationArguments.baseUrl));
            }
          } else {
            store.dispatch(SetAuthenticationBiometricStateAction(AuthenticationBiometricState.unauthenticated));
          }
        }));
    });
  }
}