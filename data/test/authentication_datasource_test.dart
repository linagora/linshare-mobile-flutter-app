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
import 'package:data/src/network/model/request/permanent_token_body_request.dart';
import 'package:data/src/network/model/response/permanent_token.dart';
import 'package:dio/dio.dart';
import 'package:domain/domain.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'fixture/mock/mock_fixtures.dart';

void main() {
  group('test authentication dataSource', () {
    MockDeviceManager _deviceManager;
    MockLinShareHttpClient _linShareHttpClient;
    AuthenticationDataSource _authenticationDataSource;

    setUp(() {
      _deviceManager = MockDeviceManager();
      _linShareHttpClient = MockLinShareHttpClient();
      _authenticationDataSource = AuthenticationDataSource(_linShareHttpClient, _deviceManager);
    });

    test('createPermanentToken should create permanentToken success', () async {
      when(_deviceManager.getDeviceUUID())
        .thenAnswer((_) async => Future.value('12345-bde44'));
      when(_deviceManager.getPlatformString())
        .thenAnswer((_) => 'IOS-App');
      when(_linShareHttpClient.createPermanentToken(
          Uri.parse('http://linshare.test'),
          'user1@linsahre.org',
          '123456',
          argThat(isA<PermanentTokenBodyRequest>())))
        .thenAnswer((_) => Future.value(PermanentToken('token', TokenId('12345-5555'))));

      var token = await _authenticationDataSource.createPermanentToken(
          Uri.parse('http://linshare.test'),
          UserName('user1@linsahre.org'),
          Password('123456'));

      expect(token, Token('token', TokenId('12345-5555')));
    });

    test('createPermanentToken should throw UnknownError when deviceManager throw an exception', () async {
      when(_deviceManager.getDeviceUUID())
        .thenThrow(Exception());
      when(_deviceManager.getPlatformString())
        .thenAnswer((_) => 'IOS-App');
      when(_linShareHttpClient.createPermanentToken(
          Uri.parse('http://linshare.test'),
          'user1@linsahre.org',
          '123456',
          argThat(isA<PermanentTokenBodyRequest>())))
        .thenAnswer((_) => Future.value(PermanentToken('token', TokenId('12345-5555'))));

      await _authenticationDataSource.createPermanentToken(
          Uri.parse('http://linshare.test'),
          UserName('user1@linsahre.org'),
          Password('123456'))
        .catchError((error) => expect(error, isA<UnknownError>()));
    });

    test('createPermanentToken should throw BadCredential when linShareHttpClient response error with 401', () async {
      var error = DioError(
        type: DioErrorType.RESPONSE,
        response: Response(statusCode: 401)
      );
      when(_deviceManager.getDeviceUUID())
          .thenAnswer((_) async => Future.value('12345-bde44'));
      when(_deviceManager.getPlatformString())
          .thenAnswer((_) => 'IOS-App');
      when(_linShareHttpClient.createPermanentToken(
          Uri.parse('http://linshare.test'),
          'user1@linsahre.org',
          '123456',
          argThat(isA<PermanentTokenBodyRequest>())))
        .thenThrow(error);

      await _authenticationDataSource.createPermanentToken(
          Uri.parse('http://linshare.test'),
          UserName('user1@linsahre.org'),
          Password('123456'))
        .catchError((error) => expect(error, isA<BadCredentials>()));
    });

    test('createPermanentToken should throw ServerNotFound when linShareHttpClient response error', () async {
      var error = DioError(
          type: DioErrorType.DEFAULT
      );
      when(_deviceManager.getDeviceUUID())
          .thenAnswer((_) async => Future.value('12345-bde44'));
      when(_deviceManager.getPlatformString())
          .thenAnswer((_) => 'IOS-App');
      when(_linShareHttpClient.createPermanentToken(
            Uri.parse('http://linshare.test'),
            'user1@linsahre.org',
            '123456',
            argThat(isA<PermanentTokenBodyRequest>())))
          .thenThrow(error);

      await _authenticationDataSource.createPermanentToken(
            Uri.parse('http://linshare.test'),
            UserName('user1@linsahre.org'),
            Password('123456'))
          .catchError((error) => expect(error, isA<ServerNotFound>()));
    });
  });
}
