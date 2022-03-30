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

import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:testshared/fixture/my_space_fixture.dart';

import 'remove_multiple_documents_interactor_test.mocks.dart';

@GenerateMocks([DocumentRepository])
void main() {
  group('remove_multiple_documents_interactor tests', () {
    late MockDocumentRepository documentRepository;
    RemoveDocumentInteractor removeDocumentInteractor;
    late RemoveMultipleDocumentsInteractor removeMultipleDocumentsInteractor;

    setUp(() {
      documentRepository = MockDocumentRepository();
      removeDocumentInteractor = RemoveDocumentInteractor(documentRepository);
      removeMultipleDocumentsInteractor = RemoveMultipleDocumentsInteractor(removeDocumentInteractor);
    });

    test('remove multiple_documents should return success with valid data', () async {
      when(documentRepository.remove(document1.documentId))
          .thenAnswer((_) async => document1);
      when(documentRepository.remove(document2.documentId))
          .thenAnswer((_) async => document2);

      final result = await removeMultipleDocumentsInteractor.execute(documentIds: [document1.documentId, document2.documentId]);
      final state = result.getOrElse(() => IdleState());
      expect(state, isA<RemoveMultipleDocumentsAllSuccessViewState>());

      (state as RemoveMultipleDocumentsAllSuccessViewState).resultList[0].fold(
              (failure) => {},
              (success) => expect((success as RemoveDocumentViewState).document, document1));

      state.resultList[1].fold(
              (failure) => {},
              (success) => expect((success as RemoveDocumentViewState).document, document2));
    });

    test('remove multiple_documents should return success with some file failed to delete', () async {
      when(documentRepository.remove(document1.documentId))
          .thenAnswer((_) async => document1);
      when(documentRepository.remove(document2.documentId))
          .thenThrow(Exception());

      final result = await removeMultipleDocumentsInteractor.execute(documentIds: [document1.documentId, document2.documentId]);
      final state = result.getOrElse(() => IdleState());
      expect(state, isA<RemoveMultipleDocumentsHasSomeFilesFailedViewState>());

      (state as RemoveMultipleDocumentsHasSomeFilesFailedViewState).resultList.forEach((element) {
        element.fold(
                (failure) => {expect(failure, isA<RemoveDocumentFailure>())},
                (success) => expect((success as RemoveDocumentViewState).document, document1));
      });
    });

    test('remove multiple_documents should return failure with all file failed to delete', () async {
      when(documentRepository.remove(document1.documentId))
          .thenThrow(Exception());
      when(documentRepository.remove(document2.documentId))
          .thenThrow(Exception());

      final result = await removeMultipleDocumentsInteractor.execute(documentIds: [document1.documentId, document2.documentId]);
      result.fold(
              (failure) {
            expect(failure, isA<RemoveMultipleDocumentsAllFailureViewState>());
            (failure as RemoveMultipleDocumentsAllFailureViewState).resultList.forEach((element) {
              element.fold(
                      (failure) => {expect(failure, isA<RemoveDocumentFailure>())},
                      (success) => {}
              );
            });
          },
              (success) => {});

    });
  });
}
