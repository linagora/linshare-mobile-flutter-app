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
// Linagora © 2009–2021. Contribute to Linshare R&D by subscribing to an Enterprise
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
import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/authentication_action.dart';
import 'package:linshare_flutter_app/presentation/redux/online_thunk_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_toast.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/util/router/route_paths.dart';
import 'package:linshare_flutter_app/presentation/widget/authentication/authentication_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/enter_otp/enter_otp_argument.dart';
import 'package:redux/src/store.dart';

class EnterOTPViewModel extends BaseViewModel {
  final AppNavigation _appNavigation;
  final CreatePermanentTokenInteractor _getPermanentTokenInteractor;
  final CreatePermanentTokenOIDCInteractor _getPermanentTokenSSOInteractor;
  final DynamicUrlInterceptors _dynamicUrlInterceptors;
  final DynamicAPIVersionSupportInterceptor _dynamicAPIVersionSupportInterceptor;
  final AppToast _appToast;
  late EnterOTPArgument _enterOTPArgument;

  EnterOTPViewModel(
    Store<AppState> store,
    this._appNavigation,
    this._getPermanentTokenInteractor,
    this._getPermanentTokenSSOInteractor,
    this._dynamicUrlInterceptors,
    this._dynamicAPIVersionSupportInterceptor,
    this._appToast
  ) : super(store);

  void setEnterOTPArgument(EnterOTPArgument argument) {
    _enterOTPArgument = argument;
  }

  void onBackPressed() {
    _appNavigation.popBack();
  }

  void onLoginPressed(String otp, BuildContext context) {
    if(_enterOTPArgument.tokenOIDC != null) {
      store.dispatch(_loginSSOWithOTPAction(otp, context));
    } else if(_enterOTPArgument.email != null && _enterOTPArgument.password != null) {
      store.dispatch(_loginWithOTPAction(otp, context));
    }
  }

  OnlineThunkAction _loginWithOTPAction(String otp, BuildContext context) {
    return OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(StartAuthenticationLoadingAction());
      await _getPermanentTokenInteractor
          .execute(_enterOTPArgument.baseUrl, _enterOTPArgument.email!, _enterOTPArgument.password!, otpCode: OTPCode(otp))
          .then(
              (result) => result.fold(
                  (failure) {
                    if (failure is AuthenticationFailure) {
                      _loginFailure(failure, context);
                    }
                  },
                  ((success) {
                    if(success is AuthenticationViewState) {
                      _loginSuccess(success);
                    }
                  })));
    });
  }

  OnlineThunkAction _loginSSOWithOTPAction(String otp, BuildContext context) {
    return OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(StartAuthenticationLoadingAction());
      await _getPermanentTokenSSOInteractor
          .execute(_enterOTPArgument.baseUrl, _enterOTPArgument.tokenOIDC!, otpCode: OTPCode(otp))
          .then(
              (result) => result.fold(
                  (failure) {
                if (failure is AuthenticationFailure) {
                  _loginFailure(failure, context);
                }
              },
              ((success) {
                if(success is AuthenticationViewState) {
                  _loginSuccess(success);
                }
              })));
    });
  }

  void _loginFailure(AuthenticationFailure authenticationFailure, BuildContext context) async {
    final authenException = authenticationFailure.authenticationException;
    store.dispatch(AuthenticationAction(Left(authenticationFailure)));
    if (authenException is UserLocked) {
      _appNavigation.popBack();
    } else {
      _appToast.showErrorToast(AppLocalizations.of(context).invalid_otp);
    }
  }

  void _loginSuccess(AuthenticationViewState success) async {
    store.dispatch(AuthenticationAction(Right(success)));
    _dynamicUrlInterceptors.changeBaseUrl(_enterOTPArgument.baseUrl.origin);
    _dynamicAPIVersionSupportInterceptor.supportAPI = success.apiVersionSupported;
    await _appNavigation.pushAndRemoveAll(RoutePaths.authentication, arguments: AuthenticationArguments(_enterOTPArgument.baseUrl));
  }
}
