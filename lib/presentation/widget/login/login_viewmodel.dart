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
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/authentication_oidc_config.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/url_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/validator_failure_extension.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/util/router/route_paths.dart';
import 'package:linshare_flutter_app/presentation/widget/authentication/authentication_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/enter_otp/enter_otp_argument.dart';
import 'package:linshare_flutter_app/presentation/widget/login/authentication_type.dart';
import 'package:linshare_flutter_app/presentation/widget/login/login_form_type.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

class LoginViewModel extends BaseViewModel {

  final CreatePermanentTokenInteractor _getPermanentTokenInteractor;
  final CreatePermanentTokenOIDCInteractor _createPermanentTokenOIDCInteractor;
  final GetTokenOIDCInteractor _getTokenOIDCInteractor;
  final AppNavigation _appNavigation;
  final DynamicUrlInterceptors _dynamicUrlInterceptors;
  final GetOIDCConfigurationInteractor _getOIDCConfigurationInteractor;
  final VerifyNameInteractor _verifyNameInteractor;
  final GetSaaSConfigurationInteractor _getSaaSConfigurationInteractor;

  LoginViewModel(
    Store<AppState> store,
    this._getPermanentTokenInteractor,
    this._createPermanentTokenOIDCInteractor,
    this._getTokenOIDCInteractor,
    this._appNavigation,
    this._dynamicUrlInterceptors,
    this._getOIDCConfigurationInteractor,
    this._verifyNameInteractor,
    this._getSaaSConfigurationInteractor,
  ) : super(store);

  final ValueNotifier<bool> loginWithSSONotifier = ValueNotifier<bool>(false);
  final TextEditingController loginInputUrlController = TextEditingController();

  String _urlText = '';
  String _emailText = '';
  String _passwordText = '';

  void setUrlText(String url) => _urlText = url.trim();

  void setEmailText(String email) => _emailText = email.trim();

  void setPasswordText(String password) => _passwordText = password.trim();

  Uri _parseUri(String url) => Uri.parse(url);

  UserName _parseUserName(String userName) => UserName(userName);

  Password _parsePassword(String password) => Password(password);

  void _clearAllValueInput() {
    loginWithSSONotifier.value = false;
    loginInputUrlController.clear();
    setUrlText('');
    setEmailText('');
    setPasswordText('');
  }

  void handleSignUpPressed(BuildContext context) {
    _appNavigation.push(RoutePaths.signUpRoute);
  }

  void handleLoginPressed(
      BuildContext context,
      LoginFormType loginFormType,
      AuthenticationType authenticationType
  ) {
    FocusScope.of(context).unfocus();

    switch(authenticationType) {
      case AuthenticationType.saas:
        _loginToSaaS(context);
        break;
      case AuthenticationType.credentials:
        if (loginFormType == LoginFormType.useOwnServer) {
          if (_urlText.isNotEmpty) {
            store.dispatch(UpdateAuthenticationScreenStateAction(LoginFormType.credentials));
          } else {
            store.dispatch(AuthenticationAction(Left(AuthenticationFailure(EmptyLoginUrlException()))));
          }
        } else {
          if (_emailText.isNotEmpty) {
            if (_passwordText.isNotEmpty) {
              _loginWithCredentials();
            } else {
              store.dispatch(AuthenticationAction(Left(AuthenticationFailure(EmptyLoginPasswordException()))));
            }
          } else {
            if (_passwordText.isNotEmpty) {
              store.dispatch(AuthenticationAction(Left(AuthenticationFailure(EmptyLoginEmailException()))));
            } else {
              store.dispatch(AuthenticationAction(Left(AuthenticationFailure(EmptyLoginEmailAndPasswordException()))));
            }
          }
        }
        break;
      case AuthenticationType.sso:
        if (_urlText.isNotEmpty) {
          _loginWithSSO(context, _urlText.formatURLValid());
        } else {
          store.dispatch(AuthenticationAction(Left(AuthenticationFailure(EmptyLoginUrlException()))));
        }
        break;
      case AuthenticationType.none:
        break;
    }
  }

  void _loginToSaaS(BuildContext context) {
    _getSaaSConfiguration(context);
  }

  void _getSaaSConfiguration(BuildContext context) {
    store.dispatch(_getSaaSConfigurationAction(context));
  }

  ThunkAction<AppState> _getSaaSConfigurationAction(BuildContext context) {
    return (Store<AppState> store) async {
      store.dispatch(StartAuthenticationSaaSLoadingAction());

      await _getSaaSConfigurationInteractor.execute(SaaSType.dev)
        .then((result) => result.fold(
          (failure) {
            if (failure is GetSaaSConfigurationFailure) {
              _loginOIDCFailureAction(context, failure, AuthenticationType.saas);
            }
          },
          ((success) {
            if (success is GetSaaSConfigurationViewState) {
              store.dispatch(UpdateSaaSConfigurationAction(success.saaSConfiguration));
              _getOIDCConfiguration(context, success.saaSConfiguration.loginBaseUrl.origin, AuthenticationType.saas);
            }
          })));
    };
  }

