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

import 'package:dartz/dartz.dart' as dartz;
import 'package:domain/domain.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/upload_request_file_details_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/media_type_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/audit_log_entry_user_extension.dart';
import 'package:linshare_flutter_app/presentation/view/avatar/label_avatar_builder.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/datetime_extension.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/file_details/upload_request_file_details_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/file_details/upload_request_file_details_viewmodel.dart';

class UploadRequestFileDetailsWidget extends StatefulWidget {
  @override
  _UploadRequestFileDetailsWidgetState createState() => _UploadRequestFileDetailsWidgetState();
}

class _UploadRequestFileDetailsWidgetState extends State<UploadRequestFileDetailsWidget> {
  final _model = getIt<UploadRequestFileDetailsViewModel>();
  final imagePath = getIt<AppImagePaths>();

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      var arguments = ModalRoute.of(context)?.settings.arguments as UploadRequestFileDetailsArguments;
      _model.initState(arguments);
    });
    super.initState();
  }

  @override
  void dispose() {
    _model.onDisposed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments as UploadRequestFileDetailsArguments;

    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              key: Key('upload_request_file_details_arrow_back_button'),
              icon: Image.asset(imagePath.icArrowBack),
              onPressed: () => _model.backToUploadRequestGroup(),
            ),
            centerTitle: true,
            title: Text(arguments.entry.name,
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
                    _tabTextWidget(AppLocalizations.of(context).activities),
                  ],
                ),
              ),
              Expanded(
                  child: TabBarView(children: [
                    StoreConnector<AppState, UploadRequestFileDetailsState>(
                        converter: (store) => store.state.uploadRequestFileDetailsState,
                        builder: (_, state) => _detailsTabWidget(state)),
                    StoreConnector<AppState, UploadRequestFileDetailsState>(
                        converter: (store) => store.state.uploadRequestFileDetailsState,
                        builder: (_, state) => _activitiesTabWidget(state.activities)),
                  ]))
            ],
          ),
        ));
  }

  Text _tabTextWidget(String title) {
    return Text(
      title,
      style: TextStyle(fontWeight: FontWeight.normal, fontStyle: FontStyle.normal, fontSize: 18),
    );
  }

  Widget _detailsTabWidget(UploadRequestFileDetailsState state) {
    if (state.entry == null) {
      return Container(
          color: AppColor.userTagBackgroundColor,
          child: Align(
            alignment: Alignment.center,
            child: Container(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                backgroundColor: AppColor.primaryColor,
              ),
            ),
          ));
    }

    return SafeArea(child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _uploadRequestFileDetailsTitleWidget(state),
            Divider(),
            _uploadedPersonInformation(state.entry),
            Divider(),
            Column(
              children: [
                _uploadRequestFileInformation(AppLocalizations.of(context).modified,
                    state.entry?.modificationDate?.getMMMddyyyyFormatString() ?? ''),
                _uploadRequestFileInformation(AppLocalizations.of(context).created,
                    state.entry?.creationDate?.getMMMddyyyyFormatString() ?? ''),
              ],
            ),
          ],
        )));
  }

  ListTile _uploadRequestFileDetailsTitleWidget(UploadRequestFileDetailsState state) {
    return ListTile(
      leading: SvgPicture.asset(state.entry?.mediaType.getFileTypeImagePath(imagePath) ?? imagePath.icFileTypeFile,
              width: 20, height: 24, fit: BoxFit.fill),
      title: Text(state.entry?.name ?? '',
          style: TextStyle(
              color: AppColor.workGroupDetailsName, fontWeight: FontWeight.normal, fontSize: 16.0)),
      trailing: Text(
        filesize(state.entry?.size),
        style: TextStyle(
          fontSize: 14,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.normal,
          color: AppColor.uploadFileFileSizeTextColor,
        ),
      ),
    );
  }

  ListTile _uploadRequestFileInformation(String category, String value) {
    return ListTile(
      dense: true,
      title: Text(category,
          style: TextStyle(
              color: AppColor.uploadRequestLabelsColor,
              fontWeight: FontWeight.w500,
              fontSize: 16.0)),
      trailing: Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColor.uploadRequestLabelsColor,
        ),
      ),
    );
  }

  ListTile _uploadedPersonInformation(UploadRequestEntry? entry) {
    return ListTile(
        leading: LabelAvatarBuilder(entry?.recipient?.mail.characters.first ?? '')
            .key(Key('label_upload_request_file_owner_avatar'))
            .build(),
        title: Text(
            entry?.recipient?.mail ?? '',
            style: TextStyle(
                color: AppColor.uploadRequestLabelsColor,
                fontWeight: FontWeight.w500,
                fontSize: 16.0)),
      );
  }

  Widget _buildLoadingView() {
    return StoreConnector<AppState, dartz.Either<Failure, Success>>(
      converter: (store) => store.state.uploadRequestFileDetailsState.viewState,
      builder: (context, viewState) {
        return viewState.fold(
          (failure) => SizedBox.shrink(),
          (success) => (success is LoadingState)
              ? Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                      padding: EdgeInsets.all(20),
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor))
                      )))
              : SizedBox.shrink());
      },
    );
  }

  Widget _activitiesTabWidget(List<AuditLogEntryUser?>? activitiesList) {
    return (activitiesList == null || activitiesList.isEmpty)
        ? _buildLoadingView()
        : SafeArea(
            child: ListView.builder(
              key: Key('upload_request_file_activities_list'),
              padding: EdgeInsets.only(bottom: 30),
              itemCount: activitiesList.length,
              itemBuilder: (context, index) {
                return _buildActivitiesListItem(context, activitiesList[index]);
              },
            )
          );
  }

  Widget _buildActivitiesListItem(BuildContext context, AuditLogEntryUser? auditLogEntryUser) {
    return Container(
      padding: EdgeInsets.only(left: 20, top: 30, right: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          SvgPicture.asset(
              auditLogEntryUser?.getAuditLogIconPath(imagePath) ?? imagePath.icFileTypeFile,
              width: 20,
              height: 20,
              fit: BoxFit.fill),
          Expanded(
              child: Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(
                    auditLogEntryUser?.getResourceName() ?? '',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColor.uploadFileFileNameTextColor),
                  )))
        ]),
        Divider(),
        _buildActionDetailsText(auditLogEntryUser?.getActionDetails(
            context, _model.store.state.account.user!.userId.uuid)),
        Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text(
              '${auditLogEntryUser?.getFileSize(auditLogEntryUser)}'
                  '${auditLogEntryUser?.getLogTimeAndByActor(context, _model.store.state.account.user!.userId.uuid) ?? ''}',
              style: TextStyle(
                  fontSize: 13,
                  color: AppColor.documentModifiedDateItemTextColor),
            ))
      ]),
    );
  }

  Widget _buildActionDetailsText(Map<AuditLogActionDetail, dynamic>? actionDetails) {
    return Padding(
        padding: EdgeInsets.only(top: 0),
        child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 16, color: AppColor.documentNameItemTextColor),
              children: <TextSpan>[
                TextSpan(
                    text: actionDetails?[AuditLogActionDetail.TITLE],
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColor.documentNameItemTextColor)),
                TextSpan(
                    text: ' ${actionDetails?[AuditLogActionDetail.DETAIL]}',
                    style: TextStyle(fontSize: 16, color: AppColor.documentNameItemTextColor))
              ],
            )));
  }
}
