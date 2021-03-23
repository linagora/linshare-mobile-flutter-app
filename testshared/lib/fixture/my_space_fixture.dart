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
import 'package:http_parser/http_parser.dart';
import 'package:dartz/dartz.dart';

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

final document4 = Document(
    DocumentId('3e57d240-47a1-4a7e-b1a7-25e29870af33'),
    'description 4',
    DateTime.fromMillisecondsSinceEpoch(1604482138177),
    DateTime.fromMillisecondsSinceEpoch(1604482138177),
    DateTime.fromMillisecondsSinceEpoch(1604482138177),
    false,
    'document 4',
    189366,
    '79c2474f47566808f1a0e068c5c290fa8476c192ca443d56345a618254e599ic',
    true,
    0,
    MediaType.parse('text/calendar'));

final documentResponse1 = DocumentResponse(
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

final documentResponse2 = DocumentResponse(
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

final documentResponse3 = DocumentResponse(
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

final responseJsonDocument1 = {
  'uuid': '3e57d240-47a1-4a7e-b1a7-25e29870af31',
  'description': 'description 1',
  'creationDate': 1604482138188,
  'modificationDate': 1604482138188,
  'expirationDate': 1604482138188,
  'ciphered': false,
  'name': 'document 1',
  'size': 189366,
  'sha256sum':
  '79c2474f47566808f1a0e068c5c290fa8476c192ca443d56345a618254e5995c',
  'hasThumbnail': true,
  'shared': 0,
  'type': 'image/png'
};

final responseJsonDocument2 = {
  'uuid': '3e57d240-47a1-4a7e-b1a7-25e29870af32',
  'description': 'description 2',
  'creationDate': 1604474224450,
  'modificationDate': 1604655334118,
  'expirationDate': 1604474224450,
  'ciphered': false,
  'name': 'document 2',
  'size': 189366,
  'sha256sum':
  '79c2474f47566808f1a0e068c5c290fa8476c192ca443d56345a618254e5995a',
  'hasThumbnail': false,
  'shared': 1,
  'type': 'image/png'
};

final responseJsonDocument3 = {
  'uuid': '3e57d240-47a1-4a7e-b1a7-25e29870af33',
  'description': 'description 3',
  'creationDate': 1604482138189,
  'modificationDate': 1604482138182,
  'expirationDate': 1604482138189,
  'ciphered': false,
  'name': 'document 3',
  'size': 189366,
  'sha256sum':
  '79c2474f47566808f1a0e068c5c290fa8476c192ca443d56345a618254e5995d',
  'hasThumbnail': true,
  'shared': 0,
  'type': 'image/png'
};

final mailingListId1 = MailingListId('3e57d240-47a1-4a7e-b1a7-25e29870af33');
final genericUser1 = GenericUser('user1@linshare.org', lastName: optionOf('Smith'), firstName: optionOf('Jane'));

final share1 = Share(
    ShareId('3e57d240-47a1-4a7e-b1a7-25e29870af33'),
    'document 1',
    DateTime.fromMillisecondsSinceEpoch(1604482138181),
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    DateTime.fromMillisecondsSinceEpoch(1604482138238),
    document1,
    'description 1',
    GenericUser('user1@linshare.org'),
    2);

final share2 = Share(
    ShareId('3e57d240-47a1-4a7e-b1a7-25e29870af32'),
    'document 2',
    DateTime.fromMillisecondsSinceEpoch(1604482138181),
    DateTime.fromMillisecondsSinceEpoch(1604482138182),
    DateTime.fromMillisecondsSinceEpoch(1604482279328),
    document2,
    'description 2',
    GenericUser('user2@linshare.org'),
    5);

final mailListId = MailingListId('3e57d240-47a1-4a7e-b1a7-25e29870af33');
final genericUser = GenericUser('user1@linshare.org', firstName: none(), lastName: none());

final recipients = [
  MailingListAutoCompleteResult(mailListId.uuid, '', '', '', '', ''),
  SimpleAutoCompleteResult(genericUser.mail, '')
];

final fileInfo1 = FileInfo('fileInfo1', 'filePath1', 10);
final fileInfo2 = FileInfo('fileInfo1', 'filePath1', 20);

final sorter = Sorter(OrderScreen.mySpace, OrderBy.modificationDate, OrderType.descending);
final sorter1 = Sorter(OrderScreen.mySpace, OrderBy.creationDate, OrderType.descending);
final orderScreen = OrderScreen.mySpace;

final documentSort1 = Document(
    DocumentId('3e57d240-47a1-4a7e-b1a7-25e29870af31'),
    'description 1',
    DateTime.fromMillisecondsSinceEpoch(1616243657188),
    DateTime.fromMillisecondsSinceEpoch(1616243657188),
    DateTime.fromMillisecondsSinceEpoch(1616243657188),
    false,
    'document 1',
    189366,
    '79c2474f47566808f1a0e068c5c290fa8476c192ca443d56345a618254e5995c',
    true,
    0,
    MediaType.parse('image/png'));

final documentSort2 = Document(
    DocumentId('3e57d240-47a1-4a7e-b1a7-25e29870af31'),
    'description 1',
    DateTime.fromMillisecondsSinceEpoch(1616243658188),
    DateTime.fromMillisecondsSinceEpoch(1616243658188),
    DateTime.fromMillisecondsSinceEpoch(1616243658188),
    false,
    'document 1',
    189366,
    '79c2474f47566808f1a0e068c5c290fa8476c192ca443d56345a618254e5995c',
    true,
    0,
    MediaType.parse('image/png'));

final documentSort3 = Document(
    DocumentId('3e57d240-47a1-4a7e-b1a7-25e29870af31'),
    'description 1',
    DateTime.fromMillisecondsSinceEpoch(1616243659188),
    DateTime.fromMillisecondsSinceEpoch(1616243659188),
    DateTime.fromMillisecondsSinceEpoch(1616243659188),
    false,
    'document 1',
    189366,
    '79c2474f47566808f1a0e068c5c290fa8476c192ca443d56345a618254e5995c',
    true,
    0,
    MediaType.parse('image/png'));