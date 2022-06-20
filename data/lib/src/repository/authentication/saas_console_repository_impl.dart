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

class SaaSConsoleRepositoryImpl extends SaaSConsoleRepository {

  final loginBaseUrl = 'https://user.linshare-saas-on-commit.integration-linshare.org';
  final secretBaseUrl = 'https://dev-subscription.twake.app';
  final signUpBaseUrl = 'https://dev-account.twake.app';

  final stagingLoginBaseUrl = 'https://staging-web.linshare.app';
  final stagingSecretBaseUrl = 'https://staging-subscription.twake.app';
  final stagingSignUpBaseUrl = 'https://staging-account.twake.app';

  final prodLoginBaseUrl = 'https://web.linshare.app';
  final prodSecretBaseUrl = 'https://subscription.twake.app';
  final prodSignUpBaseUrl = 'https://account.twake.app';

  final companyName = 'My company';

  SaaSConsoleRepositoryImpl();

  @override
  Future<SaaSConfiguration> getSaaSConfiguration(SaaSType saaSType) async {
    switch(saaSType) {
      case SaaSType.dev:
        return SaaSConfiguration(
          loginBaseUrl: Uri.parse(loginBaseUrl),
          signUpBaseUrl: Uri.parse(signUpBaseUrl),
          secretBaseUrl: Uri.parse(secretBaseUrl),
          companyName: companyName);
      case SaaSType.staging:
        return SaaSConfiguration(
          loginBaseUrl: Uri.parse(stagingLoginBaseUrl),
          signUpBaseUrl: Uri.parse(stagingSignUpBaseUrl),
          secretBaseUrl: Uri.parse(stagingSecretBaseUrl),
          companyName: companyName);
      default:
        return SaaSConfiguration(
          loginBaseUrl: Uri.parse(prodLoginBaseUrl),
          signUpBaseUrl: Uri.parse(prodSignUpBaseUrl),
          secretBaseUrl: Uri.parse(prodSecretBaseUrl),
          companyName: companyName
        );
    }
  }
}