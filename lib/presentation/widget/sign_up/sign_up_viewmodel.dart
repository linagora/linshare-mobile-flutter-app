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
import 'package:linshare_flutter_app/presentation/redux/actions/sigup_authentication_action.dart';
import 'package:linshare_flutter_app/presentation/redux/online_thunk_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_toast.dart';
import 'package:linshare_flutter_app/presentation/util/authentication_oidc_config.dart';
import 'package:linshare_flutter_app/presentation/util/environment.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/validator_failure_extension.dart';
import 'package:linshare_flutter_app/presentation/util/generate_password_utils.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/util/router/route_paths.dart';
import 'package:linshare_flutter_app/presentation/widget/authentication/authentication_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/login/login_form_type.dart';
import 'package:linshare_flutter_app/presentation/widget/sign_up/sign_up_authentication_type.dart';
import 'package:linshare_flutter_app/presentation/widget/sign_up/sign_up_form_type.dart';
import 'package:linshare_flutter_app/presentation/widget/sign_up/sign_up_operator.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpViewModel extends BaseViewModel {

  final AppNavigation _appNavigation;
  final GeneratePasswordUtils _generatePasswordUtils;
  final VerifyNameInteractor _verifyNameInteractor;
  final GetSaaSConfigurationInteractor _getSaaSConfigurationInteractor;
  final GetOIDCConfigurationInteractor _getOIDCConfigurationInteractor;
  final GetSecretTokenInteractor _getSecretTokenInteractor;
  final VerifyEmailSaaSInteractor _verifyEmailSaaSInteractor;
  final SignUpForSaaSInteractor _signUpForSaaSInteractor;
  final GetTokenOIDCInteractor _getTokenOIDCInteractor;
  final CreatePermanentTokenOIDCInteractor _createPermanentTokenOIDCInteractor;
  final DynamicUrlInterceptors _dynamicUrlInterceptors;
  final DynamicAPIVersionSupportInterceptor _dynamicAPIVersionSupportInterceptor;
  final AppToast _appToast;

  SignUpViewModel(
    Store<AppState> store,
    this._appNavigation,
    this._generatePasswordUtils,
    this._verifyNameInteractor,
    this._getSaaSConfigurationInteractor,
    this._getOIDCConfigurationInteractor,
    this._getSecretTokenInteractor,
    this._verifyEmailSaaSInteractor,
    this._signUpForSaaSInteractor,
    this._getTokenOIDCInteractor,
    this._createPermanentTokenOIDCInteractor,
    this._dynamicUrlInterceptors,
    this._dynamicAPIVersionSupportInterceptor,
    this._appToast,
  ) : super(store);

  String _emailText = '';
  String _nameText = '';
  String _surnameText = '';

  String get emailText => _emailText;

  void setEmailText(String email) => _emailText = email.trim();

  void setNameText(String name) => _nameText = name.trim();

  void setSurnameText(String surname) => _surnameText = surname.trim();

  void _clearAllValueInput() {
    setNameText('');
    setEmailText('');
    setSurnameText('');
  }

  void handleSignUpPressed(
      BuildContext context,
      SignUpFormType formType,
      SignUpAuthenticationType authenticationType
  ) {
    FocusScope.of(context).unfocus();

    switch(authenticationType) {
      case SignUpAuthenticationType.sendEmail:
        if (_emailText.isNotEmpty) {
          _verifyEmailSaaS(context, _emailText);
        } else {
          store.dispatch(SignUpAuthenticationAction(Left(AuthenticationFailure(EmptyLoginEmailException()))));
        }
        break;
      case SignUpAuthenticationType.sendPassword:
        if (_nameText.isNotEmpty) {
          if (_surnameText.isNotEmpty) {
            _handleSignUpToSaaSAction(context);
          } else {
            store.dispatch(SignUpAuthenticationAction(Left(AuthenticationFailure(EmptySignUpSurnameException()))));
          }
        } else {
          if (_surnameText.isNotEmpty) {
            store.dispatch(SignUpAuthenticationAction(Left(AuthenticationFailure(EmptySignUpNameException()))));
          } else {
            store.dispatch(SignUpAuthenticationAction(Left(AuthenticationFailure(EmptySignUpAllNameException()))));
          }
        }
        break;
      case SignUpAuthenticationType.signUpAgain:
        store.dispatch(UpdateSignUpAuthenticationScreenStateAction(SignUpFormType.fillName));
        _clearFillNameFormAndFocus(context);
        break;
      case SignUpAuthenticationType.contactSupport:
        _goToContactTechnicalSupport(context);
        break;
    }
  }

  void _clearFillNameFormAndFocus(BuildContext context) {
    setNameText('');
    setSurnameText('');
    FocusScope.of(context).requestFocus();
  }

  void _goToContactTechnicalSupport(BuildContext context) async {
    if (await canLaunch(AuthenticationOIDCConfig.contactTechnicalSupport)) {
      await launch(AuthenticationOIDCConfig.contactTechnicalSupport);
    } else {
      _appToast.showErrorToast(AppLocalizations.of(context).contact_technical_support_failed);
    }
  }

  void _handleSignUpToSaaSAction(BuildContext context) {
    if (saaSConfiguration != null) {
      _getSecretToken(context, saaSConfiguration!);
    } else {
      _getSaaSConfiguration(context, SignUpOperator.getSecretToken);
    }
  }

  void _getSaaSConfiguration(BuildContext context, SignUpOperator operator) {
    store.dispatch(_getSaaSConfigurationAction(context, operator));
  }

  ThunkAction<AppState> _getSaaSConfigurationAction(BuildContext context, SignUpOperator operator) {
    return (Store<AppState> store) async {
      store.dispatch(StartSignUpAuthenticationLoadingAction());

      await _getSaaSConfigurationInteractor.execute(Environment.saasType)
        .then((result) => result.fold(
          (failure) {
            if (failure is GetSaaSConfigurationFailure) {
              _signUpSaaSFailureAction(context, failure);
            }
          },
          ((success) {
            if (success is GetSaaSConfigurationViewState) {
              store.dispatch(SetSaaSConfigurationAction(success.saaSConfiguration));
              if (operator == SignUpOperator.verifyEmail) {
                store.dispatch(_verifyEmailSaaSAction(context, success.saaSConfiguration, _emailText));
              } else if (operator == SignUpOperator.getSecretToken) {
                _getSecretToken(context, success.saaSConfiguration);
              }
            }
          })));
    };
  }

  SaaSConfiguration? get saaSConfiguration => store.state.signUpAuthenticationState.saaSConfiguration;

  void _verifyEmailSaaS(BuildContext context, String email) {
    if (saaSConfiguration != null) {
      store.dispatch(_verifyEmailSaaSAction(context, saaSConfiguration!, email));
    } else {
      _getSaaSConfiguration(context, SignUpOperator.verifyEmail);
    }
  }

  OnlineThunkAction _verifyEmailSaaSAction(
      BuildContext context,
      SaaSConfiguration saaSConfiguration,
      String email,
  ) {
    return OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(StartSignUpAuthenticationLoadingAction());

      await _verifyEmailSaaSInteractor.execute(saaSConfiguration.verifyEmailBaseUrl, email)
        .then((result) => result.fold(
          (failure) {
            if (failure is VerifyEmailSaaSFailure) {
              store.dispatch(SignUpAuthenticationAction(Left(AuthenticationFailure(LoginEmailInvalidException()))));
            }
          },
          (success) {
            if (success is VerifyEmailSaaSViewState) {
              if (success.isEmailAvailable) {
                store.dispatch(UpdateSignUpAuthenticationScreenStateAction(SignUpFormType.fillName));
              } else {
                store.dispatch(SignUpAuthenticationAction(Left(AuthenticationFailure(EmailNotAvailableException()))));
              }
            }
          }));
    });
  }

  void _getSecretToken(BuildContext context, SaaSConfiguration saaSConfiguration) {
    store.dispatch(_getSecretTokenAction(context, saaSConfiguration, PlanRequest.free()));
  }

  OnlineThunkAction _getSecretTokenAction(
      BuildContext context,
      SaaSConfiguration saaSConfiguration,
      PlanRequest planRequest
  ) {
    return OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(StartSignUpAuthenticationLoadingAction());

      await _getSecretTokenInteractor.execute(saaSConfiguration.secretBaseUrl, planRequest)
        .then((result) => result.fold(
          (failure) {
            if (failure is GetSecretTokenFailure) {
              _signUpSaaSFailureAction(context, failure);
            }
          },
          (success) {
            if (success is GetSecretTokenViewState) {
              final signUpRequest = _generateSignUpRequest(context, success.secretToken, saaSConfiguration.companyName);
              _signUpForSaaS(context, saaSConfiguration.signUpBaseUrl, signUpRequest);
            }
          }));
    });
  }

  SignUpRequest _generateSignUpRequest(BuildContext context, SaaSSecretToken secretToken, String companyName) {
    final passwordSaaS = _generatePasswordUtils.generateSaaSPassword;
    final captchaResponseToken = AuthenticationOIDCConfig.captcha;
    final currentLocale = Localizations.localeOf(context).languageCode;

    final signUpRequest = SignUpRequest(
        _emailText,
        _nameText,
        _surnameText,
        companyName,
        passwordSaaS,
        currentLocale,
        captchaResponseToken,
        secretToken);

    return signUpRequest;
  }

  void _signUpForSaaS(BuildContext context, Uri baseUrl, SignUpRequest signUpRequest) {
    store.dispatch(_signUpForSaaSAction(context, baseUrl, signUpRequest));
  }

  OnlineThunkAction _signUpForSaaSAction(BuildContext context, baseUrl, SignUpRequest signUpRequest) {
    return OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(StartSignUpAuthenticationLoadingAction());

      await _signUpForSaaSInteractor.execute(baseUrl, signUpRequest)
        .then((result) => result.fold(
          (failure) {
            if (failure is SignUpForSaaSFailure) {
              _signUpSaaSFailureAction(context, failure);
              store.dispatch(UpdateSignUpAuthenticationScreenStateAction(SignUpFormType.failed));
            }
          },
          (success) {
            if (success is SignUpForSaaSViewState) {
              store.dispatch(SetSignUpSuccessAction(success.userSaaS, SignUpFormType.completed));
            } else {
              store.dispatch(UpdateSignUpAuthenticationScreenStateAction(SignUpFormType.failed));
            }
          }));
    });
  }

  void loginToSaaS(BuildContext context, Uri baseUrl) {
    _getOIDCConfiguration(context, baseUrl);
  }

  void _getOIDCConfiguration(BuildContext context, Uri baseUrl) {
    store.dispatch(_getOIDCConfigurationAction(context, baseUrl));
  }

  OnlineThunkAction _getOIDCConfigurationAction(BuildContext context, Uri baseUrl) {
    return OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(StartSignUpAuthenticationLoadingAction());

      await _getOIDCConfigurationInteractor.execute(baseUrl)
        .then((result) => result.fold(
          (failure) {
            if (failure is GetOIDCConfigurationFailure) {
              _signUpSaaSFailureAction(context, failure);
            }
          },
          (success) {
            if (success is GetOIDCConfigurationViewState) {
              _getTokenOIDC(context, success.oidcConfiguration, baseUrl);
            }
          }));
    });
  }

  void _signUpSaaSFailureAction(BuildContext context, Failure failure) async {
    store.dispatch(SignUpAuthenticationAction(Left(failure)));
  }

  void _getTokenOIDC(BuildContext context, OIDCConfiguration oidcConfiguration, Uri baseUrl) {
    store.dispatch(_getTokenOIDCAction(
        context,
        oidcConfiguration.clientId,
        oidcConfiguration.redirectUrl,
        oidcConfiguration.discoveryUrl,
        oidcConfiguration.scopes,
        AuthenticationOIDCConfig.preferEphemeralSessionIOS,
        AuthenticationOIDCConfig.promptValues,
        AuthenticationOIDCConfig.allowInsecureConnection,
        baseUrl));
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
      Uri baseUrl,
  ) {
    return (Store<AppState> store) async {
      store.dispatch(StartSignUpAuthenticationLoadingAction());

      await _getTokenOIDCInteractor
        .execute(clientId, redirectUrl, discoveryUrl, scopes, preferEphemeralSessionIOS, promptValues, allowInsecureConnections)
        .then((result) => result.fold(
          (failure) {
            if (failure is GetTokenOIDCFailure) {
              _signUpSaaSFailureAction(context, failure);
            }
          },
          (success) {
            if (success is GetTokenOIDCViewState) {
              return store.dispatch(_getPermanentTokenOIDCAction(context, success.tokenOIDC, baseUrl));
            }
          }));
    };
  }

  ThunkAction<AppState> _getPermanentTokenOIDCAction(BuildContext context, TokenOIDC tokenOIDC, Uri baseUrl) {
    return (Store<AppState> store) async {
      await _createPermanentTokenOIDCInteractor
        .execute(baseUrl, tokenOIDC)
        .then((result) => result.fold(
          (failure) {
            if (failure is AuthenticationFailure) {
              _signUpSaaSFailureAction(context, failure);
            }
          },
          (success) {
            if (success is AuthenticationViewState) {
              return store.dispatch(_loginOIDCSuccessAction(baseUrl, success));
            }
          }));
    };
  }

  ThunkAction<AppState> _loginOIDCSuccessAction(Uri baseUrl, AuthenticationViewState success) {
    return (Store<AppState> store) async {
      store.dispatch(AuthenticationAction(Right(success)));

      _dynamicUrlInterceptors.changeBaseUrl(baseUrl.origin);
      _dynamicAPIVersionSupportInterceptor.supportAPI = success.apiVersionSupported;

      await _appNavigation.pushAndRemoveAll(
        RoutePaths.authentication,
        arguments: AuthenticationArguments(baseUrl));
    };
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
          } else if (failure.authenticationException is EmailNotAvailableException) {
            return AppLocalizations.of(context).email_is_not_available;
          } else if (failure.authenticationException is EmptySignUpNameException) {
            return AppLocalizations.of(context).name_is_required;
          } else if (failure.authenticationException is EmptySignUpSurnameException) {
            return AppLocalizations.of(context).surname_is_required;
          } else if (failure.authenticationException is EmptySignUpAllNameException) {
            if (inputType == InputType.name) {
              return AppLocalizations.of(context).name_is_required;
            } else if (inputType == InputType.surname) {
              return AppLocalizations.of(context).surname_is_required;
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

  void handleCloseSignUpPressed(BuildContext context) {
    FocusScope.of(context).unfocus();
    _clearAllValueInput();
    store.dispatch(UpdateSignUpAuthenticationScreenStateAction(SignUpFormType.main));
    _appNavigation.popBack();
  }

  @override
  void onDisposed() {
    _clearAllValueInput();
    store.dispatch(CleanSignUpAuthenticationStateAction());
    super.onDisposed();
  }
}