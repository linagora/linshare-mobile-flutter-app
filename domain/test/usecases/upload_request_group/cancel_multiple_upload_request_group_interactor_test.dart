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
import 'package:testshared/fixture/upload_request_group_fixture.dart';

import 'cancel_multiple_upload_request_group_interactor_test.mocks.dart';

@GenerateMocks([UploadRequestGroupRepository])
void main() {
  group('cancel_multiple_upload_request_group_interactor tests', () {
    late MockUploadRequestGroupRepository uploadRequestGroupRepository;
    UpdateUploadRequestGroupStateInteractor uploadRequestGroupStateInteractor;
    late UpdateMultipleUploadRequestGroupStateInteractor multipleUploadRequestGroupStateInteractor;

    setUp(() {
      uploadRequestGroupRepository = MockUploadRequestGroupRepository();
      uploadRequestGroupStateInteractor = UpdateUploadRequestGroupStateInteractor(uploadRequestGroupRepository);
      multipleUploadRequestGroupStateInteractor = UpdateMultipleUploadRequestGroupStateInteractor(uploadRequestGroupStateInteractor);
    });

    test('cancel multiple upload_request_group should return success with valid data', () async {
      when(uploadRequestGroupRepository.updateUploadRequestGroupState(uploadRequestGroup1, UploadRequestStatus.CANCELED))
          .thenAnswer((_) async => uploadRequestGroupCanceled1);
      when(uploadRequestGroupRepository.updateUploadRequestGroupState(uploadRequestGroup2, UploadRequestStatus.CANCELED))
          .thenAnswer((_) async => uploadRequestGroupCanceled2);

      final result = await multipleUploadRequestGroupStateInteractor.execute(
          [uploadRequestGroup1, uploadRequestGroup2], UploadRequestStatus.CANCELED);
      final state = result.getOrElse(() => IdleState());
      expect(state, isA<UpdateUploadRequestGroupAllSuccessViewState>());

      (state as UpdateUploadRequestGroupAllSuccessViewState).resultList[0].fold(
        (failure) => {},
        (success) => expect((success as UpdateUploadRequestGroupStateViewState).uploadRequestGroup, uploadRequestGroupCanceled1));

      state.resultList[1].fold(
        (failure) => {},
        (success) => expect((success as UpdateUploadRequestGroupStateViewState).uploadRequestGroup, uploadRequestGroupCanceled2));
    });

    test('cancel multiple upload_request_group should return success with some failed groups to cancel', () async {
      when(uploadRequestGroupRepository.updateUploadRequestGroupState(uploadRequestGroup1, UploadRequestStatus.CANCELED))
          .thenAnswer((_) async => uploadRequestGroupCanceled1);
      when(uploadRequestGroupRepository.updateUploadRequestGroupState(uploadRequestGroup2, UploadRequestStatus.CANCELED))
          .thenThrow(Exception());

      final result = await multipleUploadRequestGroupStateInteractor.execute(
          [uploadRequestGroup1, uploadRequestGroup2], UploadRequestStatus.CANCELED);
      final state = result.getOrElse(() => IdleState());
      expect(state, isA<UpdateUploadRequestGroupHasSomeGroupsFailedViewState>());

      (state as UpdateUploadRequestGroupHasSomeGroupsFailedViewState).resultList.forEach((element) {
        element.fold(
          (failure) => {expect(failure, isA<UpdateUploadRequestGroupStateFailure>())},
          (success) => expect((success as UpdateUploadRequestGroupStateViewState).uploadRequestGroup, uploadRequestGroupCanceled1));
      });
    });

    test('cancel multiple upload_request_group should return failure with all failed groups to cancel', () async {
      when(uploadRequestGroupRepository.updateUploadRequestGroupState(uploadRequestGroup1, UploadRequestStatus.CANCELED))
          .thenThrow(Exception());
      when(uploadRequestGroupRepository.updateUploadRequestGroupState(uploadRequestGroup2, UploadRequestStatus.CANCELED))
          .thenThrow(Exception());

      final result = await multipleUploadRequestGroupStateInteractor.execute(
          [uploadRequestGroup1, uploadRequestGroup2], UploadRequestStatus.CANCELED);
      result.fold(
        (failure) {
          expect(failure, isA<UpdateUploadRequestGroupAllFailureViewState>());
          (failure as UpdateUploadRequestGroupAllFailureViewState).resultList.forEach((element) {
            element.fold(
              (failure) => {expect(failure, isA<UpdateUploadRequestGroupStateFailure>())},
              (success) => {}
            );
          });
        },
        (success) => {});

    });
  });
}
