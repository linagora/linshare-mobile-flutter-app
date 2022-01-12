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
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/media_type_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/audit_log_entry_type_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/datetime_extension.dart';

extension AuditLogEntryUserExtension on AuditLogEntryUser {

  String getAuditLogIconPath(AppImagePaths imagePath) {
    switch (type) {
      case AuditLogEntryType.WORKGROUP:
        return imagePath.icSharedSpace;
      case AuditLogEntryType.WORKGROUP_MEMBER:
        return imagePath.icAddMember;
      case AuditLogEntryType.WORKGROUP_FOLDER:
        return imagePath.icFolder;
      case AuditLogEntryType.WORKGROUP_DOCUMENT:
      case AuditLogEntryType.WORKGROUP_DOCUMENT_REVISION:
        return getWorkGroupDocumentAuditLogIconPath(this, imagePath);
      case AuditLogEntryType.UPLOAD_REQUEST:
        return imagePath.icAddMember;
      case AuditLogEntryType.UPLOAD_REQUEST_URL:
        return imagePath.icContextItemShare;
      default:
        return imagePath.icFileTypeFile;
    }
  }

  String getWorkGroupDocumentAuditLogIconPath(AuditLogEntryUser  auditLogEntryUser, AppImagePaths imagePath) {
    if (auditLogEntryUser is WorkGroupDocumentAuditLogEntry) {
      return getWorkGroupNodeIconPath(imagePath, auditLogEntryUser.resource);
    } else if (auditLogEntryUser is WorkGroupDocumentRevisionAuditLogEntry) {
      return getWorkGroupNodeIconPath(imagePath, auditLogEntryUser.resource);
    }
    return imagePath.icFileTypeFile;
  }

  String getWorkGroupNodeIconPath(AppImagePaths imagePath, WorkGroupNode? workGroupNode) {
    if (workGroupNode is WorkGroupDocument) {
      return workGroupNode.mediaType.getFileTypeImagePath(imagePath);
    }
    return imagePath.icFolder;
  }

  Map<AuditLogActionDetail, dynamic> getActionDetails(BuildContext context, String loggedUserId) {
    final clientLogAction = type?.generateClientLogAction(this);

    final messageComponents = getActionMessageComponents();
    final authorName = messageComponents[AuditLogActionMessageParam.authorName];
    final isCurrentUserAuthor = authUser?.accountId.uuid == loggedUserId;
    messageComponents[AuditLogActionMessageParam.authorName] = authorName;

    final actionTitle = type?.getAuditLogMapping(context, clientLogAction, messageComponents, isCurrentUserAuthor)[AuditLogActionMessage.TITLE];
    final actionDetails = type?.getAuditLogMapping(context, clientLogAction, messageComponents, isCurrentUserAuthor)[AuditLogActionMessage.DETAILS];

    return {AuditLogActionDetail.TITLE : actionTitle, AuditLogActionDetail.DETAIL : actionDetails};
  }

  String getLogTimeAndByActor(BuildContext context, String loggedUserId) {
    final logTime = creationDate.getMMMddyyyyFormatString();
    final byActor = AppLocalizations.of(context).audit_log_actor(
        authUser?.accountId.uuid == loggedUserId
            ? AppLocalizations.of(context).me
            : (actor?.name ?? ''));
    return logTime + ' | ' + byActor;
  }
}