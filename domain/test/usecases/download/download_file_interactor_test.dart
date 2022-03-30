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
import 'download_file_interactor_test.mocks.dart';

@GenerateMocks([DocumentRepository, TokenRepository, CredentialRepository, APIRepository])
void main() {
  group('download_file_interactor_test', () {
    late MockDocumentRepository documentRepository;
    late MockTokenRepository tokenRepository;
    late MockCredentialRepository credentialRepository;
    late MockAPIRepository apiRepository;
    late DownloadFileInteractor downloadFileInteractor;
    late DocumentId documentId;

    setUp(() {
      documentRepository = MockDocumentRepository();
      tokenRepository = MockTokenRepository();
      credentialRepository = MockCredentialRepository();
      apiRepository = MockAPIRepository();
      documentId = DocumentId('383-384-C');
      downloadFileInteractor = DownloadFileInteractor(documentRepository, tokenRepository, credentialRepository, apiRepository);
    });

    test('downloadFileInteractor should return success with correct document ID', () async {
      when(tokenRepository.getToken()).thenAnswer((_) async => permanentToken);
      when(credentialRepository.getBaseUrl()).thenAnswer((_) async => linShareBaseUrl);
      when(apiRepository.getAPIVersionSupported()).thenAnswer((_) async => APIVersionSupported.v4);
      when(documentRepository.downloadDocuments([documentId], permanentToken, linShareBaseUrl, APIVersionSupported.v4))
          .thenAnswer((_) async => [DownloadTaskId('task_id_1')]);

      final result = await downloadFileInteractor.execute([documentId]);

      verify(tokenRepository.getToken()).called(1);
      verify(credentialRepository.getBaseUrl()).called(1);

      expect(result, Right<Failure, Success>(DownloadFileViewState([DownloadTaskId('task_id_1')])));
    });

    test('downloadFileInteractor should return success with multiple document ID', () async {
      final documentId2 = DocumentId('383-384-D');
      when(tokenRepository.getToken()).thenAnswer((_) async => permanentToken);
      when(credentialRepository.getBaseUrl()).thenAnswer((_) async => linShareBaseUrl);
      when(apiRepository.getAPIVersionSupported()).thenAnswer((_) async => APIVersionSupported.v4);
      when(documentRepository.downloadDocuments([documentId, documentId2], permanentToken, linShareBaseUrl, APIVersionSupported.v4))
          .thenAnswer((_) async => [DownloadTaskId('task_id_1'), DownloadTaskId('task_id_2')]);

      final result = await downloadFileInteractor.execute([documentId, documentId2]);

      verify(tokenRepository.getToken()).called(1);
      verify(credentialRepository.getBaseUrl()).called(1);

      expect(result, Right<Failure, Success>(DownloadFileViewState([DownloadTaskId('task_id_1'), DownloadTaskId('task_id_2')])));
      expect(result.getOrElse(() => IdleState()), isA<DownloadFileViewState>());

    });

    test('downloadFileInteractor should fail with wrong baseUrl', () async {
      when(tokenRepository.getToken()).thenAnswer((_) async => permanentToken);
      when(credentialRepository.getBaseUrl()).thenAnswer((_) async => wrongUrl);
      when(apiRepository.getAPIVersionSupported()).thenAnswer((_) async => APIVersionSupported.v4);
      final exception = Exception();
      when(documentRepository.downloadDocuments([documentId], permanentToken, wrongUrl, APIVersionSupported.v4)).thenThrow(exception);

      final result = await downloadFileInteractor.execute([documentId]);

      verify(tokenRepository.getToken()).called(1);
      verify(credentialRepository.getBaseUrl()).called(1);

      expect(result, Left<Failure, Success>(DownloadFileFailure(exception)));
    });

    test('downloadFileInteractor should fail when get base url fails', () async {
      final exception = Exception();
      when(tokenRepository.getToken()).thenAnswer((_) async => permanentToken);
      when(credentialRepository.getBaseUrl()).thenThrow(exception);
      when(apiRepository.getAPIVersionSupported()).thenAnswer((_) async => APIVersionSupported.v4);
      when(documentRepository.downloadDocuments([documentId], permanentToken, wrongUrl, APIVersionSupported.v4)).thenThrow(exception);

      final result = await downloadFileInteractor.execute([documentId]);

      verify(tokenRepository.getToken()).called(1);
      verify(credentialRepository.getBaseUrl()).called(1);

      expect(result, Left<Failure, Success>(DownloadFileFailure(exception)));
    });

    test('downloadFileInteractor should fail with wrong token', () async {
      when(tokenRepository.getToken()).thenAnswer((_) async => wrongToken);
      when(credentialRepository.getBaseUrl()).thenAnswer((_) async => linShareBaseUrl);
      final exception = Exception();
      when(apiRepository.getAPIVersionSupported()).thenAnswer((_) async => APIVersionSupported.v4);
      when(documentRepository.downloadDocuments([documentId], wrongToken, linShareBaseUrl, APIVersionSupported.v4)).thenThrow(exception);

      final result = await downloadFileInteractor.execute([documentId]);

      verify(tokenRepository.getToken()).called(1);
      verify(credentialRepository.getBaseUrl()).called(1);

      expect(result, Left<Failure, Success>(DownloadFileFailure(exception)));
    });

    test('downloadFileInteractor should fail when get token fails', () async {
      final exception = Exception();
      when(tokenRepository.getToken()).thenThrow(exception);
      when(credentialRepository.getBaseUrl()).thenAnswer((_) async => linShareBaseUrl);
      when(apiRepository.getAPIVersionSupported()).thenAnswer((_) async => APIVersionSupported.v4);
      when(documentRepository.downloadDocuments([documentId], permanentToken, wrongUrl, APIVersionSupported.v4))
        .thenAnswer((_) async => [DownloadTaskId('task_id_1')]);

      when(documentRepository.downloadDocuments([documentId], permanentToken, wrongUrl, APIVersionSupported.v4))
        .thenAnswer((_) async => [DownloadTaskId('task_id_1')]);

      final result = await downloadFileInteractor.execute([documentId]);
      verify(tokenRepository.getToken()).called(1);
      verifyNever(credentialRepository.getBaseUrl());

      expect(result, Left<Failure, Success>(DownloadFileFailure(exception)));
    });
  });
}
