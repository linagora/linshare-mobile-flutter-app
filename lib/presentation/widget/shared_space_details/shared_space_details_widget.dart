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
import 'package:linshare_flutter_app/presentation/model/versioning_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/shared_space_details_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/audit_log_entry_user_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/shared_space_role_name_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/shared_space_member_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/linshare_node_type_extension.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/view/custom_list_tiles/drive_member_list_tile_builder.dart';
import 'package:linshare_flutter_app/presentation/view/custom_list_tiles/shared_space_member_list_tile_builder.dart';
import 'package:linshare_flutter_app/presentation/view/custom_list_tiles/work_space_member_list_tile_builder.dart';
import 'package:linshare_flutter_app/presentation/view/header/simple_bottom_sheet_header_builder.dart';
import 'package:linshare_flutter_app/presentation/view/modal_sheets/confirm_modal_sheet_builder.dart';
import 'package:linshare_flutter_app/presentation/view/modal_sheets/select_role_modal_sheet_builder.dart';
import 'package:linshare_flutter_app/presentation/view/modal_sheets/select_role_with_action_modal_sheet_builder.dart';
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
        length: arguments.sharedSpace.nodeType == LinShareNodeType.WORK_GROUP ? 3 : 2,
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
                    if (arguments.sharedSpace.nodeType == LinShareNodeType.WORK_GROUP) _tabTextWidget(AppLocalizations.of(context).activities)
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(children: [
                  StoreConnector<AppState, SharedSpaceDetailsState>(
                    converter: (store) => store.state.sharedSpaceDetailsState,
                    builder: (_, state) => _detailsTabWidget(state)),
                  StoreConnector<AppState, SharedSpaceDetailsState>(
                    converter: (store) => store.state.sharedSpaceDetailsState,
                    builder: (_, state) => _membersTabWidget(state)),
                  if (arguments.sharedSpace.nodeType == LinShareNodeType.WORK_GROUP)
                    StoreConnector<AppState, List<AuditLogEntryUser?>?>(
                      converter: (store) => store.state.sharedSpaceDetailsState.activitiesList,
                      builder: (_, activitiesList) => _activitiesTabWidget(activitiesList)),
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
    if (state.sharedSpace == null) {
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

    return SingleChildScrollView(child: Column(
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
          trailing: state.quota != null
            ? Text(
                filesize(state.quota?.usedSpace.size ?? 0),
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.normal,
                  color: AppColor.uploadFileFileSizeTextColor,
                ),
              )
            : null,
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
                toBeginningOfSentenceCase(state.sharedSpace?.nodeType?.getRoleDisplayName(context, state.sharedSpace?.sharedSpaceRole.name)) ?? ''),
            if (state.sharedSpace?.nodeType == LinShareNodeType.WORK_GROUP && state.quota != null)
              _sharedSpaceInformationTile(AppLocalizations.of(context).max_file_size, filesize(state.quota?.maxFileSize.size ?? 0)),
          ],
        ),
        Divider(),
        Container(
            margin: EdgeInsets.only(left: 16, top: 10, bottom: 16),
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
            )),
        if (state.sharedSpace != null && state.sharedSpace?.nodeType == LinShareNodeType.WORK_GROUP)
          Column(children: [
            Divider(),
            _sharedSpaceVersioningWidget(context, state.sharedSpace!)
          ])
      ],
    ));
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

  Widget _sharedSpaceVersioningWidget(BuildContext context, SharedSpaceNodeNested sharedSpace) {
    return ListTile(
      dense: true,
      title: Text(
        AppLocalizations.of(context).versioning_enable,
        style: TextStyle(
          color: sharedSpace.sharedSpaceRole.name == SharedSpaceRoleName.ADMIN
            ? AppColor.versioningTextColor
            : AppColor.versioningDisabledTextColor,
          fontStyle: FontStyle.normal,
          fontSize: 16.0)),
      trailing: Checkbox(
        value: sharedSpace.versioningParameters.enable,
        onChanged: (bool? value) => sharedSpace.sharedSpaceRole.name == SharedSpaceRoleName.ADMIN
          ? _model.enableVersioningForWorkgroup(
              sharedSpace,
              value == true ? VersioningState.ENABLE : VersioningState.DISABLE)
          : null,
        activeColor: sharedSpace.sharedSpaceRole.name == SharedSpaceRoleName.ADMIN
          ? AppColor.primaryColor
          : AppColor.versioningDisabledTextColor),
    );
  }

  Widget _membersTabWidget(SharedSpaceDetailsState state) {
    return RefreshIndicator(
      onRefresh: () async {
        _model.refreshSharedSpaceMembers(state.sharedSpace);
      },
      child: Scaffold(
        body: ListView.builder(
          itemCount: state.membersList.length,
          itemBuilder: (context, index) {
            final member = state.membersList[index];
            if(state.sharedSpace == null) {
              return SizedBox.shrink();
            }
            return _buildItemMember(state.sharedSpace!, member, state.membersOfParentNodeList);
          }),
        floatingActionButton: state.sharedSpace != null && _validateDisplayAddMemberButton(state.sharedSpace!)
            ? FloatingActionButton(
                onPressed: () => _goToAddMember(state.sharedSpace!, state.membersList),
                backgroundColor: AppColor.primaryColor,
                child: Icon(Icons.person_add, color: Colors.white, size: 24.0))
            : SizedBox.shrink(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ));
  }

  void _goToAddMember(SharedSpaceNodeNested sharedSpace, List<SharedSpaceMember> membersList) {
    if (sharedSpace.nodeType == LinShareNodeType.WORK_GROUP) {
      _model.goToAddSharedSpaceMember(sharedSpace, membersList);
    } else if (sharedSpace.nodeType == LinShareNodeType.DRIVE || sharedSpace.nodeType == LinShareNodeType.WORK_SPACE) {
      _model.goToAddSharedSpaceNodeMember(sharedSpace, membersList);
    }
  }

  bool _validateDisplayAddMemberButton(SharedSpaceNodeNested sharedSpace) {
    if (sharedSpace.nodeType == LinShareNodeType.WORK_GROUP) {
      return SharedSpaceOperationRole.addMemberSharedSpaceRoles.contains(sharedSpace.sharedSpaceRole.name);
    } else if (sharedSpace.nodeType == LinShareNodeType.DRIVE) {
      return SharedSpaceOperationRole.addDriveMemberRoles.contains(sharedSpace.sharedSpaceRole.name);
    } else if (sharedSpace.nodeType == LinShareNodeType.WORK_SPACE) {
      return SharedSpaceOperationRole.addWorkspaceMemberRoles.contains(sharedSpace.sharedSpaceRole.name);
    }
    return false;
  }

  Widget _buildItemMember(SharedSpaceNodeNested sharedSpace, SharedSpaceMember member, List<SharedSpaceMember> membersOfParentNode) {
    final memberType = sharedSpace.parentId != null ? member.getMemberType(membersOfParentNode) : null;
    if (sharedSpace.nodeType == LinShareNodeType.WORK_GROUP) {
      return SharedSpaceMemberListTileBuilder(
          context,
          member.account?.name ?? '',
          member.account?.mail ?? '',
          member.role?.name.getRoleName(context) ?? AppLocalizations.of(context).unknown_role,
          memberType: memberType,
          userCurrentRole: sharedSpace.sharedSpaceRole.name,
          onSelectedRoleCallback: () => selectRoleBottomSheet(
              context,
              member.role?.name ?? SharedSpaceRoleName.READER,
              sharedSpace,
              member),
          onDeleteMemberCallback: () => confirmDeleteMember(
              context,
              member.account?.name ?? '',
              sharedSpace.name,
              sharedSpace,
              sharedSpace.nodeType!,
              member.sharedSpaceMemberId)).build();
    } else if (sharedSpace.nodeType == LinShareNodeType.DRIVE) {
      return DriveMemberListTileBuilder(
          member.account?.name ?? '',
          member.account?.mail ?? '',
          member.role?.name.getRoleName(context) ?? AppLocalizations.of(context).unknown_role,
          member.nestedRole?.name.getWorkgroupRoleNameInsideDriveOrWorkspace(context) ?? AppLocalizations.of(context).unknown_role,
          userCurrentDriveRole: sharedSpace.sharedSpaceRole.name,
          onSelectedRoleDriveCallback: () => selectSharedSpaceNodeMemberRoleBottomSheet(
              context,
              member.role?.name ?? sharedSpace.nodeType!.getDefaultSharedSpaceRole().name,
              sharedSpace,
              sharedSpace.nodeType!,
              member),
          onSelectedRoleWorkgroupCallback: () => selectWorkgroupRoleInsideSharedSpaceNodeBottomSheet(
              context,
              member.nestedRole?.name ?? SharedSpaceRoleName.READER,
              sharedSpace,
              sharedSpace.nodeType!,
              member),
          onDeleteMemberCallback: () => confirmDeleteMember(
            context,
            member.account?.name ?? '',
            sharedSpace.name,
            sharedSpace,
            sharedSpace.nodeType!,
            member.sharedSpaceMemberId)
      ).build();
    } else if (sharedSpace.nodeType == LinShareNodeType.WORK_SPACE) {
      return WorkspaceMemberListTileBuilder(
          member.account?.name ?? '',
          member.account?.mail ?? '',
          member.role?.name.getRoleName(context) ?? AppLocalizations.of(context).unknown_role,
          member.nestedRole?.name.getWorkgroupRoleNameInsideDriveOrWorkspace(context) ?? AppLocalizations.of(context).unknown_role,
          userCurrentWorkspaceRole: sharedSpace.sharedSpaceRole.name,
          onSelectedRoleWorkspaceCallback: () => selectSharedSpaceNodeMemberRoleBottomSheet(
              context,
              member.role?.name ?? sharedSpace.nodeType!.getDefaultSharedSpaceRole().name,
              sharedSpace,
              sharedSpace.nodeType!,
              member),
          onSelectedRoleWorkgroupCallback: () => selectWorkgroupRoleInsideSharedSpaceNodeBottomSheet(
              context,
              member.nestedRole?.name ?? SharedSpaceRoleName.READER,
              sharedSpace,
              sharedSpace.nodeType!,
              member),
          onDeleteMemberCallback: () => confirmDeleteMember(
              context,
              member.account?.name ?? '',
              sharedSpace.name,
              sharedSpace,
              sharedSpace.nodeType!,
              member.sharedSpaceMemberId)
      ).build();
    }
    return SizedBox.shrink();
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
      SharedSpaceNodeNested sharedSpace,
      SharedSpaceMember member) {
    SelectRoleModalSheetBuilder(
          key: Key('select_role_on_shared_space_member_details'),
          selectedRole: selectedRole,
          listRoles: [
            SharedSpaceRoleName.READER,
            SharedSpaceRoleName.ADMIN,
            SharedSpaceRoleName.CONTRIBUTOR,
            SharedSpaceRoleName.WRITER
          ])
        .onConfirmAction((role) => _model.changeMemberRole(sharedSpace, member, role))
        .show(context);
  }

  void confirmDeleteMember(
      BuildContext context,
      String memberName,
      String sharedSpaceName,
      SharedSpaceNodeNested sharedSpace,
      LinShareNodeType nodeType,
      SharedSpaceMemberId sharedSpaceMemberId) {
    final deleteTitle = nodeType.getTitleModalSheetDeleteMember(context, memberName, sharedSpaceName);
    ConfirmModalSheetBuilder(appNavigation)
        .key(Key('delete_member_shared_space_confirm_modal'))
        .title(deleteTitle)
        .cancelText(AppLocalizations.of(context).cancel)
        .onConfirmAction(
          AppLocalizations.of(context).delete,
            (_) => _model.deleteMember(sharedSpace, sharedSpaceMemberId))
        .show(context);
  }

  void selectSharedSpaceNodeMemberRoleBottomSheet(
      BuildContext context,
      SharedSpaceRoleName selectedRole,
      SharedSpaceNodeNested nodeNested,
      LinShareNodeType nodeType,
      SharedSpaceMember member
  ) {
    SelectRoleModalSheetBuilder(
          key: Key('select_role_on_shared_space_node_member_details'),
          selectedRole: selectedRole,
          listRoles: nodeType.listRoleName)
      .addHeader(SimpleBottomSheetHeaderBuilder(Key('role_on_shared_space_node_member_header'))
          .addTransformPadding(Matrix4.translationValues(0, -5, 0.0))
          .textStyle(TextStyle(fontSize: 18.0, color: AppColor.uploadFileFileNameTextColor, fontWeight: FontWeight.w500))
          .addLabel(nodeType.getTitleRoleAddMember(context))
          .build())
      .onConfirmAction((role) => _model.changeSharedSpaceNodeMemberRole(nodeNested, member, role, nodeType))
      .show(context);
  }

  void selectWorkgroupRoleInsideSharedSpaceNodeBottomSheet(
      BuildContext context,
      SharedSpaceRoleName selectedRole,
      SharedSpaceNodeNested nodeNested,
      LinShareNodeType nodeType,
      SharedSpaceMember member) {
    SelectRoleWithActionModalSheetBuilder(
        context,
        key: Key('select_role_on_workgroup_inside_shared_space_node_member_details'),
        selectedRole: selectedRole,
        listRoles: LinShareNodeType.WORK_GROUP.listRoleName)
      .addHeader(SimpleBottomSheetHeaderBuilder(Key('role_on_workgroup_inside_shared_space_node_member_header'))
        .addTransformPadding(Matrix4.translationValues(0, -5, 0.0))
        .textStyle(TextStyle(fontSize: 18.0, color: AppColor.uploadFileFileNameTextColor, fontWeight: FontWeight.w500))
        .addLabel(AppLocalizations.of(context).edit_default_workgroup_role)
        .build())
      .optionalCheckbox(AppLocalizations.of(context).override_this_role_for_all_existing_workgroups)
      .onNegativeAction(() => appNavigation.popBack())
      .onPositiveAction((role, isOverrideRoleForAll) =>
        _model.changeMemberRoleWorkgroupInsideSharedSpaceNode(nodeNested, member, role, nodeType, isOverrideRoleForAll: isOverrideRoleForAll))
      .show(context);
  }
}