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
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:testshared/fixture/audit_user_fixture.dart';

import 'fixture/mock/mock_fixtures.dart';

void main() {
  group('audit_user_datasource_impl_test', () {
    late MockLinShareHttpClient _linShareHttpClient;
    late MockRemoteExceptionThrower _remoteExceptionThrower;
    late AuditUserDataSourceImpl _auditUserDataSourceImpl;

    setUp(() {
      _linShareHttpClient = MockLinShareHttpClient();
      _remoteExceptionThrower = MockRemoteExceptionThrower();
      _auditUserDataSourceImpl = AuditUserDataSourceImpl(
        _linShareHttpClient,
        _remoteExceptionThrower
      );
    });

    test('getLastLogin should return success with valid data', () async {
      when(_linShareHttpClient.getAuditAuthenticationEntryUser())
        .thenAnswer((_) async => [authenticationAuditLogEntryUserResponse1, authenticationAuditLogEntryUserResponse2]);

      final result = await _auditUserDataSourceImpl.getLastLogin();
      expect(result, authenticationAuditLogEntryUserResponse2.toLastLogin());
    });

    test('getLastLogin should throw UnknownError when linShareHttpClient throw exception', () async {
      when(_linShareHttpClient.getAuditAuthenticationEntryUser())
        .thenThrow(Exception());

      await _auditUserDataSourceImpl.getLastLogin()
        .catchError((error) {
          expect(error, isA<UnknownError>());
        });
    });
  });
}
