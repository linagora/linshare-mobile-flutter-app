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
// for more DETAILS.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for
// more DETAILS.
// You should have received a copy of the GNU Affero General Public License and its
// applicable Additional Terms for LinShare along with this program. If not, see
// <http://www.gnu.org/licenses/> for the GNU Affero General Public License version
//  3 and <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf> for
//  the Additional Terms applicable to LinShare software.

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';

extension AuditLogEntryTypeExtension on AuditLogEntryType {

  Map<AuditLogActionMessage, String> getAuditLogMapping(
      BuildContext context,
      ClientLogAction clientLogAction,
      Map<AuditLogActionMessageParam, dynamic> actionMessages,
      bool isAuthorMe)
  {
    switch(this) {
      case AuditLogEntryType.WORKGROUP:
        switch(clientLogAction) {
          case ClientLogAction.CREATE:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_create,
              AuditLogActionMessage.DETAILS: AppLocalizations.of(context).audit_action_message_create_workgroup(
                      actionMessages[AuditLogActionMessageParam.authorName],
                      actionMessages[AuditLogActionMessageParam.resourceName]
                  )
            };
          case ClientLogAction.DELETE:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_delete,
              AuditLogActionMessage.DETAILS: AppLocalizations.of(context).audit_action_message_delete_workgroup(
                      actionMessages[AuditLogActionMessageParam.authorName],
                      actionMessages[AuditLogActionMessageParam.resourceName]
                  )
            };
          case ClientLogAction.UPDATE:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_update,
              AuditLogActionMessage.DETAILS: AppLocalizations.of(context).audit_action_message_update_workgroup(
                      actionMessages[AuditLogActionMessageParam.authorName],
                      actionMessages[AuditLogActionMessageParam.resourceName]
                  )
            };
          default:
            return {};
        }
        break;
      case AuditLogEntryType.WORKGROUP_MEMBER:
        switch(clientLogAction) {
          case ClientLogAction.ADDITION:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_addition,
              AuditLogActionMessage.DETAILS: AppLocalizations.of(context).audit_action_message_add_member(
                      actionMessages[AuditLogActionMessageParam.authorName],
                      actionMessages[AuditLogActionMessageParam.resourceName],
                      actionMessages[AuditLogActionMessageParam.nameVarious]
                  )
            };
          case ClientLogAction.DELETE:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_delete,
              AuditLogActionMessage.DETAILS: AppLocalizations.of(context).audit_action_message_delete_member(
                      actionMessages[AuditLogActionMessageParam.authorName],
                      actionMessages[AuditLogActionMessageParam.resourceName],
                      actionMessages[AuditLogActionMessageParam.nameVarious]
                  )
            };
          case ClientLogAction.UPDATE:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_update,
              AuditLogActionMessage.DETAILS: AppLocalizations.of(context).audit_action_message_update_member(
                      actionMessages[AuditLogActionMessageParam.authorName],
                      actionMessages[AuditLogActionMessageParam.resourceName],
                      actionMessages[AuditLogActionMessageParam.nameVarious]
                  )
            };
          default:
            return {};
        }
        break;
      case AuditLogEntryType.WORKGROUP_FOLDER:
        switch(clientLogAction) {
          case ClientLogAction.CREATE:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_create,
              AuditLogActionMessage.DETAILS: AppLocalizations.of(context).audit_action_message_create_folder(
                      actionMessages[AuditLogActionMessageParam.authorName],
                      actionMessages[AuditLogActionMessageParam.resourceName],
                      actionMessages[AuditLogActionMessageParam.nameVarious]
                  )
            };
          case ClientLogAction.DELETE:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_delete,
              AuditLogActionMessage.DETAILS: AppLocalizations.of(context).audit_action_message_delete_folder(
                      actionMessages[AuditLogActionMessageParam.authorName],
                      actionMessages[AuditLogActionMessageParam.resourceName],
                      actionMessages[AuditLogActionMessageParam.nameVarious]
                  )
            };
          case ClientLogAction.UPDATE:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_update,
              AuditLogActionMessage.DETAILS: AppLocalizations.of(context).audit_action_message_update_folder(
                      actionMessages[AuditLogActionMessageParam.authorName],
                      actionMessages[AuditLogActionMessageParam.resourceName],
                      actionMessages[AuditLogActionMessageParam.nameVarious]
                  )
            };
          case ClientLogAction.DOWNLOAD:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_download,
              AuditLogActionMessage.DETAILS: AppLocalizations.of(context).audit_action_message_download_folder(
                      actionMessages[AuditLogActionMessageParam.authorName],
                      actionMessages[AuditLogActionMessageParam.resourceName],
                      actionMessages[AuditLogActionMessageParam.nameVarious]
                  )
            };
          default:
            return {};
        }
        break;
      case AuditLogEntryType.WORKGROUP_DOCUMENT:
        switch(clientLogAction) {
          case ClientLogAction.DELETE:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_delete,
              AuditLogActionMessage.DETAILS: AppLocalizations.of(context).audit_action_message_delete_workgroup_document(
                      actionMessages[AuditLogActionMessageParam.authorName],
                      actionMessages[AuditLogActionMessageParam.resourceName],
                      actionMessages[AuditLogActionMessageParam.nameVarious]
                  )
            };
          case ClientLogAction.UPDATE:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_update,
              AuditLogActionMessage.DETAILS: AppLocalizations.of(context).audit_action_message_update_workgroup_document(
                      actionMessages[AuditLogActionMessageParam.authorName],
                      actionMessages[AuditLogActionMessageParam.resourceName],
                      actionMessages[AuditLogActionMessageParam.nameVarious]
                  )
            };
          case ClientLogAction.DOWNLOAD:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_download,
              AuditLogActionMessage.DETAILS: AppLocalizations.of(context).audit_action_message_download_workgroup_document(
                      actionMessages[AuditLogActionMessageParam.authorName],
                      actionMessages[AuditLogActionMessageParam.resourceName],
                      actionMessages[AuditLogActionMessageParam.nameVarious]
                  )
            };
          case ClientLogAction.UPLOAD:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_upload,
              AuditLogActionMessage.DETAILS: AppLocalizations.of(context).audit_action_message_upload_workgroup_document(
                      actionMessages[AuditLogActionMessageParam.authorName],
                      actionMessages[AuditLogActionMessageParam.resourceName],
                      actionMessages[AuditLogActionMessageParam.nameVarious]
                  )
            };
          case ClientLogAction.COPY_FROM_PERSONAL_SPACE:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_copy,
              AuditLogActionMessage.DETAILS: AppLocalizations.of(context).audit_action_message_copy_document_from_personal_space(
                      actionMessages[AuditLogActionMessageParam.authorName],
                      actionMessages[AuditLogActionMessageParam.resourceName],
                      actionMessages[AuditLogActionMessageParam.nameVarious],
                      isAuthorMe ? AppLocalizations.of(context).your : AppLocalizations.of(context).his
                  )
            };
          case ClientLogAction.COPY_FROM_RECEIVED_SHARE:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_copy,
              AuditLogActionMessage.DETAILS: AppLocalizations.of(context).audit_action_message_copy_document_from_received_share(
                      actionMessages[AuditLogActionMessageParam.authorName],
                      actionMessages[AuditLogActionMessageParam.resourceName],
                      actionMessages[AuditLogActionMessageParam.nameVarious],
                      isAuthorMe ? AppLocalizations.of(context).your : AppLocalizations.of(context).his
                  )
            };
          case ClientLogAction.COPY_FROM_SHARED_SPACE:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_copy,
              AuditLogActionMessage.DETAILS: AppLocalizations.of(context).audit_action_message_copy_document_from_shared_space(
                      actionMessages[AuditLogActionMessageParam.authorName],
                      actionMessages[AuditLogActionMessageParam.resourceName]
                  )
            };
          case ClientLogAction.COPY_TO_PERSONAL_SPACE:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_copy,
              AuditLogActionMessage.DETAILS: AppLocalizations.of(context).audit_action_message_copy_document_to_personal_space(
                      actionMessages[AuditLogActionMessageParam.authorName],
                      actionMessages[AuditLogActionMessageParam.resourceName],
                      isAuthorMe ? AppLocalizations.of(context).your : AppLocalizations.of(context).his
                  )
            };
          case ClientLogAction.COPY_TO_SHARED_SPACE:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_copy,
              AuditLogActionMessage.DETAILS: AppLocalizations.of(context).audit_action_message_copy_document_to_shared_space(
                      actionMessages[AuditLogActionMessageParam.authorName],
                      actionMessages[AuditLogActionMessageParam.nameVarious]
                  )
            };
          default:
            return {};
        }
        break;
      case AuditLogEntryType.WORKGROUP_DOCUMENT_REVISION:
        switch(clientLogAction) {
          case ClientLogAction.UPLOAD_REVISION:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_upload_revision,
              AuditLogActionMessage.DETAILS: AppLocalizations.of(context).audit_action_message_upload_revision(
                      actionMessages[AuditLogActionMessageParam.resourceName],
                      actionMessages[AuditLogActionMessageParam.nameVarious]
                  )
            };
          case ClientLogAction.DELETE_REVISION:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_delete_revision,
              AuditLogActionMessage.DETAILS: AppLocalizations.of(context).audit_action_message_delete_revision(
                      actionMessages[AuditLogActionMessageParam.resourceName],
                      actionMessages[AuditLogActionMessageParam.nameVarious]
                  )
            };
          case ClientLogAction.DOWNLOAD_REVISION:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_download_revision,
              AuditLogActionMessage.DETAILS: AppLocalizations.of(context).audit_action_message_download_revision(
                      actionMessages[AuditLogActionMessageParam.authorName],
                      actionMessages[AuditLogActionMessageParam.resourceName],
                      actionMessages[AuditLogActionMessageParam.nameVarious]
                  )
            };
          case ClientLogAction.RESTORE_REVISION:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_restore_revision,
              AuditLogActionMessage.DETAILS: AppLocalizations.of(context).audit_action_message_copy_revision_from_shared_space(
                      actionMessages[AuditLogActionMessageParam.resourceName]
                  )
            };
          default:
            return {};
        }
        break;
      default:
        return {};
    }
  }
}