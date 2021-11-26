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
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/signup_authentication_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/helper/responsive_utils.dart';
import 'package:linshare_flutter_app/presentation/view/text/login_text_input_builder.dart';
import 'package:linshare_flutter_app/presentation/view/text/rich_text_builder.dart';
import 'package:linshare_flutter_app/presentation/view/text/text_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/login/login_form_type.dart';
import 'package:linshare_flutter_app/presentation/widget/sign_up/sign_up_authentication_type.dart';
import 'package:linshare_flutter_app/presentation/widget/sign_up/sign_up_form_type.dart';
import 'package:linshare_flutter_app/presentation/widget/sign_up/sign_up_viewmodel.dart';

class SignUpWidget extends StatefulWidget {
  @override
  _SignUpWidgetState createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  final _viewModel = getIt<SignUpViewModel>();
  final _imagePath = getIt<AppImagePaths>();
  final _responsiveUtils = getIt<ResponsiveUtils>();

  @override
  void dispose() {
    _viewModel.onDisposed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColor.loginBackgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Stack(
            children: [
              Container(
                alignment: AlignmentDirectional.center,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: Image(
                        image: AssetImage(_imagePath.icLoginLogoStandard),
                        fit: BoxFit.fill,
                        width: 150,
                        alignment: Alignment.center)),
                    Expanded(child: StoreConnector<AppState, SignUpAuthenticationState>(
                      converter: (store) => store.state.signUpAuthenticationState,
                      builder: (context, state) {
                        switch(state.signUpFormType) {
                          case SignUpFormType.main:
                            return _buildMainSignUpForm();
                          case SignUpFormType.fillName:
                            return _buildFillNameForm(context);
                          case SignUpFormType.completed:
                            return _buildSignUpCompletedForm(context, state);
                          default:
                            return _buildMainSignUpForm();
                        }
                      }
                    )),
                  ],
                ),
              ),
              StoreConnector<AppState, SignUpFormType>(
                converter: (store) => store.state.signUpAuthenticationState.signUpFormType,
                builder: (context, loginFormType) => Positioned(
                  right: 10,
                  child: IconButton(
                    key: Key('sign_up_close_button'),
                    onPressed: () => _viewModel.handleCloseSignUpPressed(context),
                    icon: SvgPicture.asset(_imagePath.icLoginClose, width: 18, height: 18, fit: BoxFit.fill)
                  ))
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
    } else if (failure is GetSecretTokenFailure) {
      if (failure.exception is UnknownError) {
        return AppLocalizations.of(context).unknown_error_login_message;
      } else if (_checkCredentialError(failure.exception)) {
        return _getCredentialErrorMessage(failure.exception);
      } else if (_checkUrlError(failure.exception)) {
        return AppLocalizations.of(context).wrong_url_message;
      } else {
        return AppLocalizations.of(context).unknown_error_login_message;
      }
    } else if (failure is SignUpForSaaSFailure) {
      if (failure.exception is UnknownError) {
        return AppLocalizations.of(context).unknown_error_login_message;
      } else if (_checkCredentialError(failure.exception)) {
        return _getCredentialErrorMessage(failure.exception);
      } else if (_checkUrlError(failure.exception)) {
        return AppLocalizations.of(context).wrong_url_message;
      } else {
        return AppLocalizations.of(context).unknown_error_login_message;
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

  Widget _buildSignUpButton(BuildContext context, SignUpFormType formType, SignUpAuthenticationType authenticationType) {
    return SizedBox(
      key: Key('sign_up_${formType.toString()}_${authenticationType.toString()}_confirm_button'),
      width: _getWidthButton(context),
      height: 48,
      child: ElevatedButton(
        onPressed: () => _viewModel.handleSignUpPressed(context, formType, authenticationType),
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) => Colors.white,
          ),
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) => AppColor.loginDefaultButtonColor,
          ),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
                width: 0,
                color: AppColor.loginDefaultButtonColor),
          )),
          elevation: MaterialStateProperty.resolveWith<double>((Set<MaterialState> states) => 0)
        ),
        child: Text(
          authenticationType == SignUpAuthenticationType.sendEmail
              ? AppLocalizations.of(context).sign_up_continue
              : AppLocalizations.of(context).sign_up_send_me_a_password,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.normal,
            color: Colors.white)),
      ),
    );
  }

  Widget _signUpCompletedContinueButton(BuildContext context, SignUpAuthenticationState state) {
    return SizedBox(
      key: Key('sign_up_completed_continue_button'),
      width: _getWidthButton(context),
      height: 48,
      child: ElevatedButton(
        onPressed: () => _viewModel.loginToSaaS(context, state.saaSConfiguration!.loginBaseUrl),
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
          AppLocalizations.of(context).sign_up_continue,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17, color: AppColor.loginDefaultButtonColor, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildMainSignUpForm() {
    return Column(
      children: [
        Padding(
        padding: EdgeInsets.only(
            top: 80,
            left: _getPaddingHorizontal(context),
            right: _getPaddingHorizontal(context)),
        child: Container(
          width: _getWidthButton(context),
          child: StoreConnector<AppState, dartz.Either<Failure, Success>>(
              converter: (store) => store.state.signUpAuthenticationState.viewState,
              builder: (context, viewState) => (LoginTextInputBuilder(context, _imagePath)
                  ..key(Key('sign_up_email_input'))
                  ..onChange((value) => _viewModel.setEmailText(value))
                  ..textInputAction(TextInputAction.next)
                  ..title(AppLocalizations.of(context).login_email_title)
                  ..errorText(_viewModel.getErrorInputString(viewState, context, InputType.email))
                  ..setErrorString((value) => _viewModel.getErrorValidatorString(context, value, InputType.email))
                  ..hintText(AppLocalizations.of(context).hint_input_email_login)
                  ..labelText(AppLocalizations.of(context).hint_input_email_login))
                .build()),
        )),
        StoreConnector<AppState, SignUpAuthenticationState>(
          converter: (store) => store.state.signUpAuthenticationState,
          builder: (context, signUpAuthenticationState) =>
            Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: _getPaddingHorizontal(context),
                right: _getPaddingHorizontal(context)),
              child: signUpAuthenticationState.isSignUpAuthenticationLoading()
                ? _loadingCircularProgress()
                : _buildSignUpButton(context, SignUpFormType.main, SignUpAuthenticationType.sendEmail))),
      ],
    );
  }

  Widget _buildFillNameForm(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: 80,
            left: _getPaddingHorizontal(context),
            right: _getPaddingHorizontal(context)),
          child: Container(
            width: _getWidthButton(context),
            child: StoreConnector<AppState, dartz.Either<Failure, Success>>(
              converter: (store) => store.state.signUpAuthenticationState.viewState,
              builder: (context, viewState) => (LoginTextInputBuilder(context, _imagePath)
                    ..key(Key('login_name_input'))
                    ..onChange((value) => _viewModel.setNameText(value))
                    ..textInputAction(TextInputAction.next)
                    ..title(AppLocalizations.of(context).sign_up_name_title)
                    ..errorText(_viewModel.getErrorInputString(viewState, context, InputType.name))
                    ..setErrorString((value) => _viewModel.getErrorValidatorString(context, value, InputType.name))
                    ..hintText(AppLocalizations.of(context).hint_input_sign_up_name)
                    ..labelText(AppLocalizations.of(context).hint_input_sign_up_name))
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
              converter: (store) => store.state.signUpAuthenticationState.viewState,
              builder: (context, viewState) => (LoginTextInputBuilder(context, _imagePath)
                    ..key(Key('login_surname_input'))
                    ..onChange((value) => _viewModel.setSurnameText(value))
                    ..textInputAction(TextInputAction.next)
                    ..title(AppLocalizations.of(context).sign_up_surname_title)
                    ..errorText(_viewModel.getErrorInputString(viewState, context, InputType.surname))
                    ..setErrorString((value) => _viewModel.getErrorValidatorString(context, value, InputType.surname))
                    ..hintText(AppLocalizations.of(context).hint_input_sign_up_surname)
                    ..labelText(AppLocalizations.of(context).hint_input_sign_up_surname))
                .build()),
          )),
        StoreConnector<AppState, dartz.Either<Failure, Success>>(
          converter: (store) => store.state.signUpAuthenticationState.viewState,
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
              bottom: 24,
              left: _getPaddingHorizontal(context),
              right: _getPaddingHorizontal(context)),
            child: StoreConnector<AppState, SignUpAuthenticationState>(
              converter: (store) => store.state.signUpAuthenticationState,
              builder: (context, signUpAuthenticationState) => signUpAuthenticationState.isSignUpAuthenticationLoading()
                ? _loadingCircularProgress()
                : _buildSignUpButton(context, SignUpFormType.fillName, SignUpAuthenticationType.sendPassword))),
      ],
    );
  }

  Widget _buildSignUpCompletedForm(BuildContext context, SignUpAuthenticationState state) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: 80,
            left: _getPaddingHorizontal(context),
            right: _getPaddingHorizontal(context)),
          child: Center(
            child: SvgPicture.asset(
              _imagePath.icEmailSentSignUp,
              width: 120,
              fit: BoxFit.fill))),
        Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: _getPaddingHorizontal(context),
            right: _getPaddingHorizontal(context)),
          child: Container(
            width: _getWidthButton(context),
            child: CenterTextBuilder()
              .text(AppLocalizations.of(context).sign_up_completed_title_center)
              .textStyle(TextStyle(fontSize: 20, color: AppColor.loginLabelTextFieldColor, fontWeight: FontWeight.bold))
              .build())),
        Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: _getPaddingHorizontal(context),
            right: _getPaddingHorizontal(context)),
          child: Container(
            width: _getWidthButton(context),
            child: (RichTextBuilder(
                    AppLocalizations.of(context).sign_up_completed_message_center(state.userSaaS?.email ?? ''),
                    '${state.userSaaS?.email ?? ''}',
                    TextStyle(fontSize: 14, color: AppColor.backLoginColor, fontWeight: FontWeight.normal),
                    TextStyle(fontSize: 14, color: AppColor.loginDefaultButtonColor, fontWeight: FontWeight.normal))
                ..maxLines(5)
                ..setOverflow(null))
              .build())),
        Spacer(),
        Padding(
          padding: EdgeInsets.only(
            top: 30,
            bottom: 80,
            left: _getPaddingHorizontal(context),
            right: _getPaddingHorizontal(context)),
          child: StoreConnector<AppState, SignUpAuthenticationState>(
            converter: (store) => store.state.signUpAuthenticationState,
            builder: (context, signUpAuthenticationState) => signUpAuthenticationState.isSignUpAuthenticationLoading()
                ? _loadingCircularProgress()
                : _signUpCompletedContinueButton(context, state))),
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