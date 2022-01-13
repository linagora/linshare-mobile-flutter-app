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
// You should have received a COPY of the GNU Affero General Public License and its
// applicable Additional Terms for LinShare along with this program. If not, see
// <http://www.gnu.org/licenses/> for the GNU Affero General Public License version
//  3 and <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf> for
//  the Additional Terms applicable to LinShare software.

import 'package:domain/domain.dart';

extension AuditLogEntryTypeExtension on AuditLogEntryType {

  String get value {
    switch(this) {
      case AuditLogEntryType.WORKGROUP:
        return 'WORKGROUP';
      case AuditLogEntryType.WORKGROUP_MEMBER:
        return 'WORKGROUP_MEMBER';
      case AuditLogEntryType.WORKGROUP_FOLDER:
        return 'WORKGROUP_FOLDER';
      case AuditLogEntryType.WORKGROUP_DOCUMENT:
        return 'WORKGROUP_DOCUMENT';
      case AuditLogEntryType.WORKGROUP_DOCUMENT_REVISION:
        return 'WORKGROUP_DOCUMENT_REVISION';
      case AuditLogEntryType.UPLOAD_REQUEST:
        return 'UPLOAD_REQUEST';
      case AuditLogEntryType.UPLOAD_REQUEST_URL:
        return 'UPLOAD_REQUEST_URL';
      case AuditLogEntryType.UPLOAD_REQUEST_ENTRY:
        return 'UPLOAD_REQUEST_ENTRY';
      default:
        return toString();
    }
  }

  ClientLogAction generateClientLogAction(AuditLogEntry auditLogEntry) {
    switch(this) {
      case AuditLogEntryType.WORKGROUP:
        if (auditLogEntry.action == LogAction.CREATE) {
          return ClientLogAction.CREATE;
        } else if (auditLogEntry.action == LogAction.DELETE) {
          return ClientLogAction.DELETE;
        }
        return ClientLogAction.UPDATE;
      case AuditLogEntryType.WORKGROUP_MEMBER:
        if (auditLogEntry.action == LogAction.CREATE) {
          return ClientLogAction.ADDITION;
        } else if (auditLogEntry.action == LogAction.DELETE) {
          return ClientLogAction.DELETE;
        }
        return ClientLogAction.UPDATE;
      case AuditLogEntryType.WORKGROUP_FOLDER:
        if (auditLogEntry.action == LogAction.CREATE) {
          return ClientLogAction.CREATE;
        } else if (auditLogEntry.action == LogAction.DELETE) {
          return ClientLogAction.DELETE;
        } else if (auditLogEntry.action == LogAction.DOWNLOAD) {
          return ClientLogAction.DOWNLOAD;
        }
        return ClientLogAction.UPDATE;
      case AuditLogEntryType.WORKGROUP_DOCUMENT:
        if (auditLogEntry.cause == LogActionCause.COPY) {
          return getClientLogActionForCopyDocumentAction(auditLogEntry);
        }
        return mappingClientLogAction(auditLogEntry.action);
      case AuditLogEntryType.WORKGROUP_DOCUMENT_REVISION:
        return getClientLogActionForCopyDocumentAction(auditLogEntry);
      case AuditLogEntryType.UPLOAD_REQUEST:
      case AuditLogEntryType.UPLOAD_REQUEST_URL:
        if (auditLogEntry.action == LogAction.CREATE) {
          return ClientLogAction.CREATE;
        }
        return ClientLogAction.UPDATE;
      case AuditLogEntryType.UPLOAD_REQUEST_ENTRY:
        return getClientLogActionForCopyDocumentAction(auditLogEntry);
      default:
        return ClientLogAction.UPDATE;
    }
  }

  ClientLogAction getClientLogActionForCopyDocumentAction(AuditLogEntry auditLogEntry) {
      if (auditLogEntry is WorkGroupDocumentAuditLogEntry) {
        if (auditLogEntry.copiedFrom != null) {
          switch(auditLogEntry.copiedFrom!.kind!) {
            case SpaceType.PERSONAL_SPACE:
              return ClientLogAction.COPY_FROM_PERSONAL_SPACE;
            case SpaceType.RECEIVED_SHARE:
              return ClientLogAction.COPY_FROM_RECEIVED_SHARE;
            case SpaceType.SHARED_SPACE:
              return ClientLogAction.COPY_FROM_SHARED_SPACE;
          }
        }

        if (auditLogEntry.copiedTo != null) {
            if (auditLogEntry.copiedTo!.kind == SpaceType.SHARED_SPACE) {
              return ClientLogAction.COPY_TO_SHARED_SPACE;
            } else {
              return ClientLogAction.COPY_TO_PERSONAL_SPACE;
            }
        }
      } else if (auditLogEntry is WorkGroupDocumentRevisionAuditLogEntry) {
        if (auditLogEntry.copiedFrom != null && auditLogEntry.copiedFrom!.kind == SpaceType.SHARED_SPACE) {
          return ClientLogAction.RESTORE_REVISION;
        }
      } else if (auditLogEntry is UploadRequestEntryAuditLogEntry) {
        if (auditLogEntry.copiedTo != null) {
          if (auditLogEntry.copiedTo!.kind == SpaceType.PERSONAL_SPACE) {
            return ClientLogAction.COPY_TO_PERSONAL_SPACE;
          } else {
            return ClientLogAction.COPY_TO_SHARED_SPACE;
          }
        }
      }

      return mappingClientLogAction(auditLogEntry.action);
  }

  ClientLogAction mappingClientLogAction(LogAction? logAction) {
    switch(logAction) {
      case LogAction.CREATE:
        if (this == AuditLogEntryType.WORKGROUP_DOCUMENT_REVISION) {
          return ClientLogAction.UPLOAD_REVISION;
        }
        if (this == AuditLogEntryType.UPLOAD_REQUEST_ENTRY) {
          return ClientLogAction.CREATE;
        }
        return ClientLogAction.UPLOAD;
      case LogAction.DELETE:
        if (this == AuditLogEntryType.WORKGROUP_DOCUMENT_REVISION) {
          return ClientLogAction.DELETE_REVISION;
        }
        return ClientLogAction.DELETE;
      case LogAction.DOWNLOAD:
        if (this == AuditLogEntryType.WORKGROUP_DOCUMENT_REVISION) {
          return ClientLogAction.DOWNLOAD_REVISION;
        }
        return ClientLogAction.DOWNLOAD;
      default:
        return ClientLogAction.UPDATE;
    }
  }
}