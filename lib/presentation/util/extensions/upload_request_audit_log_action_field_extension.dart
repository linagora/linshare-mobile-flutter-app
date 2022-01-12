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
// for more DETAILS.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for
// more DETAILS.
// You should have received a copy of the GNU Affero General Public License and its
// applicable Additional Terms for LinShare along with this program. If not, see
// <http://www.gnu.org/licenses/> for the GNU Affero General Public License version
//  3 and <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf> for
//  the Additional Terms applicable to LinShare software.

import 'package:domain/domain.dart';
import 'package:flutter/cupertino.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/model/notification_language.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/string_extensions.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/datetime_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/file_size_extension.dart';
import 'package:linshare_flutter_app/presentation/model/file_size_type.dart';

extension UploadRequestAuditLogActionFieldExtension on UploadRequestAuditLogActionField {

  String getValueChanged(BuildContext context) {
    if (oldValue == null || newValue == null) {
      return '';
    }

    switch(field) {
      case UploadRequestField.status:
        UploadRequestStatus? value1 = oldValue;
        UploadRequestStatus? value2 = newValue;
        return '${value1?.value.capitalizeFirst()} -> '
            '${value2?.value.capitalizeFirst()}';
      case UploadRequestField.notificationLanguage:
        String value1 = oldValue;
        String value2 = newValue;
        return '${value1.toNotificationLanguage().text.capitalizeFirst()} -> '
            '${value2.toNotificationLanguage().text.capitalizeFirst()}';
      case UploadRequestField.allowDeletion:
      case UploadRequestField.allowClosure:
        bool? value1 = oldValue;
        bool? value2 = newValue;
        return '${value1 == true ? AppLocalizations.of(context).yes : AppLocalizations.of(context).no} -> '
          '${value2 == true ? AppLocalizations.of(context).yes : AppLocalizations.of(context).no}';
      case UploadRequestField.maxNumberOfFiles:
        int? value1 = oldValue;
        int? value2 = newValue;
        return '$value1 -> $value2';
      case UploadRequestField.maxSizePerFile:
      case UploadRequestField.maxTotalFileSize:
        double? value1 = oldValue;
        double? value2 = newValue;
        return '${value1.toFileSize().value1} ${value1.toFileSize().value2.text} -> '
            '${value2.toFileSize().value1} ${value2.toFileSize().value2.text}';
      case UploadRequestField.notificationDate:
      case UploadRequestField.expirationDate:
      case UploadRequestField.activationDate:
        DateTime value1 = oldValue;
        DateTime value2 = newValue;
        return '${value1.getYYYYMMddHHMMFormatString()} -> '
            '${value2.getYYYYMMddHHMMFormatString()}';
    }
  }
}