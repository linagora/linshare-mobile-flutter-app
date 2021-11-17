// LinShare is an open source filesharing software, part of the LinPKI software
// suite, developed by Linagora.
//
// Copyright (C) 2021 LINAGORA
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

enum FunctionalityIdentifier {
  UNKNOWN_IDENTIFIER,
  WORK_GROUP,
  UPLOAD_REQUEST,
  UPLOAD_REQUEST__MAXIMUM_FILE_SIZE,
  UPLOAD_REQUEST__MAXIMUM_FILE_COUNT,
  UPLOAD_REQUEST__MAXIMUM_DEPOSIT_SIZE,
  UPLOAD_REQUEST__DELAY_BEFORE_NOTIFICATION,
  UPLOAD_REQUEST__DELAY_BEFORE_ACTIVATION,
  UPLOAD_REQUEST__DELAY_BEFORE_EXPIRATION,
  UPLOAD_REQUEST__NOTIFICATION_LANGUAGE,
  UPLOAD_REQUEST__REMINDER_NOTIFICATION,
  UPLOAD_REQUEST__CAN_DELETE,
  UPLOAD_REQUEST__CAN_CLOSE,
  UPLOAD_REQUEST__PROTECTED_BY_PASSWORD,
  DRIVE,
  DRIVE__CREATION_RIGHT,
}

extension FunctionalityIdentifierExtension on FunctionalityIdentifier {
  String get name {
    return toString().split('.').last;
  }
}
