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

import 'package:data/src/local/config/shared_space_table.dart';
import 'package:data/src/local/converter/boolean_converter.dart';
import 'package:data/src/local/converter/datetime_converter.dart';
import 'package:data/src/local/converter/linshare_node_type_converter.dart';
import 'package:data/src/local/converter/quota_id_converter.dart';
import 'package:data/src/local/converter/shared_space_id_converter.dart';
import 'package:data/src/local/converter/shared_space_role_id_converter.dart';
import 'package:data/src/local/converter/shared_space_role_name_converter.dart';
import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'shared_space_cache.g.dart';

@JsonSerializable()
@DatetimeConverter()
@BooleanConverter()
@SharedSpaceIdConverter()
@SharedSpaceRoleIdConverter()
@SharedSpaceRoleNameConverter()
@LinShareNodeTypeConverter()
@QuotaIdConverter()
class SharedSpaceCache with EquatableMixin {

  @JsonKey(name: SharedSpaceTable.SHARED_SPACE_ID)
  final SharedSpaceId sharedSpaceId;
  @JsonKey(name: SharedSpaceTable.SHARED_SPACE_ROLE_ID)
  final SharedSpaceRoleId? sharedSpaceRoleId;
  @JsonKey(name: SharedSpaceTable.SHARED_SPACE_ROLE_NAME)
  final SharedSpaceRoleName? sharedSpaceRoleName;
  @JsonKey(name: SharedSpaceTable.SHARED_SPACE_ROLE_ENABLE)
  final bool? sharedSpaceRoleEnable;
  @JsonKey(name: SharedSpaceTable.CREATION_DATE)
  final DateTime? creationDate;
  @JsonKey(name: SharedSpaceTable.MODIFICATION_DATE)
  final DateTime? modificationDate;
  @JsonKey(name: SharedSpaceTable.NAME)
  final String name;
  @JsonKey(name: SharedSpaceTable.NODE_TYPE)
  final LinShareNodeType? nodeType;
  @JsonKey(name: SharedSpaceTable.QUOTA_ID)
  final QuotaId? quotaId;
  @JsonKey(name: SharedSpaceTable.VERSIONING_PARAMETERS)
  final bool? versioningParameters;

  SharedSpaceCache(
    this.sharedSpaceId,
    this.sharedSpaceRoleId,
    this.sharedSpaceRoleName,
    this.sharedSpaceRoleEnable,
    this.creationDate,
    this.modificationDate,
    this.name,
    this.nodeType,
    this.quotaId,
    this.versioningParameters);

  factory SharedSpaceCache.fromJson(Map<String, dynamic> json) => _$SharedSpaceCacheFromJson(json);

  Map<String, dynamic> toJson() => _$SharedSpaceCacheToJson(this);

  @override
  List<Object?> get props => [
    sharedSpaceId,
    sharedSpaceRoleId,
    sharedSpaceRoleName,
    sharedSpaceRoleEnable,
    creationDate,
    modificationDate,
    name,
    nodeType,
    quotaId,
    versioningParameters
  ];
}

extension SharedSpaceCacheExtension on SharedSpaceCache {
  SharedSpaceNodeNested toSharedSpaceNodeNested() {
    return SharedSpaceNodeNested(
        sharedSpaceId,
        (sharedSpaceRoleId == null || sharedSpaceRoleName == null || sharedSpaceRoleEnable == null)
            ?  null
            : SharedSpaceRole(sharedSpaceRoleId!, sharedSpaceRoleName!, enabled: sharedSpaceRoleEnable!),
        creationDate ?? DateTime.now(),
        modificationDate ?? DateTime.now(),
        name,
        nodeType,
        quotaId,
        VersioningParameter(versioningParameters ?? false)
    );
  }
}