/*
 * LinShare is an open source filesharing software, part of the LinPKI software
 * suite, developed by Linagora.
 *
 * Copyright (C) 2021 LINAGORA
 *
 * This program is free software: you can redistribute it and/or modify it under the
 * terms of the GNU Affero General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version,
 * provided you comply with the Additional Terms applicable for LinShare software by
 * Linagora pursuant to Section 7 of the GNU Affero General Public License,
 * subsections (b), (c), and (e), pursuant to which you must notably (i) retain the
 * display in the interface of the “LinShare™” trademark/logo, the "Libre & Free" mention,
 * the words “You are using the Free and Open Source version of LinShare™, powered by
 * Linagora © 2009–2021. Contribute to Linshare R&D by subscribing to an Enterprise
 * offer!”. You must also retain the latter notice in all asynchronous messages such as
 * e-mails sent with the Program, (ii) retain all hypertext links between LinShare and
 * http://www.linshare.org, between linagora.com and Linagora, and (iii) refrain from
 * infringing Linagora intellectual property rights over its trademarks and commercial
 * brands. Other Additional Terms apply, see
 * <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf>
 * for more details.
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for
 * more details.
 * You should have received a copy of the GNU Affero General Public License and its
 * applicable Additional Terms for LinShare along with this program. If not, see
 * <http://www.gnu.org/licenses/> for the GNU Affero General Public License version
 *  3 and <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf> for
 *  the Additional Terms applicable to LinShare software.
 */

class ReceivedShareTable {
  static const String TABLE_NAME = 'received_share';

  static const String SHARE_ID = 'shareId';
  static const String DOWNLOADED = 'downloaded';
  static const String DESCRIPTION = 'description';
  static const String CREATION_DATE = 'creationDate';
  static const String MODIFICATION_DATE = 'modificationDate';
  static const String EXPIRATION_DATE = 'expirationDate';
  static const String NAME = 'name';
  static const String SIZE = 'size';
  static const String HAS_THUMBNAIL = 'hasThumbnail';
  static const String SHARED = 'shared';
  static const String MEDIA_TYPE = 'mediaType';
  static const String LOCAL_PATH = 'localPath';

  static const String MAIL_RECIPIENT = 'mail_recipient';
  static const String FIRST_NAME_RECIPIENT = 'first_name_recipient';
  static const String LAST_NAME_RECIPIENT = 'last_name_recipient';

  static const String MAIL_SENDER = 'mail_sender';
  static const String FIRST_NAME_SENDER = 'first_name_sender';
  static const String LAST_NAME_SENDER = 'last_name_sender';


  static const String CREATE = '''CREATE TABLE IF NOT EXISTS $TABLE_NAME (
    $SHARE_ID TEXT PRIMARY KEY,
    $NAME TEXT,
    $CREATION_DATE Integer,
    $MODIFICATION_DATE Integer,
    $EXPIRATION_DATE Integer,
    $DESCRIPTION TEXT,
    $DOWNLOADED Integer,
    $MAIL_RECIPIENT TEXT,
    $FIRST_NAME_RECIPIENT TEXT,
    $LAST_NAME_RECIPIENT TEXT,
    $MEDIA_TYPE TEXT,
    $MAIL_SENDER TEXT,
    $FIRST_NAME_SENDER TEXT,
    $LAST_NAME_SENDER TEXT,
    $SIZE Integer,
    $HAS_THUMBNAIL Integer,
    $LOCAL_PATH TEXT
  )''';
}
