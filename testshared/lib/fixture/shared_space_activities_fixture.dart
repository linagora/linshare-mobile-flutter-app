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

import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:testshared/fixture/shared_space_document_fixture.dart';
import 'package:http_parser/http_parser.dart';

final sharedSpaceIdForAuditLog = SharedSpaceId('eda9a917-10a7-44e0-98dc-7179ab914ab7');

final workGroupLightDto = WorkGroupLightDto(
    WorkGroupNodeId('eda9a917-10a7-44e0-98dc-7179ab914ab7'),
    DateTime.fromMillisecondsSinceEpoch(1616088020412),
    'New workgroup (2)'
);

final workGroupLight = WorkGroupLight(
    WorkGroupNodeId('eda9a917-10a7-44e0-98dc-7179ab914ab7'),
    DateTime.fromMillisecondsSinceEpoch(1616088020412),
    'New workgroup (2)'
);

final workGroupCopyDto = WorkGroupCopyDto(
    WorkGroupNodeId('543bde3b-f161-4d30-b480-593052f5e56f'),
    CopyContextId('741ddf11-0e1c-4dcf-9fc5-1833db9173bf'),
    'sample.ods',
    SpaceType.SHARED_SPACE,
    WorkGroupNodeType.DOCUMENT
);

final workGroupCopy = WorkGroupCopy(
    WorkGroupNodeId('543bde3b-f161-4d30-b480-593052f5e56f'),
    CopyContextId('741ddf11-0e1c-4dcf-9fc5-1833db9173bf'),
    'sample.ods',
    SpaceType.SHARED_SPACE,
    WorkGroupNodeType.DOCUMENT
);

final workGroupCopyDto2 = WorkGroupCopyDto(
    WorkGroupNodeId('543bde3b-f161-4d30-b480-593052f5e56f'),
    CopyContextId('741ddf11-0e1c-4dcf-9fc5-1833db9173bf'),
    'sample.ods',
    SpaceType.SHARED_SPACE,
    WorkGroupNodeType.FOLDER
);

final workGroupCopy2 = WorkGroupCopy(
    WorkGroupNodeId('543bde3b-f161-4d30-b480-593052f5e56f'),
    CopyContextId('741ddf11-0e1c-4dcf-9fc5-1833db9173bf'),
    'sample.ods',
    SpaceType.SHARED_SPACE,
    WorkGroupNodeType.FOLDER
);

final workGroupDocumentDto = WorkGroupDocumentDto(
    WorkGroupNodeId('2638b3a2-f782-4bf1-9015-200ee0067921'),
    WorkGroupNodeId('e2c7569a-2fba-4a46-a02d-9a11643c0a46'),
    WorkGroupNodeType.DOCUMENT,
    SharedSpaceId('eda9a917-10a7-44e0-98dc-7179ab914ab7'),
    DateTime.fromMillisecondsSinceEpoch(1616561531356),
    DateTime.fromMillisecondsSinceEpoch(1616561531356),
    '',
    'sample.ods',
    accountDto1,
    3112,
    MediaType.parse('application/vnd.oasis.opendocument.spreadsheet'),
    false,
    DateTime.fromMillisecondsSinceEpoch(1616561531356),
    false,
    'c6215e10c2f6086a2cd090cecfbad515d13170f00b7effe9cd6b162991622dea'
);

final workGroupDocument = WorkGroupDocument(
    WorkGroupNodeId('2638b3a2-f782-4bf1-9015-200ee0067921'),
    WorkGroupNodeId('e2c7569a-2fba-4a46-a02d-9a11643c0a46'),
    WorkGroupNodeType.DOCUMENT,
    SharedSpaceId('eda9a917-10a7-44e0-98dc-7179ab914ab7'),
    DateTime.fromMillisecondsSinceEpoch(1616561531356),
    DateTime.fromMillisecondsSinceEpoch(1616561531356),
    '',
    'sample.ods',
    account1,
    3112,
    MediaType.parse('application/vnd.oasis.opendocument.spreadsheet'),
    false,
    DateTime.fromMillisecondsSinceEpoch(1616561531356),
    false,
    'c6215e10c2f6086a2cd090cecfbad515d13170f00b7effe9cd6b162991622dea'
);

