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
import 'package:domain/domain.dart';

extension StringExtension on String {
  int compareToSort(String value, OrderType orderType) =>
      toLowerCase().compareTo(value.toLowerCase()) * (orderType == OrderType.ascending ? -1 : 1);

  bool isIntegerNumber() {
    return int.tryParse(this) != null;
  }

  String toMiddleEllipsis() {
    if (contains('.')) {
      final subLength = length - split('.').last.length;
      return subLength >= 3
          ? '...' + substring(subLength - 3, subLength) + split('.').last
          : this;
    } else {
      return length >= 3 ? '...' + substring(length - 3, length) : this;
    }
  }

  String capitalizeFirst() {
    if (isEmpty) {
      return this;
    }
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  SharedSpaceRoleName? toSharedSpaceRoleName() {
    switch (this) {
      case 'READER':
        return SharedSpaceRoleName.READER;
      case 'CONTRIBUTOR':
        return SharedSpaceRoleName.CONTRIBUTOR;
      case 'WRITER':
        return SharedSpaceRoleName.WRITER;
      case 'ADMIN':
        return SharedSpaceRoleName.ADMIN;
      case 'DRIVE_READER':
        return SharedSpaceRoleName.DRIVE_READER;
      case 'DRIVE_WRITER':
        return SharedSpaceRoleName.DRIVE_WRITER;
      case 'DRIVE_ADMIN':
        return SharedSpaceRoleName.DRIVE_ADMIN;
      default:
        return null;
    }
  }

  LinShareNodeType? toLinShareNodeType() {
    switch (this) {
      case 'DRIVE':
        return LinShareNodeType.DRIVE;
      case 'WORK_GROUP':
        return LinShareNodeType.WORK_GROUP;
      default:
        return null;
    }
  }

  WorkGroupNodeType? toWorkGroupNodeType() {
    switch (this) {
      case 'FOLDER':
        return WorkGroupNodeType.FOLDER;
      case 'DOCUMENT':
        return WorkGroupNodeType.DOCUMENT;
      case 'DOCUMENT_REVISION':
        return WorkGroupNodeType.DOCUMENT_REVISION;
      default:
        return null;
    }
  }

  AccountType? toAccountType() {
    switch (this) {
      case 'INTERNAL':
        return AccountType.INTERNAL;
      case 'SYSTEM':
        return AccountType.SYSTEM;
      default:
        return null;
    }
  }

}
