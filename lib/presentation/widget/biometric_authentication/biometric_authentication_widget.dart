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

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/biometric_authentication_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/authentication_biometric_state_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/list_biometric_kind_extension.dart';
import 'package:linshare_flutter_app/presentation/view/text/linshare_slogan_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/biometric_authentication/biometric_authentication_viewmodel.dart';

class BiometricAuthenticationWidget extends StatefulWidget {
  @override
  _BiometricAuthenticationState createState() => _BiometricAuthenticationState();
}

class _BiometricAuthenticationState extends State<BiometricAuthenticationWidget>  with WidgetsBindingObserver {
  final _biometricAuthenticationViewModel = getIt<BiometricAuthenticationViewModel>();
  final _imagePath = getIt<AppImagePaths>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _biometricAuthenticationViewModel.getAvailableBiometric(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, biometricState) => Scaffold(
        backgroundColor: AppColor.primaryColor,
        body: _buildBody(context)
      )
    );
  }

  Widget _buildBody(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: 100),
              child: Column(
                children: [
                  LinShareSloganBuilder()
                      .setSloganText(AppLocalizations.of(context).login_text_slogan)
                      .setSloganTextAlign(TextAlign.center)
                      .setSloganTextStyle(TextStyle(color: Colors.white, fontSize: 16))
                      .setLogo(_imagePath.icLoginLogo)
                      .build(),
                  SizedBox(height: 80),
                  _buildSetupBiometric(context)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupBiometric(BuildContext context) {
    return StoreConnector<AppState, BiometricAuthenticationState>(
      converter: (store) => store.state.biometricAuthenticationState,
      builder: (context, biometricState) => Expanded(
        child: Container(
          width: double.infinity,
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 36.0, left: 65, right: 65, bottom: 20),
                child: Text(
                  biometricState.authenticationBiometricState.getBiometricStatusName(context, biometricState.biometricKindList),
                  textAlign: TextAlign.center,
                  style:
                  TextStyle(color: _getColorTextBiometric(biometricState), fontSize: 16),
                ),
              ),
              GestureDetector(
                  onTap: () => _onBiometricClickAction(biometricState),
                  child: SvgPicture.asset(
                    biometricState.biometricKindList.getBiometricIcon(_imagePath),
                    width: biometricState.biometricKindList.getBiometricIconSize(),
                    height: biometricState.biometricKindList.getBiometricIconSize(),
                    color: _getColorIconBiometric(biometricState),
                  )
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 25),
                child: Text(
                  AppLocalizations.of(context).or,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColor.documentNameItemTextColor, fontSize: 16),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 70),
                  child: GestureDetector(
                      onTap: () => _biometricAuthenticationViewModel.gotoSignIn(),
                      child: Text(
                        AppLocalizations.of(context).go_to_sign_in,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColor.toastBackgroundColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w400
                        ),
                      )
                  )
              )
            ])
        ),
      )
    );
  }

  void _onBiometricClickAction(BiometricAuthenticationState biometricState) {
    return biometricState.authenticationBiometricState.isAuthenticateReady()
        ? _biometricAuthenticationViewModel.authenticationBiometric(context)
        : {};
  }

  Color _getColorIconBiometric(BiometricAuthenticationState biometricState) {
    return biometricState.authenticationBiometricState.isAuthenticateReady()
      ? AppColor.defaultLabelAvatarBackgroundColor
      : AppColor.uploadButtonDisableBackgroundColor;
  }

  Color _getColorTextBiometric(BiometricAuthenticationState biometricState) {
    return biometricState.authenticationBiometricState.isAuthenticateReady()
      ? AppColor.loginTextFieldTextColor
      : AppColor.toastErrorBackgroundColor;
  }
}