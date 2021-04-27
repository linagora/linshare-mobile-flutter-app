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
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:testshared/testshared.dart';

import '../../mock/repository/mock_autocomplete_repository.dart';

void main() {
  group('get_autocomplete_sharing_interactor_test', () {
    late AutoCompleteRepository autoCompleteRepository;
    late GetAutoCompleteSharingInteractor getAutoCompleteSharingInteractor;

    setUp(() {
      autoCompleteRepository = MockAutoCompleteRepository();
      getAutoCompleteSharingInteractor = GetAutoCompleteSharingInteractor(autoCompleteRepository);
    });

    test('getAutoCompleteSharingInteractor should success with valid data', () async {
      when(autoCompleteRepository.getAutoComplete(AutoCompletePattern('user'), AutoCompleteType.SHARING))
          .thenAnswer((_) async => [simpleAutoCompleteResult1, userAutoCompleteResult1, mailingListAutoCompleteResult1]);

      final state = await getAutoCompleteSharingInteractor.execute(AutoCompletePattern('user'), AutoCompleteType.SHARING);
      final autoCompleteResultList = state.map((success) => (success as AutoCompleteViewState).results)
          .getOrElse(() => []);
      
      expect(
          autoCompleteResultList,
          containsAllInOrder([simpleAutoCompleteResult1, userAutoCompleteResult1, mailingListAutoCompleteResult1]));
    });

    test('getAutoCompleteSharingInteractor should fail when pattern size is less than 3', () async {
      final exception = InvalidPatternMinimumCharactersLengthException();
      when(autoCompleteRepository.getAutoComplete(AutoCompletePattern('us'), AutoCompleteType.SHARING))
          .thenThrow(exception);

      final result = await getAutoCompleteSharingInteractor.execute(AutoCompletePattern('us'), AutoCompleteType.SHARING);
      expect(result, Left<Failure, Success>(AutoCompleteFailure(exception)));
    });

    test('getAutoCompleteSharingInteractor should return failure ServerNotFound', () async {
      final exception = ServerNotFound();
      when(autoCompleteRepository.getAutoComplete(AutoCompletePattern('us'), AutoCompleteType.SHARING))
          .thenThrow(exception);

      final result = await getAutoCompleteSharingInteractor.execute(AutoCompletePattern('us'), AutoCompleteType.SHARING);
      expect(result, Left<Failure, Success>(AutoCompleteFailure(exception)));
    });

    test('getAutoCompleteSharingInteractor should return failure ConnectError', () async {
      final exception = ConnectError();
      when(autoCompleteRepository.getAutoComplete(AutoCompletePattern('us'), AutoCompleteType.SHARING))
          .thenThrow(exception);

      final result = await getAutoCompleteSharingInteractor.execute(AutoCompletePattern('us'), AutoCompleteType.SHARING);
      expect(result, Left<Failure, Success>(AutoCompleteFailure(exception)));
    });

    test('getAutoCompleteSharingInteractor should return failure DocumentNotFound', () async {
      final exception = DocumentNotFound();
      when(autoCompleteRepository.getAutoComplete(AutoCompletePattern('us'), AutoCompleteType.SHARING))
          .thenThrow(exception);

      final result = await getAutoCompleteSharingInteractor.execute(AutoCompletePattern('us'), AutoCompleteType.SHARING);
      expect(result, Left<Failure, Success>(AutoCompleteFailure(exception)));
    });

    test('getAutoCompleteSharingInteractor should return failure UnknownError', () async {
      final exception = UnknownError('unknown error');
      when(autoCompleteRepository.getAutoComplete(AutoCompletePattern('us'), AutoCompleteType.SHARING))
          .thenThrow(exception);

      final result = await getAutoCompleteSharingInteractor.execute(AutoCompletePattern('us'), AutoCompleteType.SHARING);
      expect(result, Left<Failure, Success>(AutoCompleteFailure(exception)));
    });
  });
}
