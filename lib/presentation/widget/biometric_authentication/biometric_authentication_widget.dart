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
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/biometric_authentication_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';

import 'biometric_authentication_viewmodel.dart';

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
    WidgetsBinding.instance.addObserver(this);
    _biometricAuthenticationViewModel.getBiometricSetting();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  WillPopScope(
      onWillPop: () async {
        _biometricAuthenticationViewModel.backToAccountDetail();
        return false;
      },
      child: StoreConnector<AppState, BiometricAuthenticationState>(
        converter: (store) => store.state.biometricAuthenticationState,
        builder: (context, biometricState) => Scaffold(
          appBar: AppBar(
            leading: IconButton(
              key: Key('biometric_authentication_arrow_back_button'),
              icon: Image.asset(_imagePath.icArrowBack),
              onPressed: () => _biometricAuthenticationViewModel.backToAccountDetail()),
            centerTitle: true,
            title: Text(
              AppLocalizations.of(context).biometric_authentication,
              key: Key('biometric_authentication_title'),
              style: TextStyle(fontSize: 24, color: Colors.white)),
            backgroundColor: AppColor.primaryColor),
          body: Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context).biometric_authentication,
                      style: TextStyle(fontSize: 16, color: AppColor.documentNameItemTextColor)),
                    GestureDetector(
                      onTap: () => biometricState.authenticationBiometricState == AuthenticationBiometricState.unEnrolled
                        ? {}
                        : _biometricAuthenticationViewModel.toggleBiometricState(context),
                      child: SvgPicture.asset(
                        _getIconBiometricAuthenticationState(biometricState),
                        width: 52,
                        height: 32,
                        fit: BoxFit.fill))
                  ]
                ),
                Padding(
                  padding: EdgeInsets.only(top: 14),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppLocalizations.of(context).biometric_authentication_message(AppLocalizations.of(context).fingerprint),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 16,
                          color: AppColor.documentModifiedDateItemTextColor))
                  )),
                biometricState.authenticationBiometricState == AuthenticationBiometricState.unEnrolled
                  ? Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppLocalizations.of(context).biometric_authentication_not_enrolled(AppLocalizations.of(context).fingerprint),
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 16, color: AppColor.statusUploadFailedSubTitleColor))))
                  : SizedBox.shrink()
              ])
          )
        )
      )
    );
  }

  String _getIconBiometricAuthenticationState(BiometricAuthenticationState biometricState) {
    if (biometricState.authenticationBiometricState == AuthenticationBiometricState.unEnrolled) {
      return _imagePath.icSwitchDisabled;
    } else {
      return biometricState.biometricState == BiometricState.enabled ? _imagePath.icSwitchOn : _imagePath.icSwitchOff;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _biometricAuthenticationViewModel.checkBiometricState(context);
    }
  }
}