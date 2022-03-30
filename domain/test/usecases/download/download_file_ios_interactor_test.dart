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
import 'package:dio/dio.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:testshared/testshared.dart';

import '../../fixture/test_fixture.dart';
import 'download_file_ios_interactor_test.mocks.dart';

@GenerateMocks([DocumentRepository, TokenRepository, CredentialRepository])
void main() {
  group('download_file_ios_interactor_test', () {
    late MockDocumentRepository documentRepository;
    late MockTokenRepository tokenRepository;
    late MockCredentialRepository credentialRepository;
    late DownloadFileIOSInteractor downloadFileIOSInteractor;
    late CancelToken cancelToken;
    late String validFilePath;

    setUp(() {
      documentRepository = MockDocumentRepository();
      tokenRepository = MockTokenRepository();
      credentialRepository = MockCredentialRepository();
      downloadFileIOSInteractor = DownloadFileIOSInteractor(documentRepository, tokenRepository, credentialRepository);
      cancelToken = CancelToken();
      validFilePath = './document/valid_file_path/file.png';
    });

    test('download file should return success with valid data', () async {
      when(tokenRepository.getToken()).thenAnswer((_) async => permanentToken);
      when(credentialRepository.getBaseUrl()).thenAnswer((_) async => linShareBaseUrl);
      when(documentRepository.downloadDocumentIOS(document1, permanentToken, linShareBaseUrl, cancelToken))
          .thenAnswer((_) async => validFilePath);

      final result = await downloadFileIOSInteractor.execute(document1, cancelToken);

      expect(result, Right<Failure, Success>(DownloadFileIOSViewState(validFilePath)));
    });

    test('download file should return failure with invalid token', () async {
      final downloadException = CommonDownloadFileException('download exception');
      when(tokenRepository.getToken()).thenAnswer((_) async => wrongToken);
      when(credentialRepository.getBaseUrl()).thenAnswer((_) async => linShareBaseUrl);
      when(documentRepository.downloadDocumentIOS(document1, wrongToken, linShareBaseUrl, cancelToken))
          .thenThrow(downloadException);

      final result = await downloadFileIOSInteractor.execute(document1, cancelToken);

      expect(result, Left<Failure, Success>(DownloadFileIOSFailure(downloadException)));
    });

    test('download file should return cancel download exception', () async {
      final downloadException = CancelDownloadFileException('cancel download exception');
      when(tokenRepository.getToken()).thenAnswer((_) async => wrongToken);
      when(credentialRepository.getBaseUrl()).thenAnswer((_) async => linShareBaseUrl);
      when(documentRepository.downloadDocumentIOS(document1, wrongToken, linShareBaseUrl, cancelToken))
          .thenThrow(downloadException);

      final result = await downloadFileIOSInteractor.execute(document1, cancelToken);

      expect(result, Left<Failure, Success>(DownloadFileIOSFailure(downloadException)));
    });
  });
}
