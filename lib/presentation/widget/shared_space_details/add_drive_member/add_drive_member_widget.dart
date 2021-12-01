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
import 'package:linshare_flutter_app/presentation/redux/states/add_drive_member_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/shared_space_role_name_extension.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/view/avatar/label_avatar_builder.dart';
import 'package:linshare_flutter_app/presentation/view/custom_list_tiles/drive_member_list_tile_builder.dart';
import 'package:linshare_flutter_app/presentation/view/header/simple_bottom_sheet_header_builder.dart';
import 'package:linshare_flutter_app/presentation/view/modal_sheets/confirm_modal_sheet_builder.dart';
import 'package:linshare_flutter_app/presentation/view/modal_sheets/select_role_modal_sheet_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_details/add_drive_member/add_drive_member_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_details/add_drive_member/add_drive_member_viewmodel.dart';

class AddDriveMemberWidget extends StatefulWidget {
  AddDriveMemberWidget({Key? key}) : super(key: key);

  @override
  _AddDriveMemberWidgetState createState() => _AddDriveMemberWidgetState();
}

class _AddDriveMemberWidgetState extends State<AddDriveMemberWidget> {
  final _model = getIt<AddDriveMemberViewModel>();
  final imagePath = getIt<AppImagePaths>();
  final TextEditingController _typeAheadController = TextEditingController();
  final appNavigation = getIt<AppNavigation>();

  AddDriveMemberArguments? _arguments;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _arguments = ModalRoute.of(context)?.settings.arguments as AddDriveMemberArguments;
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
    _arguments = ModalRoute.of(context)?.settings.arguments as AddDriveMemberArguments;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            key: Key('add_drive_member_arrow_back_button'),
            icon: Image.asset(imagePath.icArrowBack),
            onPressed: () => _model.backToSharedSpacesDetails(),
          ),
          centerTitle: true,
          title: Text(_arguments?.drive.name ?? '',
              key: Key('add_drive_member_title'),
              style: TextStyle(fontSize: 24, color: Colors.white)),
          backgroundColor: AppColor.primaryColor,
        ),
        body: SafeArea(
          child: Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                _buildLoadingView(),
                StoreConnector<AppState, AddDriveMemberState>(
                    converter: (store) => store.state.addDriveMemberState,
                    builder: (_, state) => state.drive != null
                        ? _addMemberWidget(state.drive!, state.membersList)
                        : SizedBox.shrink()),
                StoreConnector<AppState, AddDriveMemberState>(
                    converter: (store) => store.state.addDriveMemberState,
                    builder: (_, state) => state.drive != null
                        ? Expanded(child: _membersListWidget(state.drive!, state.membersList))
                        : SizedBox.shrink()),
              ]),
          ),
        )
    );
  }

  Widget _buildLoadingView() {
    return StoreConnector<AppState, dartz.Either<Failure, Success>>(
      converter: (store) => store.state.addDriveMemberState.viewState,
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

  Padding _addMemberWidget(SharedSpaceNodeNested drive, List<SharedSpaceMember> members) {
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
                    child: Text(AppLocalizations.of(context).role_in_this_drive,
                        style: TextStyle(color: AppColor.addSharedSpaceMemberTitleColor, fontSize: 14))),
                  StoreConnector<AppState, SharedSpaceRoleName>(
                    converter: (store) => store.state.addDriveMemberState.selectedDriveRole,
                    builder: (_, role) =>  TextButton(
                        onPressed: () => selectRoleBottomSheet(
                            context,
                            LinShareNodeType.DRIVE,
                            role,
                            [
                              SharedSpaceRoleName.DRIVE_READER,
                              SharedSpaceRoleName.DRIVE_ADMIN,
                              SharedSpaceRoleName.DRIVE_WRITER
                            ],
                            onNewRoleUpdated: (newRole) {
                              _model.selectDriveRole(newRole);
                            }),
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
                    converter: (store) => store.state.addDriveMemberState.selectedWorkgroupRole,
                    builder: (_, role) =>  TextButton(
                        onPressed: () => selectRoleBottomSheet(
                            context,
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
                      return await _model.getAutoCompleteSharing(pattern, drive, members);
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
                    _model.addDriveMember(
                        drive.sharedSpaceId, autoCompleteResult as SharedSpaceMemberAutoCompleteResult);
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

  Widget _membersListWidget(SharedSpaceNodeNested drive, List<SharedSpaceMember> members) {
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
      Expanded(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: members.length,
          itemBuilder: (context, index) {
            var member = members[index];
            return DriveMemberListTileBuilder(
              member.account?.name ?? '',
              member.account?.mail ?? '',
              member.role?.name.getRoleName(context) ?? AppLocalizations.of(context).unknown_role,
              member.nestedRole?.name.getWorkgroupRoleNameInsideDrive(context) ?? AppLocalizations.of(context).unknown_role,
              tileColor: Colors.white,
              userCurrentDriveRole: drive.sharedSpaceRole.name,
              onDeleteMemberCallback: () => _confirmDeleteMember(
                context,
                member.account?.name ?? '',
                drive.name,
                drive.sharedSpaceId,
                member.sharedSpaceMemberId)
            ).build();
          }))
    ]);
  }

  void selectRoleBottomSheet(
    BuildContext context,
    LinShareNodeType type,
    SharedSpaceRoleName selectedRole,
    List<SharedSpaceRoleName> listRoles,
    {Function(SharedSpaceRoleName)? onNewRoleUpdated}
  ) {
    SelectRoleModalSheetBuilder(
          key: Key('select_role_on_add_drive_member'),
          selectedRole: selectedRole,
          listRoles: listRoles)
      .addHeader(SimpleBottomSheetHeaderBuilder(Key('role_on_add_drive_member_header'))
          .addTransformPadding(Matrix4.translationValues(0, -5, 0.0))
          .textStyle(TextStyle(fontSize: 18.0, color: AppColor.uploadFileFileNameTextColor, fontWeight: FontWeight.w500))
          .addLabel(type == LinShareNodeType.DRIVE
            ? AppLocalizations.of(context).role_in_this_drive
            : AppLocalizations.of(context).member_default_role_of_all_workgroups_inside_this_drive)
          .build())
      .onConfirmAction((role) => onNewRoleUpdated?.call(role))
      .show(context);
  }

  void _confirmDeleteMember(
      BuildContext context,
      String memberName,
      String driveName,
      SharedSpaceId sharedSpaceId,
      SharedSpaceMemberId sharedSpaceMemberId
  ) {
    final deleteTitle = AppLocalizations.of(context).are_you_sure_you_want_to_delete_drive_member(memberName, driveName);
    ConfirmModalSheetBuilder(appNavigation)
        .key(Key('delete_member_drive_confirm_modal'))
        .title(deleteTitle)
        .cancelText(AppLocalizations.of(context).cancel)
        .onConfirmAction(AppLocalizations.of(context).delete,
            (_) => _model.deleteMember(sharedSpaceId, sharedSpaceMemberId))
        .show(context);
  }
}