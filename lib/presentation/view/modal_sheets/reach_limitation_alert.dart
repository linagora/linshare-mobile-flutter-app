/*
 * LinShare is an open source filesharing software, part of the LinPKI software
 * suite, developed by Linagora.
 *
 * Copyright (C) 2022 LINAGORA
 *
 * This program is free software: you can redistribute it and/or modify it under the
 * terms of the GNU Affero General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version,
 * provided you comply with the Additional Terms applicable for LinShare software by
 * Linagora pursuant to Section 7 of the GNU Affero General Public License,
 * subsections (b), (c), and (e), pursuant to which you must notably (i) retain the
 * display in the interface of the “LinShare™” trademark/logo, the "Libre & Free" mention,
 * the words “You are using the Free and Open Source version of LinShare™, powered by
 * Linagora © 2009–2021. Contribute to Linshare R&D by subscribing to an Enterprise
 * offer!”. You must also retain the latter notice in all asynchronous messages such as
 * e-mails sent with the Program, (ii) retain all hypertext links between LinShare and
 * http://www.linshare.org, between linagora.com and Linagora, and (iii) refrain from
 * infringing Linagora intellectual property rights over its trademarks and commercial
 * brands. Other Additional Terms apply, see
 * <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf>
 * for more details.
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for
 * more details.
 * You should have received a copy of the GNU Affero General Public License and its
 * applicable Additional Terms for LinShare along with this program. If not, see
 * <http://www.gnu.org/licenses/> for the GNU Affero General Public License version
 *  3 and <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf> for
 *  the Additional Terms applicable to LinShare software.
 */

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/helper/responsive_utils.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';

typedef OnContactNowPress = void Function();

class ReachLimitationAlert extends StatelessWidget {
  final _imagePath = getIt<AppImagePaths>();
  final _responsiveUtils = getIt<ResponsiveUtils>();

  ReachLimitationAlert(this.title,
      this._content,
      this._actionText,
      this._appNavigation, {
      Key? key,
      this.onContactNowPress
  }) : super(key: key);

  final String title;
  final String _content;
  final String _actionText;
  final AppNavigation _appNavigation;
  final OnContactNowPress? onContactNowPress;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      width: _responsiveUtils.isSmallScreen(context) ? double.infinity : _responsiveUtils.getWidthLoginButton(),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(18))),
      child: Stack(children: [
        Wrap(children: [
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Center(
                child: SvgPicture.asset(_imagePath.icWarningLimitation, width: 68, height: 68, fit: BoxFit.fill)
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 16, top: 24),
            child: Center(child: Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20.0, color: Colors.black, fontWeight: FontWeight.bold)))),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 16, top: 8),
            child: Center(
              child: Text(_content,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.0, color: AppColor.loginLabelInputColor, fontWeight: FontWeight.w400)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16, top: 24),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              ElevatedButton(
                onPressed: () => _appNavigation.popBack(),
                style: ElevatedButton.styleFrom(
                  fixedSize: Size.fromHeight(48),
                  primary: AppColor.closeButtonBackgroundColor,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide.none
                  ),
                  elevation: 0),
                child: Text(AppLocalizations.of(context).close,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: AppColor.primaryColor)),
              ),
              OutlinedButton(
                onPressed: () => onContactNowPress?.call(),
                style: OutlinedButton.styleFrom(
                  fixedSize: Size.fromHeight(48),
                  primary: AppColor.loginDefaultButtonColor,
                  backgroundColor: AppColor.loginDefaultButtonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide.none,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                ),
                child: Text(_actionText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.white
                  )
                ),
              )
            ])
          )
        ]),
        Positioned(
            right: 0,
            child: IconButton(
                iconSize: 30,
                padding: EdgeInsets.only(top: 10, right: 10),
                onPressed: () => _appNavigation.popBack(),
                icon: SvgPicture.asset(_imagePath.icCloseDialog, width: 28, height: 28, fit: BoxFit.fill)))
      ]),
    );
  }
}
