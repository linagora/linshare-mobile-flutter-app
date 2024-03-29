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
import 'package:flutter/material.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/biometric_authentication_setting_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/constant.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:redux/redux.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/list_biometric_kind_extension.dart';

class BiometricAuthenticationSettingViewModel extends BaseViewModel {
  final AppNavigation _appNavigation;
  final AuthenticationBiometricInteractor _authenticationBiometricInteractor;
  final EnableBiometricInteractor _enableBiometricInteractor;
  final GetAvailableBiometricInteractor _getAvailableBiometricInteractor;
  final GetBiometricSettingInteractor _getBiometricSettingInteractor;
  final DisableBiometricInteractor _disableBiometricInteractor;

  BiometricAuthenticationSettingViewModel(
    Store<AppState> store,
    this._appNavigation,
    this._authenticationBiometricInteractor,
    this._enableBiometricInteractor,
    this._getAvailableBiometricInteractor,
    this._getBiometricSettingInteractor,
    this._disableBiometricInteractor
  ) : super(store);

  void getBiometricSettings(BuildContext context) {
    store.dispatch((Store<AppState> store) async {

      await Future.wait([
        _getBiometricSettingInteractor.execute(),
        _getAvailableBiometricInteractor.execute()
      ]).then((response) async {
        final defaultTimeoutSettings =
            Constant.defaultBiometricAuthenticationTimeoutInMilliseconds.convertMillisecondsToBiometricTimeout;

        final biometricSettings = response[0]
            .map((result) => result is GetBiometricSettingViewState
                ? result.biometricSettings
                : BiometricAuthenticationSettings(BiometricState.disabled, defaultTimeoutSettings))
            .getOrElse(() => BiometricAuthenticationSettings(BiometricState.disabled, defaultTimeoutSettings));

        response[1].fold(
          (failure) {
            store.dispatch(SetBiometricAuthenticationSettingAction(
              Right(UpdateBiometricSettingTimeoutViewState(biometricSettings.biometricTimeout)),
              biometricSettings.biometricState,
              [],
              biometricSettings.biometricTimeout));
            store.dispatch(CleanBiometricAuthenticationStateSettingAction());
        },
          (success) {
            store.dispatch(SetBiometricAuthenticationSettingAction(
              Right(UpdateBiometricSettingTimeoutViewState(biometricSettings.biometricTimeout)),
              biometricSettings.biometricState,
              success is GetAvailableBiometricViewState ? success.biometricKinds : [],
              biometricSettings.biometricTimeout
            ));
            store.dispatch(CleanBiometricAuthenticationStateSettingAction());
          }
        );
      });
    });
  }

  void setNewTimeout(BuildContext context, BiometricAuthenticationTimeout newTimeout) {
    _appNavigation.popBack();
    store.dispatch(SetAuthenticationBiometricTimeoutAction(Right(UpdateBiometricSettingTimeoutViewState(newTimeout)), newTimeout));
    store.dispatch(CleanBiometricAuthenticationStateSettingAction());
    _enableBiometricAuthentication(
        BiometricAuthenticationSettings(store.state.biometricAuthenticationSettingState.biometricState, newTimeout));
  }

  void backToAccountDetail() {
    _appNavigation.popBack();
    if (store.state.biometricAuthenticationSettingState.authenticationBiometricState == AuthenticationBiometricState.unEnrolled) {
      store.dispatch(SetAuthenticationBiometricStateForBiometricSettingAction(AuthenticationBiometricState.unauthenticated));
    }
  }

  void checkBiometricState(BuildContext context) {
    final authenticationBiometricState = store.state.biometricAuthenticationSettingState.authenticationBiometricState;
    if (authenticationBiometricState == AuthenticationBiometricState.unEnrolled) {
      _authenticationBiometric(context, BiometricState.disabled);
    }
  }

  void toggleBiometricState(BuildContext context) {
    final biometricState = store.state.biometricAuthenticationSettingState.biometricState;
    _authenticationBiometric(context, biometricState);
  }

  void _authenticationBiometric(BuildContext context, BiometricState biometricState) {
    final localizedReason = AppLocalizations.of(context).biometric_authentication_localized_reason(
        store.state.biometricAuthenticationSettingState.biometricKindList.getBiometricKind(context));

    final androidSetting = AndroidSettingArgument(AppLocalizations.of(context).cancel, AppLocalizations.of(context).biometric_authentication);
    final iosSetting = IOSSettingArgument(AppLocalizations.of(context).cancel);

    store.dispatch((Store<AppState> store) async {
      await _authenticationBiometricInteractor.execute(localizedReason, androidSettingArgument: androidSetting, iosSettingArgument: iosSetting)
          .then((result) => result.fold(
            (failure) => store.dispatch(SetAuthenticationBiometricStateForBiometricSettingAction(AuthenticationBiometricState.unauthenticated)),
            (success) {
              if (success is AuthenticationBiometricViewState) {
                if (success.authenticationState == AuthenticationBiometricState.authenticated) {
                  final newBiometricState = biometricState == BiometricState.disabled ? BiometricState.enabled : BiometricState.disabled;

                  newBiometricState == BiometricState.enabled
                        ? _enableBiometricAuthentication(BiometricAuthenticationSettings(newBiometricState,
                              store.state.biometricAuthenticationSettingState.biometricTimeout))
                        : _disableBiometricAuthentication();

                  store.dispatch(SetBiometricStateForBiometricSettingAction(newBiometricState));
                }
                store.dispatch(SetAuthenticationBiometricStateForBiometricSettingAction(success.authenticationState));
              } else {
                store.dispatch(SetAuthenticationBiometricStateForBiometricSettingAction(AuthenticationBiometricState.unauthenticated));
              }
          }));
    });
  }

  void _enableBiometricAuthentication(BiometricAuthenticationSettings biometricSettings) {
    store.dispatch((Store<AppState> store) async {
      await _enableBiometricInteractor.execute(biometricSettings);
    });
  }

  void _disableBiometricAuthentication() {
    store.dispatch((Store<AppState> store) async {
      await _disableBiometricInteractor.execute();
    });
  }
}