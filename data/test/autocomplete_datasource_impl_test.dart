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

import 'package:data/data.dart';
import 'package:dio/dio.dart';
import 'package:domain/domain.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:testshared/testshared.dart';

import 'fixture/mock/mock_fixtures.dart';

void main() {
  group('autocomplete_datasource_impl_test', () {
    late LinShareHttpClient linShareHttpClient;
    RemoteExceptionThrower remoteExceptionThrower;
    late AutoCompleteDataSourceImpl autoCompleteDataSourceImpl;

    setUp(() {
      linShareHttpClient = MockLinShareHttpClient();
      remoteExceptionThrower = MockRemoteExceptionThrower();
      autoCompleteDataSourceImpl = AutoCompleteDataSourceImpl(linShareHttpClient, remoteExceptionThrower);
    });

    test('getAutoComplete should return success with valid data', () async {
      when(linShareHttpClient.getSharingAutoComplete(AutoCompletePattern('user'), AutoCompleteType.SHARING))
          .thenAnswer((_) async => [simpleAutoCompleteResultDto1, userAutoCompleteResultDto1, mailingListAutoCompleteResultDto1]);

      final result = await autoCompleteDataSourceImpl.getAutoComplete(AutoCompletePattern('user'), AutoCompleteType.SHARING);
      expect(result, [simpleAutoCompleteResult1, userAutoCompleteResult1, mailingListAutoCompleteResult1]);
    });

    test('getAutoComplete should throw DocumentNotFound when linShareHttpClient response error with 404', () async {
      final error = DioError(
          type: DioErrorType.response,
          response: Response(statusCode: 404, requestOptions: RequestOptions(path: '')), requestOptions: RequestOptions(path: '')
      );
      when(linShareHttpClient.getSharingAutoComplete(AutoCompletePattern('user'), AutoCompleteType.SHARING))
          .thenThrow(error);

      await autoCompleteDataSourceImpl.getAutoComplete(AutoCompletePattern('user'), AutoCompleteType.SHARING)
          .catchError((error) {
            expect(error, isA<DocumentNotFound>());
          });
    });

    test('getAutoComplete should throw DocumentNotFound when linShareHttpClient response error with 500 with errCode 1000', () async {
      final error = DioError(
          type: DioErrorType.response,
          response: Response(statusCode: 500, data: {'errCode': 1000}, requestOptions: RequestOptions(path: '')), requestOptions: RequestOptions(path: '')
      );
      when(linShareHttpClient.getSharingAutoComplete(AutoCompletePattern('us'), AutoCompleteType.SHARING))
          .thenThrow(error);

      await autoCompleteDataSourceImpl.getAutoComplete(AutoCompletePattern('us'), AutoCompleteType.SHARING)
          .catchError((error) {
            expect(error, isA<InvalidPatternMinimumCharactersLengthException>());
          });
    });

    test('getAutoComplete should throw exception when linShareHttpClient throw exception', () async {
      when(linShareHttpClient.getSharingAutoComplete(AutoCompletePattern('us'), AutoCompleteType.SHARING))
          .thenThrow(Exception());

      await autoCompleteDataSourceImpl.getAutoComplete(AutoCompletePattern('us'), AutoCompleteType.SHARING)
          .catchError((error) {
            expect(error, isA<UnknownError>());
          });
    });
  });
}
