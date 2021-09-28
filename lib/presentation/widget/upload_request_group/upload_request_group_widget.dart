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

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/upload_request_group_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/view/background_widgets/background_widget_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_group/upload_request_group_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/datetime_extension.dart';

class UploadRequestGroupWidget extends StatefulWidget {
  UploadRequestGroupWidget({Key? key}) : super(key: key);

  @override
  _UploadRequestGroupWidgetState createState() => _UploadRequestGroupWidgetState();
}

class _UploadRequestGroupWidgetState extends State<UploadRequestGroupWidget> {
  final _model = getIt<UploadRequestGroupViewModel>();
  final imagePath = getIt<AppImagePaths>();

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      _model.initState();
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
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: TabBar(
              unselectedLabelColor: AppColor.uploadRequestLabelsColor,
              unselectedLabelStyle: TextStyle(fontSize: 16),
              labelStyle: TextStyle(fontSize: 16),
              labelColor: AppColor.primaryColor,
              indicatorColor: AppColor.primaryColor,
              tabs: [
                FittedBox(
                  fit: BoxFit.contain,
                  child: Tab(
                    text: AppLocalizations.of(context).pending,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.none,
                  child: Tab(
                    text: AppLocalizations.of(context).active_closed,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.contain,
                  child: Tab(
                    text: AppLocalizations.of(context).archived,
                  ),
                ),
              ]),
          body: StoreConnector<AppState, UploadRequestGroupState>(
            converter: (store) => store.state.uploadRequestGroupState,
            builder: (_, state) => TabBarView(
              children: [
                _buildPendingUploadRequestListWidget(context, state.uploadRequestsCreatedList),
                _buildActiveClosedListWidget(context, state.uploadRequestsActiveClosedList),
                _buildArchivedUploadRequestListWidget(context, state.uploadRequestsArchivedList)
              ],
            ),
          ),
        ));
  }

  Widget _buildArchivedUploadRequestListWidget(
      BuildContext context, List<UploadRequestGroup> uploadRequestList) {
    return RefreshIndicator(
        onRefresh: () async => _model.getUploadRequestArchivedStatus(),
        child: uploadRequestList.isEmpty
            ? _buildCreateUploadRequestsHere(context)
            : ListView.builder(
                itemCount: uploadRequestList.length,
                itemBuilder: (context, index) =>
                    _buildArchivedUploadTile(uploadRequestList[index])));
  }

  Widget _buildPendingUploadRequestListWidget(
      BuildContext context, List<UploadRequestGroup> uploadRequestList) {
    return RefreshIndicator(
        onRefresh: () async => _model.getUploadRequestCreatedStatus(),
        child: uploadRequestList.isEmpty
            ? _buildCreateUploadRequestsHere(context)
            : ListView.builder(
                itemCount: uploadRequestList.length,
                itemBuilder: (context, index) =>
                    _buildPendingUploadTile(uploadRequestList[index])));
  }

  Widget _buildActiveClosedListWidget(
      BuildContext context, List<UploadRequestGroup> uploadRequestList) {
    return RefreshIndicator(
        onRefresh: () async => _model.getUploadRequestActiveClosedStatus(),
        child: uploadRequestList.isEmpty
            ? _buildCreateUploadRequestsHere(context)
            : ListView.builder(
                itemCount: uploadRequestList.length,
                itemBuilder: (context, index) =>
                    _buildActiveClosedUploadTile(uploadRequestList[index])));
  }

  ListTile _buildPendingUploadTile(UploadRequestGroup request) {
    return ListTile(
      dense: true,
      leading: _getTileIcon(request.collective),
      title: Text(request.label,
          style: TextStyle(fontSize: 14, color: AppColor.uploadRequestLabelsColor)),
      subtitle: Text(
          AppLocalizations.of(context)
              .activated_date(request.activationDate.getMMMddyyyyFormatString()),
          style: TextStyle(fontSize: 14, color: AppColor.uploadFileFileSizeTextColor)),
      trailing: IconButton(
          icon: SvgPicture.asset(
            imagePath.icContextMenu,
            width: 24,
            height: 24,
            fit: BoxFit.fill,
          ),
          onPressed: () => null),
    );
  }

  ListTile _buildArchivedUploadTile(UploadRequestGroup request) {
    return ListTile(
      dense: true,
      leading: _getTileIcon(request.collective),
      title: Text(request.label,
          style: TextStyle(fontSize: 14, color: AppColor.uploadRequestLabelsColor)),
      subtitle: Text(
          AppLocalizations.of(context)
              .archived_date(request.activationDate.getMMMddyyyyFormatString()),
          style: TextStyle(fontSize: 14, color: AppColor.uploadFileFileSizeTextColor)),
      trailing: IconButton(
          icon: SvgPicture.asset(
            imagePath.icContextMenu,
            width: 24,
            height: 24,
            fit: BoxFit.fill,
          ),
          onPressed: () => null),
    );
  }

  ListTile _buildActiveClosedUploadTile(UploadRequestGroup request) {
    return ListTile(
      dense: true,
      leading: _getTileIcon(request.collective),
      title: Text(request.label,
          style: TextStyle(fontSize: 14, color: AppColor.uploadRequestLabelsColor)),
      subtitle: _buildActiveClosedSubtitleWidget(request.status),
      trailing: IconButton(
          icon: SvgPicture.asset(
            imagePath.icContextMenu,
            width: 24,
            height: 24,
            fit: BoxFit.fill,
          ),
          onPressed: () => null),
    );
  }

  Widget _buildActiveClosedSubtitleWidget(UploadRequestStatus status) {
    if (status == UploadRequestStatus.ENABLED) {
      return Row(children: [
        Container(
          margin: EdgeInsets.only(right: 4),
          width: 7.0,
          height: 7.0,
          decoration: BoxDecoration(
            color: AppColor.primaryColor,
            shape: BoxShape.circle,
          ),
        ),
        Text(AppLocalizations.of(context).active,
            style: TextStyle(fontSize: 14, color: AppColor.uploadFileFileSizeTextColor))
      ]);
    }

    if (status == UploadRequestStatus.CLOSED) {
      return Row(children: [
        Container(
          margin: EdgeInsets.only(right: 4),
          width: 7.0,
          height: 7.0,
          decoration: BoxDecoration(
            color: AppColor.uploadRequestLabelsColor,
            shape: BoxShape.circle,
          ),
        ),
        Text(AppLocalizations.of(context).expired_closed,
            style: TextStyle(fontSize: 14, color: AppColor.uploadFileFileSizeTextColor))
      ]);
    }

    return SizedBox.shrink();
  }

  Widget _buildCreateUploadRequestsHere(BuildContext context) {
    return BackgroundWidgetBuilder()
        .key(Key('create_upload_request_here'))
        .image(SvgPicture.asset(imagePath.icCreateUploadRequest,
            width: 120, height: 120, fit: BoxFit.fill))
        .text(AppLocalizations.of(context).create_upload_requests_here)
        .build();
  }

  Widget _getTileIcon(bool collective) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      SvgPicture.asset(
          collective ? imagePath.icUploadRequestCollective : imagePath.icUploadRequestIndividual,
          width: 20,
          height: 24,
          fit: BoxFit.fill)
    ]);
  }
}
