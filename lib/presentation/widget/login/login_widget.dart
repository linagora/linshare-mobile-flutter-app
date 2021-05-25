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
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/redux/selectors/authentication_selector.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/authentication_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/helper/responsive_utils.dart';
import 'package:linshare_flutter_app/presentation/view/text/input_decoration_builder.dart';
import 'package:linshare_flutter_app/presentation/view/text/linshare_slogan_builder.dart';
import 'package:linshare_flutter_app/presentation/view/text/login_text_builder.dart';
import 'package:linshare_flutter_app/presentation/view/text/text_builder.dart';
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
      resizeToAvoidBottomPadding: false,
      backgroundColor: AppColor.primaryColor,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                left: 10,
                child: IconButton(
                  key: Key('login_arrow_back_button'),
                  onPressed: () => {},
                  icon: Image(
                      image: AssetImage(imagePath.icArrowBack),
                      alignment: Alignment.center),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  reverse: true,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(top: 45),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          LinShareSloganBuilder()
                            .setSloganText(AppLocalizations.of(context).login_text_slogan)
                            .setSloganTextAlign(TextAlign.center)
                            .setSloganTextStyle(TextStyle(color: Colors.white, fontSize: 16))
                            .setLogo(imagePath.icLoginLogo)
                            .build(),
                          Padding(
                            padding: EdgeInsets.only(bottom: 24, top: 80),
                            child: StoreConnector<AppState, dartz.Either<Failure, Success>>(
                              converter: (store) => store.state.authenticationState.viewState,
                              builder: (context, viewState) {
                                return Container(
                                  width: _responsiveUtils.getWidthLoginTextBuilder(context),
                                  child: CenterTextBuilder()
                                    .key(Key('login_message'))
                                    .text(_getLoginMessage(viewState))
                                    .textStyle(_getLoginMessageTextStyle(viewState))
                                    .build(),
                                );
                              }
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: StoreConnector<AppState, dartz.Either<Failure, Success>>(
                              converter: (store) => store.state.authenticationState.viewState,
                              builder: (context, viewState) {
                                return Container(
                                  width: _responsiveUtils.getWidthLoginTextBuilder(context),
                                  child: LoginTextBuilder()
                                    .key(Key('login_url_input'))
                                    .onChange((value) => loginViewModel.setUrlText(value))
                                    .textInputAction(TextInputAction.next)
                                    .textDecoration(_buildUrlInputDecoration(viewState))
                                    .build(),
                                );
                              }
                            )
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: StoreConnector<AppState, dartz.Either<Failure, Success>>(
                              converter: (store) => store.state.authenticationState.viewState,
                              builder: (context, viewState) {
                                return Container(
                                  width: _responsiveUtils.getWidthLoginTextBuilder(context),
                                  child: LoginTextBuilder()
                                    .key(Key('login_email_input'))
                                    .onChange((value) => loginViewModel.setEmailText(value))
                                    .textInputAction(TextInputAction.next)
                                    .textDecoration(
                                      _buildCredentialInputDecoration(
                                          viewState,
                                          AppLocalizations.of(context).email,
                                          AppLocalizations.of(context).email))
                                    .build(),
                                );
                              }
                            )
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 24),
                            child: StoreConnector<AppState, dartz.Either<Failure, Success>>(
                              converter: (store) => store.state.authenticationState.viewState,
                              builder: (context, viewState) {
                                return Container(
                                  width: _responsiveUtils.getWidthLoginTextBuilder(context),
                                  child: LoginTextBuilder()
                                    .key(Key('login_password_input'))
                                    .obscureText(true)
                                    .onChange((value) => loginViewModel.setPasswordText(value))
                                    .textInputAction(TextInputAction.done)
                                    .textDecoration(
                                      _buildCredentialInputDecoration(
                                        viewState,
                                        AppLocalizations.of(context).password,
                                        AppLocalizations.of(context).password))
                                    .build(),
                                );
                              }
                            )
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 24),
                            child: StoreConnector<AppState, AuthenticationState>(
                              converter: (store) => store.state.authenticationState,
                              builder: (context, authenticationState) =>
                              authenticationState.isAuthenticationLoading()
                                  ? loadingCircularProgress()
                                  : loginButton(context)),
                          )
                        ],
                      ),
                    ),
                  )
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  
  String _getLoginMessage(dartz.Either<Failure, Success> viewState) {
    return viewState.fold(
        (failure) => _getErrorMessage(failure),
        (success) => AppLocalizations.of(context).login_text_login_to_continue);
  }

  TextStyle _getLoginMessageTextStyle(dartz.Either<Failure, Success> viewState) {
    final messageColor = viewState.fold(
        (failure) => AppColor.loginTextFieldErrorBorder,
        (success) => Colors.white);
    return TextStyle(color: messageColor);
  }
  
  String _getErrorMessage(Failure failure) {
    if (failure is AuthenticationFailure) {
      if (failure.authenticationException is UnknownError) {
        return AppLocalizations.of(context).unknown_error_login_message;
      } else if (_checkCredentialError(failure)) {
        return AppLocalizations.of(context).credential_error_message;
      } else if (_checkUrlError(failure)) {
        return AppLocalizations.of(context).wrong_url_message;
      }
    }
    return AppLocalizations.of(context).unknown_error_login_message;
  }

  InputDecoration _buildUrlInputDecoration(dartz.Either<Failure, Success> viewState) {
    final loginInputDecorationBuilder = viewState.fold(
        (failure) {
          if (_checkUrlError(failure)) {
              return LoginInputDecorationBuilder()
                  .labelText(AppLocalizations.of(context).https)
                  .prefixText(AppLocalizations.of(context).https)
                  .enabledBorder(OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                      borderSide: BorderSide(
                      width: 1, color: AppColor.loginTextFieldErrorBorder)));
          }
          return LoginInputDecorationBuilder()
              .labelText(AppLocalizations.of(context).https)
              .prefixText(AppLocalizations.of(context).https);
        },
        (success) => LoginInputDecorationBuilder()
            .labelText(AppLocalizations.of(context).https)
            .prefixText(AppLocalizations.of(context).https));
    return loginInputDecorationBuilder.build();
  }

  bool _checkUrlError(Failure failure) {
    if (failure is AuthenticationFailure) {
      return failure.authenticationException is ServerNotFound ||
          failure.authenticationException is ConnectError ||
          failure.authenticationException is UnknownError;
    }
    return false;
  }

  InputDecoration _buildCredentialInputDecoration(
      dartz.Either<Failure, Success> viewState,
      String labelText,
      String hintText
  ) {
    final loginInputDecorationBuilder = viewState.fold(
        (failure) {
          if (_checkCredentialError(failure)) {
            return LoginInputDecorationBuilder()
                .labelText(labelText)
                .hintText(hintText)
                .enabledBorder(OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                    borderSide: BorderSide(
                    width: 1, color: AppColor.loginTextFieldErrorBorder)));
          }
          return LoginInputDecorationBuilder().labelText(labelText).hintText(hintText);
        },
        (success) => LoginInputDecorationBuilder().labelText(labelText).hintText(hintText));
    return loginInputDecorationBuilder.build();
  }

  bool _checkCredentialError(Failure failure) {
    if (failure is AuthenticationFailure) {
      return failure.authenticationException is BadCredentials ||
          failure.authenticationException is UserLocked  ||
          failure.authenticationException is UnknownError ;
    }
    return false;
  }

  String _getCredentialErrorMessage(
      AuthenticationFailure authenticationFailure) {
    var authenException = authenticationFailure.authenticationException;
    return authenException is UserLocked
        ? AppLocalizations.of(context).user_locked_message
        : AppLocalizations.of(context).credential_error_message;
  }

  Widget loadingCircularProgress() {
    return SizedBox(
      key: Key('login_loading_icon'),
      width: 40,
      height: 40,
      child: CircularProgressIndicator(),
    );
  }

  Widget loginButton(BuildContext context) {
    return SizedBox(
      key: Key('login_confirm_button'),
      width: _responsiveUtils.getWidthLoginButton(),
      height: 48,
      child: RaisedButton(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(80),
          side: BorderSide(width: 0, color: AppColor.loginButtonColor),
        ),
        onPressed: () {
          FocusScope.of(context).unfocus();
          loginViewModel.handleLoginPressed();
        },
        color: AppColor.loginButtonColor,
        textColor: Colors.white,
        child: Text(AppLocalizations.of(context).login_button_login,
            style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }
}
