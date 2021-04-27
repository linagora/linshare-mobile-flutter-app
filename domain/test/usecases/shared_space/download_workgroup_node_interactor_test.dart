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
import 'package:domain/src/usecases/shared_space/download_workgroup_node_interactor.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:testshared/fixture/shared_space_document_fixture.dart';

import '../../fixture/test_fixture.dart';
import '../../mock/repository/authentication/mock_credential_repository.dart';
import '../../mock/repository/authentication/mock_token_repository.dart';
import '../../mock/repository/mock_shared_space_document_repository.dart';

void main() {
  group('download_workgroup_node_interactor_test', () {
    late MockSharedSpaceDocumentRepository sharedSpaceDocumentRepository;
    late MockTokenRepository tokenRepository;
    late MockCredentialRepository credentialRepository;
    late DownloadWorkGroupNodeInteractor downloadNodeInteractor;
    late WorkGroupNode workGroupNode;

    setUp(() {
      sharedSpaceDocumentRepository = MockSharedSpaceDocumentRepository();
      tokenRepository = MockTokenRepository();
      credentialRepository = MockCredentialRepository();
      workGroupNode = workGroupDocument1;
      downloadNodeInteractor = DownloadWorkGroupNodeInteractor(sharedSpaceDocumentRepository, tokenRepository, credentialRepository);
    });

    test('download should return success with correct node ID', () async {
      when(tokenRepository.getToken()).thenAnswer((_) async => permanentToken);
      when(credentialRepository.getBaseUrl()).thenAnswer((_) async => linShareBaseUrl);
      when(sharedSpaceDocumentRepository.downloadNodes([workGroupNode], permanentToken, linShareBaseUrl))
          .thenAnswer((_) async => [DownloadTaskId('task_id_1')]);

      final result = await downloadNodeInteractor.execute([workGroupNode]);

      verify(tokenRepository.getToken()).called(1);
      verify(credentialRepository.getBaseUrl()).called(1);

      expect(result, Right<Failure, Success>(DownloadNodesSuccessViewState([DownloadTaskId('task_id_1')])));
    });

    test('download should return success with multiple node ID', () async {
      when(tokenRepository.getToken()).thenAnswer((_) async => permanentToken);
      when(credentialRepository.getBaseUrl()).thenAnswer((_) async => linShareBaseUrl);
      when(sharedSpaceDocumentRepository.downloadNodes([workGroupNode, workGroupDocument2], permanentToken, linShareBaseUrl))
          .thenAnswer((_) async => [DownloadTaskId('task_id_1'), DownloadTaskId('task_id_2')]);

      final result = await downloadNodeInteractor.execute([workGroupNode, workGroupDocument2]);

      verify(tokenRepository.getToken()).called(1);
      verify(credentialRepository.getBaseUrl()).called(1);

      expect(result, Right<Failure, Success>(DownloadNodesSuccessViewState([DownloadTaskId('task_id_1'), DownloadTaskId('task_id_2')])));
      expect(result.getOrElse(() => IdleState()), isA<DownloadNodesSuccessViewState>());
      expect(
          (result.getOrElse(() => IdleState()) as DownloadNodesSuccessViewState).taskIds,
          containsAll([DownloadTaskId('task_id_1'), DownloadTaskId('task_id_2')]));
    });

    test('download should fail with wrong baseUrl', () async {
      when(tokenRepository.getToken()).thenAnswer((_) async => permanentToken);
      when(credentialRepository.getBaseUrl()).thenAnswer((_) async => wrongUrl);
      final exception = Exception();
      when(sharedSpaceDocumentRepository.downloadNodes([workGroupNode], permanentToken, wrongUrl)).thenThrow(exception);

      final result = await downloadNodeInteractor.execute([workGroupNode]);

      verify(tokenRepository.getToken()).called(1);
      verify(credentialRepository.getBaseUrl()).called(1);

      expect(result, Left<Failure, Success>(DownloadNodesFailure(exception)));
    });

    test('download should fail when get base url fails', () async {
      final exception = Exception();
      when(tokenRepository.getToken()).thenAnswer((_) async => permanentToken);
      when(credentialRepository.getBaseUrl()).thenThrow(exception);
      when(sharedSpaceDocumentRepository.downloadNodes([workGroupNode], permanentToken, wrongUrl)).thenThrow(exception);

      final result = await downloadNodeInteractor.execute([workGroupNode]);

      verify(tokenRepository.getToken()).called(1);
      verify(credentialRepository.getBaseUrl()).called(1);

      expect(result, Left<Failure, Success>(DownloadNodesFailure(exception)));
    });

    test('download should fail with wrong token', () async {
      when(tokenRepository.getToken()).thenAnswer((_) async => wrongToken);
      when(credentialRepository.getBaseUrl()).thenAnswer((_) async => linShareBaseUrl);
      final exception = Exception();
      when(sharedSpaceDocumentRepository.downloadNodes([workGroupNode], wrongToken, linShareBaseUrl)).thenThrow(exception);

      final result = await downloadNodeInteractor.execute([workGroupNode]);

      verify(tokenRepository.getToken()).called(1);
      verify(credentialRepository.getBaseUrl()).called(1);

      expect(result, Left<Failure, Success>(DownloadNodesFailure(exception)));
    });

    test('download should fail when get token fails', () async {
      final exception = Exception();
      when(tokenRepository.getToken()).thenThrow(exception);
      when(credentialRepository.getBaseUrl()).thenAnswer((_) async => linShareBaseUrl);
      when(sharedSpaceDocumentRepository.downloadNodes([workGroupNode], permanentToken, wrongUrl))
          .thenAnswer((_) async => [DownloadTaskId('task_id_1')]);

      when(sharedSpaceDocumentRepository.downloadNodes([workGroupNode], permanentToken, wrongUrl))
          .thenAnswer((_) async => [DownloadTaskId('task_id_1')]);

      final result = await downloadNodeInteractor.execute([workGroupNode]);
      verify(tokenRepository.getToken()).called(1);
      verifyNever(credentialRepository.getBaseUrl());

      expect(result, Left<Failure, Success>(DownloadNodesFailure(exception)));
    });
  });
}
