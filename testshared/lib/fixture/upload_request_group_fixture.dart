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
import 'package:data/data.dart';
import 'package:dartz/dartz.dart';

final uploadRequestGroup1 = UploadRequestGroup(
  UploadRequestGroupId('upload_request_group_1'),
  'uploadRequestGroup1',
  'uploadRequestGroupBody1',
  DateTime.fromMillisecondsSinceEpoch(1604482138188),
  DateTime.fromMillisecondsSinceEpoch(1604482138188),
  23232323,
  232332323232,
  23232323232323,
  DateTime.fromMillisecondsSinceEpoch(1604482138188),
  DateTime.fromMillisecondsSinceEpoch(1604482138188),
  DateTime.fromMillisecondsSinceEpoch(1604482138188),
  true,
  true,
  true,
  true,
  'mailmessageId1',
  false,
  true,
  GenericUser('user1@linshare.org', lastName: optionOf('Smith'), firstName: optionOf('Jane')),
  UploadRequestStatus.CREATED,
  2323872,
  1,
  'ENGLISH'
);

final uploadRequestGroup2 = UploadRequestGroup(
  UploadRequestGroupId('upload_request_group_2'),
  'uploadRequestGroup2',
  'uploadRequestGroupBody2',
  DateTime.fromMillisecondsSinceEpoch(1604482349834),
  DateTime.fromMillisecondsSinceEpoch(1619349271000),
  23232323,
  232332323232,
  23232323232323,
  DateTime.fromMillisecondsSinceEpoch(1604482124944),
  DateTime.fromMillisecondsSinceEpoch(1604482984244),
  DateTime.fromMillisecondsSinceEpoch(1604482298044),
  true,
  true,
  true,
  true,
  'mailmessageId2',
  false,
  true,
  GenericUser('user1@linshare.org', lastName: optionOf('Smith'), firstName: optionOf('Jane')),
  UploadRequestStatus.CREATED,
  2323872,
  1,
  'ENGLISH'
);

final uploadRequestGroupCanceled1 = UploadRequestGroup(
    UploadRequestGroupId('upload_request_group_1'),
    'uploadRequestGroup1',
    'uploadRequestGroupBody1',
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    23232323,
    232332323232,
    23232323232323,
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    true,
    true,
    true,
    true,
    'mailmessageId1',
    false,
    true,
    GenericUser('user1@linshare.org', lastName: optionOf('Smith'), firstName: optionOf('Jane')),
    UploadRequestStatus.CANCELED,
    2323872,
    1,
    'ENGLISH'
);

final uploadRequestGroupArchived1 = UploadRequestGroup(
    UploadRequestGroupId('upload_request_group_1'),
    'uploadRequestGroup1',
    'uploadRequestGroupBody1',
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    23232323,
    232332323232,
    23232323232323,
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    true,
    true,
    true,
    true,
    'mailmessageId1',
    false,
    true,
    GenericUser('user1@linshare.org', lastName: optionOf('Smith'), firstName: optionOf('Jane')),
    UploadRequestStatus.ARCHIVED,
    2323872,
    1,
    'ENGLISH'
);

final uploadRequestGroupCanceled2 = UploadRequestGroup(
    UploadRequestGroupId('upload_request_group_2'),
    'uploadRequestGroup2',
    'uploadRequestGroupBody2',
    DateTime.fromMillisecondsSinceEpoch(1604482349834),
    DateTime.fromMillisecondsSinceEpoch(1619349271000),
    23232323,
    232332323232,
    23232323232323,
    DateTime.fromMillisecondsSinceEpoch(1604482124944),
    DateTime.fromMillisecondsSinceEpoch(1604482984244),
    DateTime.fromMillisecondsSinceEpoch(1604482298044),
    true,
    true,
    true,
    true,
    'mailmessageId2',
    false,
    true,
    GenericUser('user1@linshare.org', lastName: optionOf('Smith'), firstName: optionOf('Jane')),
    UploadRequestStatus.CANCELED,
    2323872,
    1,
    'ENGLISH'
);

