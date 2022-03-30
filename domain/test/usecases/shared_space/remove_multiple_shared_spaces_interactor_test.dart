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
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:testshared/testshared.dart';

import 'remove_multiple_shared_spaces_interactor_test.mocks.dart';

@GenerateMocks([SharedSpaceRepository])
void main() {
  group('remove_multiple_shared_spaces_interactor test', () {
    late MockSharedSpaceRepository sharedSpaceRepository;
    RemoveSharedSpaceInteractor removeSharedSpaceInteractor;
    late RemoveMultipleSharedSpacesInteractor removeMultipleSharedSpacesInteractor;

    setUp(() {
      sharedSpaceRepository = MockSharedSpaceRepository();
      removeSharedSpaceInteractor = RemoveSharedSpaceInteractor(sharedSpaceRepository);
      removeMultipleSharedSpacesInteractor = RemoveMultipleSharedSpacesInteractor(removeSharedSpaceInteractor);
    });

    test('remove multiple shared space interactor should return success with valid data', () async {
      when(sharedSpaceRepository.deleteSharedSpace(sharedSpace1.sharedSpaceId))
        .thenAnswer((_) async => sharedSpace1);
      when(sharedSpaceRepository.deleteSharedSpace(sharedSpace2.sharedSpaceId))
        .thenAnswer((_) async => sharedSpace2);

      final result = await removeMultipleSharedSpacesInteractor.execute([sharedSpace1.sharedSpaceId, sharedSpace2.sharedSpaceId]);
      final state = result.getOrElse(() => IdleState());
      expect(state, isA<RemoveAllSharedSpacesSuccessViewState>());

      (state as RemoveAllSharedSpacesSuccessViewState).resultList[0].fold(
          (failure) => {},
          (success) => expect((success as RemoveSharedSpaceViewState).sharedSpaceNodeNested, sharedSpace1));

      state.resultList[1].fold(
          (failure) => {},
          (success) => expect((success as RemoveSharedSpaceViewState).sharedSpaceNodeNested, sharedSpace2));
    });

    test('remove multiple shared space interactor should return success with some failed to copy', () async {
      when(sharedSpaceRepository.deleteSharedSpace(sharedSpace1.sharedSpaceId))
        .thenAnswer((_) async => sharedSpace1);
      when(sharedSpaceRepository.deleteSharedSpace(sharedSpace2.sharedSpaceId))
        .thenThrow(Exception());

      final result = await removeMultipleSharedSpacesInteractor.execute([sharedSpace1.sharedSpaceId, sharedSpace2.sharedSpaceId]);
      final state = result.getOrElse(() => IdleState());
      expect(state, isA<RemoveSomeSharedSpacesSuccessViewState>());

      (state as RemoveSomeSharedSpacesSuccessViewState).resultList[0].fold(
          (failure) => {},
          (success) => expect((success as RemoveSharedSpaceViewState).sharedSpaceNodeNested, sharedSpace1));

      state.resultList[1].fold(
          (failure) => {},
          (success) => expect((success as RemoveSharedSpaceFailure).exception, isA<Exception>()));
    });

    test('remove multiple shared spaces interactor should return failure with all failed to delete', () async {
      when(sharedSpaceRepository.deleteSharedSpace(sharedSpace1.sharedSpaceId))
        .thenThrow(Exception());
      when(sharedSpaceRepository.deleteSharedSpace(sharedSpace2.sharedSpaceId))
        .thenThrow(Exception());

      final result = await removeMultipleSharedSpacesInteractor.execute([sharedSpace1.sharedSpaceId, sharedSpace2.sharedSpaceId]);

      result.fold(
          (failure) {
            expect(failure, isA<RemoveAllSharedSpacesFailureViewState>());
            (failure as RemoveAllSharedSpacesFailureViewState).resultList.forEach((element) {
              element.fold(
                (failure) => {expect(failure, isA<RemoveSharedSpaceFailure>())},
                (success) => {}
              );
            });
          },
          (success) => {});
    });
  });
}