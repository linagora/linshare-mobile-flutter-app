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
import 'package:flutter_redux/flutter_redux.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/model/upload_and_share/upload_and_share_model.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/widget/current_uploads/current_uploads_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/current_uploads/upload_files/upload_files_state_widget.dart';

class CurrentUploadsWidget extends StatefulWidget {
  @override
  _CurrentUploadsWidgetState createState() => _CurrentUploadsWidgetState();
}

class _CurrentUploadsWidgetState extends State<CurrentUploadsWidget> {
  final imagePath = getIt<AppImagePaths>();
  final viewModel = getIt<CurrentUploadsViewModel>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Image.asset(imagePath.icArrowBack),
            onPressed: () => viewModel.backToPreviousScreen(),
          ),
          centerTitle: true,
          title: Text(
            AppLocalizations.of(context).current_uploads_screen_title,
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
          backgroundColor: AppColor.primaryColor,
          bottom: TabBar(
            tabs: <Widget>[
              Tab(text: AppLocalizations.of(context).current_uploads_my_space_tab),
              Tab(text: AppLocalizations.of(context).current_uploads_shared_space_tab),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StoreConnector<AppState, List<UploadAndShareFileState>>(
              builder: (_, files) => UploadFilesStateWidget(files),
              converter: (store) => store.state.uploadFileState.mySpaceUploadFiles,
            ),
            StoreConnector<AppState, List<UploadAndShareFileState>>(
              builder: (_, files) => UploadFilesStateWidget(files),
              converter: (store) => store.state.uploadFileState.workgroupUploadFiles,
            ),
          ],
        ),
      ),
    );
  }
}
