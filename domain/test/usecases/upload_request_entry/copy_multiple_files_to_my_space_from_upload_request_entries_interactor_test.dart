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
import 'package:mockito/mockito.dart';
import 'package:testshared/fixture/upload_request_entry_fixture.dart';
import 'package:testshared/testshared.dart';

import '../../mock/repository/authentication/mock_document_repository.dart';

void main() {
  group('copy_multiples_files_to_my_space_from_upload_request_entries_interactor tests', () {
    late MockDocumentRepository documentRepository;
    late CopyToMySpaceInteractor copyToMySpaceInteractor;
    late CopyMultipleFilesFromUploadRequestEntriesToMySpaceInteractor _copyMultipleFilesFromUploadRequestEntriesToMySpaceInteractor;

    setUp(() {
      documentRepository = MockDocumentRepository();
      copyToMySpaceInteractor = CopyToMySpaceInteractor(documentRepository);
      _copyMultipleFilesFromUploadRequestEntriesToMySpaceInteractor = CopyMultipleFilesFromUploadRequestEntriesToMySpaceInteractor(copyToMySpaceInteractor);
    });

    test('copy multiples files to my space from upload request entries interactor should return success with valid data', () async {
      when(documentRepository.copyToMySpace(
          CopyRequest(uploadRequestEntry1.uploadRequestEntryId!.uuid, SpaceType.UPLOAD_REQUEST)))
      .thenAnswer((_) async => [document1]);

      when(documentRepository.copyToMySpace(
          CopyRequest(uploadRequestEntry2.uploadRequestEntryId!.uuid, SpaceType.UPLOAD_REQUEST)))
      .thenAnswer((_) async => [document2]);

      final result = await _copyMultipleFilesFromUploadRequestEntriesToMySpaceInteractor.execute([uploadRequestEntry1, uploadRequestEntry2]);
      final resultsList = result
          .map((success) => (success as CopyMultipleToMySpaceFromUploadRequestEntriesAllSuccessViewState).resultList)
          .getOrElse(() => []);
      expect(resultsList, [Right<Failure, Success>(CopyToMySpaceViewState([document1])), Right<Failure, Success>(CopyToMySpaceViewState([document2]))]);
    });

    test('copy multiples files to my space from upload request entries interactor should return success with some failures', () async {
      final exception = DocumentNotFound();
      when(documentRepository.copyToMySpace(
          CopyRequest(uploadRequestEntry1.uploadRequestEntryId!.uuid, SpaceType.UPLOAD_REQUEST)))
      .thenThrow(exception);

      when(documentRepository.copyToMySpace(
          CopyRequest(uploadRequestEntry2.uploadRequestEntryId!.uuid, SpaceType.UPLOAD_REQUEST)))
      .thenAnswer((_) async => [document2]);

      final result = await _copyMultipleFilesFromUploadRequestEntriesToMySpaceInteractor.execute([uploadRequestEntry1, uploadRequestEntry2]);
      final resultsList = result
          .map((success) => (success as CopyMultipleToMySpaceFromUploadRequestEntriesHasSomeFilesViewState).resultList)
          .getOrElse(() => []);
      expect(resultsList, [Left<Failure, Success>(CopyToMySpaceFailure(exception)), Right<Failure, Success>(CopyToMySpaceViewState([document2]))]);
    });

    test('copy multiples files to my space from upload request entries interactor should return success with one document', () async {
      when(documentRepository.copyToMySpace(
          CopyRequest(uploadRequestEntry1.uploadRequestEntryId!.uuid, SpaceType.UPLOAD_REQUEST)))
      .thenAnswer((_) async => [document1]);

      final result = await _copyMultipleFilesFromUploadRequestEntriesToMySpaceInteractor.execute([uploadRequestEntry1]);
      final documentsList = result
          .map((success) => (success as CopyToMySpaceViewState).documentsList)
          .getOrElse(() => []);
      expect(documentsList, [document1]);
    });

    test('copy multiples files to my space from upload request entries interactor should fail with only failures', () async {
      final exception = DocumentNotFound();
      when(documentRepository.copyToMySpace(
          CopyRequest(uploadRequestEntry1.uploadRequestEntryId!.uuid, SpaceType.UPLOAD_REQUEST)))
      .thenThrow(exception);

      when(documentRepository.copyToMySpace(
          CopyRequest(uploadRequestEntry2.uploadRequestEntryId!.uuid, SpaceType.UPLOAD_REQUEST)))
      .thenThrow(exception);

      final result = await _copyMultipleFilesFromUploadRequestEntriesToMySpaceInteractor.execute([uploadRequestEntry1, uploadRequestEntry2]);
      expect(result, Left<Failure, Success>(CopyMultipleToMySpaceFromUploadRequestEntriesAllFailure([Left<Failure, Success>(CopyToMySpaceFailure(exception)), Left<Failure, Success>(CopyToMySpaceFailure(exception))])));
    });
  });
}
