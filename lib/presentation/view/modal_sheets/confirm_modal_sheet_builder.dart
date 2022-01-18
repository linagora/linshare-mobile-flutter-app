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
// <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf
//
// for more details.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for
// more details.
// You should have received a copy of the GNU Affero General Public License and its
// applicable Additional Terms for LinShare along with this program. If not, see
// <http://www.gnu.org/licenses
// for the GNU Affero General Public License version
//
// 3 and <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf
// for
//
// the Additional Terms applicable to LinShare software.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/helper/responsive_utils.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';

typedef OnConfirmActionClick = void Function(bool?);

class ConfirmModalSheetBuilder {
  final responsiveUtils = getIt<ResponsiveUtils>();

  @protected
  final AppNavigation _appNavigation;

  @protected
  late Key _key;
  @protected
  String _title = '';
  @protected
  String _cancelText = '';
  @protected
  String _confirmText = '';
  @protected
  late OnConfirmActionClick _onConfirmActionClick;

  @protected
  String? _optionalCheckboxString;

  var isOptionalCheckboxChecked = false;

  ConfirmModalSheetBuilder(this._appNavigation);

  ConfirmModalSheetBuilder key(Key key) {
    _key = key;
    return this;
  }

  ConfirmModalSheetBuilder title(String title) {
    _title = title;
    return this;
  }

  ConfirmModalSheetBuilder cancelText(String cancelText) {
    _cancelText = cancelText;
    return this;
  }

  ConfirmModalSheetBuilder onConfirmAction(
      String confirmText, OnConfirmActionClick onConfirmActionClick) {
    _onConfirmActionClick = onConfirmActionClick;
    _confirmText = confirmText;
    return this;
  }

  ConfirmModalSheetBuilder optionalCheckbox(String? checkboxName) {
    _optionalCheckboxString = checkboxName;
    return this;
  }

  Widget _buildCheckboxRow() {
    return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return CheckboxListTile(
          dense: true,
          activeColor: AppColor.primaryColor,
          contentPadding: EdgeInsets.symmetric(horizontal: 36),
          title: Text(_optionalCheckboxString ?? '', style: TextStyle(
            color: AppColor.deleteMemberIconColor,
            fontSize: 12
          )),
          value: isOptionalCheckboxChecked,
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (bool? value) => setState(() {
                isOptionalCheckboxChecked = value!;
              }));
    });
  }

  RoundedRectangleBorder _shape() {
    return RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0)
        )
    );
  }

  BoxDecoration _decoration(BuildContext context) {
    return BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20.0),
            topRight: const Radius.circular(20.0)));
  }

  void show(context) {
    showModalBottomSheet(
        useRootNavigator: true,
        shape: _shape(),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: SingleChildScrollView(
                  child: Container(
                      key: _key,
                      padding: EdgeInsets.all(20),
                      margin: responsiveUtils.getMarginContextMenuForScreen(context),
                      decoration: _decoration(context),
                      child: GestureDetector(
                          onTap: () => {},
                          child: Wrap(
                            children: [
                              Padding(
                                  padding: EdgeInsets.only(left: 50, right: 50, top: 48, bottom: 19),
                                  child: Text(
                                    _title,
                                    style: TextStyle(fontSize: 16, color: AppColor.confirmDialogTitleTextColor),
                                    textAlign: TextAlign.center,
                                  )),
                              if ((_optionalCheckboxString != null && _optionalCheckboxString!.isNotEmpty)) _buildCheckboxRow(),
                              Padding(
                                  padding: EdgeInsets.only(top: 20),
                                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                          primary: AppColor.documentNameItemTextColor,
                                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                                      onPressed: () => _appNavigation.popBack(),
                                      child: Text(_cancelText, style: TextStyle(fontSize: 14)),
                                    ),
                                    OutlinedButton(
                                        onPressed: () => _onConfirmActionClick(isOptionalCheckboxChecked),
                                        style: OutlinedButton.styleFrom(
                                            primary: Colors.white,
                                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                                            backgroundColor: AppColor.toastErrorBackgroundColor,
                                            shape:
                                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                                        child: Text(_confirmText))
                                  ])
                              ),
                            ],
                          )
                      )
                  )
              )
          );
        }
    );
  }
}
