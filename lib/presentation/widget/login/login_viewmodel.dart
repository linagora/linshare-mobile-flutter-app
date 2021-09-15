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
import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/authentication_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/authentication_sso_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_toast.dart';
import 'package:linshare_flutter_app/presentation/util/authentication_sso_config.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/url_extension.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/util/router/route_paths.dart';
import 'package:linshare_flutter_app/presentation/widget/authentication/authentication_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/enter_otp/enter_otp_argument.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

class LoginViewModel extends BaseViewModel {
  LoginViewModel(
    Store<AppState> store,
    this._getPermanentTokenInteractor,
    this._getPermanentTokenSSOInteractor,
    this._getTokenSSOInteractor,
    this._appNavigation,
    this._dynamicUrlInterceptors,
    this._appToast
  ) : super(store);

  final CreatePermanentTokenInteractor _getPermanentTokenInteractor;
  final CreatePermanentTokenSSOInteractor _getPermanentTokenSSOInteractor;
  final GetTokenSSOInteractor _getTokenSSOInteractor;
  final AppNavigation _appNavigation;
  final DynamicUrlInterceptors _dynamicUrlInterceptors;
  final AppToast _appToast;

  String _urlText = '';
  String _emailText = '';
  String _passwordText = '';



  void setUrlText(String url) => _urlText = url.formatURLValid();

  void setEmailText(String email) => _emailText = email;

  void setPasswordText(String password) => _passwordText = password;

  void handleLoginPressed() {
    store.dispatch(loginAction(_parseUri(_urlText), _parseUserName(_emailText),
        _parsePassword(_passwordText)));
  }

  void handleLoginSSOPressed(BuildContext context) {
    store.dispatch(loginSSOAction(
        context,
        AuthenticationSSOConfig.clientId,
        AuthenticationSSOConfig.redirectUrl,
        AuthenticationSSOConfig.ssoConfiguration,
        AuthenticationSSOConfig.scopes,
        AuthenticationSSOConfig.preferEphemeralSession,
        AuthenticationSSOConfig.allowInsecureConnection,
        AuthenticationSSOConfig.baseUrlSupported));
  }

  Uri _parseUri(String url) => Uri.parse(url);

  UserName _parseUserName(String userName) => UserName(userName);

  Password _parsePassword(String password) => Password(password);

  ThunkAction<AppState> loginAction(Uri baseUrl, UserName userName, Password password) {
    return (Store<AppState> store) async {
      store.dispatch(StartAuthenticationLoadingAction());
      await _getPermanentTokenInteractor.execute(baseUrl, userName, password).then(
        (result) => result.fold(
          (failure) {
            if(failure is AuthenticationFailure) {
              _loginFailureAction(failure);
            }
          },
          (success) {
            if(success is AuthenticationViewState) {
              return store.dispatch(loginSuccessAction(success));
            }
          }));
    };
  }

  ThunkAction<AppState> loginSuccessAction(AuthenticationViewState success) {
    return (Store<AppState> store) async {
      store.dispatch(AuthenticationAction(Right(success)));
      _dynamicUrlInterceptors.changeBaseUrl(_urlText);
      await _appNavigation.push(RoutePaths.authentication, arguments: AuthenticationArguments(_parseUri(_urlText)));
    };
  }

  void _loginFailureAction(AuthenticationFailure failure) async {
    store.dispatch(AuthenticationAction(Left(failure)));
    if (failure.authenticationException is NeedAuthenticateWithOTP) {
      await _appNavigation.push(RoutePaths.enter_otp,
          arguments: EnterOTPArgument(_parseUri(_urlText), email: _parseUserName(_emailText), password: _parsePassword(_passwordText)));
    }
  }

  ThunkAction<AppState> loginSSOAction(
      BuildContext context,
      String clientId,
      String redirectUrl,
      SSOConfiguration configuration,
      List<String> scopes,
      bool preferEphemeralSession,
      bool allowInsecureConnections,
      String baseUrlSupported) {
    return (Store<AppState> store) async {
      store.dispatch(StartAuthenticationSSOLoadingAction());
      await _getTokenSSOInteractor
          .execute(
            clientId,
            redirectUrl,
            configuration,
            scopes,
            preferEphemeralSession,
            allowInsecureConnections)
          .then((result) => result.fold(
            (failure) {
              if (failure is AuthenticationSSOFailure) {
                _getTokenSSOFailureAction(failure, context);
              }
            },
            ((success) {
              if (success is AuthenticationSSOViewState) {
                return store.dispatch(getTokenSSOSuccessAction(success, baseUrlSupported));
              }
            })));
    };
  }

  ThunkAction<AppState> getTokenSSOSuccessAction(AuthenticationSSOViewState success, String baseUrl) {
    return (Store<AppState> store) async {
      await _getPermanentTokenSSOInteractor.execute(_parseUri(baseUrl), success.tokenSSO).then(
        (result) => result.fold(
          (failure) {
            if(failure is AuthenticationFailure) {
              _loginSSOFailureAction(failure, success.tokenSSO);
            }
          },
          (success) {
            if(success is AuthenticationViewState) {
              return store.dispatch(_loginSSOSuccessAction(success));
            }
          }));
    };
  }

  void _getTokenSSOFailureAction(AuthenticationSSOFailure failure, BuildContext context) async {
    store.dispatch(AuthenticationSSOAction(Left(failure)));
    _appToast.showErrorToast(AppLocalizations.of(context).login_sso_failed);
  }

  ThunkAction<AppState> _loginSSOSuccessAction(AuthenticationViewState success) {
    return (Store<AppState> store) async {
      store.dispatch(AuthenticationSSOAction(Right(success)));
      _dynamicUrlInterceptors.changeBaseUrl(AuthenticationSSOConfig.baseUrlSupported);
      await _appNavigation.push(RoutePaths.authentication, arguments: AuthenticationArguments(_parseUri(AuthenticationSSOConfig.baseUrlSupported)));
    };
  }

  void _loginSSOFailureAction(AuthenticationFailure failure, TokenSSO tokenSSO) async {
    store.dispatch(AuthenticationSSOAction(Left(failure)));
    if (failure.authenticationException is NeedAuthenticateWithOTP) {
      await _appNavigation.push(RoutePaths.enter_otp,
          arguments: EnterOTPArgument(_parseUri(AuthenticationSSOConfig.baseUrlSupported), tokenSSO: tokenSSO));
    }
  }

}
