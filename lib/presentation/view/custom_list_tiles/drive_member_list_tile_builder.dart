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

typedef DeleteDriveMemberCallback = void Function();
typedef SelectRoleDriveCallback = void Function();
typedef SelectRoleWorkgroupCallback = void Function();

class DriveMemberListTileBuilder {
  final String _name;
  final String _email;
  final String _driveRoleName;
  final String _workgroupRoleName;
  final SharedSpaceRoleName? userCurrentDriveRole;

  Color? tileColor;

  final DeleteDriveMemberCallback? onDeleteMemberCallback;
  final SelectRoleDriveCallback? onSelectedRoleDriveCallback;
  final SelectRoleWorkgroupCallback? onSelectedRoleWorkgroupCallback;

  DriveMemberListTileBuilder(
    this._name,
    this._email,
    this._driveRoleName,
    this._workgroupRoleName,
    {
      this.tileColor,
      this.userCurrentDriveRole,
      this.onDeleteMemberCallback,
      this.onSelectedRoleDriveCallback,
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
                .key(Key('label_drive_member_avatar'))
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
            if (SharedSpaceOperationRole.deleteDriveMemberRoles.contains(userCurrentDriveRole))
              GestureDetector(
                  onTap: () => _handleDeleteMemberTap(),
                  child: Icon(Icons.close, color: AppColor.deleteMemberIconColor))
          ]),
          Padding(
              padding: EdgeInsets.only(top: 8, left: 56),
              child: Row(
                children: [
                  _buildDriveMemberTypeLabel(),
                  SizedBox(width: 20),
                  Expanded(child: _buildWorkgroupMemberTypeLabel()),
                ],
              ))
        ],
      ),
    );
  }

  Widget _buildDriveMemberTypeLabel() {
    return GestureDetector(
      onTap: () => _handleUpdateRoleDriveTap(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
              _driveRoleName,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.normal,
                  color: AppColor.workgroupNodesSurfingBackTitleColor)),
          SharedSpaceOperationRole.editDriveMemberRoles.contains(userCurrentDriveRole)
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
          SharedSpaceOperationRole.editDriveMemberRoles
                  .contains(userCurrentDriveRole)
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

  void _handleUpdateRoleDriveTap() {
    if (onSelectedRoleDriveCallback != null &&
        SharedSpaceOperationRole.editDriveMemberRoles.contains(userCurrentDriveRole)) {
      onSelectedRoleDriveCallback?.call();
    }
  }

  void _handleUpdateRoleWorkgroupTap() {
    if (onSelectedRoleWorkgroupCallback != null &&
        SharedSpaceOperationRole.editDriveMemberRoles.contains(userCurrentDriveRole)) {
      onSelectedRoleWorkgroupCallback?.call();
    }
  }
}