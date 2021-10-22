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

final workGroupFolder1 = WorkGroupFolder(
    WorkGroupNodeId('f9f65f03-4f7a-4024-ab1f-73b2e90a4c66'),
    WorkGroupNodeId('c542ac1f-2683-4591-9b3f-468b6b6e9d86'),
    WorkGroupNodeType.FOLDER,
    SharedSpaceId('150e408a-dde9-4315-9a5b-7fe0f251fa83'),
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    DateTime.fromMillisecondsSinceEpoch(1604482138189),
    'description1',
    'folder1',
        Account(
        'user1@linshare.org',
        'user1@linshare.org',
        AccountId('1f75190b-73aa-4c4b-9efb-2760be07c3bb'),
        AccountType.INTERNAL,
        'John',
        'Doe'),
    []
);

final workGroupDocument1 = WorkGroupDocument(
    WorkGroupNodeId('f9f65f03-4f7a-4024-ab1f-73b2e90a4c66'),
    WorkGroupNodeId('c542ac1f-2683-4591-9b3f-468b6b6e9d86'),
    WorkGroupNodeType.DOCUMENT,
    SharedSpaceId('150e408a-dde9-4315-9a5b-7fe0f251fa83'),
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    DateTime.fromMillisecondsSinceEpoch(1604482138189),
    'description1',
    'Workgroup Node 1',
    Account(
        'user1@linshare.org',
        'user1@linshare.org',
        AccountId('1f75190b-73aa-4c4b-9efb-2760be07c3bb'),
        AccountType.INTERNAL,
        'John',
        'Doe'),
    [],
    1000,
    MediaType.parse('image/png'),
    true,
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    false,
    '557c7bf3f95d00547b83ad0f7d75b1bb345d80947b2f0c4ca14643298fbde4ab');

final workGroupDocument2 = WorkGroupDocument(
    WorkGroupNodeId('f9f65f03-4f7a-4024-ab1f-73b2e90a4c64'),
    WorkGroupNodeId('c542ac1f-2683-4591-9b3f-468b6b6e9d84'),
    WorkGroupNodeType.DOCUMENT,
    SharedSpaceId('150e408a-dde9-4315-9a5b-7fe0f251fa83'),
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    DateTime.fromMillisecondsSinceEpoch(1604482138189),
    'description1',
    'Workgroup Node 2',
    Account(
        'user1@linshare.org',
        'user1@linshare.org',
        AccountId('1f75190b-73aa-4c4b-9efb-2760be07c3bb'),
        AccountType.INTERNAL,
        'John',
        'Doe'),
    [],
    1000,
    MediaType.parse('image/png'),
    true,
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    false,
    '557c7bf3f95d00547b83ad0f7d75b1bb345d80947b2f0c4ca14643298fbde4ab');

final workGroupDocument3 = WorkGroupDocument(
    WorkGroupNodeId('f9f65f03-4f7a-4024-ab1f-73b2e90a4c64'),
    WorkGroupNodeId('c542ac1f-2683-4591-9b3f-468b6b6e9d84'),
    WorkGroupNodeType.DOCUMENT,
    SharedSpaceId('150e408a-dde9-4315-9a5b-7fe0f251fa83'),
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    DateTime.fromMillisecondsSinceEpoch(1604482138189),
    'description1',
    'Workgroup Node 2',
    Account(
        'user1@linshare.org',
        'user1@linshare.org',
        AccountId('1f75190b-73aa-4c4b-9efb-2760be07c3bb'),
        AccountType.INTERNAL,
        'John',
        'Doe'),
    [],
    1000,
    MediaType.parse('text/calendar'),
    true,
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    false,
    '557c7bf3f95d00547b83ad0f7d75b1bb345d80947b2f0c4ca14643298fbde4ab');

final sharedSpaceId1 = SharedSpaceId('1');
final sharedSpaceId2 = SharedSpaceId('2');
final sharedSpaceId3 = SharedSpaceId('3');
final sharedMemberId1 = SharedSpaceMemberId('1');
final parentWorkGroupNodeId1 = WorkGroupNodeId('0');
final workGroupNodeId1 = WorkGroupNodeId('1');
final workGroupNodeId2 = WorkGroupNodeId('1');
final accountDto1 = AccountDto(
  'User1', 'user1@linagora.org', AccountId('1'), AccountType.INTERNAL, '', 'User1',
);

final accountDto2 = AccountDto(
  'User2', 'user2@linagora.org', AccountId('2'), AccountType.INTERNAL, '', 'User2',
);

final account1 = Account(
  'User1', 'user1@linagora.org', AccountId('1'), AccountType.INTERNAL, '', 'User1',
);

final account2 = Account(
  'User2', 'user2@linagora.org', AccountId('2'), AccountType.INTERNAL, '', 'User2',
);

final sharedSpaceFolder1 = WorkGroupNodeFolderDto(
    workGroupNodeId1,
    parentWorkGroupNodeId1,
    WorkGroupNodeType.FOLDER,
    sharedSpaceId1,
    DateTime.now(),
    DateTime.now(),
    'Folder 1',
    'Folder 1',
    accountDto1,
    []);

final sharedSpaceFolder2 = WorkGroupNodeFolderDto(
    workGroupNodeId2,
    parentWorkGroupNodeId1,
    WorkGroupNodeType.FOLDER,
    sharedSpaceId1,
    DateTime.now(),
    DateTime.now(),
    'Folder 2',
    'Folder 2',
    accountDto1,
    []);

final moveWorkGroupNodeRequest = MoveWorkGroupNodeRequest(
    WorkGroupNodeId('f9f65f03-4f7a-4024-ab1f-73b2e90a4c64'),
    WorkGroupNodeId('c542ac1f-2683-4591-9b3f-468b6b6e9d84'),
    SharedSpaceId('150e408a-dde9-4315-9a5b-7fe0f251fa83'),
    WorkGroupNodeType.DOCUMENT,
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    DateTime.fromMillisecondsSinceEpoch(1604482138189),
    'description1',
    'Workgroup Node 1',
    Account(
        'user1@linshare.org',
        'user1@linshare.org',
        AccountId('1f75190b-73aa-4c4b-9efb-2760be07c3bb'),
        AccountType.INTERNAL,
        'John',
        'Doe')
);

final moveWorkGroupNodeBodyRequest = moveWorkGroupNodeRequest.toMoveWorkGroupNodeBodyRequest();