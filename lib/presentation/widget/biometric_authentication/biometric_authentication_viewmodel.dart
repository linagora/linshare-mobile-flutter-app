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
import 'package:linshare_flutter_app/presentation/redux/actions/biometric_authentication_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:redux/redux.dart';

class BiometricAuthenticationViewModel extends BaseViewModel {
  final AppNavigation _appNavigation;
  final AuthenticationBiometricInteractor _authenticationBiometricInteractor;
  final EnableBiometricInteractor _enableBiometricInteractor;
  final GetAvailableBiometricInteractor _getAvailableBiometricInteractor;
  final GetBiometricSettingInteractor _getBiometricSettingInteractor;
  final DisableBiometricInteractor _disableBiometricInteractor;

  BiometricAuthenticationViewModel(
    Store<AppState> store,
    this._appNavigation,
    this._authenticationBiometricInteractor,
    this._enableBiometricInteractor,
    this._getAvailableBiometricInteractor,
    this._getBiometricSettingInteractor,
    this._disableBiometricInteractor
    ) : super(store);

  void getBiometricSetting() {
    store.dispatch((Store<AppState> store) async {

      await Future.wait([
        _getBiometricSettingInteractor.execute(),
        _getAvailableBiometricInteractor.execute()
      ]).then((response) async {

        final biometricState = response[0]
            .map((result) => result is GetBiometricSettingViewState ? result.biometricState : BiometricState.disabled)
            .getOrElse(() => BiometricState.disabled);

        response[1].fold((failure) {
          store.dispatch(SetBiometricAuthenticationAction(biometricState, []));
        }, (success) {
          store.dispatch(SetBiometricAuthenticationAction(
              biometricState,
              success is GetAvailableBiometricViewState ? success.biometricKinds : []));
        });
      });
    });
  }

  void backToAccountDetail() {
    _appNavigation.popBack();
    if (store.state.biometricAuthenticationState.authenticationBiometricState == AuthenticationBiometricState.unEnrolled) {
      store.dispatch(SetAuthenticationBiometricStateAction(AuthenticationBiometricState.unAuthenticated));
    }
  }

  void checkBiometricState(BuildContext context) {
    final authenticationBiometricState = store.state.biometricAuthenticationState.authenticationBiometricState;
    if (authenticationBiometricState == AuthenticationBiometricState.unEnrolled) {
      _authenticationBiometric(context, BiometricState.disabled);
    }
  }

  void toggleBiometricState(BuildContext context) {
    final biometricState = store.state.biometricAuthenticationState.biometricState;
    _authenticationBiometric(context, biometricState);
  }

  void _authenticationBiometric(BuildContext context, BiometricState biometricState) {
    var localizedReason = biometricState == BiometricState.enabled
      ? AppLocalizations.of(context).biometric_authentication_localized_reason_disable
      : AppLocalizations.of(context).biometric_authentication_localized_reason_enable;

    store.dispatch((Store<AppState> store) async {
      await _authenticationBiometricInteractor.execute(localizedReason)
          .then((result) => result.fold(
            (failure) => store.dispatch(SetAuthenticationBiometricStateAction(AuthenticationBiometricState.unAuthenticated)),
            (success) {
              if (success is AuthenticationBiometricViewState) {
                if (success.authenticationState == AuthenticationBiometricState.authenticated) {
                  final newBiometricState = biometricState == BiometricState.disabled ? BiometricState.enabled : BiometricState.disabled;

                  newBiometricState == BiometricState.enabled
                      ? _enableBiometricAuthentication(newBiometricState)
                      : _disableBiometricAuthentication();

                  store.dispatch(SetBiometricStateAction(newBiometricState));
                }
                store.dispatch(SetAuthenticationBiometricStateAction(success.authenticationState));
              } else {
                store.dispatch(SetAuthenticationBiometricStateAction(AuthenticationBiometricState.unAuthenticated));
              }
          }));
    });
  }

  void _enableBiometricAuthentication(BiometricState biometricState) {
    store.dispatch((Store<AppState> store) async {
      await _enableBiometricInteractor.execute(biometricState);
    });
  }

  void _disableBiometricAuthentication() {
    store.dispatch((Store<AppState> store) async {
      await _disableBiometricInteractor.execute();
    });
  }
}