  void _loginWithCredentials() {
    store.dispatch(_loginCredentialsAction(
      _parseUri(_urlText.formatURLValid()),
      _parseUserName(_emailText),
      _parsePassword(_passwordText)));
  }

  void _loginWithSSO(BuildContext context, String baseUrl) {
    _getOIDCConfiguration(context, baseUrl, AuthenticationType.sso);
  }

  void _getOIDCConfiguration(BuildContext context, String baseUrl, AuthenticationType authenticationType) {
    store.dispatch(_getOIDCConfigurationAction(context, baseUrl, authenticationType));
  }

  ThunkAction<AppState> _getOIDCConfigurationAction(
      BuildContext context,
      String baseUrl,
      AuthenticationType authenticationType
  ) {
    return (Store<AppState> store) async {
      if (authenticationType == AuthenticationType.saas) {
        store.dispatch(StartAuthenticationSaaSLoadingAction());
      } else if (authenticationType == AuthenticationType.sso) {
        store.dispatch(StartAuthenticationSSOLoadingAction());
      }

      await _getOIDCConfigurationInteractor
        .execute(_parseUri(baseUrl))
        .then((result) => result.fold(
          (failure) {
            if (failure is GetOIDCConfigurationFailure) {
              _loginOIDCFailureAction(context, failure, authenticationType);
            }
          },
          ((success) {
            if (success is GetOIDCConfigurationViewState) {
              _getTokenOIDC(context, success.oidcConfiguration, baseUrl, authenticationType);
            }
          })));
    };
  }

  void _getTokenOIDC(
      BuildContext context,
      OIDCConfiguration oidcConfiguration,
      String baseUrl,
      AuthenticationType authenticationType
  ) {
    store.dispatch(_getTokenOIDCAction(
        context,
        oidcConfiguration.clientId,
        oidcConfiguration.redirectUrl,
        oidcConfiguration.discoveryUrl,
        oidcConfiguration.scopes,
        AuthenticationOIDCConfig.preferEphemeralSessionIOS,
        AuthenticationOIDCConfig.promptValues,
        AuthenticationOIDCConfig.allowInsecureConnection,
        baseUrl,
        authenticationType));
  }

  ThunkAction<AppState> _getTokenOIDCAction(
      BuildContext context,
      String clientId,
      String redirectUrl,
      String discoveryUrl,
      List<String> scopes,
      bool preferEphemeralSessionIOS,
      List<String>? promptValues,
      bool allowInsecureConnections,
      String baseUrl,
      AuthenticationType authenticationType
  ) {
    return (Store<AppState> store) async {
      if (authenticationType == AuthenticationType.saas) {
        store.dispatch(StartAuthenticationSaaSLoadingAction());
      } else if (authenticationType == AuthenticationType.sso) {
        store.dispatch(StartAuthenticationSSOLoadingAction());
      }

      await _getTokenOIDCInteractor
        .execute(clientId, redirectUrl, discoveryUrl, scopes, preferEphemeralSessionIOS, promptValues, allowInsecureConnections)
        .then((result) => result.fold(
          (failure) {
            if (failure is GetTokenOIDCFailure) {
              _loginOIDCFailureAction(context, failure, authenticationType);
            }
          },
          (success) {
            if (success is GetTokenOIDCViewState) {
              return store.dispatch(_getPermanentTokenOIDCAction(
                context,
                success.tokenOIDC,
                baseUrl,
                authenticationType));
            }
            }));
    };
  }

  ThunkAction<AppState> _getPermanentTokenOIDCAction(
      BuildContext context,
      TokenOIDC tokenOIDC,
      String baseUrl,
      AuthenticationType authenticationType
  ) {
    return (Store<AppState> store) async {
      await _createPermanentTokenOIDCInteractor
        .execute(_parseUri(baseUrl), tokenOIDC)
        .then((result) => result.fold(
          (failure) {
            if (failure is AuthenticationFailure) {
              _loginOIDCFailureAction(context, failure, authenticationType);
            }
          },
          (success) {
            if (success is AuthenticationViewState) {
              return store.dispatch(_loginOIDCSuccessAction(baseUrl, success, authenticationType));
            }
          }));
    };
  }

  ThunkAction<AppState> _loginOIDCSuccessAction(String baseUrl, AuthenticationViewState success, AuthenticationType authenticationType) {
    return (Store<AppState> store) async {
      store.dispatch(AuthenticationAction(Right(success)));

      _dynamicUrlInterceptors.changeBaseUrl(baseUrl);

      await _appNavigation.push(
        RoutePaths.authentication,
        arguments: AuthenticationArguments(_parseUri(baseUrl)));
    };
  }

