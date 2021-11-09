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
import 'package:flutter/services.dart';
import 'package:linshare_flutter_app/presentation/model/file_size_type.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/styles.dart';
import 'package:linshare_flutter_app/presentation/util/value_notifier_common.dart';

class FileSizeInputFieldBuilder {

  final BuildContext context;
  Key? _key;
  String? _title;
  List<FileSizeType>? _listSizeType;

  TextEditingController? _controller;
  FileSizeValueNotifier? _onSizeTypeNotifier;

  FileSizeInputFieldBuilder(this.context);

  void setKey(Key? key) {
    _key = key;
  }

  void setTitle(String title) {
    _title = title;
  }

  void setListSizeType(List<FileSizeType>? listValue) {
    _listSizeType = listValue;
  }

  void addController(TextEditingController? controller) {
    _controller = controller;
  }

  void addOnSizeTypeNotifier(FileSizeValueNotifier? onSizeTypeNotifier) {
    _onSizeTypeNotifier = onSizeTypeNotifier;
  }

  Widget build() {
    return Row(
      key: _key,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(_title ?? '', style: CommonTextStyle.textStyleUploadRequestSettingsTitle),
        Row(children: [
          Container(
            width: 40.0,
            child: TextFormField(
              maxLength: 3,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.right,
              style: CommonTextStyle.textStyleUploadRequestSettingsValue,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(0),
                isDense: true,
                hintText: '0',
                counterText: '',
                hintStyle: TextStyle(color: AppColor.uploadRequestHintTextColor)),
                controller: _controller)),
          SizedBox(width: 16.0),
          ValueListenableBuilder(
            valueListenable: _onSizeTypeNotifier ?? FileSizeValueNotifier(),
            builder: (context, FileSizeType value, child) => DropdownButtonHideUnderline(
              child: DropdownButton<FileSizeType>(
                iconEnabledColor: AppColor.uploadRequestTextClickableColor,
                items: <FileSizeType>[..._listSizeType ?? []].map((FileSizeType value) {
                  return DropdownMenuItem<FileSizeType>(
                    value: value,
                    child: Text(
                      value.text,
                      style: CommonTextStyle.textStyleNormal.copyWith(color: AppColor.uploadRequestTextClickableColor)),
                  );
                }).toList(),
              onChanged: (value) => _onSizeTypeNotifier?.value = value ?? FileSizeType.GB,
              value: value)),
            )
        ])
      ],
    );
  }
}