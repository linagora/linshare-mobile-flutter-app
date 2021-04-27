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

import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:testshared/fixture/shared_space_document_fixture.dart';

import '../../mock/repository/mock_shared_space_document_repository.dart';

void main() {
  group('remove_multiple_shared_space_nodes_interactor test', () {
    late MockSharedSpaceDocumentRepository sharedSpaceDocumentRepository;
    RemoveSharedSpaceNodeInteractor removeSharedSpaceNodeInteractor;
    late RemoveMultipleSharedSpaceNodesInteractor removeMultipleSharedSpaceNodesInteractor;

    setUp(() {
      sharedSpaceDocumentRepository = MockSharedSpaceDocumentRepository();
      removeSharedSpaceNodeInteractor = RemoveSharedSpaceNodeInteractor(sharedSpaceDocumentRepository);
      removeMultipleSharedSpaceNodesInteractor = RemoveMultipleSharedSpaceNodesInteractor(removeSharedSpaceNodeInteractor);
    });

    test('remove multiple shared space nodes interactor should return success with valid data', () async {
      when(sharedSpaceDocumentRepository.removeSharedSpaceNode(
        workGroupDocument1.sharedSpaceId,
        workGroupDocument1.workGroupNodeId))
      .thenAnswer((_) async => workGroupDocument1);
      when(sharedSpaceDocumentRepository.removeSharedSpaceNode(
        workGroupDocument2.sharedSpaceId,
        workGroupDocument2.workGroupNodeId))
      .thenAnswer((_) async => workGroupDocument2);

      final result = await removeMultipleSharedSpaceNodesInteractor.execute([workGroupDocument1, workGroupDocument2]);
      final state = result.getOrElse(() => IdleState());
      expect(state, isA<RemoveAllSharedSpaceNodesSuccessViewState>());

      (state as RemoveAllSharedSpaceNodesSuccessViewState).resultList[0].fold(
          (failure) => {},
          (success) => expect((success as RemoveSharedSpaceNodeViewState).workGroupNode, workGroupDocument1));

      (state).resultList[1].fold(
          (failure) => {},
          (success) => expect((success as RemoveSharedSpaceNodeViewState).workGroupNode, workGroupDocument2));
    });

    test('remove multiple shared space nodes interactor should return success with some file failed to copy', () async {
      when(sharedSpaceDocumentRepository.removeSharedSpaceNode(
        workGroupDocument1.sharedSpaceId,
        workGroupDocument1.workGroupNodeId))
      .thenAnswer((_) async => workGroupDocument1);
      when(sharedSpaceDocumentRepository.removeSharedSpaceNode(
        workGroupDocument2.sharedSpaceId,
        workGroupDocument2.workGroupNodeId))
      .thenThrow(Exception());

      final result = await removeMultipleSharedSpaceNodesInteractor.execute([workGroupDocument1, workGroupDocument2]);
      final state = result.getOrElse(() => IdleState());
      expect(state, isA<RemoveSomeSharedSpaceNodesSuccessViewState>());

      (state as RemoveSomeSharedSpaceNodesSuccessViewState).resultList[0].fold(
          (failure) => {},
          (success) => expect((success as RemoveSharedSpaceNodeViewState).workGroupNode, workGroupDocument1));

      (state).resultList[1].fold(
          (failure) => {},
          (success) => expect((success as RemoveSharedSpaceNodeFailure).exception, isA<Exception>()));
    });

    test('remove multiple shared space nodes interactor should return failure with all file failed to delete', () async {
      when(sharedSpaceDocumentRepository.removeSharedSpaceNode(
        workGroupDocument1.sharedSpaceId,
        workGroupDocument1.workGroupNodeId))
      .thenThrow(Exception());
      when(sharedSpaceDocumentRepository.removeSharedSpaceNode(
        workGroupDocument2.sharedSpaceId,
        workGroupDocument2.workGroupNodeId))
      .thenThrow(Exception());

      final result = await removeMultipleSharedSpaceNodesInteractor.execute([workGroupDocument1, workGroupDocument2]);

      result.fold(
          (failure) {
            expect(failure, isA<RemoveAllSharedSpaceNodesFailureViewState>());
            (failure as RemoveAllSharedSpaceNodesFailureViewState).resultList.forEach((element) {
              element.fold(
                (failure) => {expect(failure, isA<RemoveSharedSpaceNodeFailure>())},
                (success) => {}
              );
            });
          },
          (success) => {});
    });
  });
}