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
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:testshared/fixture/upload_request_group_fixture.dart';

import 'get_all_upload_request_group_interactor_test.mocks.dart';

@GenerateMocks([UploadRequestGroupRepository])
void main() {
  group('get_all_upload_request_group_interactor_test', () {
    late MockUploadRequestGroupRepository uploadRequestGroupRepository;
    late GetAllUploadRequestGroupsInteractor getAllUploadRequestGroupsInteractor;
    late AddNewUploadRequestInteractor addNewUploadRequestInteractor;

    setUp(() {
      uploadRequestGroupRepository = MockUploadRequestGroupRepository();
      getAllUploadRequestGroupsInteractor = GetAllUploadRequestGroupsInteractor(uploadRequestGroupRepository);
      addNewUploadRequestInteractor = AddNewUploadRequestInteractor(uploadRequestGroupRepository);
    });

    test('getAllUploadRequestGroupsInteractor should return success with upload request list', () async {
      when(uploadRequestGroupRepository.getUploadRequestGroups([UploadRequestStatus.CREATED])).thenAnswer((_) async => [uploadRequestGroup1]);

      final result = await getAllUploadRequestGroupsInteractor.execute([UploadRequestStatus.CREATED]);

      final uploadRequestGroupsList = result.map((success) => (success as UploadRequestGroupViewState).uploadRequestGroups)
          .getOrElse(() => []);

      expect(
          uploadRequestGroupsList,
          containsAllInOrder([uploadRequestGroup1]));
    });

    test('getAllUploadRequestGroupsInteractor should fail when get all failed', () async {
      final exception = Exception();

      when(uploadRequestGroupRepository.getUploadRequestGroups([UploadRequestStatus.CREATED])).thenThrow(exception);

      final result = await getAllUploadRequestGroupsInteractor.execute([UploadRequestStatus.CREATED]);

      result.fold(
        (failure) => expect(failure, isA<UploadRequestGroupFailure>()),
        (success) => expect(success, isA<UploadRequestGroupViewState>()));

      expect(result, Left<Failure, Success>(UploadRequestGroupFailure(exception)));
    });

    test('addNewUploadRequest should return success with an upload request', () async {
      when(uploadRequestGroupRepository.addNewUploadRequest(UploadRequestCreationType.INDIVIDUAL, addUploadRequest1)).thenAnswer((_) async => uploadRequestGroup1);

      final result = await addNewUploadRequestInteractor.execute(UploadRequestCreationType.INDIVIDUAL, addUploadRequest1);

      result.fold((failure) => null, (success) {
        expect(success, isA<AddNewUploadRequestViewState>());
        expect((success as AddNewUploadRequestViewState).uploadRequestGroup, uploadRequestGroup1);
      });
    });

    test('addNewUploadRequest should return failure with an exception', () async {
      final exception = Exception();

      when(uploadRequestGroupRepository.addNewUploadRequest(UploadRequestCreationType.INDIVIDUAL, addUploadRequest1)).thenThrow(exception);

      final result = await addNewUploadRequestInteractor.execute(UploadRequestCreationType.INDIVIDUAL, addUploadRequest1);

      result.fold(
              (failure) => expect(failure, isA<AddNewUploadRequestFailure>()),
              (success) => expect(success, isA<AddNewUploadRequestViewState>()));

      expect(result, Left<Failure, Success>(AddNewUploadRequestFailure(exception)));
    });

  });
}
