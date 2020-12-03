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

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';

class DownloadingFileBuilder {
  final CancelToken cancelToken;
  final AppNavigation _appNavigation;

  Key _key;
  String _title = '';
  String _content = '';
  String _actionText = '';

  DownloadingFileBuilder(this.cancelToken, this._appNavigation);

  DownloadingFileBuilder key(Key key) {
    _key = key;
    return this;
  }

  DownloadingFileBuilder title(String title) {
    _title = title;
    return this;
  }

  DownloadingFileBuilder content(String content) {
    _content = content;
    return this;
  }

  DownloadingFileBuilder actionText(String actionText) {
    _actionText = actionText;
    return this;
  }

  Widget build() {
    return CupertinoAlertDialog(
      key: _key,
      title: Text(_title, style: TextStyle(fontSize: 17.0, color: Colors.black),),
      content: Padding(
        padding: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
        child: Center(
          child: Column(
            children: [
              SizedBox(
                width: 20.0,
                height: 20.0,
                child: CupertinoActivityIndicator(),
              ),
              SizedBox(height: 16,),
              Text(_content,
                style: TextStyle(fontSize: 13.0, color: Colors.black),
                softWrap: false,
                maxLines: 1,
              )
            ],
          ),
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(
            _actionText,
            style: TextStyle(
                fontSize: 17.0,
                color: AppColor.exportFileDialogButtonCancelTextColor),
          ),
          onPressed: () {
            cancelToken.cancel(['user cancel download file']);
            _appNavigation.popBack();
          },
        )
      ],
    );
  }
}
