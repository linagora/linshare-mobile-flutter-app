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

import 'package:dartz/dartz.dart';
import 'package:data/src/network/model/generic_user_dto.dart';
import 'package:data/src/network/model/share/mailing_list_id_dto.dart';
import 'package:data/src/network/model/share/share_dto.dart';
import 'package:data/src/network/model/share/share_id_dto.dart';
import 'package:testshared/testshared.dart';
import 'package:http_parser/http_parser.dart';

final shareIdDto1 = ShareIdDto('3e57d240-47a1-4a7e-b1a7-25e29870af33');
final shareIdDto2 = ShareIdDto('3e57d240-47a1-4a7e-b1a7-25e29870af32');
final mailingListIdDto1 = MailingListIdDto('3e57d240-47a1-4a7e-b1a7-25e29870af33');
final genericUserDto1 = GenericUserDto('user1@linshare.org',
    lastName: optionOf('Smith'), firstName: optionOf('Jane'));

final shareDto1 = ShareDto(
    shareIdDto1,
    'document 1',
    DateTime.fromMillisecondsSinceEpoch(1604482138181),
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    documentResponse1,
    'description 1',
    GenericUserDto('user1@linshare.org'),
    MediaType.parse('image/png'),
    GenericUserDto('user1@linshare.org', lastName: optionOf('Smith'), firstName: optionOf('Jane'))
);

final shareDto2 = ShareDto(
    shareIdDto2,
    'document2',
    DateTime.fromMillisecondsSinceEpoch(1604482138181),
    DateTime.fromMillisecondsSinceEpoch(1604482138182),
    documentResponse2,
    'description 2',
    GenericUserDto('user2@linshare.org'),
    MediaType.parse('image/png'),
    GenericUserDto('user1@linshare.org', lastName: optionOf('Smith'), firstName: optionOf('Jane')));
