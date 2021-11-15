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

class SharedSpaceTable {
  static const String TABLE_NAME = 'sharedSpace';

  static const String SHARED_SPACE_ID = 'sharedSpaceId';
  static const String DRIVE_ID = 'driveId';
  static const String SHARED_SPACE_ROLE_ID = 'sharedSpaceRoleId';
  static const String SHARED_SPACE_ROLE_NAME = 'sharedSpaceRoleName';
  static const String SHARED_SPACE_ROLE_ENABLE = 'sharedSpaceRoleEnable';
  static const String CREATION_DATE = 'creationDate';
  static const String MODIFICATION_DATE = 'modificationDate';
  static const String NAME = 'name';
  static const String NODE_TYPE = 'nodeType';
  static const String QUOTA_ID = 'quotaId';
  static const String VERSIONING_PARAMETERS = 'versioningParameters';

  static const String CREATE = '''CREATE TABLE IF NOT EXISTS $TABLE_NAME (
    $SHARED_SPACE_ID TEXT PRIMARY KEY,
    $DRIVE_ID TEXT,
    $SHARED_SPACE_ROLE_ID TEXT,
    $SHARED_SPACE_ROLE_NAME TEXT,
    $SHARED_SPACE_ROLE_ENABLE Integer,
    $CREATION_DATE Integer,
    $MODIFICATION_DATE Integer,
    $NAME TEXT,
    $NODE_TYPE TEXT,
    $QUOTA_ID TEXT,
    $VERSIONING_PARAMETERS Integer
  )''';

  static const String ADD_NEW_COLUMN_DRIVE_ID = 'ALTER TABLE $TABLE_NAME ADD COLUMN $DRIVE_ID TEXT';
}