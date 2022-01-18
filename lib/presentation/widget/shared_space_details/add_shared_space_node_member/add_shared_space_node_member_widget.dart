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
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/redux/states/add_shared_space_node_member_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/shared_space_role_name_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/linshare_node_type_extension.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/view/avatar/label_avatar_builder.dart';
import 'package:linshare_flutter_app/presentation/view/custom_list_tiles/drive_member_list_tile_builder.dart';
import 'package:linshare_flutter_app/presentation/view/custom_list_tiles/work_space_member_list_tile_builder.dart';
import 'package:linshare_flutter_app/presentation/view/header/simple_bottom_sheet_header_builder.dart';
import 'package:linshare_flutter_app/presentation/view/modal_sheets/confirm_modal_sheet_builder.dart';
import 'package:linshare_flutter_app/presentation/view/modal_sheets/select_role_modal_sheet_builder.dart';
import 'package:linshare_flutter_app/presentation/view/modal_sheets/select_role_with_action_modal_sheet_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_details/add_shared_space_node_member/add_shared_space_node_member_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_details/add_shared_space_node_member/add_shared_space_node_member_viewmodel.dart';

class AddSharedSpaceNodeMemberWidget extends StatefulWidget {
  AddSharedSpaceNodeMemberWidget({Key? key}) : super(key: key);

  @override
  _AddSharedSpaceNodeMemberWidgetState createState() => _AddSharedSpaceNodeMemberWidgetState();
}

class _AddSharedSpaceNodeMemberWidgetState extends State<AddSharedSpaceNodeMemberWidget> {
  final _model = getIt<AddSharedSpaceNodeMemberViewModel>();
  final imagePath = getIt<AppImagePaths>();
  final TextEditingController _typeAheadController = TextEditingController();
  final appNavigation = getIt<AppNavigation>();

