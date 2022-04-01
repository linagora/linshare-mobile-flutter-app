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

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/view/toolbar/toolbar_builder.dart' as toolbar;
import 'package:linshare_flutter_app/presentation/widget/second_factor_authentication/second_factor_authentication_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/second_factor_authentication/second_factor_authentication_viewmodel.dart';

class SecondFactorAuthenticationWidget extends StatelessWidget {
  final imagePath = getIt<AppImagePaths>();
  final viewModel = getIt<SecondFactorAuthenticationViewModel>();

  @override
  Widget build(BuildContext context) {
    var arguments = ModalRoute.of(context)?.settings.arguments as SecondFactorAuthenticationArguments;
    viewModel.setSecondFactorAuthenticationArguments(arguments);

    return Scaffold(
        backgroundColor: AppColor.primaryColor, body: _buildBody(context));
  }

  Widget _buildBody(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          LayoutBuilder(
          builder: (context, constraint) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraint.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(top: 100),
                      child: Column(
                        children: [
                          ..._buildLinShareLogo(context),
                          SizedBox(height: 80),
                          _buildSetup2FA(context)
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
          ),
          toolbar.ToolbarBuilder(
              Key('two_fa_setup_arrow_back_button'),
              contentPadding: EdgeInsets.only(left: 10),
              actionIcon: imagePath.icArrowBack,
              onButtonActionClick: () => viewModel.onBackPressed())
              .build(),
        ],
      ),
    );
  }

  List<Widget> _buildLinShareLogo(BuildContext context) {
    return <Widget>[
      Image(
          image: AssetImage(imagePath.icLoginLogo),
          alignment: Alignment.center),
      Padding(
        padding: EdgeInsets.only(top: 16, left: 16, right: 16),
        child: Text(
          AppLocalizations.of(context).login_text_slogan,
          style: TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    ];
  }

  Widget _buildSetup2FA(BuildContext context) {
    return Expanded(
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding:
                  EdgeInsets.only(top: 36.0, left: 65, right: 65, bottom: 23),
              child: Text(
                AppLocalizations.of(context)
                    .second_factor_authentication_is_required_for_your_account,
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: AppColor.loginButtonColor, fontSize: 16),
              ),
            ),
            SvgPicture.asset(
              imagePath.icSecurity,
              width: 60,
              height: 74,
              color: AppColor.primaryColor,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 22),
              child: Text(
                AppLocalizations.of(context)
                    .please_enable_second_factor_authentication_to_continue,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColor.networkConnectionBackgroundColor,
                    fontSize: 15),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 67),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: RaisedButton(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(80),
                    side:
                        BorderSide(width: 0, color: AppColor.loginButtonColor),
                  ),
                  onPressed: () => viewModel.goToSetup2FA(),
                  color: AppColor.loginButtonColor,
                  textColor: Colors.white,
                  child: Text(AppLocalizations.of(context).go_to_setup,
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
