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
      ClientLogAction? clientLogAction,
      Map<AuditLogActionMessageParam, dynamic> actionMessages,
      bool isCurrentUserAuthor) {
    switch (this) {
      case AuditLogEntryType.WORK_GROUP:
        switch (clientLogAction) {
          case ClientLogAction.CREATE:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_create,
              AuditLogActionMessage.DETAILS: isCurrentUserAuthor
                  ? AppLocalizations.of(context).audit_action_message_create_workgroup_self(
                      actionMessages[AuditLogActionMessageParam.resourceName])
                  : AppLocalizations.of(context).audit_action_message_create_workgroup_other(
                      actionMessages[AuditLogActionMessageParam.authorName],
                      actionMessages[AuditLogActionMessageParam.resourceName])
            };
          case ClientLogAction.DELETE:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_delete,
              AuditLogActionMessage.DETAILS: isCurrentUserAuthor
                  ? AppLocalizations.of(context).audit_action_message_delete_workgroup_self(
                      actionMessages[AuditLogActionMessageParam.resourceName])
                  : AppLocalizations.of(context).audit_action_message_delete_workgroup_other(
                      actionMessages[AuditLogActionMessageParam.authorName],
                      actionMessages[AuditLogActionMessageParam.resourceName])
            };
          case ClientLogAction.UPDATE:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_update,
              AuditLogActionMessage.DETAILS: isCurrentUserAuthor
                  ? AppLocalizations.of(context).audit_action_message_update_workgroup_self(
                      actionMessages[AuditLogActionMessageParam.resourceName])
                  : AppLocalizations.of(context).audit_action_message_update_workgroup_other(
                      actionMessages[AuditLogActionMessageParam.authorName],
                      actionMessages[AuditLogActionMessageParam.resourceName])
            };
          default:
            return {};
        }
      case AuditLogEntryType.WORKGROUP_MEMBER:
        switch (clientLogAction) {
          case ClientLogAction.ADDITION:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_addition,
              AuditLogActionMessage.DETAILS: isCurrentUserAuthor
                  ? AppLocalizations.of(context).audit_action_message_add_member_self(
                      actionMessages[AuditLogActionMessageParam.resourceName],
                      actionMessages[AuditLogActionMessageParam.nameVarious])
                  : AppLocalizations.of(context).audit_action_message_add_member_other(
                      actionMessages[AuditLogActionMessageParam.authorName],
                      actionMessages[AuditLogActionMessageParam.resourceName],
                      actionMessages[AuditLogActionMessageParam.nameVarious])
            };
          case ClientLogAction.DELETE:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_delete,
              AuditLogActionMessage.DETAILS: isCurrentUserAuthor
                  ? AppLocalizations.of(context).audit_action_message_delete_member_self(
                      actionMessages[AuditLogActionMessageParam.resourceName],
                      actionMessages[AuditLogActionMessageParam.nameVarious])
                  : AppLocalizations.of(context).audit_action_message_delete_member_other(
                      actionMessages[AuditLogActionMessageParam.authorName],
                      actionMessages[AuditLogActionMessageParam.resourceName],
                      actionMessages[AuditLogActionMessageParam.nameVarious])
            };
          case ClientLogAction.UPDATE:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_update,
              AuditLogActionMessage.DETAILS: isCurrentUserAuthor
                  ? AppLocalizations.of(context).audit_action_message_update_member_self(
                      actionMessages[AuditLogActionMessageParam.resourceName],
                      actionMessages[AuditLogActionMessageParam.nameVarious])
                  : AppLocalizations.of(context).audit_action_message_update_member_other(
                      actionMessages[AuditLogActionMessageParam.authorName],
                      actionMessages[AuditLogActionMessageParam.resourceName],
                      actionMessages[AuditLogActionMessageParam.nameVarious])
            };
          default:
            return {};
        }
      case AuditLogEntryType.WORKGROUP_FOLDER:
        switch (clientLogAction) {
          case ClientLogAction.CREATE:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_create,
              AuditLogActionMessage.DETAILS: isCurrentUserAuthor
                  ? AppLocalizations.of(context).audit_action_message_create_folder_self(
                      actionMessages[AuditLogActionMessageParam.resourceName],
                      actionMessages[AuditLogActionMessageParam.nameVarious])
                  : AppLocalizations.of(context).audit_action_message_create_folder_other(
                      actionMessages[AuditLogActionMessageParam.authorName],
                      actionMessages[AuditLogActionMessageParam.resourceName],
                      actionMessages[AuditLogActionMessageParam.nameVarious])
            };
          case ClientLogAction.DELETE:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_delete,
              AuditLogActionMessage.DETAILS: isCurrentUserAuthor
                  ? AppLocalizations.of(context).audit_action_message_delete_folder_self(
                      actionMessages[AuditLogActionMessageParam.resourceName],
                      actionMessages[AuditLogActionMessageParam.nameVarious])
                  : AppLocalizations.of(context).audit_action_message_delete_folder_other(
                      actionMessages[AuditLogActionMessageParam.authorName],
                      actionMessages[AuditLogActionMessageParam.resourceName],
                      actionMessages[AuditLogActionMessageParam.nameVarious])
            };
          case ClientLogAction.UPDATE:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_update,
              AuditLogActionMessage.DETAILS: isCurrentUserAuthor
                  ? AppLocalizations.of(context).audit_action_message_update_folder_self(
                      actionMessages[AuditLogActionMessageParam.resourceName],
                      actionMessages[AuditLogActionMessageParam.nameVarious])
                  : AppLocalizations.of(context).audit_action_message_update_folder_other(
                      actionMessages[AuditLogActionMessageParam.authorName],
                      actionMessages[AuditLogActionMessageParam.resourceName],
                      actionMessages[AuditLogActionMessageParam.nameVarious])
            };
          case ClientLogAction.DOWNLOAD:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_download,
              AuditLogActionMessage.DETAILS: isCurrentUserAuthor
                  ? AppLocalizations.of(context).audit_action_message_download_folder_self(
                      actionMessages[AuditLogActionMessageParam.resourceName],
                      actionMessages[AuditLogActionMessageParam.nameVarious])
                  : AppLocalizations.of(context).audit_action_message_download_folder_other(
                      actionMessages[AuditLogActionMessageParam.authorName],
                      actionMessages[AuditLogActionMessageParam.resourceName],
                      actionMessages[AuditLogActionMessageParam.nameVarious])
            };
          default:
            return {};
        }
      case AuditLogEntryType.WORKGROUP_DOCUMENT:
        switch (clientLogAction) {
          case ClientLogAction.DELETE:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_delete,
              AuditLogActionMessage.DETAILS: isCurrentUserAuthor
                  ? AppLocalizations.of(context)
                      .audit_action_message_delete_workgroup_document_self(
                          actionMessages[AuditLogActionMessageParam.resourceName],
                          actionMessages[AuditLogActionMessageParam.nameVarious])
                  : AppLocalizations.of(context)
                      .audit_action_message_delete_workgroup_document_other(
                          actionMessages[AuditLogActionMessageParam.authorName],
                          actionMessages[AuditLogActionMessageParam.resourceName],
                          actionMessages[AuditLogActionMessageParam.nameVarious])
            };
          case ClientLogAction.UPDATE:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_update,
              AuditLogActionMessage.DETAILS: isCurrentUserAuthor
                  ? AppLocalizations.of(context)
                      .audit_action_message_update_workgroup_document_self(
                          actionMessages[AuditLogActionMessageParam.resourceName],
                          actionMessages[AuditLogActionMessageParam.nameVarious])
                  : AppLocalizations.of(context)
                      .audit_action_message_update_workgroup_document_other(
                          actionMessages[AuditLogActionMessageParam.authorName],
                          actionMessages[AuditLogActionMessageParam.resourceName],
                          actionMessages[AuditLogActionMessageParam.nameVarious])
            };
          case ClientLogAction.DOWNLOAD:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_download,
              AuditLogActionMessage.DETAILS: isCurrentUserAuthor
                  ? AppLocalizations.of(context)
                      .audit_action_message_download_workgroup_document_self(
                          actionMessages[AuditLogActionMessageParam.resourceName],
                          actionMessages[AuditLogActionMessageParam.nameVarious])
                  : AppLocalizations.of(context)
                      .audit_action_message_download_workgroup_document_other(
                          actionMessages[AuditLogActionMessageParam.authorName],
                          actionMessages[AuditLogActionMessageParam.resourceName],
                          actionMessages[AuditLogActionMessageParam.nameVarious])
            };
          case ClientLogAction.UPLOAD:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_upload,
              AuditLogActionMessage.DETAILS: isCurrentUserAuthor
                  ? AppLocalizations.of(context)
                      .audit_action_message_upload_workgroup_document_self(
                          actionMessages[AuditLogActionMessageParam.resourceName],
                          actionMessages[AuditLogActionMessageParam.nameVarious])
                  : AppLocalizations.of(context)
                      .audit_action_message_upload_workgroup_document_other(
                          actionMessages[AuditLogActionMessageParam.authorName],
                          actionMessages[AuditLogActionMessageParam.resourceName],
                          actionMessages[AuditLogActionMessageParam.nameVarious])
            };
          case ClientLogAction.COPY_FROM_PERSONAL_SPACE:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_copy,
              AuditLogActionMessage.DETAILS: isCurrentUserAuthor
                  ? AppLocalizations.of(context)
                      .audit_action_message_copy_document_from_personal_space_self(
                      actionMessages[AuditLogActionMessageParam.resourceName],
                      actionMessages[AuditLogActionMessageParam.nameVarious],
                    )
                  : AppLocalizations.of(context)
                      .audit_action_message_copy_document_from_personal_space_other(
                      actionMessages[AuditLogActionMessageParam.authorName],
                      actionMessages[AuditLogActionMessageParam.resourceName],
                      actionMessages[AuditLogActionMessageParam.nameVarious],
                    )
            };
          case ClientLogAction.COPY_FROM_RECEIVED_SHARE:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_copy,
              AuditLogActionMessage.DETAILS: isCurrentUserAuthor
                  ? AppLocalizations.of(context)
                      .audit_action_message_copy_document_from_received_share_self(
                      actionMessages[AuditLogActionMessageParam.resourceName],
                      actionMessages[AuditLogActionMessageParam.nameVarious],
                    )
                  : AppLocalizations.of(context)
                      .audit_action_message_copy_document_from_received_share_other(
                      actionMessages[AuditLogActionMessageParam.authorName],
                      actionMessages[AuditLogActionMessageParam.resourceName],
                      actionMessages[AuditLogActionMessageParam.nameVarious],
                    )
            };
          case ClientLogAction.COPY_FROM_SHARED_SPACE:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_copy,
              AuditLogActionMessage.DETAILS: isCurrentUserAuthor
                  ? AppLocalizations.of(context)
                      .audit_action_message_copy_document_from_shared_space_self(
                          actionMessages[AuditLogActionMessageParam.resourceName])
                  : AppLocalizations.of(context)
                      .audit_action_message_copy_document_from_shared_space_other(
                          actionMessages[AuditLogActionMessageParam.authorName],
                          actionMessages[AuditLogActionMessageParam.resourceName])
            };
          case ClientLogAction.COPY_TO_PERSONAL_SPACE:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_copy,
              AuditLogActionMessage.DETAILS: isCurrentUserAuthor
                  ? AppLocalizations.of(context)
                      .audit_action_message_copy_document_to_personal_space_self(
                      actionMessages[AuditLogActionMessageParam.resourceName],
                    )
                  : AppLocalizations.of(context)
                      .audit_action_message_copy_document_to_personal_space_other(
                      actionMessages[AuditLogActionMessageParam.authorName],
                      actionMessages[AuditLogActionMessageParam.resourceName],
                    )
            };
          case ClientLogAction.COPY_TO_SHARED_SPACE:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_copy,
              AuditLogActionMessage.DETAILS: isCurrentUserAuthor
                  ? AppLocalizations.of(context)
                      .audit_action_message_copy_document_to_shared_space_self(
                          actionMessages[AuditLogActionMessageParam.nameVarious])
                  : AppLocalizations.of(context)
                      .audit_action_message_copy_document_to_shared_space_other(
                          actionMessages[AuditLogActionMessageParam.authorName],
                          actionMessages[AuditLogActionMessageParam.nameVarious])
            };
          default:
            return {};
        }
      case AuditLogEntryType.WORKGROUP_DOCUMENT_REVISION:
        switch (clientLogAction) {
          case ClientLogAction.UPLOAD_REVISION:
            return {
              AuditLogActionMessage.TITLE:
                  AppLocalizations.of(context).audit_action_title_upload_revision,
              AuditLogActionMessage.DETAILS: AppLocalizations.of(context)
                  .audit_action_message_upload_revision(
                      actionMessages[AuditLogActionMessageParam.resourceName],
                      actionMessages[AuditLogActionMessageParam.nameVarious])
            };
          case ClientLogAction.DELETE_REVISION:
            return {
              AuditLogActionMessage.TITLE:
                  AppLocalizations.of(context).audit_action_title_delete_revision,
              AuditLogActionMessage.DETAILS: AppLocalizations.of(context)
                  .audit_action_message_delete_revision(
                      actionMessages[AuditLogActionMessageParam.resourceName],
                      actionMessages[AuditLogActionMessageParam.nameVarious])
            };
          case ClientLogAction.DOWNLOAD_REVISION:
            return {
              AuditLogActionMessage.TITLE:
                  AppLocalizations.of(context).audit_action_title_download_revision,
              AuditLogActionMessage.DETAILS: AppLocalizations.of(context)
                  .audit_action_message_download_revision(
                      actionMessages[AuditLogActionMessageParam.authorName],
                      actionMessages[AuditLogActionMessageParam.resourceName],
                      actionMessages[AuditLogActionMessageParam.nameVarious])
            };
          case ClientLogAction.RESTORE_REVISION:
            return {
              AuditLogActionMessage.TITLE:
                  AppLocalizations.of(context).audit_action_title_restore_revision,
              AuditLogActionMessage.DETAILS: AppLocalizations.of(context)
                  .audit_action_message_copy_revision_from_shared_space(
                      actionMessages[AuditLogActionMessageParam.resourceName])
            };
          default:
            return {};
        }
      case AuditLogEntryType.UPLOAD_REQUEST:
        switch (clientLogAction) {
          case ClientLogAction.CREATE:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_create,
              AuditLogActionMessage.DETAILS: AppLocalizations.of(context).audit_action_message_create_upload_request_recipient
            };
          case ClientLogAction.UPDATE:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_update,
              AuditLogActionMessage.DETAILS: AppLocalizations.of(context).audit_action_message_update_upload_request_recipient
            };
          default:
            return {};
        }
      case AuditLogEntryType.UPLOAD_REQUEST_URL:
        switch (clientLogAction) {
          case ClientLogAction.CREATE:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_create,
              AuditLogActionMessage.DETAILS: AppLocalizations.of(context).audit_action_message_create_upload_request_url(
                  actionMessages[AuditLogActionMessageParam.resourceName])
            };
          default:
            return {};
        }
      case AuditLogEntryType.UPLOAD_REQUEST_ENTRY:
        switch (clientLogAction) {
          case ClientLogAction.CREATE:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_create,
              AuditLogActionMessage.DETAILS: AppLocalizations.of(context).audit_action_message_create_upload_request_entry(
                  actionMessages[AuditLogActionMessageParam.resourceName])
            };
          case ClientLogAction.DOWNLOAD:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_download,
              AuditLogActionMessage.DETAILS: isCurrentUserAuthor
                  ? AppLocalizations.of(context).audit_action_message_download_upload_request_entry_self(
                      actionMessages[AuditLogActionMessageParam.resourceName])
                  : AppLocalizations.of(context).audit_action_message_download_upload_request_entry_other(
                      actionMessages[AuditLogActionMessageParam.authorName],
                      actionMessages[AuditLogActionMessageParam.resourceName])
            };
          case ClientLogAction.COPY_TO_PERSONAL_SPACE:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_copy,
              AuditLogActionMessage.DETAILS: isCurrentUserAuthor
                  ? AppLocalizations.of(context).audit_action_message_copy_document_to_personal_space_self(
                      actionMessages[AuditLogActionMessageParam.resourceName])
                  : AppLocalizations.of(context).audit_action_message_copy_document_to_personal_space_other(
                      actionMessages[AuditLogActionMessageParam.authorName],
                      actionMessages[AuditLogActionMessageParam.resourceName],
              )
            };
          case ClientLogAction.COPY_TO_SHARED_SPACE:
            return {
              AuditLogActionMessage.TITLE: AppLocalizations.of(context).audit_action_title_copy,
              AuditLogActionMessage.DETAILS: isCurrentUserAuthor
                  ? AppLocalizations.of(context).audit_action_message_copy_document_to_shared_space_self(
                      actionMessages[AuditLogActionMessageParam.nameVarious])
                  : AppLocalizations.of(context).audit_action_message_copy_document_to_shared_space_other(
                      actionMessages[AuditLogActionMessageParam.authorName],
                      actionMessages[AuditLogActionMessageParam.nameVarious])
            };
          default:
            return {};
        }
      default:
        return {};
    }
  }
}
