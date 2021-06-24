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

import 'package:data/src/local/config/work_group_node_table.dart';
import 'package:data/src/local/converter/account_id_converter.dart';
import 'package:data/src/local/converter/account_type_converter.dart';
import 'package:data/src/local/converter/boolean_converter.dart';
import 'package:data/src/local/converter/datetime_converter.dart';
import 'package:data/src/local/converter/media_type_converter.dart';
import 'package:data/src/local/converter/shared_space_id_converter.dart';
import 'package:data/src/local/converter/work_group_node_id_converter.dart';
import 'package:data/src/local/converter/work_group_node_type_converter.dart';
import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:http_parser/http_parser.dart';

part 'work_group_node_cache.g.dart';

@JsonSerializable()
@DatetimeConverter()
@BooleanConverter()
@SharedSpaceIdConverter()
@WorkGroupNodeIdConverter()
@AccountIdConverter()
@WorkGroupNodeTypeConverter()
@AccountTypeConverter()
@MediaTypeConverter()
class WorkGroupNodeCache with EquatableMixin {

  @JsonKey(name: WorkGroupNodeTable.NODE_ID)
  final WorkGroupNodeId nodeId;
  @JsonKey(name: WorkGroupNodeTable.SHARED_SPACE_ID)
  final SharedSpaceId sharedSpaceId;
  @JsonKey(name: WorkGroupNodeTable.PARENT_NODE_ID)
  final WorkGroupNodeId parentNodeId;
  @JsonKey(name: WorkGroupNodeTable.CREATION_DATE)
  final DateTime? creationDate;
  @JsonKey(name: WorkGroupNodeTable.MODIFICATION_DATE)
  final DateTime? modificationDate;
  @JsonKey(name: WorkGroupNodeTable.NAME)
  final String name;
  @JsonKey(name: WorkGroupNodeTable.NODE_TYPE)
  final WorkGroupNodeType? nodeType;
  @JsonKey(name: WorkGroupNodeTable.DESCRIPTION)
  final String? description;
  @JsonKey(name: WorkGroupNodeTable.NAME_ACCOUNT)
  final String? nameAccount;
  @JsonKey(name: WorkGroupNodeTable.MAIL_ACCOUNT)
  final String? mailAccount;
  @JsonKey(name: WorkGroupNodeTable.FIRST_NAME_ACCOUNT)
  final String? firstNameAccount;
  @JsonKey(name: WorkGroupNodeTable.LAST_NAME_ACCOUNT)
  final String? lastNameAccount;
  @JsonKey(name: WorkGroupNodeTable.ACCOUNT_ID)
  final AccountId? accountId;
  @JsonKey(name: WorkGroupNodeTable.ACCOUNT_TYPE)
  final AccountType? accountType;
  @JsonKey(name: WorkGroupNodeTable.SIZE)
  final int? size;
  @JsonKey(name: WorkGroupNodeTable.MEDIA_TYPE)
  final MediaType? mediaType;
  @JsonKey(name: WorkGroupNodeTable.HAS_THUMBNAIL)
  final bool? hasThumbnail;
  @JsonKey(name: WorkGroupNodeTable.UPLOAD_DATE)
  final DateTime? uploadDate;
  @JsonKey(name: WorkGroupNodeTable.HAS_REVISION)
  final bool? hasRevision;
  @JsonKey(name: WorkGroupNodeTable.SHA256_SUM)
  final String? sha256sum;
  @JsonKey(name: WorkGroupNodeTable.LOCAL_PATH)
  final String? localPath;

  WorkGroupNodeCache(
      this.nodeId,
      this.sharedSpaceId,
      this.parentNodeId,
      this.creationDate,
      this.modificationDate,
      this.name,
      this.nodeType,
      this.description,
      this.nameAccount,
      this.mailAccount,
      this.firstNameAccount,
      this.lastNameAccount,
      this.accountId,
      this.accountType,
      this.size,
      this.mediaType,
      this.hasThumbnail,
      this.uploadDate,
      this.hasRevision,
      this.sha256sum,
      this.localPath);

  factory WorkGroupNodeCache.fromJson(Map<String, dynamic> json) => _$WorkGroupNodeCacheFromJson(json);

  Map<String, dynamic> toJson() => _$WorkGroupNodeCacheToJson(this);

  @override
  List<Object?> get props => [
    nodeId,
    sharedSpaceId,
    parentNodeId,
    creationDate,
    modificationDate,
    name,
    nodeType,
    description,
    nameAccount,
    mailAccount,
    firstNameAccount,
    lastNameAccount,
    accountId,
    accountType,
    size,
    mediaType,
    hasThumbnail,
    uploadDate,
    hasRevision,
    sha256sum,
    localPath
  ];
}

extension WorkGroupNodeCacheExtension on WorkGroupNodeCache {
  WorkGroupDocument toWorkGroupDocument() {
    return WorkGroupDocument(
        nodeId,
        parentNodeId,
        nodeType,
        sharedSpaceId,
        creationDate ?? DateTime.now(),
        modificationDate ?? DateTime.now(),
        description,
        name,
        Account(
          nameAccount ?? '',
          mailAccount ?? '',
          accountId ?? AccountId(''),
          accountType ?? AccountType.INTERNAL,
          firstNameAccount ?? '',
          lastNameAccount ?? ''),
        size ?? 0,
        mediaType ?? MediaType.parse(''),
        hasThumbnail ?? false,
        uploadDate ?? DateTime.now(),
        hasRevision ?? false,
        sha256sum ?? '',
        localPath: localPath ?? '',
        syncOfflineState: SyncOfflineState.completed
    );
  }

  WorkGroupFolder toWorkGroupFolder() {
    return WorkGroupFolder(
        nodeId,
        parentNodeId,
        nodeType,
        sharedSpaceId,
        creationDate ?? DateTime.now(),
        modificationDate ?? DateTime.now(),
        description,
        name,
        Account(
          nameAccount ?? '',
          mailAccount ?? '',
          accountId ?? AccountId(''),
          accountType ?? AccountType.INTERNAL,
          firstNameAccount ?? '',
          lastNameAccount ?? ''),
        []
    );
  }
}