final workGroupFolderDto = WorkGroupNodeFolderDto(
    WorkGroupNodeId('2638b3a2-f782-4bf1-9015-200ee0067921'),
    WorkGroupNodeId('e2c7569a-2fba-4a46-a02d-9a11643c0a46'),
    WorkGroupNodeType.FOLDER,
    SharedSpaceId('eda9a917-10a7-44e0-98dc-7179ab914ab7'),
    DateTime.fromMillisecondsSinceEpoch(1616561531356),
    DateTime.fromMillisecondsSinceEpoch(1616561531356),
    '',
    'sample.ods',
    accountDto1,
    []
);

final workGroupFolder = WorkGroupFolder(
    WorkGroupNodeId('2638b3a2-f782-4bf1-9015-200ee0067921'),
    WorkGroupNodeId('e2c7569a-2fba-4a46-a02d-9a11643c0a46'),
    WorkGroupNodeType.FOLDER,
    SharedSpaceId('eda9a917-10a7-44e0-98dc-7179ab914ab7'),
    DateTime.fromMillisecondsSinceEpoch(1616561531356),
    DateTime.fromMillisecondsSinceEpoch(1616561531356),
    '',
    'sample.ods',
    account1,
    []
);


final documentAuditLogDto = WorkGroupDocumentAuditLogEntryDto(
    AuditLogEntryId('119b56e8-3d43-43a0-a422-0037c96e5b1c'),
    AuditLogResourceId('2638b3a2-f782-4bf1-9015-200ee0067921'),
    AuditLogResourceId('2638b3a2-f782-4bf1-9015-200ee0067921'),
    DateTime.fromMillisecondsSinceEpoch(1617156864861),
    accountDto1,
    AuditLogEntryType.WORKGROUP_DOCUMENT,
    LogAction.DOWNLOAD,
    LogActionCause.COPY,
    accountDto1,
    workGroupLightDto,
    workGroupDocumentDto,
    workGroupDocumentDto,
    workGroupCopyDto,
    workGroupCopyDto
);

final folderAuditLogDto = WorkGroupFolderAuditLogEntryDto(
    AuditLogEntryId('119b56e8-3d43-43a0-a422-0037c96e5b1c'),
    AuditLogResourceId('2638b3a2-f782-4bf1-9015-200ee0067921'),
    AuditLogResourceId('2638b3a2-f782-4bf1-9015-200ee0067921'),
    DateTime.fromMillisecondsSinceEpoch(1617156864861),
    accountDto1,
    AuditLogEntryType.WORKGROUP_FOLDER,
    LogAction.UPDATE,
    LogActionCause.COPY,
    accountDto1,
    workGroupLightDto,
    workGroupFolderDto,
    workGroupFolderDto,
    workGroupCopyDto2,
    workGroupCopyDto2
);

final documentAuditLog = WorkGroupDocumentAuditLogEntry(
    AuditLogEntryId('119b56e8-3d43-43a0-a422-0037c96e5b1c'),
    AuditLogResourceId('2638b3a2-f782-4bf1-9015-200ee0067921'),
    AuditLogResourceId('2638b3a2-f782-4bf1-9015-200ee0067921'),
    DateTime.fromMillisecondsSinceEpoch(1617156864861),
    account1,
    AuditLogEntryType.WORKGROUP_DOCUMENT,
    LogAction.DOWNLOAD,
    LogActionCause.COPY,
    account1,
    workGroupLight,
    workGroupDocument,
    workGroupDocument,
    workGroupCopy,
    workGroupCopy
);

final folderAuditLog = WorkGroupFolderAuditLogEntry(
    AuditLogEntryId('119b56e8-3d43-43a0-a422-0037c96e5b1c'),
    AuditLogResourceId('2638b3a2-f782-4bf1-9015-200ee0067921'),
    AuditLogResourceId('2638b3a2-f782-4bf1-9015-200ee0067921'),
    DateTime.fromMillisecondsSinceEpoch(1617156864861),
    account1,
    AuditLogEntryType.WORKGROUP_FOLDER,
    LogAction.UPDATE,
    LogActionCause.COPY,
    account1,
    workGroupLight,
    workGroupFolder,
    workGroupFolder,
    workGroupCopy2,
    workGroupCopy2
);

