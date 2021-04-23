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


import 'package:domain/domain.dart';
import 'package:domain/src/usecases/sort/sort_interactor.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:testshared/testshared.dart';

import '../../fixture/test_fixture.dart';
import '../../mock/repository/mock_sort_repository.dart';

void main() {
  group('sort_interactor_test', () {
    MockSortRepository sortRepository;
    SortInteractor sortInteractor;

    setUp(() {
      sortRepository = MockSortRepository();
      sortInteractor = SortInteractor(sortRepository);
    });

    test('sortFiles should return success with documentList has been sorted by modificationDate', () async {
      when(sortRepository.sortFiles([documentSort1, documentSort2, documentSort3], sorter)).thenAnswer((_) async => [documentSort3, documentSort2, documentSort1]);

      final result = await sortInteractor.execute([documentSort1, documentSort2, documentSort3], sorter);

      final documentList = result.map((success) => (success as MySpaceViewState).documentList).getOrElse(() => []);

      expect(documentList, [documentSort3, documentSort2, documentSort1]);
    });

    test('sortFiles should return success with WorkGroupNode has been sorted by modificationDate', () async {
      when(sortRepository.sortFiles([workGroupDocument1, workGroupDocument2, workGroupFolder1], sorter)).thenAnswer((_) async => [workGroupDocument1, workGroupDocument2, workGroupFolder1]);

      final result = await sortInteractor.execute([workGroupDocument1, workGroupDocument2, workGroupFolder1], sorter);

      final workGroupNodes = result.map((success) => (success as GetChildNodesViewState).workGroupNodes).getOrElse(() => []);

      expect(workGroupNodes, [workGroupDocument1, workGroupDocument2, workGroupFolder1]);
    });

    test('sortFiles should return success with received shares has been sorted by sender', () async {
      when(sortRepository.sortFiles([receivedShare1, receivedShare2], sorterSender)).thenAnswer((_) async => [receivedShare2, receivedShare1]);

      final result = await sortInteractor.execute([receivedShare1, receivedShare2], sorterSender);

      final receivedShares = result.map((success) => (success as GetAllReceivedShareSuccess).receivedShares).getOrElse(() => []);

      expect(receivedShares, [receivedShare2, receivedShare1]);
    });

    test('sortFiles should return success with Shared Space has been sorted by modificationDate', () async {
      when(sortRepository.sortFiles([sharedSpace1, sharedSpace3], sharedSpaceModificationDateSorter)).thenAnswer((_) async => [sharedSpace3, sharedSpace1]);

      final result = await sortInteractor.execute([sharedSpace1, sharedSpace3], sharedSpaceModificationDateSorter);

      final sharedSpaces = result.map((success) => (success as SharedSpacesViewState).sharedSpacesList).getOrElse(() => []);

      expect(sharedSpaces, [sharedSpace3, sharedSpace1]);
    });
  });
}