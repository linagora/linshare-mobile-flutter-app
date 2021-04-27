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
// Linagora © 2009–2021. Contribute to Linshare R&D by subscribing to an Enterprise
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
import 'package:domain/src/model/autocomplete/autocomplete_type.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:testshared/testshared.dart';

import '../../mock/repository/mock_autocomplete_repository.dart';
import '../../mock/repository/mock_contact_repository.dart';

void main() {
  group('get_autocomplete_sharing_with_device_contact_interactor_test', () {
    late AutoCompleteRepository autoCompleteRepository;
    late ContactRepository contactRepository;
    GetAutoCompleteSharingInteractor getAutoCompleteSharingInteractor;
    GetDeviceContactSuggestionsInteractor getDeviceContactSuggestionsInteractor;
    late GetAutoCompleteSharingWithDeviceContactInteractor getAutoCompleteSharingWithDeviceContactInteractor;

    setUp(() {
      autoCompleteRepository = MockAutoCompleteRepository();
      contactRepository = MockContactRepository();
      getAutoCompleteSharingInteractor = GetAutoCompleteSharingInteractor(autoCompleteRepository);
      getDeviceContactSuggestionsInteractor = GetDeviceContactSuggestionsInteractor(contactRepository);
      getAutoCompleteSharingWithDeviceContactInteractor = GetAutoCompleteSharingWithDeviceContactInteractor(
        getAutoCompleteSharingInteractor,
        getDeviceContactSuggestionsInteractor);
    });

    test('get autocomplete should return results with valid data', () async {
      final pattern = AutoCompletePattern('user');
      when(autoCompleteRepository.getAutoComplete(pattern, AutoCompleteType.SHARING))
        .thenAnswer((_) async => [simpleAutoCompleteResult1, userAutoCompleteResult1]);
      when(contactRepository.getContactSuggestions(pattern))
        .thenAnswer((_) async => [contact1]);

      final state = await getAutoCompleteSharingWithDeviceContactInteractor.execute(pattern, AutoCompleteType.SHARING);
      state.fold(
        (failure) => null,
        (success) {
          expect(success, isA<AutoCompleteViewState>());
          expect(
            [simpleAutoCompleteResult1, userAutoCompleteResult1, simpleAutoCompleteResult3],
            (success as AutoCompleteViewState).results);
        });
    });

    test('get autocomplete should return results when no result found from device contact', () async {
      final pattern = AutoCompletePattern('user');
      when(autoCompleteRepository.getAutoComplete(pattern, AutoCompleteType.SHARING))
        .thenAnswer((_) async => [simpleAutoCompleteResult1, userAutoCompleteResult1]);
      when(contactRepository.getContactSuggestions(pattern))
        .thenAnswer((_) async => []);

      final state = await getAutoCompleteSharingWithDeviceContactInteractor.execute(pattern, AutoCompleteType.SHARING);
      state.fold(
        (failure) => null,
        (success) {
          expect(success, isA<AutoCompleteViewState>());
          expect(
            [simpleAutoCompleteResult1, userAutoCompleteResult1],
            (success as AutoCompleteViewState).results);
          });
    });

    test('get autocomplete should return results when no result found from remote', () async {
      final pattern = AutoCompletePattern('user');
      when(autoCompleteRepository.getAutoComplete(pattern, AutoCompleteType.SHARING))
          .thenAnswer((_) async => []);
      when(contactRepository.getContactSuggestions(pattern))
          .thenAnswer((_) async => [contact1]);

      final state = await getAutoCompleteSharingWithDeviceContactInteractor.execute(pattern, AutoCompleteType.SHARING);
      state.fold(
        (failure) => null,
        (success) {
          expect(success, isA<AutoCompleteViewState>());
          expect(
            [simpleAutoCompleteResult3],
            (success as AutoCompleteViewState).results);
          });
    });

    test('get autocomplete should failure when get suggest from device contact throw exception', () async {
      final pattern = AutoCompletePattern('user');
      when(autoCompleteRepository.getAutoComplete(pattern, AutoCompleteType.SHARING))
        .thenAnswer((_) async => [simpleAutoCompleteResult1, userAutoCompleteResult1]);
      when(contactRepository.getContactSuggestions(pattern))
        .thenThrow(Exception());

      final state = await getAutoCompleteSharingWithDeviceContactInteractor.execute(pattern, AutoCompleteType.SHARING);
      state.fold(
        (failure) => expect(failure, isA<AutoCompleteFailure>()),
        (success) => null);
    });

    test('get autocomplete should failure when get suggest from remote throw exception', () async {
      final pattern = AutoCompletePattern('user');
      when(autoCompleteRepository.getAutoComplete(pattern, AutoCompleteType.SHARING))
        .thenThrow(Exception());
      when(contactRepository.getContactSuggestions(pattern))
        .thenAnswer((_) async => [contact1]);

      final state = await getAutoCompleteSharingWithDeviceContactInteractor.execute(pattern, AutoCompleteType.SHARING);
      state.fold(
        (failure) => expect(failure, isA<AutoCompleteFailure>()),
        (success) => null);
    });
  });
}