final sharedSpaceIdOffline1 = SharedSpaceId('eda9a917-10a7-44e0-98dc-7179ab914ab7');
final workGroupNodeIdOffline1 = WorkGroupNodeId('e2c7569a-2fba-4a46-a02d-9a11643c0a46');
final workGroupCache1 = WorkGroupNodeCache(
    WorkGroupNodeId('2638b3a2-f782-4bf1-9015-200ee0067921'),
    SharedSpaceId('eda9a917-10a7-44e0-98dc-7179ab914ab7'),
    WorkGroupNodeId('e2c7569a-2fba-4a46-a02d-9a11643c0a46'),
    DateTime.fromMillisecondsSinceEpoch(1616561531356),
    DateTime.fromMillisecondsSinceEpoch(1616561531356),
    'sample.ods',
    WorkGroupNodeType.DOCUMENT,
    '',
    account1.name,
    account1.mail,
    account1.firstName,
    account1.lastName,
    account1.accountId,
    account1.accountType,
    3112,
    MediaType.parse('application/vnd.oasis.opendocument.spreadsheet'),
    false,
    DateTime.fromMillisecondsSinceEpoch(1616561531356),
    false,
    'c6215e10c2f6086a2cd090cecfbad515d13170f00b7effe9cd6b162991622dea',
    '/storage/path'
);

final workGroupCache2 = WorkGroupNodeCache(
    WorkGroupNodeId('2638b3a2-f782-4bf1-9015-200ee0067921'),
    SharedSpaceId('eda9a917-10a7-44e0-98dc-7179ab914ab7'),
    WorkGroupNodeId('e2c7569a-2fba-4a46-a02d-9a11643c0a46'),
    DateTime.fromMillisecondsSinceEpoch(1616561531358),
    DateTime.fromMillisecondsSinceEpoch(1616561531358),
    'hello.ods',
    WorkGroupNodeType.DOCUMENT,
    '',
    account1.name,
    account1.mail,
    account1.firstName,
    account1.lastName,
    account1.accountId,
    account1.accountType,
    3112,
    MediaType.parse('application/vnd.oasis.opendocument.spreadsheet'),
    false,
    DateTime.fromMillisecondsSinceEpoch(1616561531358),
    false,
    'c6215e10c2f6086a2cd090cecfbad515d13170f00b7effe9cd6b162991622dea',
    '/storage/path'
);
final workGroupNode1 = WorkGroupDocument(
    WorkGroupNodeId('2638b3a2-f782-4bf1-9015-200ee0067921'),
    WorkGroupNodeId('e2c7569a-2fba-4a46-a02d-9a11643c0a46'),
    WorkGroupNodeType.DOCUMENT,
    SharedSpaceId('eda9a917-10a7-44e0-98dc-7179ab914ab7'),
    DateTime.fromMillisecondsSinceEpoch(1616561531356),
    DateTime.fromMillisecondsSinceEpoch(1616561531356),
    '',
    'sample.ods',
    account1,
    3112,
    MediaType.parse('application/vnd.oasis.opendocument.spreadsheet'),
    false,
    DateTime.fromMillisecondsSinceEpoch(1616561531356),
    false,
    'c6215e10c2f6086a2cd090cecfbad515d13170f00b7effe9cd6b162991622dea',
    localPath: '/storage/path'
);
final workGroupNode2 = WorkGroupDocument(
    WorkGroupNodeId('2638b3a2-f782-4bf1-9015-200ee0067921'),
    WorkGroupNodeId('e2c7569a-2fba-4a46-a02d-9a11643c0a46'),
    WorkGroupNodeType.DOCUMENT,
    SharedSpaceId('eda9a917-10a7-44e0-98dc-7179ab914ab7'),
    DateTime.fromMillisecondsSinceEpoch(1616561531358),
    DateTime.fromMillisecondsSinceEpoch(1616561531358),
    '',
    'hello.ods',
    account1,
    3112,
    MediaType.parse('application/vnd.oasis.opendocument.spreadsheet'),
    false,
    DateTime.fromMillisecondsSinceEpoch(1616561531358),
    false,
    'c6215e10c2f6086a2cd090cecfbad515d13170f00b7effe9cd6b162991622dea',
    localPath: '/storage/path'
);