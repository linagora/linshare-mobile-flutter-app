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
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/view/avatar/label_avatar_builder.dart';

typedef DeleteWorkspaceMemberCallback = void Function();
typedef SelectRoleWorkspaceCallback = void Function();
typedef SelectRoleWorkgroupCallback = void Function();

class WorkspaceMemberListTileBuilder {
  final String _name;
  final String _email;
  final String _workspaceRoleName;
  final String _workgroupRoleName;
  final SharedSpaceRoleName? userCurrentWorkspaceRole;

  Color? tileColor;

  final DeleteWorkspaceMemberCallback? onDeleteMemberCallback;
  final SelectRoleWorkspaceCallback? onSelectedRoleWorkspaceCallback;
  final SelectRoleWorkgroupCallback? onSelectedRoleWorkgroupCallback;

  WorkspaceMemberListTileBuilder(
    this._name,
    this._email,
    this._workspaceRoleName,
    this._workgroupRoleName,
    {
      this.tileColor,
      this.userCurrentWorkspaceRole,
      this.onDeleteMemberCallback,
      this.onSelectedRoleWorkspaceCallback,
      this.onSelectedRoleWorkgroupCallback,
    }
  );

  Widget build() {
    return Container(
      color: tileColor,
      padding: EdgeInsets.only(left: 20, top: 16, bottom: 8, right: 20),
      child: Column(
        children: [
          Row(children: [
            LabelAvatarBuilder(_name.characters.first.toUpperCase())
                .key(Key('label_workspace_member_avatar'))
                .build(),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Padding(
                      padding: EdgeInsets.only(bottom: 8, left: 16),
                      child: Text(_name,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.normal,
                              color: AppColor.loginTextFieldTextColor))),
                  Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Text(_email,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            fontStyle: FontStyle.italic,
                            color: AppColor.documentModifiedDateItemTextColor)),
                  ),
                ])),
            if (SharedSpaceOperationRole.deleteWorkspaceMemberRoles.contains(userCurrentWorkspaceRole))
              GestureDetector(
                  onTap: () => _handleDeleteMemberTap(),
                  child: Icon(Icons.close, color: AppColor.deleteMemberIconColor))
          ]),
          Padding(
              padding: EdgeInsets.only(top: 8, left: 56),
              child: Row(
                children: [
                  _buildWorkspaceMemberTypeLabel(),
                  SizedBox(width: 20),
                  Expanded(child: _buildWorkgroupMemberTypeLabel()),
                ],
              ))
        ],
      ),
    );
  }

  Widget _buildWorkspaceMemberTypeLabel() {
    return GestureDetector(
      onTap: () => _handleUpdateRoleWorkspaceTap(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
              _workspaceRoleName,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.normal,
                  color: AppColor.workgroupNodesSurfingBackTitleColor)),
          SharedSpaceOperationRole.editWorkspaceMemberRoles.contains(userCurrentWorkspaceRole)
              ? Icon(Icons.arrow_drop_down, color: AppColor.primaryColor)
              : SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildWorkgroupMemberTypeLabel() {
    return GestureDetector(
      onTap: () => _handleUpdateRoleWorkgroupTap(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_workgroupRoleName,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.normal,
                  color: AppColor.workgroupNodesSurfingBackTitleColor)),
          SharedSpaceOperationRole.editWorkspaceMemberRoles
                  .contains(userCurrentWorkspaceRole)
              ? Icon(Icons.arrow_drop_down, color: AppColor.primaryColor)
              : SizedBox.shrink(),
        ],
      ),
    );
  }

  void _handleDeleteMemberTap() {
    if (onDeleteMemberCallback != null) {
      onDeleteMemberCallback?.call();
    }
  }

  void _handleUpdateRoleWorkspaceTap() {
    if (onSelectedRoleWorkspaceCallback != null &&
        SharedSpaceOperationRole.editWorkspaceMemberRoles.contains(userCurrentWorkspaceRole)) {
      onSelectedRoleWorkspaceCallback?.call();
    }
  }

  void _handleUpdateRoleWorkgroupTap() {
    if (onSelectedRoleWorkgroupCallback != null &&
        SharedSpaceOperationRole.editWorkspaceMemberRoles.contains(userCurrentWorkspaceRole)) {
      onSelectedRoleWorkgroupCallback?.call();
    }
  }
}