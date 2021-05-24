// LinShare is an open source filesharing software, part of the LinPKI software
// suite, developed by Linagora.
//
// Copyright (C) 2021 LINAGORA
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
import 'package:dio/dio.dart';
import 'package:domain/domain.dart';
import 'package:domain/src/usecases/shared_space/download_node_ios_interactor.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:testshared/testshared.dart';

import '../../fixture/test_fixture.dart';
import '../../mock/repository/authentication/mock_credential_repository.dart';
import '../../mock/repository/authentication/mock_token_repository.dart';
import '../../mock/repository/mock_shared_space_document_repository.dart';

void main() {
  group('download_node_ios_interactor_test', () {
    MockSharedSpaceDocumentRepository sharedSpaceDocumentRepository;
    MockTokenRepository tokenRepository;
    MockCredentialRepository credentialRepository;
    DownloadNodeIOSInteractor downloadNodeIOSInteractor;
    CancelToken cancelToken;
    String validFilePath;

    setUp(() {
      sharedSpaceDocumentRepository = MockSharedSpaceDocumentRepository();
      tokenRepository = MockTokenRepository();
      credentialRepository = MockCredentialRepository();
      downloadNodeIOSInteractor = DownloadNodeIOSInteractor(sharedSpaceDocumentRepository, tokenRepository, credentialRepository);
      cancelToken = CancelToken();
      validFilePath = './document/valid_file_path/file.png';
    });

    test('download node should return success with valid data', () async {
      when(tokenRepository.getToken()).thenAnswer((_) async => permanentToken);
      when(credentialRepository.getBaseUrl()).thenAnswer((_) async => linShareBaseUrl);
      when(sharedSpaceDocumentRepository.downloadNodeIOS(workGroupDocument1, permanentToken, linShareBaseUrl, cancelToken))
          .thenAnswer((_) async => validFilePath);

      final result = await downloadNodeIOSInteractor.execute(workGroupDocument1, cancelToken);

      expect(result, Right<Failure, Success>(DownloadNodeIOSViewState(validFilePath)));
    });

    test('download node should return failure with invalid token', () async {
      final downloadException = CommonDownloadFileException('download exception');
      when(tokenRepository.getToken()).thenAnswer((_) async => wrongToken);
      when(credentialRepository.getBaseUrl()).thenAnswer((_) async => linShareBaseUrl);
      when(sharedSpaceDocumentRepository.downloadNodeIOS(workGroupDocument1, wrongToken, linShareBaseUrl, cancelToken))
          .thenThrow(downloadException);

      final result = await downloadNodeIOSInteractor.execute(workGroupDocument1, cancelToken);

      expect(result, Left<Failure, Success>(DownloadNodeIOSFailure(downloadException)));
    });

    test('download node should return cancel download exception', () async {
      final downloadException = CancelDownloadFileException('cancel download exception');
      when(tokenRepository.getToken()).thenAnswer((_) async => wrongToken);
      when(credentialRepository.getBaseUrl()).thenAnswer((_) async => linShareBaseUrl);
      when(sharedSpaceDocumentRepository.downloadNodeIOS(workGroupDocument1, wrongToken, linShareBaseUrl, cancelToken))
          .thenThrow(downloadException);

      final result = await downloadNodeIOSInteractor.execute(workGroupDocument1, cancelToken);

      expect(result, Left<Failure, Success>(DownloadNodeIOSFailure(downloadException)));
    });
  });
}