  AddSharedSpaceNodeMemberArguments? _arguments;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _arguments = ModalRoute.of(context)?.settings.arguments as AddSharedSpaceNodeMemberArguments;
      _model.initState(_arguments);
    });
  }

  @override
  void dispose() {
    _typeAheadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _arguments = ModalRoute.of(context)?.settings.arguments as AddSharedSpaceNodeMemberArguments;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            key: Key('add_shared_space_node_member_arrow_back_button'),
            icon: Image.asset(imagePath.icArrowBack),
            onPressed: () => _model.backToSharedSpacesDetails(),
          ),
          centerTitle: true,
          title: Text(_arguments?.nodeNested.name ?? '',
              key: Key('add_shared_space_node_member_title'),
              style: TextStyle(fontSize: 24, color: Colors.white)),
          backgroundColor: AppColor.primaryColor,
        ),
        body: SingleChildScrollView(
          child: SafeArea(
            child: Container(
              alignment: Alignment.center,
              child: Column(
                  children: [
                    _buildLoadingView(),
                    StoreConnector<AppState, AddSharedSpaceNodeMemberState>(
                        converter: (store) => store.state.addSharedSpaceNodeMemberState,
                        builder: (_, state) => state.nodeNested != null
                            ? _addMemberWidget(state.nodeNested!, state.membersList)
                            : SizedBox.shrink()),
                    StoreConnector<AppState, AddSharedSpaceNodeMemberState>(
                        converter: (store) => store.state.addSharedSpaceNodeMemberState,
                        builder: (_, state) => state.nodeNested != null
                            ? _membersListWidget(state.nodeNested!, state.membersList)
                            : SizedBox.shrink()),
                  ]),
            ),
          ),
        )
    );
  }

  Widget _buildLoadingView() {
    return StoreConnector<AppState, dartz.Either<Failure, Success>>(
      converter: (store) => store.state.addSharedSpaceNodeMemberState.viewState,
      builder: (context, viewState) {
        return viewState.fold(
          (failure) => SizedBox.shrink(),
          (success) => (success is LoadingState)
            ? Padding(
                padding: EdgeInsets.only(top: 20),
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),),
                ))
            : SizedBox.shrink());
      },
    );
  }

  Padding _addMemberWidget(SharedSpaceNodeNested nodeNested, List<SharedSpaceMember> members) {
    return Padding(
        padding: EdgeInsets.only(top: 24, left: 24, right: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(AppLocalizations.of(context).add_team_members_with_roles,
                  style: TextStyle(color: AppColor.addSharedSpaceMemberTitleColor, fontSize: 16, fontWeight: FontWeight.w500))),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(nodeNested.nodeType?.getTitleRoleAddMember(context) ?? '',
                        style: TextStyle(color: AppColor.addSharedSpaceMemberTitleColor, fontSize: 14))),
                  StoreConnector<AppState, SharedSpaceRoleName>(
                    converter: (store) => store.state.addSharedSpaceNodeMemberState.selectedNodeNestedRole,
                    builder: (_, role) =>  TextButton(
                        onPressed: () => selectRoleBottomSheet(
                            context,
                            nodeNested,
                            nodeNested.nodeType!,
                            role,
                            nodeNested.nodeType!.listRoleName,
                            onNewRoleUpdated: (newRole) => _model.selectNodeNestedRole(newRole)),
                        style: ButtonStyle(
                            foregroundColor: MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) => AppColor.addSharedSpaceMemberRoleColor,
                            ),
                            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) => AppColor.addSharedSpaceMemberRoleColor,
                            ),
                            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(36),
                              side: BorderSide(width: 0, color: AppColor.addSharedSpaceMemberRoleColor),
                            )),
                            elevation: MaterialStateProperty.resolveWith<double>((Set<MaterialState> states) => 0)),
                        child: Padding(
                          padding: EdgeInsets.only(left: 8, right: 3),
                          child: Row(children: [
                            Text(role.getRoleName(context),
                                style: TextStyle(color: AppColor.primaryColor, fontSize: 14, fontWeight: FontWeight.w500)),
                            Icon(Icons.arrow_drop_down, color: AppColor.primaryColor)
                          ]),
                        )
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(AppLocalizations.of(context).default_role_in_workgroups,
                        style: TextStyle(color: AppColor.addSharedSpaceMemberTitleColor, fontSize: 14))),
                  StoreConnector<AppState, SharedSpaceRoleName>(
                    converter: (store) => store.state.addSharedSpaceNodeMemberState.selectedWorkgroupRole,
                    builder: (_, role) =>  TextButton(
                        onPressed: () => selectRoleBottomSheet(
                            context,
                            nodeNested,
                            LinShareNodeType.WORK_GROUP,
                            role,
                            [
                              SharedSpaceRoleName.READER,
                              SharedSpaceRoleName.ADMIN,
                              SharedSpaceRoleName.CONTRIBUTOR,
                              SharedSpaceRoleName.WRITER
                            ],
                            onNewRoleUpdated: (newRole) {
                              _model.selectWorkgroupRole(newRole);
                            }),
                        style: ButtonStyle(
                            foregroundColor: MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) => AppColor.addSharedSpaceMemberRoleColor,
                            ),
                            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) => AppColor.addSharedSpaceMemberRoleColor,
                            ),
                            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(width: 0, color: AppColor.addSharedSpaceMemberRoleColor),
                            )),
                            elevation: MaterialStateProperty.resolveWith<double>((Set<MaterialState> states) => 0)),
                        child: Padding(
                          padding: EdgeInsets.only(left: 8, right: 3),
                          child: Row(children: [
                            Text(role.getRoleName(context),
                                style: TextStyle(color: AppColor.primaryColor, fontSize: 14, fontWeight: FontWeight.w500)),
                            Icon(Icons.arrow_drop_down, color: AppColor.primaryColor)
                          ]),
                        )
                    ),
                  )
                ],
              ),
            ],
          ),
          Padding(
              padding: EdgeInsets.only(top: 8),
              child: TypeAheadFormField(
                  textFieldConfiguration: TextFieldConfiguration(
                      controller: _typeAheadController,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 15),
                          hintText: AppLocalizations.of(context).add_people,
                          hintStyle: TextStyle(
                              color: AppColor.uploadFileFileSizeTextColor, fontSize: 16.0),
                          prefixIcon: Icon(
                            Icons.person_add,
                            size: 24.0,
                          ))),
                  debounceDuration: Duration(milliseconds: 300),
                  suggestionsCallback: (pattern) async {
                    if (pattern.length >= 3) {
                      return await _model.getAutoCompleteSharing(pattern, nodeNested, members);
                    }
                    return <AutoCompleteResult>[];
                  },
                  itemBuilder: (context, AutoCompleteResult autoCompleteResult) {
                    return ListTile(
                      leading: LabelAvatarBuilder(autoCompleteResult
                          .getSuggestionDisplayName()
                          .characters
                          .first
                          .toUpperCase())
                          .key(Key('label_avatar'))
                          .build(),
                      title: Text(autoCompleteResult.getSuggestionDisplayName(),
                          style:
                          TextStyle(fontSize: 14.0, color: AppColor.userTagTextColor)),
                      subtitle: Text(autoCompleteResult.getSuggestionMail(),
                          style: TextStyle(
                              fontSize: 14.0,
                              color: AppColor.userTagRemoveButtonBackgroundColor)),
                    );
                  },
                  onSuggestionSelected: (autoCompleteResult) async {
                    _typeAheadController.text = '';
                    _model.addSharedSpaceNodeMember(
                        nodeNested.sharedSpaceId,
                        nodeNested.nodeType!,
                        autoCompleteResult as SharedSpaceMemberAutoCompleteResult);
                  },
                  noItemsFoundBuilder: (context) => Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      AppLocalizations.of(context).unknown_user,
                      style: TextStyle(
                          fontSize: 14.0, color: AppColor.toastErrorBackgroundColor),
                    ),
                  )))
        ]));
  }

  Widget _membersListWidget(SharedSpaceNodeNested nodeNested, List<SharedSpaceMember> members) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: 30),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          color: AppColor.topBarBackgroundColor,
          child: Text(
              AppLocalizations.of(context).existing_members(members.length),
              style: TextStyle(
                  color: AppColor.addSharedSpaceMemberTitleColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500))),
      ListView.builder(
          shrinkWrap: true,
          primary: false,
          itemCount: members.length,
          itemBuilder: (context, index) {
            var member = members[index];
            if (nodeNested.nodeType == LinShareNodeType.DRIVE) {
              return DriveMemberListTileBuilder(
                  member.account?.name ?? '',
                  member.account?.mail ?? '',
                  member.role?.name.getRoleName(context) ?? AppLocalizations.of(context).unknown_role,
                  member.nestedRole?.name.getWorkgroupRoleNameInsideDriveOrWorkspace(context) ?? AppLocalizations.of(context).unknown_role,
                  tileColor: Colors.white,
                  userCurrentDriveRole: nodeNested.sharedSpaceRole.name,
                  onSelectedRoleDriveCallback: () =>
                      selectSharedSpaceNodeMemberRoleBottomSheet(
                          context,
                          member.role?.name ?? SharedSpaceRoleName.DRIVE_READER,
                          nodeNested,
                          nodeNested.nodeType!,
                          member),
                  onSelectedRoleWorkgroupCallback: () =>
                      selectWorkgroupRoleInsideSharedSpaceNodeBottomSheet(
                          context,
                          member.nestedRole?.name ?? SharedSpaceRoleName.READER,
                          nodeNested,
                          nodeNested.nodeType!,
                          member),
                  onDeleteMemberCallback: () =>
                      _confirmDeleteMember(
                          context,
                          member.account?.name ?? '',
                          nodeNested.name,
                          nodeNested.sharedSpaceId,
                          nodeNested.nodeType!,
                          member.sharedSpaceMemberId)
              ).build();
            } else if (nodeNested.nodeType == LinShareNodeType.WORK_SPACE) {
              return WorkspaceMemberListTileBuilder(
                  member.account?.name ?? '',
                  member.account?.mail ?? '',
                  member.role?.name.getRoleName(context) ?? AppLocalizations.of(context).unknown_role,
                  member.nestedRole?.name.getWorkgroupRoleNameInsideDriveOrWorkspace(context)
                      ?? AppLocalizations.of(context).unknown_role,
                  tileColor: Colors.white,
                  userCurrentWorkspaceRole: nodeNested.sharedSpaceRole.name,
                  onSelectedRoleWorkspaceCallback: () =>
                      selectSharedSpaceNodeMemberRoleBottomSheet(
                          context,
                          member.role?.name ?? SharedSpaceRoleName.WORK_SPACE_READER,
                          nodeNested,
                          nodeNested.nodeType!,
                          member),
                  onSelectedRoleWorkgroupCallback: () =>
                      selectWorkgroupRoleInsideSharedSpaceNodeBottomSheet(
                          context,
                          member.nestedRole?.name ?? SharedSpaceRoleName.READER,
                          nodeNested,
                          nodeNested.nodeType!,
                          member),
                  onDeleteMemberCallback: () =>
                      _confirmDeleteMember(
                          context,
                          member.account?.name ?? '',
                          nodeNested.name,
                          nodeNested.sharedSpaceId,
                          nodeNested.nodeType!,
                          member.sharedSpaceMemberId)
              ).build();
            }
            return SizedBox.shrink();
          }
      )
    ]);
  }

  void selectRoleBottomSheet(
    BuildContext context,
    SharedSpaceNodeNested nodeNested,
    LinShareNodeType type,
    SharedSpaceRoleName selectedRole,
    List<SharedSpaceRoleName> listRoles,
    {Function(SharedSpaceRoleName)? onNewRoleUpdated}
  ) {
    SelectRoleModalSheetBuilder(
          key: Key('select_role_on_add_shared_space_node_member'),
          selectedRole: selectedRole,
          listRoles: listRoles)
      .addHeader(SimpleBottomSheetHeaderBuilder(Key('role_on_add_shared_space_node_member_header'))
          .addTransformPadding(Matrix4.translationValues(0, -5, 0.0))
          .textStyle(TextStyle(fontSize: 18.0, color: AppColor.uploadFileFileNameTextColor, fontWeight: FontWeight.w500))
          .addLabel(_getLabelModalSheetSelectRole(nodeNested, type))
          .build())
      .onConfirmAction((role) => onNewRoleUpdated?.call(role))
      .show(context);
  }

  String _getLabelModalSheetSelectRole(SharedSpaceNodeNested nodeNested, LinShareNodeType type) {
    switch(type) {
      case LinShareNodeType.DRIVE:
        return AppLocalizations.of(context).role_in_this_drive;
      case LinShareNodeType.WORK_SPACE:
        return AppLocalizations.of(context).role_in_this_workspace;
      case LinShareNodeType.WORK_GROUP:
        if (nodeNested.nodeType == LinShareNodeType.DRIVE) {
          return AppLocalizations.of(context).member_default_role_of_all_workgroups_inside_this_drive;
        } else if (nodeNested.nodeType == LinShareNodeType.WORK_SPACE) {
          return AppLocalizations.of(context).member_default_role_of_all_workgroups_inside_this_workspace;
        } else {
          return '';
        }
    }
  }

  void _confirmDeleteMember(
      BuildContext context,
      String memberName,
      String nodeNestedName,
      SharedSpaceId sharedSpaceId,
      LinShareNodeType nodeType,
      SharedSpaceMemberId sharedSpaceMemberId
  ) {
    final deleteTitle = nodeType.getTitleModalSheetDeleteMember(context, memberName, nodeNestedName);
    ConfirmModalSheetBuilder(appNavigation)
        .key(Key('delete_member_shared_space_node_confirm_modal'))
        .title(deleteTitle)
        .cancelText(AppLocalizations.of(context).cancel)
        .onConfirmAction(AppLocalizations.of(context).delete,
            (_) => _model.deleteMember(sharedSpaceId, sharedSpaceMemberId))
        .show(context);
  }

  void selectSharedSpaceNodeMemberRoleBottomSheet(
      BuildContext context,
      SharedSpaceRoleName selectedRole,
      SharedSpaceNodeNested nodeNested,
      LinShareNodeType nodeType,
      SharedSpaceMember member) {
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
        key: Key('select_role_on_workgroup_inside_shared_space_node_add_member'),
        selectedRole: selectedRole,
        listRoles: LinShareNodeType.WORK_GROUP.listRoleName)
      .addHeader(SimpleBottomSheetHeaderBuilder(Key('role_on_workgroup_inside_shared_space_node_add_member_header'))
        .addTransformPadding(Matrix4.translationValues(0, -5, 0.0))
        .textStyle(TextStyle(fontSize: 18.0, color: AppColor.uploadFileFileNameTextColor, fontWeight: FontWeight.w500))
        .addLabel(AppLocalizations.of(context).edit_default_workgroup_role)
        .build())
      .optionalCheckbox(AppLocalizations.of(context).override_this_role_for_all_existing_workgroups)
      .onNegativeAction(() => appNavigation.popBack())
      .onPositiveAction((role, isOverrideRoleForAll) =>
        _model.changeWorkgroupInsideDriveMemberRole(nodeNested, member, role,
            nodeType, isOverrideRoleForAll: isOverrideRoleForAll))
      .show(context);
  }
}