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
import 'package:flutter/widgets.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';

extension SharedSpaceRoleNameExtension on SharedSpaceRoleName {
  String getRoleName(BuildContext context) {
    switch (this) {
      case SharedSpaceRoleName.ADMIN:
      case SharedSpaceRoleName.DRIVE_ADMIN:
      case SharedSpaceRoleName.WORK_SPACE_ADMIN:
        return AppLocalizations.of(context).admin;
      case SharedSpaceRoleName.READER:
      case SharedSpaceRoleName.DRIVE_READER:
      case SharedSpaceRoleName.WORK_SPACE_READER:
        return AppLocalizations.of(context).reader;
      case SharedSpaceRoleName.CONTRIBUTOR:
        return AppLocalizations.of(context).contributor;
      case SharedSpaceRoleName.WRITER:
      case SharedSpaceRoleName.DRIVE_WRITER:
      case SharedSpaceRoleName.WORK_SPACE_WRITER:
        return AppLocalizations.of(context).writer;
      default:
        return AppLocalizations.of(context).unknown_role;
    }
  }

  String getWorkgroupRoleNameInsideDriveOrWorkspace(BuildContext context) {
    switch (this) {
      case SharedSpaceRoleName.ADMIN:
        return AppLocalizations.of(context).workgroup_admin;
      case SharedSpaceRoleName.READER:
        return AppLocalizations.of(context).workgroup_reader;
      case SharedSpaceRoleName.CONTRIBUTOR:
        return AppLocalizations.of(context).workgroup_contributor;
      case SharedSpaceRoleName.WRITER:
        return AppLocalizations.of(context).workgroup_writer;
      default:
        return AppLocalizations.of(context).unknown_role;
    }
  }

  String getDriveRoleName(BuildContext context) {
    switch (this) {
      case SharedSpaceRoleName.DRIVE_ADMIN:
        return AppLocalizations.of(context).drive_admin;
      case SharedSpaceRoleName.DRIVE_READER:
        return AppLocalizations.of(context).drive_reader;
      case SharedSpaceRoleName.DRIVE_WRITER:
        return AppLocalizations.of(context).drive_writer;
      default:
        return AppLocalizations.of(context).unknown_role;
    }
  }

  String getWorkspaceRoleName(BuildContext context) {
    switch (this) {
      case SharedSpaceRoleName.WORK_SPACE_ADMIN:
        return AppLocalizations.of(context).workspace_admin;
      case SharedSpaceRoleName.WORK_SPACE_READER:
        return AppLocalizations.of(context).workspace_reader;
      case SharedSpaceRoleName.WORK_SPACE_WRITER:
        return AppLocalizations.of(context).workspace_writer;
      default:
        return AppLocalizations.of(context).unknown_role;
    }
  }
}
