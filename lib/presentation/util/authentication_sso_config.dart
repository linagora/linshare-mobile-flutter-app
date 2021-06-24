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

class AuthenticationSSOConfig {
  static const String clientId = 'linsharemobile';
  static const String redirectUrl = 'linsharemobile.com://oauthredirect';
  static const List<String> scopes = <String>[
    'openid',
    'email',
    'profile'
  ];
  static const SSOConfiguration ssoConfiguration = SSOConfiguration(
      'https://linshare-integration-4-auth.linagora.com/oauth2/authorize',
      'https://linshare-integration-4-auth.linagora.com/oauth2/token');
  static const baseUrlSupported = 'https://linshare-integration-4-files.linagora.com/';
  static const allowInsecureConnection = false;

  /// Whether to perform credentials after has been done logout before
  /// If it's true, the login form is displayed.
  /// If it's false, going to use cached credential from browser. So, it does not need to fill form again.
  static const requiredReAuth = true;

  /// For iOS:
  /// If is true, it will not share cookies each time prompting the login session. So it displays login form normally.
  /// If is false, it will display dialog with message: "Linshare wants to use linagora.com to sign in. This allows the app and website to share information about you."
  /// Then it prompts (blinking) to the login form with shared cookie from last session then back to app without credential action.
  /// For more information:
  /// https://github.com/MaikuB/flutter_appauth/pull/112
  /// https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession/3237231-prefersephemeralwebbrowsersessio
  static final preferEphemeralSessionIOS = requiredReAuth;

  /// For Android:
  /// It works as preferEphemeralSessionIOS option. If it is `login`, it will ask for credentials again.
  /// For more information:
  /// https://github.com/MaikuB/flutter_appauth/issues/48
  /// https://openid.net/specs/openid-connect-core-1_0.html#rfc.section.3.1.2.1
  static final List<String>? promptValues = requiredReAuth ? ['login'] : null;

}
