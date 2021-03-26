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

import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/model/shared_space_details_info.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/helper/date_format_helper.dart';

import 'shared_space_details_viewmodel.dart';

class SharedSpaceDetailsWidget extends StatefulWidget {
  @override
  _SharedSpaceDetailsWidgetState createState() => _SharedSpaceDetailsWidgetState();
}

class _SharedSpaceDetailsWidgetState extends State<SharedSpaceDetailsWidget> {
  final _model = getIt<SharedSpaceDetailsViewModel>();
  final imagePath = getIt<AppImagePaths>();

  @override
  void dispose() {
    _model.onDisposed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedSpaceDetailsInfo>(
        future: _model.getSharedSpaceDetails(ModalRoute.of(context).settings.arguments),
        builder: (BuildContext context, AsyncSnapshot<SharedSpaceDetailsInfo> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return DefaultTabController(
                length: 2,
                child: Scaffold(
                  appBar: AppBar(
                    leading: IconButton(
                      key: Key('upload_file_arrow_back_button'),
                      icon: Image.asset(imagePath.icArrowBack),
                      onPressed: () => _model.backToSharedSpacesList(),
                    ),
                    centerTitle: true,
                    title: Text(snapshot.data.sharedSpaceNodeNested.name,
                        key: Key('shared_space_details_title'),
                        style: TextStyle(fontSize: 24, color: Colors.white)),
                    backgroundColor: AppColor.primaryColor,
                  ),
                  body: Column(
                    children: [
                      Container(
                        height: 48.0,
                        color: Colors.white,
                        child: TabBar(
                          labelColor: AppColor.uploadProgressValueColor,
                          indicatorColor: AppColor.uploadProgressValueColor,
                          unselectedLabelColor: AppColor.loginTextFieldTextColor,
                          tabs: [
                            _tabTextWidget(AppLocalizations.of(context).details),
                            _tabTextWidget(AppLocalizations.of(context).members)
                          ],
                        ),
                      ),
                      Expanded(
                          child: TabBarView(
                        children: [_detailsTabWidget(snapshot.data), _membersTabWidget()],
                      ))
                    ],
                  ),
                ));
          } else if (snapshot.hasError) {
            return SizedBox.shrink();
          } else {
            return Align(
              alignment: Alignment.center,
              child: Container(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  backgroundColor: AppColor.primaryColor,
                ),
              ),
            );
          }
        });
  }

  Text _tabTextWidget(String title) {
    return Text(
      title,
      style: TextStyle(fontWeight: FontWeight.normal, fontStyle: FontStyle.normal, fontSize: 18),
    );
  }

  Widget _detailsTabWidget(SharedSpaceDetailsInfo details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Padding(
              padding: EdgeInsets.only(left: 10),
              child: SvgPicture.asset(imagePath.icSharedSpace,
                  color: AppColor.primaryColor, width: 20, height: 24, fit: BoxFit.fill)),
          title: Text(details.sharedSpaceNodeNested.name,
              style: TextStyle(
                  color: AppColor.workGroupDetailsName,
                  fontWeight: FontWeight.normal,
                  fontSize: 14.0)),
          trailing: Text(
            filesize(details.quota.usedSpace.size),
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.normal,
              color: AppColor.uploadFileFileSizeTextColor,
            ),
          ),
        ),
        Divider(),
        Column(
          children: [
            _sharedSpaceInformationTile(AppLocalizations.of(context).modified,
                workGroupDetailsDateFormat.format(details.sharedSpaceNodeNested.modificationDate.toLocal())),
            _sharedSpaceInformationTile(AppLocalizations.of(context).created,
                workGroupDetailsDateFormat.format(details.sharedSpaceNodeNested.creationDate.toLocal())),
            _sharedSpaceInformationTile(
                AppLocalizations.of(context).my_rights,
                toBeginningOfSentenceCase(details.sharedSpaceNodeNested.sharedSpaceRole.name
                    .toString()
                    .split('.')
                    .last
                    .toLowerCase())),
            _sharedSpaceInformationTile(AppLocalizations.of(context).max_file_size,
                filesize(details.quota.maxFileSize.size)),
          ],
        ),
        Divider(),
        Container(
            margin: EdgeInsets.only(left: 24, top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context).description,
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                        color: AppColor.workGroupDetailsName)),
                Padding(
                    padding: EdgeInsets.only(top: 18),
                    child: Text('tes tes teste stse',
                        style: TextStyle(
                            color: AppColor.searchResultsCountTextColor,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.normal,
                            fontSize: 16.0)))
              ],
            ))
      ],
    );
  }

  ListTile _sharedSpaceInformationTile(String category, String value) {
    return ListTile(
      dense: true,
      title: Text(category,
          style: TextStyle(
              color: AppColor.searchResultsCountTextColor,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w500,
              fontSize: 16.0)),
      trailing: Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColor.searchResultsCountTextColor,
        ),
      ),
    );
  }

  Widget _membersTabWidget() {
    return SizedBox.shrink();
  }
}
