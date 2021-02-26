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

import 'package:dio/dio.dart';
import 'package:domain/domain.dart';
import 'package:domain/src/usecases/shared_space/download_multiple_node_ios_interactor.dart';
import 'package:domain/src/usecases/shared_space/download_node_ios_interactor.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:testshared/testshared.dart';

import '../../fixture/test_fixture.dart';
import '../../mock/repository/authentication/mock_credential_repository.dart';
import '../../mock/repository/authentication/mock_token_repository.dart';
import '../../mock/repository/mock_shared_space_document_repository.dart';

void main() {
  group('download_multiple_node_ios_interactor_test', () {
    MockSharedSpaceDocumentRepository sharedSpaceDocumentRepository;
    MockTokenRepository tokenRepository;
    MockCredentialRepository credentialRepository;
    DownloadNodeIOSInteractor downloadNodeIOSInteractor;
    DownloadMultipleNodeIOSInteractor downloadMultipleNodeIOSInteractor;
    CancelToken cancelToken;
    Uri validFilePath1;
    Uri validFilePath2;

    setUp(() {
      sharedSpaceDocumentRepository = MockSharedSpaceDocumentRepository();
      tokenRepository = MockTokenRepository();
      credentialRepository = MockCredentialRepository();
      downloadNodeIOSInteractor = DownloadNodeIOSInteractor(sharedSpaceDocumentRepository, tokenRepository, credentialRepository);
      downloadMultipleNodeIOSInteractor = DownloadMultipleNodeIOSInteractor(downloadNodeIOSInteractor);
      cancelToken = CancelToken();
      validFilePath1 = Uri(path: './document/valid_file_path/file.png');
      validFilePath2 = Uri(path: './document/valid_file_path/file2.png');
    });

    test('download multiple node should return success with valid data', () async {
      when(tokenRepository.getToken()).thenAnswer((_) async => permanentToken);
      when(credentialRepository.getBaseUrl()).thenAnswer((_) async => linShareBaseUrl);
      when(sharedSpaceDocumentRepository.downloadNodeIOS(workGroupDocument1, permanentToken, linShareBaseUrl, cancelToken))
          .thenAnswer((_) async => validFilePath1);
      when(sharedSpaceDocumentRepository.downloadNodeIOS(workGroupDocument2, permanentToken, linShareBaseUrl, cancelToken))
          .thenAnswer((_) async => validFilePath2);

      final result = await downloadMultipleNodeIOSInteractor.execute(workGroupNodes: [workGroupDocument1, workGroupDocument2], cancelToken: cancelToken);
      final state = result.getOrElse(() => null);

      expect(state, isA<DownloadNodeIOSAllSuccessViewState>());

      (state as DownloadNodeIOSAllSuccessViewState).resultList[0].fold(
              (failure) => {},
              (success) => expect((success as DownloadNodeIOSViewState).filePath, validFilePath1));
      (state as DownloadNodeIOSAllSuccessViewState).resultList[1].fold(
              (failure) => {},
              (success) => expect((success as DownloadNodeIOSViewState).filePath, validFilePath2));
    });

    test('download multiple node should return success with some files failed to download', () async {
      when(tokenRepository.getToken()).thenAnswer((_) async => permanentToken);
      when(credentialRepository.getBaseUrl()).thenAnswer((_) async => linShareBaseUrl);
      when(sharedSpaceDocumentRepository.downloadNodeIOS(workGroupDocument1, permanentToken, linShareBaseUrl, cancelToken))
          .thenAnswer((_) async => validFilePath1);
      when(sharedSpaceDocumentRepository.downloadNodeIOS(workGroupDocument2, permanentToken, linShareBaseUrl, cancelToken))
          .thenThrow(Exception());

      final result = await downloadMultipleNodeIOSInteractor.execute(workGroupNodes: [workGroupDocument1, workGroupDocument2], cancelToken: cancelToken);
      final state = result.getOrElse(() => null);

      expect(state, isA<DownloadNodeIOSHasSomeFilesFailureViewState>());

      (state as DownloadNodeIOSHasSomeFilesFailureViewState).resultList[0].fold(
              (failure) => {},
              (success) => expect((success as DownloadNodeIOSViewState).filePath, validFilePath1));
      (state as DownloadNodeIOSHasSomeFilesFailureViewState).resultList[1].fold(
              (failure) => expect(failure, isA<DownloadNodeIOSFailure>()),
              (success) => null);
    });

    test('download multiple node should return return failure with all file failed to download', () async {
      when(tokenRepository.getToken()).thenAnswer((_) async => permanentToken);
      when(credentialRepository.getBaseUrl()).thenAnswer((_) async => linShareBaseUrl);
      when(sharedSpaceDocumentRepository.downloadNodeIOS(workGroupDocument1, permanentToken, linShareBaseUrl, cancelToken))
          .thenThrow(Exception());
      when(sharedSpaceDocumentRepository.downloadNodeIOS(workGroupDocument2, permanentToken, linShareBaseUrl, cancelToken))
          .thenThrow(Exception());

      final result = await downloadMultipleNodeIOSInteractor.execute(workGroupNodes: [workGroupDocument1, workGroupDocument2], cancelToken: cancelToken);

      result.fold(
              (failure) {
            expect(failure, isA<DownloadNodeIOSAllFailureViewState>());
            (failure as DownloadNodeIOSAllFailureViewState).resultList.forEach((element) {
              element.fold(
                      (failure) => {expect(failure, isA<DownloadNodeIOSFailure>())},
                      (success) => {}
              );
            });
          },
              (success) => null);
    });
  });
}
