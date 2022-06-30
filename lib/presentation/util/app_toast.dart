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
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';

class AppToast {
  void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        fontSize: 16,
        textColor: Colors.white,
        backgroundColor: AppColor.toastBackgroundColor,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM);
  }

  void showErrorToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        fontSize: 16,
        textColor: Colors.white,
        backgroundColor: AppColor.toastErrorBackgroundColor,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM);
  }

  void showToastWithIcon(BuildContext context, FToast fToast, String message, String leftIcon, {Duration? duration}) {
    fToast.init(context);
    fToast.showToast(
      toastDuration: duration ?? Duration(milliseconds: 1000),
      child: Material(
        color: Colors.white,
        elevation: 10,
        shadowColor: Colors.black54,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(leftIcon, width: 24, height: 24, fit: BoxFit.fill),
              Expanded(child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    message,
                    style: TextStyle(color: Colors.black, fontSize: 15.0, fontWeight: FontWeight.normal),
                  )
                )
              )
            ],
          ),
        ),
      ),
      gravity: ToastGravity.BOTTOM);
  }
}
