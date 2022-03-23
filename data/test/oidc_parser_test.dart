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
//

import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('oidc_parser_test', () {
    late OIDCParser _oidcParser;

    final oidcConfigExpect = OIDCConfiguration(
      authority: 'https://auth.linshare.local/',
      clientId: 'linshare-mobile',
      responseType: 'code',
      logoutRedirectUri: 'linshare.mobile://oauthredirect',
      scopes: ['openid', 'email', 'profile'],
    );

    setUp(() {
      _oidcParser = OIDCParser();
    });

    test('parseOIDCConfiguration should return success with valid data', () async {

      final jsConfig = '''
        (function() {
        'use strict';
      
        angular
          .module('linshareUiUserApp')
          .constant('lsUserConfig', {
            debug: false,
            licence: true,
            loginWithMailOnly: true,
            production: true,
            extLink: {
              enable: true,
              newTab: true,
              icon: 'zmdi zmdi-email',
              href: 'https://webmail.linshare-4-3-on-commit.integration-linshare.org',
              name: {
                'fr-FR': 'RoundCube',
                'en-US': 'RoundCube',
                'vi-VN': 'RoundCube',
                'ru-RU': 'RoundCube'
              }
            },
      
      
            oidcEnabled: false,
            oidcSetting: {
              authority: 'https://auth.linshare.local/',
              client_id: 'linshare',
              client_secret: 'linshare',
              redirect_uri: window.location.origin + '/#!/oidc',
              post_logout_redirect_uri: window.location.origin + '/#!/login',
              response_type: 'code',
              scope: 'openid email profile'
            },
      
            mobileOidcEnabled: false,
            mobileOidcSetting: {
              authority: 'https://auth.linshare.local/',
              client_id: 'linshare-mobile',
              redirect_url: 'linshare.mobile://oauthredirect',
              post_logout_redirect_uri: 'linshare.mobile://oauthredirect',
              response_type: 'code',
              scope: 'openid email profile'
            },
      
      
            /*
              Define configuration for the OTP uri generator.
              - type, digits, algorithm, period: need to match with linshare-core configuration
              - issuer: will determine the name of OTP entry in authentication mobile app
            */
            otpConfig: {
              type: 'totp',
              digits: 6,
              issuer: 'LinShare linshare-4-3-on-commit',
              algorithm: 'SHA1',
              period: 30
            }
          });
      })();
      ''';

      final result = _oidcParser.parseOIDCConfiguration(jsConfig);

      expect(oidcConfigExpect.clientId, equals(result?.clientId));
    });
  });
}