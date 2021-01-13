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
import 'package:http_parser/http_parser.dart';

final document1 = Document(
    DocumentId('3e57d240-47a1-4a7e-b1a7-25e29870af31'),
    'description 1',
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    false,
    'document 1',
    189366,
    '79c2474f47566808f1a0e068c5c290fa8476c192ca443d56345a618254e5995c',
    true,
    0,
    MediaType.parse('image/png'));

final document2 = Document(
    DocumentId('3e57d240-47a1-4a7e-b1a7-25e29870af32'),
    'description 2',
    DateTime.fromMillisecondsSinceEpoch(1604474224450),
    DateTime.fromMillisecondsSinceEpoch(1604655334118),
    DateTime.fromMillisecondsSinceEpoch(1604474224450),
    false,
    'document 2',
    189366,
    '79c2474f47566808f1a0e068c5c290fa8476c192ca443d56345a618254e5995a',
    false,
    1,
    MediaType.parse('image/png'));

final document3 = Document(
    DocumentId('3e57d240-47a1-4a7e-b1a7-25e29870af33'),
    'description 3',
    DateTime.fromMillisecondsSinceEpoch(1604482138189),
    DateTime.fromMillisecondsSinceEpoch(1604482138182),
    DateTime.fromMillisecondsSinceEpoch(1604482138189),
    false,
    'document 3',
    189366,
    '79c2474f47566808f1a0e068c5c290fa8476c192ca443d56345a618254e5995d',
    true,
    0,
    MediaType.parse('image/png'));

final mailingListId1 = MailingListId('3e57d240-47a1-4a7e-b1a7-25e29870af33');
final genericUser1 = GenericUser('user1@linshare.org', 'Smith', 'Jane');

final share1 = Share(
    ShareId('3e57d240-47a1-4a7e-b1a7-25e29870af33'),
    'document 1',
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    document1,
    'description 1',
    GenericUser('user1@linshare.org', null, null));

final share2 = Share(
    ShareId('3e57d240-47a1-4a7e-b1a7-25e29870af32'),
    'document 2',
    DateTime.fromMillisecondsSinceEpoch(1604482138182),
    document2,
    'description 2',
    GenericUser('user2@linshare.org', null, null));

final mailListId = MailingListId('3e57d240-47a1-4a7e-b1a7-25e29870af33');
final genericUser = GenericUser('user1@linshare.org', null, null);

final recipients = [
  MailingListAutoCompleteResult(mailListId.uuid, '', '', '', '', ''),
  SimpleAutoCompleteResult(genericUser.mail, '')
];