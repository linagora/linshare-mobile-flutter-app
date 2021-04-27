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
import 'package:data/data.dart';
import 'package:data/src/network/model/converter/audit_log_entry_id_converter.dart';
import 'package:data/src/network/model/converter/audit_log_resource_id_converter.dart';
import 'package:data/src/network/model/converter/datetime_converter.dart';
import 'package:data/src/network/model/shared_space_activities/audit_log_entry_user_dto.dart';
import 'package:domain/domain.dart';
import 'package:json_annotation/json_annotation.dart';

part 'shared_space_node_audit_log_entry_dto.g.dart';

@JsonSerializable()
@DatetimeConverter()
@AuditLogEntryIdConverter()
@AuditLogResourceIdConverter()
class SharedSpaceNodeAuditLogEntryDto extends AuditLogEntryUserDto {

  final SharedSpaceNodeNestedResponse? resource;
  final SharedSpaceNodeNestedResponse? resourceUpdated;

  SharedSpaceNodeAuditLogEntryDto(
      AuditLogEntryId auditLogEntryId,
      AuditLogResourceId resourceId,
      AuditLogResourceId fromResourceId,
      DateTime creationDate,
      AccountDto? authUser,
      AuditLogEntryType type,
      LogAction action,
      LogActionCause? cause,
      AccountDto? actor,
      this.resource,
      this.resourceUpdated
      ) : super(auditLogEntryId, resourceId, fromResourceId, creationDate, authUser, type, action, cause, actor);

  @override
  List<Object?> get props => [
    ...super.props,
    resource,
    resourceUpdated
  ];

  factory SharedSpaceNodeAuditLogEntryDto.fromJson(Map<String, dynamic> json) => _$SharedSpaceNodeAuditLogEntryDtoFromJson(json);
  Map<String, dynamic> toJson() => _$SharedSpaceNodeAuditLogEntryDtoToJson(this);
}

extension SharedSpaceNodeAuditLogEntryDtoExtension on SharedSpaceNodeAuditLogEntryDto {
  SharedSpaceNodeAuditLogEntry toSharedSpaceNodeAuditLogEntry() => SharedSpaceNodeAuditLogEntry(
      auditLogEntryId,
      resourceId,
      fromResourceId,
      creationDate ,
      authUser?.toAccount(),
      type,
      action,
      cause ?? LogActionCause.UNDEFINED,
      actor?.toAccount(),
      resource?.toSharedSpaceNodeNested(),
      resourceUpdated?.toSharedSpaceNodeNested()
  );
}