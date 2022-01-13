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
import 'package:http_parser/http_parser.dart';

final uploadRequestEntryResponse1 = UploadRequestEntryResponse(
    UploadRequestEntryId('uploadRequestEntry1'),
    UploadRequestGroupId('uploadRequestGroup1'),
    UploadRequestId('uploadRequest1'),
    UploadRequestEntryOwnerResponse(UploadRequestEntryOwnerId('uploadRequestEntryOwnerId'),
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    null,
    null,
    'dd2b70d0-6193-4980-8d5f-035a1e3c3da7'),
    GenericUserDto('user1@linshare.org', lastName: optionOf('Smith'), firstName: optionOf('Jane')),
  DateTime.fromMillisecondsSinceEpoch(1604482138188),
  DateTime.fromMillisecondsSinceEpoch(1604482138188),
  DateTime.fromMillisecondsSinceEpoch(1604482138188),
  'android-12-2.jpeg',
  '',
  '',
  false,
  30223,
  MediaType.parse('image/jpeg'),
  'd14a028c2a3a2bc9476102bb288234c415a2b01f828ea62ac5b3e42f',
  true,
  true
);

final uploadRequestEntryResponse2 = UploadRequestEntryResponse(
    UploadRequestEntryId('uploadRequestEntry2'),
    UploadRequestGroupId('uploadRequestGroup2'),
    UploadRequestId('uploadRequest2'),
    UploadRequestEntryOwnerResponse(UploadRequestEntryOwnerId('uploadRequestEntryOwnerId'),
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    null,
    null,
    'dd2b70d0-6193-4980-8d5f-035a1e3c3da7'),
    GenericUserDto('user1@linshare.org', lastName: optionOf('Smith'), firstName: optionOf('Jane')),
  DateTime.fromMillisecondsSinceEpoch(1604482138188),
  DateTime.fromMillisecondsSinceEpoch(1604482138188),
  DateTime.fromMillisecondsSinceEpoch(1604482138188),
  'android-32-2.jpeg',
  '',
  '',
  false,
  30223,
  MediaType.parse('image/jpeg'),
  'd14a028c2a3a2bc9476102bb288234c415a2b01f828ea62ac5b3e42f',
  true,
  true
);

final uploadRequestEntry1 = uploadRequestEntryResponse1.toUploadRequestEntry();
final uploadRequestEntry2 = uploadRequestEntryResponse2.toUploadRequestEntry();