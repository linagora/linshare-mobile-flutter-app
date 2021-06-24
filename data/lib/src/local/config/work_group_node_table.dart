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

class WorkGroupNodeTable {
  static const String TABLE_NAME = 'workGroupNode';

  static const String NODE_ID = 'nodeId';
  static const String SHARED_SPACE_ID = 'sharedSpaceId';
  static const String PARENT_NODE_ID = 'parentNodeId';
  static const String CREATION_DATE = 'creationDate';
  static const String MODIFICATION_DATE = 'modificationDate';
  static const String NAME = 'name';
  static const String NODE_TYPE = 'nodeType';
  static const String DESCRIPTION = 'description';
  static const String NAME_ACCOUNT = 'nameAccount';
  static const String MAIL_ACCOUNT = 'mailAccount';
  static const String FIRST_NAME_ACCOUNT = 'firstNameAccount';
  static const String LAST_NAME_ACCOUNT = 'lastNameAccount';
  static const String ACCOUNT_ID = 'accountId';
  static const String ACCOUNT_TYPE = 'accountType';
  static const String SIZE = 'size';
  static const String MEDIA_TYPE = 'mediaType';
  static const String HAS_THUMBNAIL = 'hasThumbnail';
  static const String UPLOAD_DATE = 'uploadDate';
  static const String HAS_REVISION = 'hasRevision';
  static const String SHA256_SUM = 'sha256sum';
  static const String LOCAL_PATH = 'localPath';

  static const String CREATE = '''CREATE TABLE ${TABLE_NAME} (
    ${NODE_ID} TEXT PRIMARY KEY,
    ${SHARED_SPACE_ID} TEXT,
    ${PARENT_NODE_ID} TEXT,
    ${CREATION_DATE} Integer,
    ${MODIFICATION_DATE} Integer,
    ${NAME} TEXT,
    ${NODE_TYPE} TEXT,
    ${DESCRIPTION} TEXT,
    ${NAME_ACCOUNT} TEXT,
    ${MAIL_ACCOUNT} TEXT,
    ${FIRST_NAME_ACCOUNT} TEXT,
    ${LAST_NAME_ACCOUNT} TEXT,
    ${ACCOUNT_ID} TEXT,
    ${ACCOUNT_TYPE} TEXT,
    ${SIZE} Integer,
    ${MEDIA_TYPE} TEXT,
    ${HAS_THUMBNAIL} Integer,
    ${UPLOAD_DATE} Integer,
    ${HAS_REVISION} Integer,
    ${SHA256_SUM} TEXT,
    ${LOCAL_PATH} TEXT
  )''';
}