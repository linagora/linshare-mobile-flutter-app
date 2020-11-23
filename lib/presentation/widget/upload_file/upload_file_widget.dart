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
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/upload_file_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/upload_file_viewmodel.dart';

class UploadFileWidget extends StatefulWidget {
  @override
  _UploadFileWidgetState createState() => _UploadFileWidgetState();
}

class _UploadFileWidgetState extends State<UploadFileWidget> {
  final uploadFileViewModel = getIt<UploadFileViewModel>();
  final imagePath = getIt<AppImagePaths>();
  final appNavigation = getIt<AppNavigation>();

  @override
  void dispose() {
    uploadFileViewModel.onDisposed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UploadFileArguments arguments =
        ModalRoute.of(context).settings.arguments;
    uploadFileViewModel.setFileInfo(arguments.fileInfo);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: Key('upload_file_arrow_back_button'),
          icon: Image.asset(imagePath.icArrowBack),
          onPressed: () => uploadFileViewModel.backToMySpace(),
        ),
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).upload_file_title,
          key: Key('upload_file_title'),
          style: TextStyle(fontSize: 24, color: Colors.white)),
        backgroundColor: AppColor.primaryColor,
      ),
      body: Container(
        child: Column(
          children: [
            SizedBox(
              width: double.maxFinite,
              height: 56,
              child: Container(
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                        child: Padding(
                      child: Text(
                        arguments.fileInfo.fileName,
                        key: Key('upload_file_name'),
                        style: TextStyle(
                            fontSize: 14,
                            color: AppColor.uploadFileFileNameTextColor),
                      ),
                      padding: EdgeInsets.only(left: 24),
                    )),
                    Padding(
                        padding: EdgeInsets.only(right: 24),
                        child: Text(
                          '${arguments.fileInfo.fileSize} KB',
                          key: Key('upload_file_size'),
                          style: TextStyle(
                              fontSize: 14,
                              color: AppColor.uploadFileFileSizeTextColor),
                        ))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          key: Key('upload_file_confirm_button'),
          backgroundColor: AppColor.primaryColor,
          onPressed: () => uploadFileViewModel.handleOnUploadFilePressed(),
          label: Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Text(
              AppLocalizations.of(context).upload_text_button,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.normal,
                fontStyle: FontStyle.normal),
            ),
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
