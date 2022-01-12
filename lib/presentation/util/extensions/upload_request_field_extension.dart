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

extension UploadRequestFieldExtension on UploadRequestField {

  String getName(BuildContext context) {
    switch(this) {
      case UploadRequestField.status:
        return AppLocalizations.of(context).status;
      case UploadRequestField.notificationLanguage:
        return AppLocalizations.of(context).notification_language;
      case UploadRequestField.allowDeletion:
        return AppLocalizations.of(context).allow_deletion;
      case UploadRequestField.allowClosure:
        return AppLocalizations.of(context).allow_closure;
      case UploadRequestField.maxNumberOfFiles:
        return AppLocalizations.of(context).max_number_of_files;
      case UploadRequestField.maxSizePerFile:
        return AppLocalizations.of(context).max_size_per_file;
      case UploadRequestField.maxTotalFileSize:
        return AppLocalizations.of(context).max_total_file_size;
      case UploadRequestField.notificationDate:
        return AppLocalizations.of(context).notification_date;
      case UploadRequestField.expirationDate:
        return AppLocalizations.of(context).expiration_date;
      case UploadRequestField.activationDate:
        return AppLocalizations.of(context).activation_date;
    }
  }
}