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
import 'package:data/src/network/config/endpoint.dart';
import 'package:data/src/network/linshare_http_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:testshared/testshared.dart';

import 'linshare_http_client_test.mocks.dart';

@GenerateMocks([DioClient])
void main() {
  group('linshare_http_client_test', () {
    late MockDioClient dioClient;
    late LinShareHttpClient linShareHttpClient;

    setUp(() {
      dioClient = MockDioClient();
      linShareHttpClient = LinShareHttpClient(dioClient);
    });

    test('getAllDocument should return success with valid data', () async {
      when(dioClient.get(Endpoint.documents.generateEndpointPath()))
          .thenAnswer((_) async => [responseJsonDocument1, responseJsonDocument2, responseJsonDocument3]);

      final result = await linShareHttpClient.getAllDocument();

      expect(result, containsAllInOrder([documentResponse1, documentResponse2, documentResponse3]));
    });

    test('getAllDocument should fail when response error', () async {
      when(dioClient.get(Endpoint.documents.generateEndpointPath()))
          .thenThrow(Exception());

      try {
        await linShareHttpClient.getAllDocument();
      } catch(error) {
        expect(error, isA<Exception>());
      }
    });
  });
}
