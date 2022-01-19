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
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../fixture/test_fixture.dart';
import '../../mock/repository/authentication/mock_api_repository.dart';
import '../../mock/repository/authentication/mock_credential_repository.dart';
import '../../mock/repository/authentication/mock_document_repository.dart';
import '../../mock/repository/authentication/mock_token_repository.dart';

void main() {
  group('upload_file_interactor_test', () {
    late MockDocumentRepository documentRepository;
    late MockTokenRepository tokenRepository;
    late MockCredentialRepository credentialRepository;
    late MockAPIRepository apiRepository;
    late UploadMySpaceDocumentInteractor uploadFileInteractor;
    late UploadTaskId uploadTaskId;

    setUp(() {
      documentRepository = MockDocumentRepository();
      tokenRepository = MockTokenRepository();
      credentialRepository = MockCredentialRepository();
      apiRepository = MockAPIRepository();
      uploadTaskId = UploadTaskId('upload_task_id_1');
      uploadFileInteractor = UploadMySpaceDocumentInteractor(documentRepository, tokenRepository, credentialRepository, apiRepository);
    });

    test('uploadFileInteractor should return success with correct data', () async {
      when(tokenRepository.getToken()).thenAnswer((_) async => permanentToken);
      when(credentialRepository.getBaseUrl()).thenAnswer((_) async => linShareBaseUrl);
      when(documentRepository.upload(fileInfo1, permanentToken, linShareBaseUrl, APIVersionSupported.v4))
          .thenAnswer((_) async => uploadTaskId);
      when(apiRepository.getAPIVersionSupported()).thenAnswer((_) async => APIVersionSupported.v4);

      final result = await uploadFileInteractor.execute(fileInfo1);

      expect(result, Right<Failure, Success>(FileUploadState(uploadTaskId)));
    });

    test('uploadFileInteractor should failure with wrong baseUrl', () async {
      when(tokenRepository.getToken()).thenAnswer((_) async => permanentToken);
      when(credentialRepository.getBaseUrl()).thenAnswer((_) async => wrongUrl);
      final exception = Exception();
      when(apiRepository.getAPIVersionSupported()).thenAnswer((_) async => APIVersionSupported.v4);
      when(documentRepository.upload(fileInfo1, permanentToken, wrongUrl, APIVersionSupported.v4))
          .thenThrow(exception);

      final result = await uploadFileInteractor.execute(fileInfo1);

      expect(result, Left<Failure, Success>(FileUploadFailure(UploadTaskId.undefined(), exception)));
    });

    test('uploadFileInteractor should failure with wrong token', () async {
      final wrongToken = Token('token', TokenId('uuid'));
      when(tokenRepository.getToken()).thenAnswer((_) async => wrongToken);
      when(credentialRepository.getBaseUrl()).thenAnswer((_) async => linShareBaseUrl);
      when(apiRepository.getAPIVersionSupported()).thenAnswer((_) async => APIVersionSupported.v4);
      final exception = Exception();
      when(documentRepository.upload(fileInfo1, wrongToken, linShareBaseUrl, APIVersionSupported.v4))
          .thenThrow(exception);

      final result = await uploadFileInteractor.execute(fileInfo1);

      expect(result, Left<Failure, Success>(FileUploadFailure(UploadTaskId.undefined(), exception)));
    });
  });
}
