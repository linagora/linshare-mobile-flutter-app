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
import 'package:flutter/material.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';

extension ValicatorFailureExtension on VerifyNameFailure {

  String getMessage(BuildContext context) {
    if (exception is EmptyNameException) {
      return AppLocalizations.of(context).node_name_not_empty(AppLocalizations.of(context).file);
    } else if (exception is DuplicatedNameException) {
      return AppLocalizations.of(context).node_name_already_exists(AppLocalizations.of(context).file);
    } else if (exception is SpecialCharacterException) {
      return AppLocalizations.of(context).node_name_contain_special_character(AppLocalizations.of(context).file);
    } else if (exception is LastDotException) {
      return AppLocalizations.of(context).node_name_contain_last_dot(AppLocalizations.of(context).file);
    } else if (exception is EmptyLoginEmailException) {
      return AppLocalizations.of(context).email_is_required;
    } else if (exception is LoginEmailInvalidException) {
      return AppLocalizations.of(context).email_is_invalid;
    } else if (exception is EmptyLoginPasswordException) {
      return AppLocalizations.of(context).password_is_required;
    } else if (exception is PasswordSpecialCharacterException) {
      return AppLocalizations.of(context).password_is_invalid;
    } else if (exception is EmptyLoginUrlException) {
      return AppLocalizations.of(context).url_is_invalid;
    } else if (exception is EmptySignUpNameException) {
      return AppLocalizations.of(context).name_is_required;
    } else if (exception is EmptySignUpSurnameException) {
      return AppLocalizations.of(context).surname_is_required;
    } else {
      return '';
    }
  }
}