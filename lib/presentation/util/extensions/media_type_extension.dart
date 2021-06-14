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
// infringing Linagora intellectual property rights over its trademarks and .commercial
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

import 'package:http_parser/http_parser.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:mime/mime.dart';

extension MediaTypeExtension on MediaType {
  String getFileTypeImagePath(AppImagePaths appImagePaths) {
    var fileTypeImagePath = appImagePaths.icFileTypeFile;
    switch (type) {
      case 'video':
        fileTypeImagePath = appImagePaths.icFileTypeVideo;
        break;
      case 'image':
        fileTypeImagePath = appImagePaths.icFileTypeImage;
        break;
      case 'audio':
        fileTypeImagePath = appImagePaths.icFileTypeAudio;
        break;
      case 'application':
        fileTypeImagePath = getApplicationIconBasedOnSubType(appImagePaths);
        break;
      case 'text':
        fileTypeImagePath = getTextIconBaseOnSubType(appImagePaths);
        break;
      default:
        fileTypeImagePath = appImagePaths.icFileTypeFile;
        break;
    }
    return fileTypeImagePath;
  }

  String getApplicationIconBasedOnSubType(AppImagePaths appImagePaths) {
    if (subtype == 'pdf') {
      return appImagePaths.icFileTypePdf;
    } else if (
    subtype == 'vnd.openxmlformats-officedocument.wordprocessingml.document' ||
    subtype == 'msword' ||
    subtype == 'vnd.oasis.opendocument.text') {
      return appImagePaths.icFileTypeDoc;
    } else if (
    subtype == 'vnd.oasis.opendocument.spreadsheet' ||
    subtype == 'vnd.openxmlformats-officedocument.spreadsheetml.sheet' ||
    subtype == 'vnd.ms-excel') {
      return appImagePaths.icFileTypeSheets;
    } else if (
    subtype == 'vnd.ms-powerpoint' ||
    subtype == 'vnd.openxmlformats-officedocument.presentationml.presentation' ||
    subtype == 'octet-stream' ||
    subtype == 'vnd.oasis.opendocument.presentation') {
      return appImagePaths.icFileTypeSlide;
    }
    return appImagePaths.icFileTypeFile;
  }

  String getTextIconBaseOnSubType(AppImagePaths appImagePaths) {
    if (subtype == 'plain' || subtype == 'comma-separated-values') {
      return appImagePaths.icFileTypeSheets;
    }
    return appImagePaths.icFileTypeFile;
  }
}

extension StringMimeTypeExtension on String {
  static final String defaultMimeType = 'application/octet-stream';

  static final MediaType defaultMediaType = MediaType.parse(defaultMimeType);

  String getMimeType() {
    try {
      return lookupMimeType(this) ?? defaultMimeType;
    } catch(_) {
      return defaultMimeType;
    }
  }

  MediaType getMediaType() {
    try {
      return MediaType.parse(getMimeType());
    } catch(_) {
      return defaultMediaType;
    }
  }
}
