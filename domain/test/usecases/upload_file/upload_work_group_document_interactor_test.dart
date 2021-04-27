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
import '../../mock/repository/authentication/mock_credential_repository.dart';
import '../../mock/repository/authentication/mock_token_repository.dart';
import '../../mock/repository/mock_shared_space_document_repository.dart';

void main() {
  group('upload_work_group_document_interactor_test', () {
    late MockSharedSpaceDocumentRepository sharedSpaceDocumentRepository;
    late MockTokenRepository tokenRepository;
    late MockCredentialRepository credentialRepository;
    late UploadWorkGroupDocumentInteractor uploadWorkGroupDocumentInteractor;
    late UploadTaskId uploadTaskId;

    setUp(() {
      sharedSpaceDocumentRepository = MockSharedSpaceDocumentRepository();
      tokenRepository = MockTokenRepository();
      credentialRepository = MockCredentialRepository();
      uploadTaskId = UploadTaskId('upload_task_id_1');
      uploadWorkGroupDocumentInteractor = UploadWorkGroupDocumentInteractor(
          sharedSpaceDocumentRepository,
          tokenRepository,
          credentialRepository);
    });

    test('uploadSharedSpaceDocument should return success with correct data', () async {
      final sharedSpaceId = SharedSpaceId('150e408a-dde9-4315-9a5b-7fe0f251fa83');
      when(tokenRepository.getToken()).thenAnswer((_) async => permanentToken);
      when(credentialRepository.getBaseUrl()).thenAnswer((_) async => linShareBaseUrl);
      when(sharedSpaceDocumentRepository.uploadSharedSpaceDocument(fileInfo1, permanentToken, linShareBaseUrl, sharedSpaceId))
          .thenAnswer((_) async => uploadTaskId);

      final result = await uploadWorkGroupDocumentInteractor.execute(fileInfo1, sharedSpaceId);

      expect(result, Right<Failure, Success>(FileUploadState(uploadTaskId)));
    });

    test('uploadSharedSpaceDocument should failure with invalid sharedSpaceId', () async {
      final wrongSharedSpaceId = SharedSpaceId('wrong');
      when(tokenRepository.getToken()).thenAnswer((_) async => permanentToken);
      when(credentialRepository.getBaseUrl()).thenAnswer((_) async => linShareBaseUrl);
      final exception = Exception();
      when(sharedSpaceDocumentRepository.uploadSharedSpaceDocument(fileInfo1, permanentToken, linShareBaseUrl, wrongSharedSpaceId))
          .thenThrow(exception);

      final result = await uploadWorkGroupDocumentInteractor.execute(fileInfo1, wrongSharedSpaceId);

      expect(result, Left<Failure, Success>(WorkGroupDocumentUploadFailure(fileInfo1, exception)));
    });

    test('uploadSharedSpaceDocument should failure with wrong baseUrl', () async {
      final sharedSpaceId = SharedSpaceId('150e408a-dde9-4315-9a5b-7fe0f251fa83');
      when(tokenRepository.getToken()).thenAnswer((_) async => permanentToken);
      when(credentialRepository.getBaseUrl()).thenAnswer((_) async => wrongUrl);
      final exception = Exception();
      when(sharedSpaceDocumentRepository.uploadSharedSpaceDocument(fileInfo1, permanentToken, wrongUrl, sharedSpaceId))
          .thenThrow(exception);

      final result = await uploadWorkGroupDocumentInteractor.execute(fileInfo1, sharedSpaceId);

      expect(result, Left<Failure, Success>(WorkGroupDocumentUploadFailure(fileInfo1, exception)));
    });

    test('uploadSharedSpaceDocument should failure with wrong token', () async {
      final sharedSpaceId = SharedSpaceId('150e408a-dde9-4315-9a5b-7fe0f251fa83');
      final wrongToken = Token('token', TokenId('uuid'));
      when(tokenRepository.getToken()).thenAnswer((_) async => wrongToken);
      when(credentialRepository.getBaseUrl()).thenAnswer((_) async => linShareBaseUrl);
      final exception = Exception();
      when(sharedSpaceDocumentRepository.uploadSharedSpaceDocument(fileInfo1, wrongToken, linShareBaseUrl, sharedSpaceId))
          .thenThrow(exception);

      final result = await uploadWorkGroupDocumentInteractor.execute(fileInfo1, sharedSpaceId);

      expect(result, Left<Failure, Success>(WorkGroupDocumentUploadFailure(fileInfo1, exception)));
    });
  });
}
