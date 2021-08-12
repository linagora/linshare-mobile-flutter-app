/*
 * LinShare is an open source filesharing software, part of the LinPKI software
 * suite, developed by Linagora.
 *
 * Copyright (C) 2021 LINAGORA
 *
 * This program is free software: you can redistribute it and/or modify it under the
 * terms of the GNU Affero General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version,
 * provided you comply with the Additional Terms applicable for LinShare software by
 * Linagora pursuant to Section 7 of the GNU Affero General Public License,
 * subsections (b), (c), and (e), pursuant to which you must notably (i) retain the
 * display in the interface of the “LinShare™” trademark/logo, the "Libre & Free" mention,
 * the words “You are using the Free and Open Source version of LinShare™, powered by
 * Linagora © 2009–2021. Contribute to Linshare R&D by subscribing to an Enterprise
 * offer!”. You must also retain the latter notice in all asynchronous messages such as
 * e-mails sent with the Program, (ii) retain all hypertext links between LinShare and
 * http://www.linshare.org, between linagora.com and Linagora, and (iii) refrain from
 * infringing Linagora intellectual property rights over its trademarks and commercial
 * brands. Other Additional Terms apply, see
 * <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf>
 * for more details.
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for
 * more details.
 * You should have received a copy of the GNU Affero General Public License and its
 * applicable Additional Terms for LinShare along with this program. If not, see
 * <http://www.gnu.org/licenses/> for the GNU Affero General Public License version
 *  3 and <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf> for
 *  the Additional Terms applicable to LinShare software.
 */

import 'package:dartz/dartz.dart';
import 'package:domain/domain.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:testshared/fixture/upload_request_entry_fixture.dart';

import '../../fixture/test_fixture.dart';
import '../../mock/repository/authentication/mock_credential_repository.dart';
import '../../mock/repository/authentication/mock_token_repository.dart';
import '../../mock/repository/mock_upload_request_entry_repository.dart';

void main() {
  group('download_upload_request_entry_interactor_test', () {
    late MockUploadRequestEntryRepository uploadRequestEntryRepository;
    late MockTokenRepository tokenRepository;
    late MockCredentialRepository credentialRepository;
    late DownloadUploadRequestEntriesInteractor downloadUploadRequestEntriesInteractor;

    setUp(() {
      uploadRequestEntryRepository = MockUploadRequestEntryRepository();
      tokenRepository = MockTokenRepository();
      credentialRepository = MockCredentialRepository();
      downloadUploadRequestEntriesInteractor = DownloadUploadRequestEntriesInteractor(uploadRequestEntryRepository, tokenRepository, credentialRepository);
    });

    test('download should return success with correct download task ID', () async {
      when(tokenRepository.getToken()).thenAnswer((_) async => permanentToken);
      when(credentialRepository.getBaseUrl()).thenAnswer((_) async => linShareBaseUrl);
      when(uploadRequestEntryRepository.downloadUploadRequestEntries([uploadRequestEntry1], permanentToken, linShareBaseUrl))
          .thenAnswer((_) async => [DownloadTaskId('task_id_1')]);

      final result = await downloadUploadRequestEntriesInteractor.execute([uploadRequestEntry1]);

      verify(tokenRepository.getToken()).called(1);
      verify(credentialRepository.getBaseUrl()).called(1);

      expect(result, Right<Failure, Success>(DownloadEntriesSuccessViewState([DownloadTaskId('task_id_1')])));
    });

    test('download should return success with multiple download task ID', () async {
      when(tokenRepository.getToken()).thenAnswer((_) async => permanentToken);
      when(credentialRepository.getBaseUrl()).thenAnswer((_) async => linShareBaseUrl);
      when(uploadRequestEntryRepository.downloadUploadRequestEntries([uploadRequestEntry1, uploadRequestEntry2], permanentToken, linShareBaseUrl))
          .thenAnswer((_) async => [DownloadTaskId('task_id_1'), DownloadTaskId('task_id_2')]);

      final result = await downloadUploadRequestEntriesInteractor.execute([uploadRequestEntry1, uploadRequestEntry2]);

      verify(tokenRepository.getToken()).called(1);
      verify(credentialRepository.getBaseUrl()).called(1);

      expect(result, Right<Failure, Success>(DownloadEntriesSuccessViewState([DownloadTaskId('task_id_1'), DownloadTaskId('task_id_2')])));
      expect(result.getOrElse(() => IdleState()), isA<DownloadEntriesSuccessViewState>());
      expect(
          (result.getOrElse(() => IdleState()) as DownloadEntriesSuccessViewState).taskIds,
          containsAll([DownloadTaskId('task_id_1'), DownloadTaskId('task_id_2')]));
    });

    test('download should fail when get base url fails', () async {
      final exception = Exception();
      when(tokenRepository.getToken()).thenAnswer((_) async => permanentToken);
      when(credentialRepository.getBaseUrl()).thenThrow(exception);
      when(uploadRequestEntryRepository.downloadUploadRequestEntries([uploadRequestEntry1], permanentToken, wrongUrl)).thenThrow(exception);

      final result = await downloadUploadRequestEntriesInteractor.execute([uploadRequestEntry1]);

      verify(tokenRepository.getToken()).called(1);
      verify(credentialRepository.getBaseUrl()).called(1);

      expect(result, Left<Failure, Success>(DownloadEntriesFailure(exception)));
    });

    test('download should fail with wrong token', () async {
      when(tokenRepository.getToken()).thenAnswer((_) async => wrongToken);
      when(credentialRepository.getBaseUrl()).thenAnswer((_) async => linShareBaseUrl);
      final exception = Exception();
      when(uploadRequestEntryRepository.downloadUploadRequestEntries([uploadRequestEntry1], wrongToken, linShareBaseUrl)).thenThrow(exception);

      final result = await downloadUploadRequestEntriesInteractor.execute([uploadRequestEntry1]);

      verify(tokenRepository.getToken()).called(1);
      verify(credentialRepository.getBaseUrl()).called(1);

      expect(result, Left<Failure, Success>(DownloadEntriesFailure(exception)));
    });

    test('download should fail when get token fails', () async {
      final exception = Exception();
      when(tokenRepository.getToken()).thenThrow(exception);
      when(credentialRepository.getBaseUrl()).thenAnswer((_) async => linShareBaseUrl);
      when(uploadRequestEntryRepository.downloadUploadRequestEntries([uploadRequestEntry1], permanentToken, wrongUrl))
          .thenAnswer((_) async => [DownloadTaskId('task_id_1')]);

      final result = await downloadUploadRequestEntriesInteractor.execute([uploadRequestEntry1]);

      verify(tokenRepository.getToken()).called(1);
      verifyNever(credentialRepository.getBaseUrl());

      expect(result, Left<Failure, Success>(DownloadEntriesFailure(exception)));
    });
  });
}
