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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:linshare_flutter_app/l10n/messages_all.dart';

class AppLocalizations {

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static Future<AppLocalizations> load(Locale locale) async {
    final name = locale.countryCode == null ? locale.languageCode : locale.toString();

    final localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return AppLocalizations();
    });
  }

  String get initializing_data {
    return Intl.message('Initializing data...',
      name: 'initializing_data');
  }

  String get login_text_slogan {
    return Intl.message('Store and share your files from anywhere',
      name: 'login_text_slogan');
  }

  String get login_text_login_to_continue {
    return Intl.message('Please login to continue',
      name: 'login_text_login_to_continue');
  }

  String get https {
    return Intl.message('https://',
      name: 'https');
  }

  String get email {
    return Intl.message('email',
      name: 'email');
  }

  String get password {
    return Intl.message('password',
      name: 'password');
  }

  String get login_button_login {
    return Intl.message('Login',
      name: 'login_button_login');
  }

  String get upload_file_title {
    return Intl.message('Upload file',
      name: 'upload_file_title');
  }

  String get upload_text_button {
    return Intl.message('Upload to My Space',
      name: 'upload_text_button');
  }

  String get my_space_title {
    return Intl.message('My Space',
      name: 'my_space_title');
  }

  String get upload_prepare_text {
    return Intl.message('Preparing to upload...',
      name: 'upload_prepare_text');
  }

  String get my_space_text_upload_your_files_here {
    return Intl.message('Upload your files here',
      name: 'my_space_text_upload_your_files_here');
  }

  String get upload_failure_text {
    return Intl.message('Failed to upload file',
      name: 'upload_failure_text');
  }

  String get upload_success_text {
    return Intl.message('File uploaded',
      name: 'upload_success_text');
  }

  String get wrong_url_message {
    return Intl.message('Server URL is not valid, please try again',
      name: 'wrong_url_message');
  }

  String get credential_error_message {
    return Intl.message('Authentication failed, either the email or the password is invalid, please try again',
      name: 'credential_error_message');
  }

  String get unknown_error_login_message {
    return Intl.message('Unknown error occurred, please try again',
      name: 'unknown_error_login_message');
  }

  String item_last_modified(String dateString) =>
    Intl.message('Modified $dateString',
        name: 'item_last_modified',
        args: [dateString]);

  String get my_space {
    return Intl.message('My Space', name: 'my_space');
  }

  String get common_error_occured_message {
    return Intl.message('Unexpected error occurs\nPlease reload or try again later');
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'vi', 'fr', 'ru'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
