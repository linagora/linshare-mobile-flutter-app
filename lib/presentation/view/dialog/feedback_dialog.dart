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
//

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/helper/responsive_utils.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';

typedef FeedbackDialogButtonAction = void Function();

class FeedbackDialog {
  final _imagePath = getIt<AppImagePaths>();
  final _responsiveUtils = getIt<ResponsiveUtils>();
  final AppNavigation _appNavigation;
  final BuildContext _context;

  Key? _key;
  String _title = '';
  String _content = '';
  String _actionText = '';

  FeedbackDialogButtonAction? _feedbackDialogButtonAction;

  FeedbackDialog(this._context, this._appNavigation);

  void key(Key key) {
    _key = key;
  }

  void title(String title) {
    _title = title;
  }

  void content(String content) {
    _content = content;
  }

  void actionText(String actionText) {
    _actionText = actionText;
  }

  void addFeedbackDialogButtonAction(FeedbackDialogButtonAction feedbackDialogButtonAction) {
    _feedbackDialogButtonAction = feedbackDialogButtonAction;
  }

  Widget build() {
    return Dialog(
      key: _key ?? Key('FeedbackDialog'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18))),
      insetPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 24.0),
      child: Container(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        width: _responsiveUtils.isSmallScreen(_context) ? double.infinity : _responsiveUtils.getWidthLoginButton(),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(18))),
        child: Stack(children: [
          Wrap(children: [
            Padding(
              padding: EdgeInsets.only(top: 48),
              child: Center(child: Text(_title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20.0, color: Colors.black, fontWeight: FontWeight.bold)))),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              child: Center(
                child: Text(_content,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.0, color: AppColor.loginLabelInputColor)),
              ),
            ),
            Padding(
                padding: EdgeInsets.only(bottom: 16, left: 16, right: 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _feedbackDialogButtonAction?.call(),
                  style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) => AppColor.loginDefaultButtonColor,
                      ),
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) => AppColor.loginDefaultButtonColor,
                      ),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(width: 0, color: AppColor.loginDefaultButtonColor),
                      )),
                      padding: MaterialStateProperty.resolveWith<EdgeInsets>(
                          (Set<MaterialState> states) => EdgeInsets.symmetric(horizontal: 16),
                      ),
                      elevation: MaterialStateProperty.resolveWith<double>((Set<MaterialState> states) => 0)),
                  child: Text(_actionText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Colors.white)),
                ),
              ))
          ]),
          Positioned(
            right: 0,
            child: IconButton(
              iconSize: 30,
              padding: EdgeInsets.only(top: 10, right: 10),
              onPressed: () => _appNavigation.popBack(),
              icon: SvgPicture.asset(_imagePath.icCloseDialog, width: 28, height: 28, fit: BoxFit.fill)))
        ]),
      ),
    );
  }
}
