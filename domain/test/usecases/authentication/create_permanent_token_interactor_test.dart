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

import 'package:dartz/dartz.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../fixture/test_fixture.dart';
import 'create_permanent_token_interactor_test.mocks.dart';

@GenerateMocks([AuthenticationRepository, TokenRepository, CredentialRepository, APIRepository])
void main() {

  group('create_permanent_token_interactor_test', () {
    late CreatePermanentTokenInteractor createPermanentTokenInteractor;
    late AuthenticationRepository authenticationRepository;
    late TokenRepository tokenRepository;
    late CredentialRepository credentialRepository;
    late APIRepository apiRepository;

    setUp(() {
      authenticationRepository = MockAuthenticationRepository();
      tokenRepository = MockTokenRepository();
      credentialRepository = MockCredentialRepository();
      apiRepository = MockAPIRepository();
      createPermanentTokenInteractor = CreatePermanentTokenInteractor(
          authenticationRepository,
          tokenRepository,
          credentialRepository,
          apiRepository
      );
    });

    test('createPermanentTokenInteractor should return success with correct data', () async {
      when(authenticationRepository.createPermanentToken(linShareBaseUrl, APIVersionSupported.v5, userName1, password1))
          .thenAnswer((_) async => permanentToken);
      when(tokenRepository.persistToken(permanentToken)).thenAnswer((_) => Future.delayed(Duration(milliseconds: 100)));
      when(credentialRepository.saveBaseUrl(linShareBaseUrl)).thenAnswer((_) => Future.delayed(Duration(milliseconds: 100)));
      final result = await createPermanentTokenInteractor.execute(linShareBaseUrl, userName1, password1);
      expect(result, Right<Failure, Success>(AuthenticationViewState(permanentToken, APIVersionSupported.v4)));
    });

    test('createPermanentTokenInteractor should failure with wrong url', () async {
      when(authenticationRepository.createPermanentToken(wrongUrl, APIVersionSupported.v5, userName1, password1))
          .thenThrow(ServerNotFound());
      final result = await createPermanentTokenInteractor.execute(wrongUrl, userName1, password1);
      expect(result, Left<Failure, Success>(AuthenticationFailure(ServerNotFound())));
    });

    test('createPermanentTokenInteractor should failure with wrong userName', () async {
      when(authenticationRepository.createPermanentToken(linShareBaseUrl, APIVersionSupported.v5, userName2, password1))
          .thenThrow(BadCredentials());
      final result = await createPermanentTokenInteractor.execute(linShareBaseUrl, userName2, password1);
      expect(result, Left<Failure, Success>(AuthenticationFailure(BadCredentials())));
    });

    test('createPermanentTokenInteractor should failure with wrong password', () async {
      when(authenticationRepository.createPermanentToken(linShareBaseUrl, APIVersionSupported.v5, userName1, password2))
          .thenThrow(BadCredentials());
      final result = await createPermanentTokenInteractor.execute(linShareBaseUrl, userName1, password2);
      expect(result, Left<Failure, Success>(AuthenticationFailure(BadCredentials())));
    });

    test('createPermanentTokenInteractor should failure with connection error', () async {
      when(authenticationRepository.createPermanentToken(linShareBaseUrl, APIVersionSupported.v5, userName1, password1))
          .thenThrow(ConnectError());
      final result = await createPermanentTokenInteractor.execute(linShareBaseUrl, userName1, password1);
      expect(result, Left<Failure, Success>(AuthenticationFailure(ConnectError())));
    });

    test('createPermanentTokenInteractor should failure with unknown error', () async {
      when(authenticationRepository.createPermanentToken(linShareBaseUrl, APIVersionSupported.v5, userName1, password1))
          .thenThrow(UnknownError('unknown error'));
      final result = await createPermanentTokenInteractor.execute(linShareBaseUrl, userName1, password1);
      expect(result, Left<Failure, Success>(AuthenticationFailure(UnknownError('unknown error'))));
    });
  });
}
