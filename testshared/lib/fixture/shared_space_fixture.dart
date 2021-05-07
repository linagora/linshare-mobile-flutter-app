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

import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:testshared/fixture/shared_space_document_fixture.dart';

final sharedSpace1 = SharedSpaceNodeNested(
  SharedSpaceId('e352ed55-abef-4630-816f-c025caa3b025'),
  SharedSpaceRole(
    SharedSpaceRoleId('234be74d-2966-41c1-9dee-e47c8c63c14e'),
    SharedSpaceRoleName.ADMIN
  ),
  DateTime.fromMillisecondsSinceEpoch(1604482138188),
  DateTime.fromMillisecondsSinceEpoch(1604482138188),
  'Shared Space 1',
  LinShareNodeType.WORK_GROUP,
  QuotaId('e352ed55-abef-4630-816f-c025caa3b025'),
  VersioningParameter(false)
);

final sharedSpace2 = SharedSpaceNodeNested(
  SharedSpaceId('e352ed55-ebef-4630-856f-c025caa3b025'),
  SharedSpaceRole(
    SharedSpaceRoleId('234be74d-1966-41c1-9dee-e47c8d63c14e'),
    SharedSpaceRoleName.CONTRIBUTOR
  ),
  DateTime.fromMillisecondsSinceEpoch(1604482138188),
  DateTime.fromMillisecondsSinceEpoch(1604482138188),
  'Shared Space 2',
  LinShareNodeType.DRIVE,
  QuotaId('e352ed55-abef-4630-816f-c025caa3b025'),
  VersioningParameter(false)
);

final sharedSpace3 = SharedSpaceNodeNested(
    SharedSpaceId('e352ed55-ebef-4630-856f-c025caa3b025'),
    SharedSpaceRole(
        SharedSpaceRoleId('234be74d-1966-41c1-9dee-e47c8d63c14e'),
        SharedSpaceRoleName.CONTRIBUTOR
    ),
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    DateTime.fromMillisecondsSinceEpoch(1619349271000),
    'Shared Space 3',
    LinShareNodeType.WORK_GROUP,
    QuotaId('e352ed55-abef-4630-816f-c025caa3b025'),
    VersioningParameter(false)
);

final sharedSpaceResponse1 = SharedSpaceNodeNestedResponse(
  SharedSpaceId('e352ed55-abef-4630-816f-c025caa3b025'),
  SharedSpaceRoleDto(
    SharedSpaceRoleId('234be74d-2966-41c1-9dee-e47c8c63c14e'),
    SharedSpaceRoleName.ADMIN
  ),
  DateTime.fromMillisecondsSinceEpoch(1604482138188),
  DateTime.fromMillisecondsSinceEpoch(1604482138188),
  'Shared Space 1',
  LinShareNodeType.WORK_GROUP,
  QuotaId('e352ed55-abef-4630-816f-c025caa3b025'),
  VersioningParameterDto(false)
);

final sharedSpaceResponse2 = SharedSpaceNodeNestedResponse(
  SharedSpaceId('e352ed55-ebef-4630-856f-c025caa3b025'),
  SharedSpaceRoleDto(
    SharedSpaceRoleId('234be74d-1966-41c1-9dee-e47c8d63c14e'),
    SharedSpaceRoleName.CONTRIBUTOR
  ),
  DateTime.fromMillisecondsSinceEpoch(1604482138188),
  DateTime.fromMillisecondsSinceEpoch(1604482138188),
  'Shared Space 2',
  LinShareNodeType.DRIVE,
  QuotaId('e352ed55-abef-4630-816f-c025caa3b025'),
  VersioningParameterDto(false)
);

final sharedSpaceMember1 = SharedSpaceMember(
  SharedSpaceMemberId('b4c8e5ba-8d94-11eb-8dcd-0242ac130003'),
  account1,
  DateTime.fromMillisecondsSinceEpoch(1604482138188),
  DateTime.fromMillisecondsSinceEpoch(1604482138188),
  SharedSpaceMemberNode(
    SharedSpaceId('e352ed55-ebef-4630-856f-c025caa3b025'),
    'Shared Space Member Node 1',
    LinShareNodeType.WORK_GROUP,
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
  ),
  SharedSpaceRole(SharedSpaceRoleId('an id'), SharedSpaceRoleName.ADMIN),
);

final sharedSpaceMember2 = SharedSpaceMember(
  SharedSpaceMemberId('d00df810-8d94-11eb-8dcd-0242ac130003'),
  account2,
  DateTime.fromMillisecondsSinceEpoch(1604482138188),
  DateTime.fromMillisecondsSinceEpoch(1604482138188),
  SharedSpaceMemberNode(
    SharedSpaceId('e352ed55-ebef-4230-856f-c055caa6b025'),
    'Shared Space Member Node 2',
    LinShareNodeType.WORK_GROUP,
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
  ),
  SharedSpaceRole(SharedSpaceRoleId('an id 2'), SharedSpaceRoleName.READER),
);

final sharedSpaceMemberResponse1 = SharedSpaceMemberResponse(
  accountDto1,
  SharedSpaceMemberNodeDto(
    SharedSpaceId('e352ed55-ebef-4630-856f-c025caa3b025'),
    'Shared Space Member Node 1',
    LinShareNodeType.WORK_GROUP,
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
  ),
  SharedSpaceRoleDto(SharedSpaceRoleId('an id'), SharedSpaceRoleName.ADMIN),
  SharedSpaceMemberId('b4c8e5ba-8d94-11eb-8dcd-0242ac130003'),
  DateTime.fromMillisecondsSinceEpoch(1604482138188),
  DateTime.fromMillisecondsSinceEpoch(1604482138188),
);

final sharedSpaceMemberResponse2 = SharedSpaceMemberResponse(
  accountDto2,
  SharedSpaceMemberNodeDto(
    SharedSpaceId('e352ed55-ebef-4230-856f-c055caa6b025'),
    'Shared Space Member Node 2',
    LinShareNodeType.WORK_GROUP,
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
  ),
  SharedSpaceRoleDto(SharedSpaceRoleId('an id 2'), SharedSpaceRoleName.READER),
  SharedSpaceMemberId('d00df810-8d94-11eb-8dcd-0242ac130003'),
  DateTime.fromMillisecondsSinceEpoch(1604482138188),
  DateTime.fromMillisecondsSinceEpoch(1604482138188),
);

final sharedSpaceRole1 = SharedSpaceRole(SharedSpaceRoleId('an id 1'), SharedSpaceRoleName.READER);
final sharedSpaceRole2 = SharedSpaceRole(SharedSpaceRoleId('an id 2'), SharedSpaceRoleName.ADMIN);
final sharedSpaceRole3 = SharedSpaceRole(SharedSpaceRoleId('an id 3'), SharedSpaceRoleName.CONTRIBUTOR);
final sharedSpaceRole4 = SharedSpaceRole(SharedSpaceRoleId('an id 4'), SharedSpaceRoleName.WRITER);