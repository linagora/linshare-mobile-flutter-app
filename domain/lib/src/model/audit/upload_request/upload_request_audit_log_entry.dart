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
import 'package:domain/src/model/audit/upload_request/upload_request_audit_log_action_field.dart';

class UploadRequestAuditLogEntry extends AuditLogEntryUser {
  final UploadRequest? resource;
  final UploadRequest? resourceUpdated;

  UploadRequestAuditLogEntry(
      AuditLogEntryId auditLogEntryId,
      AuditLogResourceId resourceId,
      AuditLogResourceId fromResourceId,
      DateTime creationDate,
      Account? authUser,
      AuditLogEntryType? type,
      LogAction? action,
      LogActionCause? cause,
      Account? actor,
      this.resource,
      this.resourceUpdated
  ) : super(auditLogEntryId, resourceId, fromResourceId, creationDate, authUser, type, action, cause, actor);

  @override
  List<Object?> get props => [
     ...super.props,
    resource,
    resourceUpdated
  ];

  @override
  Map<AuditLogActionMessageParam, dynamic> getActionMessageComponents() {
    return {
      AuditLogActionMessageParam.authorName : actor != null ? actor?.name : '',
      AuditLogActionMessageParam.resourceName : resource != null ? resource?.subject : '',
      AuditLogActionMessageParam.nameVarious : resource != null ? resource?.subject : ''
    };
  }

  @override
  String getResourceName() {
    return resource?.subject ?? '';
  }

  @override
  List<AuditLogActionField> getListFieldChanged() {
    if (action == LogAction.UPDATE && resource != null && resourceUpdated != null) {
      var listContents = List<AuditLogActionField>.empty(growable: true);

      if (resourceUpdated!.statusUpdated == true) {
        listContents.add(UploadRequestAuditLogActionField(
            field: UploadRequestField.status,
            oldValue: resource!.status,
            newValue: resourceUpdated!.status));
      }
      if (resource!.locale != resourceUpdated!.locale) {
        listContents.add(UploadRequestAuditLogActionField(
            field: UploadRequestField.notificationLanguage,
            oldValue: resource!.locale,
            newValue: resourceUpdated!.locale));
      }
      if (resource!.canDeleteDocument != resourceUpdated!.canDeleteDocument) {
        listContents.add(UploadRequestAuditLogActionField(
            field: UploadRequestField.allowDeletion,
            oldValue: resource!.canDeleteDocument,
            newValue: resourceUpdated!.canDeleteDocument));
      }
      if (resource!.canClose != resourceUpdated!.canClose) {
        listContents.add(UploadRequestAuditLogActionField(
            field: UploadRequestField.allowClosure,
            oldValue: resource!.canClose,
            newValue: resourceUpdated!.canClose));
      }
      if (resource!.maxFileCount != resourceUpdated!.maxFileCount) {
        listContents.add(UploadRequestAuditLogActionField(
            field: UploadRequestField.maxNumberOfFiles,
            oldValue: resource!.maxFileCount,
            newValue: resourceUpdated!.maxFileCount));
      }
      if (resource!.maxFileSize != resourceUpdated!.maxFileSize) {
        listContents.add(UploadRequestAuditLogActionField(
            field: UploadRequestField.maxSizePerFile,
            oldValue: resource!.maxFileSize,
            newValue: resourceUpdated!.maxFileSize));
      }
      if (resource!.maxDepositSize != resourceUpdated!.maxDepositSize) {
        listContents.add(UploadRequestAuditLogActionField(
            field: UploadRequestField.maxTotalFileSize,
            oldValue: resource!.maxDepositSize,
            newValue: resourceUpdated!.maxDepositSize));
      }
      if (resource!.expiryDate != resourceUpdated!.expiryDate) {
        listContents.add(UploadRequestAuditLogActionField(
            field: UploadRequestField.expirationDate,
            oldValue: resource!.expiryDate,
            newValue: resourceUpdated!.expiryDate));
      }
      if (resource!.activationDate != resourceUpdated!.activationDate) {
        listContents.add(UploadRequestAuditLogActionField(
            field: UploadRequestField.activationDate,
            oldValue: resource!.activationDate,
            newValue: resourceUpdated!.activationDate));
      }
      if (resource!.notificationDate != resourceUpdated!.notificationDate) {
        listContents.add(UploadRequestAuditLogActionField(
            field: UploadRequestField.notificationDate,
            oldValue: resource!.notificationDate,
            newValue: resourceUpdated!.notificationDate));
      }
      return listContents;
    }
    return [];
  }
}