  void _loginOIDCFailureAction(BuildContext context, Failure failure, AuthenticationType authenticationType) async {
    store.dispatch(AuthenticationAction(Left(failure)));
  }

  ThunkAction<AppState> _loginCredentialsAction(Uri baseUrl, UserName userName, Password password) {
    return (Store<AppState> store) async {
      store.dispatch(StartAuthenticationLoadingAction());

      await _getPermanentTokenInteractor
        .execute(baseUrl, userName, password)
        .then((result) => result.fold(
          (failure) {
            if(failure is AuthenticationFailure) {
              _loginCredentialsFailureAction(failure);
            }
          },
          (success) {
            if(success is AuthenticationViewState) {
              return store.dispatch(loginCredentialsSuccessAction(success));
            }
          }));
    };
  }

  ThunkAction<AppState> loginCredentialsSuccessAction(AuthenticationViewState success) {
    return (Store<AppState> store) async {
      store.dispatch(AuthenticationAction(Right(success)));

      _dynamicUrlInterceptors.changeBaseUrl(_urlText.formatURLValid());

      await _appNavigation.push(
        RoutePaths.authentication,
        arguments: AuthenticationArguments(_parseUri(_urlText.formatURLValid())));
    };
  }

  void _loginCredentialsFailureAction(AuthenticationFailure failure) async {
    store.dispatch(AuthenticationAction(Left(failure)));

    if (failure.authenticationException is NeedAuthenticateWithOTP) {
      await _appNavigation.push(
        RoutePaths.enter_otp,
        arguments: EnterOTPArgument(
          _parseUri(_urlText.formatURLValid()),
          email: _parseUserName(_emailText),
          password: _parsePassword(_passwordText)));
    }
  }

  void showLoginUseOwnServerForm() {
    store.dispatch(UpdateAuthenticationScreenStateAction(LoginFormType.useOwnServer));
  }

  void handleBackButtonLoginPressed(BuildContext context, LoginFormType loginFormType) {
    FocusScope.of(context).unfocus();

    if (loginFormType == LoginFormType.useOwnServer) {
      store.dispatch(UpdateAuthenticationScreenStateAction(LoginFormType.main));
    } else if (loginFormType == LoginFormType.credentials) {
      setEmailText('');
      setPasswordText('');
      store.dispatch(UpdateAuthenticationScreenStateAction(LoginFormType.useOwnServer));
    }
  }

  String? getErrorValidatorString(BuildContext context, String value, InputType inputType) {
    return _verifyNameInteractor.execute(value, inputType.getValidator()).fold(
      (failure) => (failure is VerifyNameFailure) ? failure.getMessage(context) : null,
      (success) => null
    );
  }

  String? getErrorInputString(Either<Failure, Success> viewState, BuildContext context, InputType inputType) {
    return viewState.fold(
      (failure) {
        if (failure is AuthenticationFailure) {
          if (failure.authenticationException is EmptyLoginEmailException) {
            return AppLocalizations.of(context).email_is_required;
          } else if (failure.authenticationException is LoginEmailInvalidException) {
            return AppLocalizations.of(context).email_is_invalid;
          } else if (failure.authenticationException is EmptyLoginPasswordException) {
            return AppLocalizations.of(context).password_is_required;
          } else if (failure.authenticationException is PasswordSpecialCharacterException) {
            return AppLocalizations.of(context).password_is_invalid;
          } else if (failure.authenticationException is EmptyLoginUrlException) {
            return AppLocalizations.of(context).url_is_invalid;
          } else if (failure.authenticationException is EmptyLoginEmailAndPasswordException) {
            if (inputType == InputType.password) {
              return AppLocalizations.of(context).password_is_required;
            } else if (inputType == InputType.email) {
              return AppLocalizations.of(context).email_is_required;
            } else {
              return null;
            }
          } else {
            return null;
          }
        }
        return null;
      },
      (success) => null);
  }

  void setCheckedLoginWithSSO(bool checked) {
    final newChecked = checked ? false : true;
    loginWithSSONotifier.value = newChecked;
  }

  void handleCloseLoginPressed(BuildContext context) {
    FocusScope.of(context).unfocus();
    _clearAllValueInput();
    store.dispatch(UpdateAuthenticationScreenStateAction(LoginFormType.main));
  }

  @override
  void onDisposed() {
    loginWithSSONotifier.dispose();
    loginInputUrlController.clear();
    _clearAllValueInput();
    store.dispatch(CleanAuthenticationStateAction());
    super.onDisposed();
  }
}