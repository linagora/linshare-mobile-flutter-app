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

import 'dart:ui';

import 'package:dartz/dartz.dart' as dartz;
import 'package:domain/domain.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/redux/selectors/authentication_selector.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/authentication_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/authentication_oidc_config.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/helper/responsive_utils.dart';
import 'package:linshare_flutter_app/presentation/view/text/login_text_input_builder.dart';
import 'package:linshare_flutter_app/presentation/view/text/text_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/login/authentication_type.dart';
import 'package:linshare_flutter_app/presentation/widget/login/login_form_type.dart';
import 'package:linshare_flutter_app/presentation/widget/login/login_viewmodel.dart';

class LoginWidget extends StatefulWidget {
  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final loginViewModel = getIt<LoginViewModel>();
  final imagePath = getIt<AppImagePaths>();
  final _responsiveUtils = getIt<ResponsiveUtils>();

  @override
  void dispose() {
    loginViewModel.onDisposed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColor.loginBackgroundColor,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                reverse: true,
                child: Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: _responsiveUtils.isLandscapeSmallScreen(context) ? double.infinity : MediaQuery.of(context).size.height,
                        minHeight: MediaQuery.of(context).size.height),
                    child: Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                            padding: EdgeInsets.only(top: _responsiveUtils.isLandscapeSmallScreen(context) ? 30 : 60),
                            child: Image(
                                image: AssetImage(imagePath.icLoginLogoStandard),
                                fit: BoxFit.fill,
                                width: 150,
                                alignment: Alignment.center)),
                        StoreConnector<AppState, LoginFormType>(
                            converter: (store) => store.state.authenticationState.loginFormType,
                            builder: (context, loginFormType) {
                              switch(loginFormType) {
                                case LoginFormType.main:
                                  return _buildMainLoginForm();
                                case LoginFormType.useOwnServer:
                                  return _buildUseOwnServerLoginForm(context);
                                case LoginFormType.credentials:
                                  return _buildCredentialsLoginForm(context);
                                default:
                                  return _buildMainLoginForm();
                              }
                            }
                        ),
                      ],
                    )),
                  )
                )
              ),
              StoreConnector<AppState, LoginFormType>(
                converter: (store) => store.state.authenticationState.loginFormType,
                builder: (context, loginFormType) => loginFormType == LoginFormType.credentials
                  ? Positioned(
                      left: 10,
                      child: Row(children: [
                        IconButton(
                          key: Key('login_arrow_back_button'),
                          onPressed: () => loginViewModel.handleBackButtonLoginPressed(context, loginFormType),
                          icon: Image(
                            image: AssetImage(imagePath.icArrowBack),
                            alignment: Alignment.center,
                            color: AppColor.backLoginColor)),
                        Transform(
                          transform: Matrix4.translationValues(-12.0, 0.0, 0.0),
                          child: GestureDetector(
                            onTap: () => loginViewModel.handleBackButtonLoginPressed(context, loginFormType),
                            child: Text(
                              AppLocalizations.of(context).back,
                              style: TextStyle(fontSize: 17, color: AppColor.backLoginColor)),
                            )
                        )
                      ]))
                  : SizedBox.shrink()
              ),
              StoreConnector<AppState, LoginFormType>(
                converter: (store) => store.state.authenticationState.loginFormType,
                builder: (context, loginFormType) => (AuthenticationOIDCConfig.saasAvailable && loginFormType != LoginFormType.main)
                  ? Positioned(
                      right: 10,
                      child: IconButton(
                        key: Key('login_close_button'),
                        onPressed: () => loginViewModel.handleCloseLoginPressed(context),
                        icon: SvgPicture.asset(imagePath.icLoginClose, width: 18, height: 18, fit: BoxFit.fill)
                      ))
                  : SizedBox.shrink()
              ),
            ],
          )
        ),
      ),
    );
  }
  
  String _getErrorMessage(Failure failure) {
    if (failure is AuthenticationFailure) {
      if (failure.authenticationException is UnknownError) {
        return AppLocalizations.of(context).unknown_error_login_message;
      } else if (_checkCredentialError(failure.authenticationException)) {
        return _getCredentialErrorMessage(failure.authenticationException);
      } else if (_checkUrlError(failure.authenticationException)) {
        return AppLocalizations.of(context).wrong_url_message;
      }
    } else if (failure is GetOIDCConfigurationFailure) {
      if (failure.exception is UnknownError) {
        return AppLocalizations.of(context).unknown_error_login_message;
      } else if (_checkCredentialError(failure.exception)) {
        return _getCredentialErrorMessage(failure.exception);
      } else if (_checkUrlError(failure.exception)) {
        return AppLocalizations.of(context).wrong_url_message;
      } else {
        return AppLocalizations.of(context).wrong_url_message;
      }
    } else if (failure is GetTokenOIDCFailure) {
      if (failure.exception is UnknownError) {
        return AppLocalizations.of(context).unknown_error_login_message;
      } else if (_checkCredentialError(failure.exception)) {
        return _getCredentialErrorMessage(failure.exception);
      } else if (_checkUrlError(failure.exception)) {
        return AppLocalizations.of(context).wrong_url_message;
      } else {
        return AppLocalizations.of(context).wrong_url_message;
      }
    }
    return '';
  }

  bool _checkUrlError(dynamic authenticationException) {
    if (authenticationException is ServerNotFound ||
        authenticationException is ConnectError ||
        authenticationException is UnknownError) {
      return true;
    }
    return false;
  }

  bool _checkCredentialError(dynamic authenticationException) {
    if (authenticationException is BadCredentials ||
        authenticationException is UserLocked  ||
        authenticationException is UnknownError) {
      return true;
    }
    return false;
  }

  String _getCredentialErrorMessage(dynamic authenticationException) {
    return authenticationException is UserLocked
        ? AppLocalizations.of(context).user_locked_message
        : AppLocalizations.of(context).credential_error_message;
  }

  Widget _loadingCircularProgress() {
    return SizedBox(
      key: Key('login_loading_icon'),
      width: 40,
      height: 40,
      child: CircularProgressIndicator(color: AppColor.loginDefaultButtonColor),
    );
  }

  Widget _buildCreateAccountButton(BuildContext context) {
    return SizedBox(
      key: Key('create_account_button'),
      width: _getWidthButton(context),
      height: 48,
      child: ElevatedButton(
        onPressed: () => loginViewModel.handleSignUpPressed(context),
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) => Colors.white,
          ),
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) => AppColor.loginDefaultButtonColor,
          ),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(width: 0, color: AppColor.loginDefaultButtonColor),
          )),
          elevation: MaterialStateProperty.resolveWith<double>((Set<MaterialState> states) => 0)
        ),
        child: Text(
          AppLocalizations.of(context).create_an_account,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context, LoginFormType loginFormType, AuthenticationType authenticationType) {
    return SizedBox(
      key: Key('login_${loginFormType.toString()}_${authenticationType.toString()}_confirm_button'),
      width: _getWidthButton(context),
      height: 48,
      child: ElevatedButton(
        onPressed: () => loginViewModel.handleLoginPressed(context, loginFormType, authenticationType),
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) => authenticationType == AuthenticationType.saas
              ? AppColor.loginDefaultButtonColor
              : Colors.white,
          ),
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) => authenticationType == AuthenticationType.saas
              ? Colors.white
              : AppColor.loginDefaultButtonColor,
          ),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
                width: authenticationType == AuthenticationType.saas ? 1: 0,
                color: AppColor.loginDefaultButtonColor),
          )),
          elevation: MaterialStateProperty.resolveWith<double>((Set<MaterialState> states) => 0)
        ),
        child: Text(
          AppLocalizations.of(context).login_button_login,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.normal,
            color: authenticationType == AuthenticationType.saas ? AppColor.loginDefaultButtonColor : Colors.white)),
      ),
    );
  }

  Widget _loginUseOwnServerButton(BuildContext context) {
    return SizedBox(
      key: Key('login_use_own_server_confirm_button'),
      width: _getWidthButton(context),
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          loginViewModel.showLoginUseOwnServerForm();
        },
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) => AppColor.loginDefaultButtonColor,
          ),
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) => AppColor.loginUseOwnServerButtonColor,
          ),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(width: 0, color: AppColor.loginUseOwnServerButtonColor),
          )),
          elevation: MaterialStateProperty.resolveWith<double>((Set<MaterialState> states) => 0)
        ),
        child: Text(
          AppLocalizations.of(context).use_your_own_server,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17, color: AppColor.loginDefaultButtonColor, fontWeight: FontWeight.normal)),
      ),
    );
  }

  Widget _buildMainLoginForm() {
    return Column(
      children: [
        if (!_responsiveUtils.isLandscapeSmallScreen(context))
          Container(
            margin: EdgeInsets.only(
              top: 114,
              left: 32,
              right: 32),
            width: _getWidthButton(context),
            child: CenterTextBuilder()
              .text(AppLocalizations.of(context).login_message_center)
              .textStyle(TextStyle(fontSize: 15, color: AppColor.loginMessageCenterColor, fontWeight: FontWeight.normal))
              .build()),
        Padding(
          padding: EdgeInsets.only(
            top: _responsiveUtils.isLandscapeSmallScreen(context) ? 24 : 16,
            left: _getPaddingHorizontal(context),
            right: _getPaddingHorizontal(context)),
          child: _buildCreateAccountButton(context)),
        StoreConnector<AppState, AuthenticationState>(
          converter: (store) => store.state.authenticationState,
          builder: (context, authenticationState) =>
            Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: _getPaddingHorizontal(context),
                right: _getPaddingHorizontal(context)),
              child: authenticationState.isAuthenticationSaaSLoading()
                ? _loadingCircularProgress()
                : _buildLoginButton(context, LoginFormType.main, AuthenticationType.saas))),
        Padding(
          padding: EdgeInsets.only(
            top: _responsiveUtils.isLandscapeSmallScreen(context) ? 20 : 80,
            left: _getPaddingHorizontal(context),
            right: _getPaddingHorizontal(context)),
          child: _loginUseOwnServerButton(context)),
        if (!_responsiveUtils.isLandscapeSmallScreen(context))
          Container(
            padding: EdgeInsets.only(
              top: 12,
              bottom: 54,
              left: 32,
              right: 32),
            width: _getWidthButton(context),
            child: CenterTextBuilder()
              .text(AppLocalizations.of(context).login_message_bottom)
              .textStyle(TextStyle(fontSize: 13, color: AppColor.loginMessageBottomColor))
              .build()),
      ],
    );
  }

  Widget _buildUseOwnServerLoginForm(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: _responsiveUtils.isLandscapeSmallScreen(context) ? 20 : 64,
            left: _getPaddingHorizontal(context),
            right: _getPaddingHorizontal(context)),
          child: Container(
            width: _getWidthButton(context),
            child: CenterTextBuilder()
              .text(AppLocalizations.of(context).login_user_own_server_message_center)
              .textStyle(TextStyle(fontSize: 15, color: AppColor.backLoginColor, fontWeight: FontWeight.normal))
              .build())),
        Padding(
          padding: EdgeInsets.only(
            top: 22,
            left: _getPaddingHorizontal(context),
            right: _getPaddingHorizontal(context)),
          child: Container(
            width: _getWidthButton(context),
            child: StoreConnector<AppState, dartz.Either<Failure, Success>>(
              converter: (store) => store.state.authenticationState.viewState,
              builder: (context, viewState) => (LoginTextInputBuilder(context, imagePath)
                  ..key(Key('login_url_input'))
                  ..onChange((value) => loginViewModel.setUrlText(value))
                  ..textInputAction(TextInputAction.done)
                  ..setTextEditingController(loginViewModel.loginInputUrlController)
                  ..errorText(loginViewModel.getErrorInputString(viewState, context, InputType.url))
                  ..setErrorString((value) => loginViewModel.getErrorValidatorString(context, value, InputType.url))
                  ..prefixText(AppLocalizations.of(context).https)
                  ..labelText(AppLocalizations.of(context).https))
                .build())
          )),
        Padding(
          padding: EdgeInsets.only(
            top: 12,
            left: _responsiveUtils.isSmallScreen(context) ? 12 : 0,
            right: _responsiveUtils.isSmallScreen(context) ? 12 : 0),
          child: Container(
            width: _getWidthButton(context),
            child: Row(
              children: [
                ValueListenableBuilder(
                  valueListenable: loginViewModel.loginWithSSONotifier,
                  builder: (context, bool valueChange, child) => Checkbox(
                    value: valueChange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      side: BorderSide(width: 1, color: AppColor.loginCheckBoxBorderColor)),
                    onChanged: (value) => loginViewModel.loginWithSSONotifier.value = value ?? false,
                    activeColor: AppColor.loginCheckBoxActiveColor)),
              Expanded(child: GestureDetector(
                  onTap: () => loginViewModel.setCheckedLoginWithSSO(loginViewModel.loginWithSSONotifier.value),
                  child: Text(
                    AppLocalizations.of(context).checkbox_text_login_with_sso,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColor.loginLabelTextFieldColor,
                      fontWeight: FontWeight.normal)),
                ))
              ]
            )
          )),
        StoreConnector<AppState, dartz.Either<Failure, Success>>(
          converter: (store) => store.state.authenticationState.viewState,
          builder: (context, viewState) => viewState.fold(
            (failure) => _getErrorMessage(failure).isNotEmpty
              ? Padding(
                  padding: EdgeInsets.only(
                    left: _responsiveUtils.isSmallScreen(context) ? 26 : 0,
                    right: _responsiveUtils.isSmallScreen(context) ? 26 : 0),
                  child: Container(
                    width: _getWidthButton(context),
                    child: TextBuilder()
                      .text(_getErrorMessage(failure))
                      .textAlign(TextAlign.left)
                      .textStyle(TextStyle(fontSize: 13, color: AppColor.loginTextFieldBorderErrorColor, fontWeight: FontWeight.normal))
                      .build()))
              : SizedBox.shrink(),
            (success) => SizedBox.shrink())),
        Padding(
          padding: EdgeInsets.only(
            top: 20,
            bottom: 20,
            left: _getPaddingHorizontal(context),
            right: _getPaddingHorizontal(context)),
          child: ValueListenableBuilder(
            valueListenable: loginViewModel.loginWithSSONotifier,
            builder: (context, bool valueChange, child) {
              if (valueChange) {
                return StoreConnector<AppState, AuthenticationState>(
                  converter: (store) => store.state.authenticationState,
                  builder: (context, authenticationState) =>
                    authenticationState.isAuthenticationSSOLoading()
                      ? _loadingCircularProgress()
                      : _buildLoginButton(context, LoginFormType.useOwnServer, AuthenticationType.sso));
              } else {
                return _buildLoginButton(context, LoginFormType.useOwnServer, AuthenticationType.credentials);
              }
            }
          )
        ),
      ],
    );
  }

  Widget _buildCredentialsLoginForm(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: _responsiveUtils.isLandscapeSmallScreen(context) ? 20 : 40,
            left: _getPaddingHorizontal(context),
            right: _getPaddingHorizontal(context)),
          child: Container(
            width: _getWidthButton(context),
            child: StoreConnector<AppState, dartz.Either<Failure, Success>>(
              converter: (store) => store.state.authenticationState.viewState,
              builder: (context, viewState) => (LoginTextInputBuilder(context, imagePath)
                  ..key(Key('login_email_input'))
                  ..onChange((value) => loginViewModel.setEmailText(value))
                  ..textInputAction(TextInputAction.next)
                  ..title(_responsiveUtils.isLandscapeSmallScreen(context)
                      ? ''
                      : AppLocalizations.of(context).login_email_title)
                  ..errorText(loginViewModel.getErrorInputString(viewState, context, InputType.email))
                  ..setErrorString((value) => loginViewModel.getErrorValidatorString(context, value, InputType.email))
                  ..hintText(AppLocalizations.of(context).hint_input_email_login)
                  ..labelText(AppLocalizations.of(context).hint_input_email_login))
                .build()),
          )),
        Padding(
          padding: EdgeInsets.only(
            top: 26,
            left: _getPaddingHorizontal(context),
            right: _getPaddingHorizontal(context)),
          child: Container(
            width: _getWidthButton(context),
            child:  StoreConnector<AppState, dartz.Either<Failure, Success>>(
              converter: (store) => store.state.authenticationState.viewState,
              builder: (context, viewState) => (LoginTextInputBuilder(context, imagePath)
                  ..key(Key('login_password_input'))
                  ..onChange((value) => loginViewModel.setPasswordText(value))
                  ..passwordInput(true)
                  ..obscureText(true)
                  ..textInputAction(TextInputAction.next)
                  ..title(_responsiveUtils.isLandscapeSmallScreen(context)
                      ? ''
                      : AppLocalizations.of(context).login_password_title)
                  ..errorText(loginViewModel.getErrorInputString(viewState, context, InputType.password))
                  ..setErrorString((value) => loginViewModel.getErrorValidatorString(context, value, InputType.password))
                  ..hintText(AppLocalizations.of(context).hint_input_password_login)
                  ..labelText(AppLocalizations.of(context).hint_input_password_login))
                .build()),
          )),
        StoreConnector<AppState, dartz.Either<Failure, Success>>(
          converter: (store) => store.state.authenticationState.viewState,
          builder: (context, viewState) => viewState.fold(
            (failure) =>  _getErrorMessage(failure).isNotEmpty
              ? Padding(
                  padding: EdgeInsets.only(
                    top: 13,
                    left: _getPaddingHorizontal(context),
                    right: _getPaddingHorizontal(context)),
                  child: Container(
                    width: _getWidthButton(context),
                    child: TextBuilder()
                      .text(_getErrorMessage(failure))
                      .textStyle(TextStyle(fontSize: 13, color: AppColor.loginTextFieldBorderErrorColor, fontWeight: FontWeight.normal))
                      .build()))
              : SizedBox.shrink(),
            (success) => SizedBox.shrink())),
        Padding(
          padding: EdgeInsets.only(
            top: 32,
            bottom: 20,
            left: _getPaddingHorizontal(context),
            right: _getPaddingHorizontal(context)),
          child: StoreConnector<AppState, AuthenticationState>(
            converter: (store) => store.state.authenticationState,
            builder: (context, authenticationState) => authenticationState.isAuthenticationLoading()
              ? _loadingCircularProgress()
              : _buildLoginButton(context, LoginFormType.credentials, AuthenticationType.credentials))),
      ],
    );
  }

  double _getWidthButton(BuildContext context) {
    return _responsiveUtils.isSmallScreen(context) ? double.infinity : _responsiveUtils.getWidthLoginButton();
  }

  double _getPaddingHorizontal(BuildContext context) {
    return _responsiveUtils.isSmallScreen(context) ? 14 : 0;
  }
}