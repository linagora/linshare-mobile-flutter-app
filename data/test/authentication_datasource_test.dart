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

import 'package:data/data.dart';
import 'package:data/src/network/model/response/permanent_token.dart';
import 'package:dio/dio.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'authentication_datasource_test.mocks.dart';
import 'fixture/user_fixture.dart';

@GenerateMocks([DeviceManager, LinShareHttpClient])
void main() {
  group('test authentication dataSource', () {
    late MockDeviceManager _deviceManager;
    late MockLinShareHttpClient _linShareHttpClient;
    late RemoteExceptionThrower _remoteExceptionThrower;
    late AuthenticationDataSourceImpl _authenticationDataSource;

    setUp(() {
      _deviceManager = MockDeviceManager();
      _linShareHttpClient = MockLinShareHttpClient();
      _remoteExceptionThrower = RemoteExceptionThrower();
      _authenticationDataSource = AuthenticationDataSourceImpl(_linShareHttpClient, _deviceManager, _remoteExceptionThrower);
    });

    test('deletePermanentToken should throw MissingRequiredFields when linShareHttpClient response error is 400', () async {
      var error = DioError(
        type: DioErrorType.response,
        response: Response(statusCode: 400, requestOptions: RequestOptions(path: '')),
        requestOptions: RequestOptions(path: '')
      );
      final token = Token('token', TokenId('12345-5555'));
      when(_linShareHttpClient.deletePermanentToken(argThat(isA<PermanentToken>())))
          .thenThrow(error);

      try {
        await _authenticationDataSource.deletePermanentToken(token);
      } catch(error) {
        expect(error, isA<MissingRequiredFields>());
      }
    });



    test('getAuthorizedUser should success', () async {
      when(_linShareHttpClient.getAuthorizedUser())
        .thenAnswer((_) async => userResponse1);

      var result = await _authenticationDataSource.getAuthorizedUser();

      expect(result, user1);
    });

    test('getAuthorizedUser should throw NotConnectedUser when linShareHttpClient response is null', () async {
      when(_linShareHttpClient.getAuthorizedUser())
        .thenAnswer((_) async => null);

      try {
        await _authenticationDataSource.getAuthorizedUser();
      } catch(error) {
        expect(error, isA<NotAuthorizedUser>());
      }
    });
  });
}
