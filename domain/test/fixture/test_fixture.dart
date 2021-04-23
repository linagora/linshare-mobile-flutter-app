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
import 'package:domain/src/model/quota/quota_id.dart';
import 'package:http_parser/http_parser.dart';

const linShareUrl = 'http://linshare.org';
const permanentTokenString = 'eyJhbGciOiJSUzUxMiJ9.';
final token = Token('correct-token', TokenId('e66fdc71-df36-4c55-aaec-aa456bfc7e4a'));
const tokenUUID = 'e66fdc71-df36-4c55-aaec-aa456bfc7e4a';

final linShareBaseUrl = Uri.parse(linShareUrl);
final wrongUrl = Uri.parse('http://linsharewrong.org');
final wrongToken = Token('token', TokenId('uuid'));
final userName1 = UserName('user1@linshare.org');
final password1 = Password('qwedsazxc');
final userName2 = UserName('user2@linshare.org');
final password2 = Password('qwedsasca');
final permanentToken = Token(permanentTokenString, TokenId(tokenUUID));

final fileInfo1 = FileInfo('fileName1', 'filePath1', 1000);
final fileInfo2 = FileInfo('fileName2', 'filePath2', 500);
final fileUploadProgress10 = UploadingProgress(UploadTaskId('1'), 10);
final fileUploadProgress30 = UploadingProgress(UploadTaskId('1'), 30);
final fileUploadProgress100 = UploadingProgress(UploadTaskId('1'), 100);

final document = Document(
  DocumentId('uuid'),
  '',
  DateTime.now(),
  DateTime.now(),
  DateTime.now(),
  false,
  'fileName1',
  123456,
  '',
  true,
  1,
  MediaType.parse('text/plain'),
);

final user1 = User(
  UserId('uuid'),
  'locale',
  'externalMailLocale',
  'domain',
  'firstName',
  'lastName',
  'mail',
  true,
  true,
  AccountType.INTERNAL,
  QuotaId('quotaUuid'),
  false,
  false
);

final quotaId1 = QuotaId('q1');

final accountQuota1 = AccountQuota(
  quota: QuotaSize(100),
  usedSpace: QuotaSize(20),
  maxFileSize: QuotaSize(30),
  maintenance: true
);

final sharedSpaceSorter1 = Sorter(OrderScreen.workGroup, OrderBy.modificationDate, OrderType.descending);
final sharedSpaceFileSizeSorter = Sorter(OrderScreen.workGroup, OrderBy.fileSize, OrderType.descending);
final sharedSpaceSharedSorter = Sorter(OrderScreen.workGroup, OrderBy.shared, OrderType.descending);
final sharedSpaceSenderSorter = Sorter(OrderScreen.workGroup, OrderBy.sender, OrderType.descending);
final sharedSpaceModificationDateSorter = Sorter(OrderScreen.workGroup, OrderBy.modificationDate, OrderType.descending);