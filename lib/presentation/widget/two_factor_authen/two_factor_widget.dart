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
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/styles.dart';
import 'package:linshare_flutter_app/presentation/view/pin_code/pin_code_widget.dart';
import 'package:linshare_flutter_app/presentation/view/text/linshare_slogan_builder.dart';
import 'package:linshare_flutter_app/presentation/view/toolbar/toolbar_builder.dart';

final _titleTextStyle = CommonTextStyle.textStyleNormal.copyWith(color: AppColor.pinCodeTitleColor, fontSize: 16);
final _subTitleTextStyle = CommonTextStyle.textStyleNormal.copyWith(color: AppColor.pinCodeSubTitleColor, fontSize: 15);
final _padTextStyle = CommonTextStyle.textStyleNormal.copyWith(color: AppColor.pinCodePadTextColor, fontSize: 20);
final _errorTextStyle = CommonTextStyle.textStyleNormal.copyWith(color: AppColor.pinCodeErrorTextColor);
final _buttonActionTextStyle = CommonTextStyle.textStyleNormal.copyWith(color: AppColor.pinCodeSubmitButtonTextColor, fontSize: 16);

class TwoFactorAuthenticationWidget extends StatefulWidget {
  @override
  _TwoFactorAuthenticationWidgetState createState() => _TwoFactorAuthenticationWidgetState();
}

class _TwoFactorAuthenticationWidgetState extends State<TwoFactorAuthenticationWidget> {
  final imagePath = getIt<AppImagePaths>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: false,
      backgroundColor: AppColor.primaryColor,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Stack(children: [
            SingleChildScrollView(
              reverse: false,
              child: Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                  alignment: Alignment.topCenter,
                  padding: EdgeInsets.only(top: 100),
                  child: Column(
                    children: [
                      LinShareSloganBuilder()
                          .setSloganText(AppLocalizations.of(context).login_text_slogan)
                          .setSloganTextAlign(TextAlign.center)
                          .setSloganTextStyle(TextStyle(color: Colors.white, fontSize: 16))
                          .setLogo(imagePath.icLoginLogo)
                          .build(),
                      SizedBox(height: 80),
                      PinCodeWidget.twoFactorAuthen(
                        title: AppLocalizations.of(context).second_factor_authentication,
                        titleStyle: _titleTextStyle,
                        subTitle: AppLocalizations.of(context).input_6_digit_from_free_otp,
                        subTitleStyle: _subTitleTextStyle,
                        pinCodeFieldBackgroundColor: AppColor.primaryColor,
                        pinBackgroundColor: AppColor.pinCodePadBackgroundColor,
                        pinTextStyle: _padTextStyle,
                        errorText: AppLocalizations.of(context).please_fill_up_all_numbers,
                        errorStyle: _errorTextStyle,
                        buttonText: AppLocalizations.of(context).submit,
                        buttonBackgroundColor: AppColor.pinCodeSubmitButtonBGColor,
                        buttonStyle: _buttonActionTextStyle,
                        onButtonClick: _sendOtpToVerify
                      )
                    ],
                  ),
                ),
              ),
            ),
            ToolbarBuilder(
                Key('two_factor_arrow_back_button'),
                contentPadding: EdgeInsets.only(left: 10),
                actionIcon: imagePath.icArrowBack,
                onButtonActionClick: _handleBackPress)
                .build(),
          ]),
        ),
      ),
    );
  }

  // TODO: invoke popBack in view model
  void _handleBackPress() {
    print('back press...');
  }

  // TODO: stuff for calling to domain layer via view model
  void _sendOtpToVerify(String otpCode) {
    print('Sending... ' + otpCode);
  }
}
