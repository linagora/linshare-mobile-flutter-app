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
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/shared_space_details_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/audit_log_entry_user_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/shared_space_role_name_extension.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/view/custom_list_tiles/shared_space_member_list_tile_builder.dart';
import 'package:linshare_flutter_app/presentation/view/modal_sheets/confirm_modal_sheet_builder.dart';
import 'package:linshare_flutter_app/presentation/view/modal_sheets/select_role_modal_sheet_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_details/shared_space_details_arguments.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/datetime_extension.dart';

import 'shared_space_details_viewmodel.dart';

class SharedSpaceDetailsWidget extends StatefulWidget {
  @override
  _SharedSpaceDetailsWidgetState createState() => _SharedSpaceDetailsWidgetState();
}

class _SharedSpaceDetailsWidgetState extends State<SharedSpaceDetailsWidget> {
  final _model = getIt<SharedSpaceDetailsViewModel>();
  final imagePath = getIt<AppImagePaths>();
  final appNavigation = getIt<AppNavigation>();

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      var arg = ModalRoute.of(context)?.settings.arguments as SharedSpaceDetailsArguments;
      _model.initState(arg);
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
    var arguments = ModalRoute.of(context)?.settings.arguments as SharedSpaceDetailsArguments;

    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              key: Key('upload_file_arrow_back_button'),
              icon: Image.asset(imagePath.icArrowBack),
              onPressed: () => _model.backToSharedSpacesList(),
            ),
            centerTitle: true,
            title: Text(arguments.sharedSpace.name,
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
                    _tabTextWidget(AppLocalizations.of(context).members),
                    _tabTextWidget(AppLocalizations.of(context).activities)
                  ],
                ),
              ),
              Expanded(
                  child: TabBarView(children: [
                StoreConnector<AppState, SharedSpaceDetailsState>(
                  converter: (store) => store.state.sharedSpaceDetailsState,
                  builder: (_, state) => _detailsTabWidget(state),
                ),
                StoreConnector<AppState, SharedSpaceDetailsState>(
                  converter: (store) => store.state.sharedSpaceDetailsState,
                  builder: (_, state) => _membersTabWidget(state),
                ),
                StoreConnector<AppState, List<AuditLogEntryUser?>?>(
                  converter: (store) => store.state.sharedSpaceDetailsState.activitiesList,
                  builder: (_, activitiesList) => _activitiesTabWidget(activitiesList),
                ),
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

  Widget _detailsTabWidget(SharedSpaceDetailsState state) {
    if (state.sharedSpace == null || state.quota == null) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Padding(
              padding: EdgeInsets.only(left: 10),
              child: SvgPicture.asset(imagePath.icSharedSpace,
                  color: AppColor.primaryColor, width: 20, height: 24, fit: BoxFit.fill)),
          title: Text(state.sharedSpace?.name ?? '',
              style: TextStyle(
                  color: AppColor.workGroupDetailsName,
                  fontWeight: FontWeight.normal,
                  fontSize: 14.0)),
          trailing: Text(
            filesize(state.quota?.usedSpace.size),
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
                state.sharedSpace?.modificationDate.getMMMddyyyyFormatString() ?? ''),
            _sharedSpaceInformationTile(AppLocalizations.of(context).created,
                state.sharedSpace?.creationDate.getMMMddyyyyFormatString() ?? ''),
            _sharedSpaceInformationTile(
                AppLocalizations.of(context).my_rights,
                toBeginningOfSentenceCase(
                    state.sharedSpace?.sharedSpaceRole.name.getRoleName(context)) ?? ''),
            _sharedSpaceInformationTile(
                AppLocalizations.of(context).max_file_size, filesize(state.quota?.maxFileSize.size)),
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
                    child: Text(AppLocalizations.of(context).no_description,
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

  Widget _membersTabWidget(SharedSpaceDetailsState state) {
    return RefreshIndicator(
      onRefresh: () async {
        _model.refreshSharedSpaceMembers(state.sharedSpace?.sharedSpaceId);
      },
      child: Scaffold(
        body: ListView.builder(
          itemCount: state.membersList?.length,
          itemBuilder: (context, index) {
            var member = state.membersList?[index];
            if(member == null) {
              return SizedBox.shrink();
            }
            return SharedSpaceMemberListTileBuilder(
              member.account?.name ?? '',
              member.account?.mail ?? '',
              member.role?.name.getRoleName(context) ?? AppLocalizations.of(context).unknown_role,
              userCurrentRole: state.sharedSpace?.sharedSpaceRole.name,
              onSelectedRoleCallback: () => selectRoleBottomSheet(
                context,
                member.role?.name ?? SharedSpaceRoleName.READER,
                state.sharedSpace!.sharedSpaceId,
                member),
              onDeleteMemberCallback: () => confirmDeleteMember(
                context,
                member.account?.name ?? '',
                state.sharedSpace?.name ?? '',
                state.sharedSpace!.sharedSpaceId,
                member.sharedSpaceMemberId)).build();
              }),
        floatingActionButton:
          SharedSpaceOperationRole.deleteSharedSpaceRoles.contains(state.sharedSpace?.sharedSpaceRole.name)
          ? FloatingActionButton(
              onPressed: () => _model.goToAddSharedSpaceMember(state.sharedSpace!, state.membersList!),
              backgroundColor: AppColor.primaryColor,
              child: Icon(Icons.person_add, color: Colors.white, size: 24.0),
            )
          : SizedBox.shrink(),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.centerFloat,
      ));
  }

  Widget _activitiesTabWidget(List<AuditLogEntryUser?>? activitiesList) {
    return (activitiesList == null || activitiesList.isEmpty)
        ? SizedBox.shrink()
        : ListView.builder(
            key: Key('activities_list'),
            padding: EdgeInsets.zero,
            itemCount: activitiesList.length,
            itemBuilder: (context, index) {
              return _buildActivitiesListItem(context, activitiesList[index]);
            },
          );
  }

  Widget _buildActivitiesListItem(BuildContext context, AuditLogEntryUser? auditLogEntryUser) {
    return ListTile(
        contentPadding: EdgeInsets.only(left: 24, top: 0),
        leading: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          SvgPicture.asset(auditLogEntryUser?.getAuditLogIconPath(imagePath) ?? imagePath.icFileTypeFile,
              width: 20, height: 20, fit: BoxFit.fill)
        ]),
        title: Transform(
          transform: Matrix4.translationValues(-16, 0.0, 0.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  auditLogEntryUser?.getResourceName() ?? '',
                  maxLines: 1,
                  style: TextStyle(fontSize: 14, color: AppColor.documentNameItemTextColor),
                )),
            _buildActionDetailsText(auditLogEntryUser?.getActionDetails(
                context, _model.store.state.account.user!.userId.uuid)),
            Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  auditLogEntryUser?.getLogTimeAndByActor(
                      context, _model.store.state.account.user!.userId.uuid) ?? '',
                  style: TextStyle(fontSize: 13, color: AppColor.documentModifiedDateItemTextColor),
                ))
          ]),
        ));
  }

  Widget _buildActionDetailsText(Map<AuditLogActionDetail, dynamic>? actionDetails) {
    return Padding(
        padding: EdgeInsets.only(top: 8),
        child: RichText(
            text: TextSpan(
          style: TextStyle(fontSize: 13, color: AppColor.documentNameItemTextColor),
          children: <TextSpan>[
            TextSpan(
                text: actionDetails?[AuditLogActionDetail.TITLE],
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColor.documentNameItemTextColor)),
            TextSpan(
                text: ' ${actionDetails?[AuditLogActionDetail.DETAIL]}',
                style: TextStyle(fontSize: 13, color: AppColor.documentNameItemTextColor))
          ],
        )));
  }

  void selectRoleBottomSheet(
      BuildContext context,
      SharedSpaceRoleName selectedRole,
      SharedSpaceId sharedSpaceId,
      SharedSpaceMember member) {
    SelectRoleModalSheetBuilder(
          key: Key('select_role_on_shared_space_member_details'),
          selectedRole: selectedRole)
        .onConfirmAction((role) => _model.changeMemberRole(sharedSpaceId, member, role))
        .show(context);
  }

  void confirmDeleteMember(
      BuildContext context,
      String memberName,
      String workspaceName,
      SharedSpaceId sharedSpaceId,
      SharedSpaceMemberId sharedSpaceMemberId) {
    final deleteTitle = AppLocalizations.of(context).are_you_sure_you_want_to_delete_member(memberName, workspaceName);
    ConfirmModalSheetBuilder(appNavigation)
        .key(Key('delete_member_shared_space_confirm_modal'))
        .title(deleteTitle)
        .cancelText(AppLocalizations.of(context).cancel)
        .onConfirmAction(
          AppLocalizations.of(context).delete,
            () => _model.deleteMember(sharedSpaceId, sharedSpaceMemberId))
        .show(context);
  }

}
