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
import 'package:domain/src/usecases/myspace/get_all_document_interactor.dart';
import 'package:domain/src/usecases/myspace/my_space_view_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:testshared/testshared.dart';

import 'get_all_document_interactor_test.mocks.dart';

@GenerateMocks([DocumentRepository])
void main() {
  group('get_all_document_interactor_test', () {
    late MockDocumentRepository documentRepository;
    late GetAllDocumentInteractor getAllDocumentInteractor;

    setUp(() {
      documentRepository = MockDocumentRepository();
      getAllDocumentInteractor = GetAllDocumentInteractor(documentRepository);
    });

    test('getAllDocumentInteractor should return success with documentList', () async {
      when(documentRepository.getAll()).thenAnswer((_) async => [document1, document2, document3]);
      when(documentRepository.getDocumentOffline(document1.documentId)).thenAnswer((_) async => null);
      when(documentRepository.getDocumentOffline(document2.documentId)).thenAnswer((_) async => null);
      when(documentRepository.getDocumentOffline(document3.documentId)).thenAnswer((_) async => null);
      final result = await getAllDocumentInteractor.execute();

      result.map((success) => (success as MySpaceViewState).documentList)
        .fold(
          (left) => throw Exception('[test failed]: ${left.toString()}'),
          (right) => expect(
              right,
              containsAllInOrder([document1, document2, document3])));
    });

    test('getAllDocumentInteractor should fail when get all failed', () async {
      final exception = Exception('get list documents failed');
      when(documentRepository.getAll()).thenThrow(exception);

      final result = await getAllDocumentInteractor.execute();

      result.fold(
              (failure) => expect(failure, isA<MySpaceFailure>()),
              (success) => expect(success, isA<MySpaceViewState>()));

      expect(result, Left<Failure, Success>(MySpaceFailure(exception)));
    });
  });
}
