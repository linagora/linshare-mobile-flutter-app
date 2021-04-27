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
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:testshared/testshared.dart';

import '../../fixture/test_fixture.dart';
import '../../mock/repository/authentication/mock_credential_repository.dart';
import '../../mock/repository/authentication/mock_document_repository.dart';
import '../../mock/repository/authentication/mock_token_repository.dart';

void main() {
  group('download_multiple_file_ios_interactor_test', () {
    late MockDocumentRepository documentRepository;
    late MockTokenRepository tokenRepository;
    late MockCredentialRepository credentialRepository;
    DownloadFileIOSInteractor downloadFileIOSInteractor;
    late DownloadMultipleFileIOSInteractor downloadMultipleFileIOSInteractor;
    late CancelToken cancelToken;
    late String validFilePath1;
    late String validFilePath2;

    setUp(() {
      documentRepository = MockDocumentRepository();
      tokenRepository = MockTokenRepository();
      credentialRepository = MockCredentialRepository();
      downloadFileIOSInteractor = DownloadFileIOSInteractor(documentRepository, tokenRepository, credentialRepository);
      downloadMultipleFileIOSInteractor = DownloadMultipleFileIOSInteractor(downloadFileIOSInteractor);
      cancelToken = CancelToken();
      validFilePath1 = './document/valid_file_path/file.png';
      validFilePath2 = './document/valid_file_path/file2.png';
    });

    test('download multiple file should return success with valid data', () async {
      when(tokenRepository.getToken()).thenAnswer((_) async => permanentToken);
      when(credentialRepository.getBaseUrl()).thenAnswer((_) async => linShareBaseUrl);
      when(documentRepository.downloadDocumentIOS(document1, permanentToken, linShareBaseUrl, cancelToken))
          .thenAnswer((_) async => validFilePath1);
      when(documentRepository.downloadDocumentIOS(document2, permanentToken, linShareBaseUrl, cancelToken))
          .thenAnswer((_) async => validFilePath2);

      final result = await downloadMultipleFileIOSInteractor.execute(documents: [document1, document2], cancelToken: cancelToken);
      final state = result.getOrElse(() => IdleState());

      expect(state, isA<DownloadFileIOSAllSuccessViewState>());

      (state as DownloadFileIOSAllSuccessViewState).resultList[0].fold(
              (failure) => {},
              (success) => expect((success as DownloadFileIOSViewState).filePath, validFilePath1));
      state.resultList[1].fold(
              (failure) => {},
              (success) => expect((success as DownloadFileIOSViewState).filePath, validFilePath2));
    });

    test('download multiple file should return success with some files failed to download', () async {
      when(tokenRepository.getToken()).thenAnswer((_) async => permanentToken);
      when(credentialRepository.getBaseUrl()).thenAnswer((_) async => linShareBaseUrl);
      when(documentRepository.downloadDocumentIOS(document1, permanentToken, linShareBaseUrl, cancelToken))
          .thenAnswer((_) async => validFilePath1);
      when(documentRepository.downloadDocumentIOS(document2, permanentToken, linShareBaseUrl, cancelToken))
          .thenThrow(Exception());

      final result = await downloadMultipleFileIOSInteractor.execute(documents: [document1, document2], cancelToken: cancelToken);
      final state = result.getOrElse(() => IdleState());

      expect(state, isA<DownloadFileIOSHasSomeFilesFailureViewState>());

      (state as DownloadFileIOSHasSomeFilesFailureViewState).resultList[0].fold(
              (failure) => {},
              (success) => expect((success as DownloadFileIOSViewState).filePath, validFilePath1));
      state.resultList[1].fold(
              (failure) => expect(failure, isA<DownloadFileIOSFailure>()),
              (success) => null);
    });

    test('download multiple file should return return failure with all file failed to download', () async {
      when(tokenRepository.getToken()).thenAnswer((_) async => permanentToken);
      when(credentialRepository.getBaseUrl()).thenAnswer((_) async => linShareBaseUrl);
      when(documentRepository.downloadDocumentIOS(document1, permanentToken, linShareBaseUrl, cancelToken))
          .thenThrow(Exception());
      when(documentRepository.downloadDocumentIOS(document2, permanentToken, linShareBaseUrl, cancelToken))
          .thenThrow(Exception());

      final result = await downloadMultipleFileIOSInteractor.execute(documents: [document1, document2], cancelToken: cancelToken);

      result.fold(
              (failure) {
                expect(failure, isA<DownloadFileIOSAllFailureViewState>());
                (failure as DownloadFileIOSAllFailureViewState).resultList.forEach((element) {
                  element.fold(
                          (failure) => {expect(failure, isA<DownloadFileIOSFailure>())},
                          (success) => {}
                  );
                });
              },
              (success) => null);
    });
  });
}