final uploadRequestGroupArchived2 = UploadRequestGroup(
    UploadRequestGroupId('upload_request_group_2'),
    'uploadRequestGroup2',
    'uploadRequestGroupBody2',
    DateTime.fromMillisecondsSinceEpoch(1604482349834),
    DateTime.fromMillisecondsSinceEpoch(1619349271000),
    23232323,
    232332323232,
    23232323232323,
    DateTime.fromMillisecondsSinceEpoch(1604482124944),
    DateTime.fromMillisecondsSinceEpoch(1604482984244),
    DateTime.fromMillisecondsSinceEpoch(1604482298044),
    true,
    true,
    true,
    true,
    'mailmessageId2',
    false,
    true,
    GenericUser('user1@linshare.org', lastName: optionOf('Smith'), firstName: optionOf('Jane')),
    UploadRequestStatus.ARCHIVED,
    2323872,
    1,
    'ENGLISH'
);

final uploadRequestGroupClosed1 = UploadRequestGroup(
    UploadRequestGroupId('upload_request_group_1'),
    'uploadRequestGroup1',
    'uploadRequestGroupBody1',
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    23232323,
    232332323232,
    23232323232323,
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    true,
    true,
    true,
    true,
    'mailmessageId1',
    false,
    true,
    GenericUser('user1@linshare.org', lastName: optionOf('Smith'), firstName: optionOf('Jane')),
    UploadRequestStatus.CLOSED,
    2323872,
    1,
    'ENGLISH'
);

final uploadRequestGroupClosed2 = UploadRequestGroup(
    UploadRequestGroupId('upload_request_group_1'),
    'uploadRequestGroup1',
    'uploadRequestGroupBody1',
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    23232323,
    232332323232,
    23232323232323,
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    true,
    true,
    true,
    true,
    'mailmessageId1',
    false,
    true,
    GenericUser('user1@linshare.org', lastName: optionOf('Smith'), firstName: optionOf('Jane')),
    UploadRequestStatus.CLOSED,
    2323872,
    1,
    'ENGLISH'
);

final uploadRequestGroupResponse1 = UploadRequestGroupResponse(
  UploadRequestGroupId('upload_request_group_1'),
  'uploadRequestGroup1',
  'uploadRequestGroupBody1',
  DateTime.fromMillisecondsSinceEpoch(1604482138188),
  DateTime.fromMillisecondsSinceEpoch(1604482138188),
  23232323,
  232332323232,
  23232323232323,
  DateTime.fromMillisecondsSinceEpoch(1604482138188),
  DateTime.fromMillisecondsSinceEpoch(1604482138188),
  DateTime.fromMillisecondsSinceEpoch(1604482138188),
  true,
  true,
  true,
  true,
  'mailmessageId1',
  false,
  true,
  GenericUserDto('user1@linshare.org', lastName: optionOf('Smith'), firstName: optionOf('Jane')),
  UploadRequestStatus.CREATED,
  2323872,
  1,
  'ENGLISH'
);

final uploadRequestGroupResponseCanceled1 = UploadRequestGroupResponse(
    UploadRequestGroupId('upload_request_group_1'),
    'uploadRequestGroup1',
    'uploadRequestGroupBody1',
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    23232323,
    232332323232,
    23232323232323,
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    true,
    true,
    true,
    true,
    'mailmessageId1',
    false,
    true,
    GenericUserDto('user1@linshare.org', lastName: optionOf('Smith'), firstName: optionOf('Jane')),
    UploadRequestStatus.CANCELED,
    2323872,
    1,
    'ENGLISH'
);

final addUploadRequest1 = AddUploadRequest(
  ['user1@linshare.org'],
  'subject 1',
  'body 1',
  DateTime.fromMillisecondsSinceEpoch(1604482138188),
  DateTime.fromMillisecondsSinceEpoch(1604482138188),
  400,
  50000000000,
  DateTime.fromMillisecondsSinceEpoch(1604482138188),
  50000000000,
  true,
  true,
  'FRENCH',
  true,
  true
);

final uploadRequestGroupId1 = UploadRequestGroupId('upload_request_group_1');
final uploadRequestGroupIdWrong1 = UploadRequestGroupId('upload_request_group_wrong_1');
