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
//

import 'package:domain/domain.dart';
import 'package:flutter/cupertino.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';

extension LinShareNodeTypeExtension on LinShareNodeType {

  String? getErrorVerifyName(BuildContext context, dynamic exception) {
    switch(this) {
      case LinShareNodeType.DRIVE:
        if (exception is EmptyNameException) {
          return AppLocalizations.of(context).node_name_not_empty(AppLocalizations.of(context).drive);
        } else if (exception is DuplicatedNameException) {
          return AppLocalizations.of(context).node_name_already_exists(AppLocalizations.of(context).drive);
        } else if (exception is SpecialCharacterException) {
          return AppLocalizations.of(context).node_name_contain_special_character(AppLocalizations.of(context).drive);
        } else {
          return null;
        }
      case LinShareNodeType.WORK_GROUP:
        if (exception is EmptyNameException) {
          return AppLocalizations.of(context).node_name_not_empty(AppLocalizations.of(context).workgroup);
        } else if (exception is DuplicatedNameException) {
          return AppLocalizations.of(context).node_name_already_exists(AppLocalizations.of(context).workgroup);
        } else if (exception is SpecialCharacterException) {
          return AppLocalizations.of(context).node_name_contain_special_character(AppLocalizations.of(context).workgroup);
        } else {
          return null;
        }
      case LinShareNodeType.WORK_SPACE:
        if (exception is EmptyNameException) {
          return AppLocalizations.of(context).node_name_not_empty(AppLocalizations.of(context).workspace);
        } else if (exception is DuplicatedNameException) {
          return AppLocalizations.of(context).node_name_already_exists(AppLocalizations.of(context).workspace);
        } else if (exception is SpecialCharacterException) {
          return AppLocalizations.of(context).node_name_contain_special_character(AppLocalizations.of(context).workspace);
        } else {
          return null;
        }
      default:
        return null;
    }
  }

  List<Validator> getListValidator(List<SharedSpaceNodeNested> sharedSpaceNodes) {
    switch(this) {
      case LinShareNodeType.DRIVE:
        return [
          EmptyNameValidator(),
          SpecialCharacterValidator()
        ];
      case LinShareNodeType.WORK_GROUP:
        return [
          EmptyNameValidator(),
          DuplicateNameValidator(sharedSpaceNodes.map((node) => node.name).toList()),
          SpecialCharacterValidator()
        ];
      case LinShareNodeType.WORK_SPACE:
        return [
          EmptyNameValidator(),
          SpecialCharacterValidator()
        ];
    }
  }

  SuggestNameType get suggestNameType {
    switch(this) {
      case LinShareNodeType.DRIVE:
        return SuggestNameType.DRIVE;
      case LinShareNodeType.WORK_GROUP:
        return SuggestNameType.WORKGROUP;
      case LinShareNodeType.WORK_SPACE:
        return SuggestNameType.WORK_SPACE;
    }
  }

  String getTitleBottomSheetCreation(BuildContext context) {
    switch(this) {
      case LinShareNodeType.DRIVE:
        return AppLocalizations.of(context).create_new_drive;
      case LinShareNodeType.WORK_GROUP:
        return AppLocalizations.of(context).create_new_workgroup;
      case LinShareNodeType.WORK_SPACE:
        return AppLocalizations.of(context).create_new_workspace;
    }
  }

  String getTitleBottomSheetRename(BuildContext context) {
    switch(this) {
      case LinShareNodeType.DRIVE:
        return AppLocalizations.of(context).rename_node(AppLocalizations.of(context).drive.toLowerCase());
      case LinShareNodeType.WORK_GROUP:
        return AppLocalizations.of(context).rename_node(AppLocalizations.of(context).workgroup.toLowerCase());
      case LinShareNodeType.WORK_SPACE:
        return AppLocalizations.of(context).rename_node(AppLocalizations.of(context).workspace.toLowerCase());
    }
  }

  String getIconNode(AppImagePaths appImagePaths) {
    switch(this) {
      case LinShareNodeType.DRIVE:
      case LinShareNodeType.WORK_SPACE:
        return appImagePaths.icDrive;
      case LinShareNodeType.WORK_GROUP:
        return appImagePaths.icWorkgroup;
    }
  }

  String getNameItemNode(BuildContext context) {
    switch(this) {
      case LinShareNodeType.DRIVE:
        return AppLocalizations.of(context).create_drive;
      case LinShareNodeType.WORK_GROUP:
        return AppLocalizations.of(context).create_workgroup;
      case LinShareNodeType.WORK_SPACE:
        return AppLocalizations.of(context).create_workspace;
    }
  }

  String getTitleRoleAddMember(BuildContext context) {
    switch(this) {
      case LinShareNodeType.DRIVE:
        return AppLocalizations.of(context).role_in_this_drive;
      case LinShareNodeType.WORK_SPACE:
        return AppLocalizations.of(context).role_in_this_workspace;
      default:
        return '';
    }
  }

  List<SharedSpaceRoleName> listRoleName() {
    switch(this) {
      case LinShareNodeType.DRIVE:
        return [
          SharedSpaceRoleName.DRIVE_READER,
          SharedSpaceRoleName.DRIVE_ADMIN,
          SharedSpaceRoleName.DRIVE_WRITER
        ];
      case LinShareNodeType.WORK_SPACE:
        return [
          SharedSpaceRoleName.WORK_SPACE_READER,
          SharedSpaceRoleName.WORK_SPACE_ADMIN,
          SharedSpaceRoleName.WORK_SPACE_WRITER
        ];
      default:
        return [];
    }
  }

  String getTitleModalSheetDeleteMember(BuildContext context, String memberName, String nodeNestedName) {
    switch(this) {
      case LinShareNodeType.DRIVE:
        return AppLocalizations.of(context).are_you_sure_you_want_to_delete_drive_member(memberName, nodeNestedName);
      case LinShareNodeType.WORK_SPACE:
        return AppLocalizations.of(context).are_you_sure_you_want_to_delete_work_space_member(memberName, nodeNestedName);
      default:
        return '';
    }
  }

  SharedSpaceRole getDefaultSharedSpaceRole() {
    switch(this) {
      case LinShareNodeType.DRIVE:
        return SharedSpaceRole.initialDrive();
      case LinShareNodeType.WORK_SPACE:
        return SharedSpaceRole.initialWorkspace();
      case LinShareNodeType.WORK_GROUP:
        return SharedSpaceRole.initial();
    }
  }
}