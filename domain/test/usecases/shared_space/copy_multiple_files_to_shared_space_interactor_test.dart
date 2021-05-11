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
import 'package:mockito/mockito.dart';
import 'package:testshared/testshared.dart';

import '../../mock/repository/mock_shared_space_document_repository.dart';

void main() {
  group('copy_multile_files_to_shared_space_interactor tests', () {
    MockSharedSpaceDocumentRepository? sharedSpaceDocumentRepository;
    late CopyMultipleFilesToSharedSpaceInteractor copyMultipleFilesToSharedSpaceInteractor;
    CopyDocumentsToSharedSpaceInteractor copyDocumentsToSharedSpaceInteractor;

    setUp(() {
      sharedSpaceDocumentRepository = MockSharedSpaceDocumentRepository();
      copyDocumentsToSharedSpaceInteractor = CopyDocumentsToSharedSpaceInteractor(sharedSpaceDocumentRepository);
      copyMultipleFilesToSharedSpaceInteractor = CopyMultipleFilesToSharedSpaceInteractor(copyDocumentsToSharedSpaceInteractor);
    });

    test('copy to shared space interactor should return success with valid data', () async {
      when(sharedSpaceDocumentRepository!.copyToSharedSpace(
          CopyRequest(document1.documentId.uuid, SpaceType.PERSONAL_SPACE),
          sharedSpace1.sharedSpaceId))
      .thenAnswer((_) async => [workGroupDocument1]);
      when(sharedSpaceDocumentRepository!.copyToSharedSpace(
          CopyRequest(document2.documentId.uuid, SpaceType.PERSONAL_SPACE),
          sharedSpace1.sharedSpaceId))
      .thenAnswer((_) async => [workGroupDocument2]);

      final result = await copyMultipleFilesToSharedSpaceInteractor.execute(
          [document1, document2].map((document) => document.toCopyRequest()).toList(), sharedSpace1.sharedSpaceId);
      final state = result.getOrElse(() => null)!;
      expect(state, isA<CopyMultipleFilesToSharedSpaceAllSuccessViewState>());

      (state as CopyMultipleFilesToSharedSpaceAllSuccessViewState).resultList[0].fold(
          (failure) => {},
          (success) => expect((success as CopyToSharedSpaceViewState).workGroupNode, [workGroupDocument1]));

      state.resultList[1].fold(
          (failure) => {},
          (success) => expect((success as CopyToSharedSpaceViewState).workGroupNode, [workGroupDocument2]));
    });

    test('copy to shared space interactor should return success with some file failed to copy', () async {
      when(sharedSpaceDocumentRepository!.copyToSharedSpace(
          CopyRequest(document1.documentId.uuid, SpaceType.PERSONAL_SPACE),
          sharedSpace1.sharedSpaceId))
          .thenAnswer((_) async => [workGroupDocument1]);
      when(sharedSpaceDocumentRepository!.copyToSharedSpace(
          CopyRequest(document2.documentId.uuid, SpaceType.PERSONAL_SPACE),
          sharedSpace1.sharedSpaceId))
      .thenThrow(Exception());


      final result = await copyMultipleFilesToSharedSpaceInteractor.execute(
          [document1, document2].map((document) => document.toCopyRequest()).toList(),
          sharedSpace1.sharedSpaceId);
      final state = result.getOrElse(() => null)!;
      expect(state, isA<CopyMultipleFilesToSharedSpaceHasSomeFilesFailedViewState>());

      (state as CopyMultipleFilesToSharedSpaceHasSomeFilesFailedViewState).resultList.forEach((element) {
        element.fold(
            (failure) => {expect(failure, isA<CopyToSharedSpaceFailure>())},
            (success) => expect((success as CopyToSharedSpaceViewState).workGroupNode, [workGroupDocument1]));
      });
    });

    test('copy to shared space interactor should return failure with all file failed to copy', () async {
      when(sharedSpaceDocumentRepository!.copyToSharedSpace(
          CopyRequest(document1.documentId.uuid, SpaceType.PERSONAL_SPACE),
          sharedSpace1.sharedSpaceId))
          .thenThrow(Exception());
      when(sharedSpaceDocumentRepository!.copyToSharedSpace(
          CopyRequest(document2.documentId.uuid, SpaceType.PERSONAL_SPACE),
          sharedSpace1.sharedSpaceId))
      .thenThrow(Exception());

      final result = await copyMultipleFilesToSharedSpaceInteractor.execute(
          [document1, document2].map((document) => document.toCopyRequest()).toList(),
          sharedSpace1.sharedSpaceId);
      result.fold(
          (failure) {
            expect(failure, isA<CopyMultipleFilesToSharedSpaceAllFailureViewState>());
            (failure as CopyMultipleFilesToSharedSpaceAllFailureViewState).resultList.forEach((element) {
              element.fold(
                  (failure) => {expect(failure, isA<CopyToSharedSpaceFailure>())},
                  (success) => {}
              );
            });
          },
          (success) => {});
    });
  });
}
