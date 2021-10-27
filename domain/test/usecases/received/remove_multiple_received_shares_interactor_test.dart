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
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:testshared/fixture/received_share_fixture.dart';

import '../../mock/repository/received/mock_received_share_repository.dart';

void main() {
  group('remove_multiple_received_shares_interactor tests', () {
    late MockReceivedShareRepository receivedShareRepository;
    late RemoveReceivedShareInteractor removeReceivedShareInteractor;
    late RemoveMultipleReceivedSharesInteractor removeMultipleReceivedSharesInteractor;

    setUp(() {
      receivedShareRepository = MockReceivedShareRepository();
      removeReceivedShareInteractor = RemoveReceivedShareInteractor(receivedShareRepository);
      removeMultipleReceivedSharesInteractor = RemoveMultipleReceivedSharesInteractor(removeReceivedShareInteractor);
    });

    test('remove multiple_received_shares should return success with valid data', () async {
      when(receivedShareRepository.remove(receivedShare1.shareId))
        .thenAnswer((_) async => receivedShare1);
      when(receivedShareRepository.remove(receivedShare2.shareId))
        .thenAnswer((_) async => receivedShare2);

      final result = await removeMultipleReceivedSharesInteractor.execute(
          shareIds: [receivedShare1.shareId, receivedShare2.shareId]);
      final state = result.getOrElse(() => IdleState());

      expect(state, isA<RemoveMultipleReceivedSharesAllSuccessViewState>());

      (state as RemoveMultipleReceivedSharesAllSuccessViewState).resultList[0].fold(
        (failure) => {},
        (success) => expect((success as RemoveReceivedShareViewState).receivedShare, receivedShare1));

      state.resultList[1].fold(
        (failure) => {},
        (success) => expect((success as RemoveReceivedShareViewState).receivedShare, receivedShare2));
    });

    test('remove multiple_received_shares should return success with some file failed to delete', () async {
      when(receivedShareRepository.remove(receivedShare1.shareId))
        .thenAnswer((_) async => receivedShare1);
      when(receivedShareRepository.remove(receivedShare2.shareId))
        .thenThrow(Exception());

      final result = await removeMultipleReceivedSharesInteractor.execute(shareIds: [receivedShare1.shareId, receivedShare2.shareId]);
      final state = result.getOrElse(() => IdleState());
      expect(state, isA<RemoveMultipleReceivedSharesHasSomeFilesFailedViewState>());

      (state as RemoveMultipleReceivedSharesHasSomeFilesFailedViewState).resultList.forEach((element) {
        element.fold(
          (failure) => {expect(failure, isA<RemoveReceivedShareFailure>())},
          (success) => expect((success as RemoveReceivedShareViewState).receivedShare, receivedShare1));
      });
    });

    test('remove multiple_received_shares should return failure with all file failed to delete', () async {
      when(receivedShareRepository.remove(receivedShare1.shareId))
        .thenThrow(Exception());
      when(receivedShareRepository.remove(receivedShare2.shareId))
        .thenThrow(Exception());

      final result = await removeMultipleReceivedSharesInteractor.execute(
        shareIds: [receivedShare1.shareId, receivedShare2.shareId]);
      result.fold(
        (failure) {
          expect(failure, isA<RemoveMultipleReceivedSharesAllFailureViewState>());
          (failure as RemoveMultipleReceivedSharesAllFailureViewState).resultList.forEach((element) {
            element.fold(
              (failure) => {expect(failure, isA<RemoveReceivedShareFailure>())},
              (success) => {}
            );
          });
        },
        (success) => {});
    });
  });
}