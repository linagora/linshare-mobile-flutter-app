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
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/shared_space_details_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/shared_space_role_name_extension.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/view/avatar/label_avatar_builder.dart';
import 'package:linshare_flutter_app/presentation/view/custom_list_tiles/shared_space_member_list_tile_builder.dart';
import 'package:linshare_flutter_app/presentation/view/modal_sheets/confirm_modal_sheet_builder.dart';
import 'package:linshare_flutter_app/presentation/view/modal_sheets/select_role_modal_sheet_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_details/add_shared_space_member/add_shared_space_member_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_details/add_shared_space_member/add_shared_space_member_viewmodel.dart';

class AddSharedSpaceMemberWidget extends StatefulWidget {
  AddSharedSpaceMemberWidget({Key key}) : super(key: key);

  @override
  _AddSharedSpaceMemberWidgetState createState() => _AddSharedSpaceMemberWidgetState();
}

class _AddSharedSpaceMemberWidgetState extends State<AddSharedSpaceMemberWidget> {
  final _model = getIt<AddSharedSpaceMemberViewModel>();
  final imagePath = getIt<AppImagePaths>();
  final TextEditingController _typeAheadController = TextEditingController();
  final appNavigation = getIt<AppNavigation>();

  @override
  void initState() {
    _model.initState();
    super.initState();
  }

  @override
  void dispose() {
    _typeAheadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AddSharedSpaceMemberArgument arguments = ModalRoute.of(context).settings.arguments;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            key: Key('add_shared_space_arrow_back_button'),
            icon: Image.asset(imagePath.icArrowBack),
            onPressed: () => _model.backToSharedSpacesDetails(),
          ),
          centerTitle: true,
          title: Text(arguments.sharedSpaceNodeNested.name,
              key: Key('shared_space_details_title'),
              style: TextStyle(fontSize: 24, color: Colors.white)),
          backgroundColor: AppColor.primaryColor,
        ),
        body: StoreConnector<AppState, SharedSpaceDetailsState>(
          converter: (store) => store.state.sharedSpaceDetailsState,
          builder: (_, state) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _addMemberWidget(state.sharedSpace, state.membersList),
            Expanded(child: _membersListWidget(state.sharedSpace, state.membersList))
          ]),
        ));
  }

  Padding _addMemberWidget(SharedSpaceNodeNested sharedSpace, List<SharedSpaceMember> members) {
    return Padding(
        padding: EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(AppLocalizations.of(context).add_team_members,
                  style: TextStyle(color: AppColor.addSharedSpaceMemberTitleColor, fontSize: 16))),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              StoreConnector<AppState, SharedSpaceRoleName>(
                converter: (store) => store.state.addSharedSpaceMembersState.selectedRole,
                builder: (_, role) =>  FlatButton(
                    onPressed: () => selectRoleBottomSheet(
                      context, 
                      role, 
                      onNewRoleUpdated: (newRole) {
                        _model.selectRole(newRole);
                      }),
                    color: AppColor.addSharedSpaceMemberRoleColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(36.0)),
                    child: Row(children: [
                      Text(role.getRoleName(context),
                          style: TextStyle(color: AppColor.primaryColor, fontSize: 14)),
                      Icon(Icons.arrow_drop_down, color: AppColor.primaryColor)
                    ])),
              ),
              Expanded(
                  child: Padding(
                      padding: EdgeInsets.only(bottom: 18, left: 18),
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
                              return await _model.getAutoCompleteSharing(
                                  pattern, sharedSpace, members);
                            }
                            return null;
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
                            _model.addSharedSpaceMember(
                                sharedSpace.sharedSpaceId, autoCompleteResult);
                          },
                          noItemsFoundBuilder: (context) => Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Text(
                                  AppLocalizations.of(context).unknown_user,
                                  style: TextStyle(
                                      fontSize: 14.0, color: AppColor.toastErrorBackgroundColor),
                                ),
                              ))))
            ],
          )
        ]));
  }

  Widget _membersListWidget(
      SharedSpaceNodeNested sharedSpace, List<SharedSpaceMember> members) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          width: double.infinity,
          padding: EdgeInsets.all(24),
          color: AppColor.topBarBackgroundColor,
          child: Text(
              AppLocalizations.of(context).existing_members(members.length),
              style: TextStyle(
                  color: AppColor.addSharedSpaceMemberTitleColor,
                  fontSize: 16))),
      Expanded(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: members.length,
          itemBuilder: (context, index) {
            var member = members[index];
            return SharedSpaceMemberListTileBuilder(
              member.account.name,
              member.account.mail,
              member.role.name.getRoleName(context),
              userCurrentRole: sharedSpace.sharedSpaceRole.name,
              tileColor: Colors.white,
              onSelectedRoleCallback: () =>
                selectRoleBottomSheet(
                  context,
                  member.role.name,
                  onNewRoleUpdated: (newRole) {
                    _model.changeMemberRole(sharedSpace.sharedSpaceId, member, newRole);
                  }),
              onDeleteMemberCallback: () => confirmDeleteMember(
                context,
                member.account.name,
                sharedSpace.name,
                sharedSpace.sharedSpaceId,
                member.sharedSpaceMemberId)).build();
          }))
    ]);
  }

  void selectRoleBottomSheet(
    BuildContext context,
    SharedSpaceRoleName selectedRole,
    {Function(SharedSpaceRoleName) onNewRoleUpdated}) {
    SelectRoleModalSheetBuilder(
      key: Key('select_role_on_add_shared_space_member'),
      selectedRole: selectedRole)
      .onConfirmAction((role) => onNewRoleUpdated.call(role))
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
