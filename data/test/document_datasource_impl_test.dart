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

import 'package:data/data.dart';
import 'package:data/src/network/model/request/share_document_body_request.dart';
import 'package:dio/dio.dart';
import 'package:domain/domain.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:testshared/testshared.dart';

import 'fixture/document_fixture.dart';
import 'fixture/mock/mock_fixtures.dart';

void main() {
  getAllDocumentTest();
  shareDocumentTest();
  removeDocumentTest();
}

void getAllDocumentTest() {
  group('document_datasource_impl getAll test', () {
    MockLinShareHttpClient _linShareHttpClient;
    MockRemoteExceptionThrower _remoteExceptionThrower;
    DocumentDataSourceImpl _documentDataSourceImpl;

    setUp(() {
      _linShareHttpClient = MockLinShareHttpClient();
      _remoteExceptionThrower = MockRemoteExceptionThrower();
      _documentDataSourceImpl = DocumentDataSourceImpl(
          _linShareHttpClient,
          _remoteExceptionThrower);
    });

    test('getAllDocument should return success with valid data', () async {
      when(_linShareHttpClient.getAllDocument())
          .thenAnswer((_) async => [documentResponse1, documentResponse2, documentResponse3]);

      final result = await _documentDataSourceImpl.getAll();
      expect(result, [document1, document2, document3]);
    });

    test('getAllDocument should throw MissingRequiredFields when linShareHttpClient response error with 400', () async {
      final error = DioError(
          type: DioErrorType.RESPONSE,
          response: Response(statusCode: 400)
      );
      when(_linShareHttpClient.getAllDocument())
          .thenThrow(error);

      await _documentDataSourceImpl.getAll()
          .catchError((error) => expect(error, isA<MissingRequiredFields>()));
    });

    test('getAllDocument should throw DataNotFound when linShareHttpClient response error with 404', () async {
      final error = DioError(
          type: DioErrorType.RESPONSE,
          response: Response(statusCode: 404)
      );
      when(_linShareHttpClient.getAllDocument())
          .thenThrow(error);

      await _documentDataSourceImpl.getAll()
          .catchError((error) => expect(error, isA<DocumentNotFound>()));
    });

    test('getAllDocument should throw InternalServerError when linShareHttpClient response error with 500', () async {
      final error = DioError(
          type: DioErrorType.RESPONSE,
          response: Response(statusCode: 500)
      );
      when(_linShareHttpClient.getAllDocument())
          .thenThrow(error);

      await _documentDataSourceImpl.getAll()
          .catchError((error) => expect(error, isA<InternalServerError>()));
    });

    test('getAllDocument should throw ServerNotFound when linShareHttpClient response server not found', () async {
      final error = DioError(type: DioErrorType.DEFAULT);
      when(_linShareHttpClient.getAllDocument())
          .thenThrow(error);

      await _documentDataSourceImpl.getAll()
          .catchError((error) => expect(error, isA<ServerNotFound>()));
    });

    test('getAllDocument should throw ConnectError when linShareHttpClient response connect timeout', () async {
      final error = DioError(type: DioErrorType.CONNECT_TIMEOUT);
      when(_linShareHttpClient.getAllDocument())
          .thenThrow(error);

      await _documentDataSourceImpl.getAll()
          .catchError((error) => expect(error, isA<ConnectError>()));
    });

    test('getAllDocument should throw UnknownError when linShareHttpClient throw exception', () async {
      when(_linShareHttpClient.getAllDocument())
          .thenThrow(Exception());

      await _documentDataSourceImpl.getAll()
          .catchError((error) => expect(error, isA<UnknownError>()));
    });
  });
}

void shareDocumentTest() {
  group('document_datasource_impl share document test', () {
    MockLinShareHttpClient _linShareHttpClient;
    MockRemoteExceptionThrower _remoteExceptionThrower;
    DocumentDataSourceImpl _documentDataSourceImpl;

    setUp(() {
      _linShareHttpClient = MockLinShareHttpClient();
      _remoteExceptionThrower = MockRemoteExceptionThrower();
      _documentDataSourceImpl = DocumentDataSourceImpl(
          _linShareHttpClient,
          _remoteExceptionThrower);
    });

    test('shareDocument should return success with valid data', () async {
      when(_linShareHttpClient.shareDocument(argThat(isA<ShareDocumentBodyRequest>())))
          .thenAnswer((_) async => [shareDto1]);

      final result = await _documentDataSourceImpl.share([document1.documentId], [mailingListId1], [genericUser1]);
      expect(result, [share1]);
    });

    test('shareDocument should throw MissingRequiredFields when linShareHttpClient response error with 400', () async {
      final error = DioError(
          type: DioErrorType.RESPONSE,
          response: Response(statusCode: 400)
      );
      when(_linShareHttpClient.shareDocument(argThat(isA<ShareDocumentBodyRequest>())))
          .thenThrow(error);

      await _documentDataSourceImpl.share([document1.documentId], [mailingListId1], [genericUser1])
          .catchError((error) => expect(error, isA<MissingRequiredFields>()));
    });

    test('shareDocument should throw DataNotFound when linShareHttpClient response error with 404', () async {
      final error = DioError(
          type: DioErrorType.RESPONSE,
          response: Response(statusCode: 404)
      );
      when(_linShareHttpClient.shareDocument(argThat(isA<ShareDocumentBodyRequest>())))
          .thenThrow(error);

      await _documentDataSourceImpl.share([document1.documentId], [mailingListId1], [genericUser1])
          .catchError((error) => expect(error, isA<DocumentNotFound>()));
    });

    test('shareDocument should throw ShareDocumentNoPermissionException when linShareHttpClient response error with 403', () async {
      final error = DioError(
          type: DioErrorType.RESPONSE,
          response: Response(statusCode: 403)
      );
      when(_linShareHttpClient.shareDocument(argThat(isA<ShareDocumentBodyRequest>())))
          .thenThrow(error);

      await _documentDataSourceImpl.share([document1.documentId], [mailingListId1], [genericUser1])
          .catchError((error) => expect(error, isA<ShareDocumentNoPermissionException>()));
    });

    test('shareDocument should throw InternalServerError when linShareHttpClient response error with 500', () async {
      final error = DioError(
          type: DioErrorType.RESPONSE,
          response: Response(statusCode: 500)
      );
      when(_linShareHttpClient.shareDocument(argThat(isA<ShareDocumentBodyRequest>())))
          .thenThrow(error);

      await _documentDataSourceImpl.share([document1.documentId], [mailingListId1], [genericUser1])
          .catchError((error) => expect(error, isA<InternalServerError>()));
    });

    test('shareDocument should throw ServerNotFound when linShareHttpClient response server not found', () async {
      final error = DioError(type: DioErrorType.DEFAULT);
      when(_linShareHttpClient.shareDocument(argThat(isA<ShareDocumentBodyRequest>())))
          .thenThrow(error);

      await _documentDataSourceImpl.share([document1.documentId], [mailingListId1], [genericUser1])
          .catchError((error) => expect(error, isA<ServerNotFound>()));
    });

    test('shareDocument should throw ConnectError when linShareHttpClient response connect timeout', () async {
      final error = DioError(type: DioErrorType.CONNECT_TIMEOUT);
      when(_linShareHttpClient.shareDocument(argThat(isA<ShareDocumentBodyRequest>())))
          .thenThrow(error);

      await _documentDataSourceImpl.share([document1.documentId], [mailingListId1], [genericUser1])
          .catchError((error) => expect(error, isA<ConnectError>()));
    });

    test('shareDocument should throw UnknownError when linShareHttpClient throw exception', () async {
      when(_linShareHttpClient.shareDocument(argThat(isA<ShareDocumentBodyRequest>())))
          .thenThrow(Exception());

      await _documentDataSourceImpl.share([document1.documentId], [mailingListId1], [genericUser1])
          .catchError((error) => expect(error, isA<UnknownError>()));
    });
  });
}

void removeDocumentTest() {
  group('remove document test', () {
    MockLinShareHttpClient _linShareHttpClient;
    MockRemoteExceptionThrower _remoteExceptionThrower;
    DocumentDataSourceImpl _documentDataSourceImpl;

    setUp(() {
      _linShareHttpClient = MockLinShareHttpClient();
      _remoteExceptionThrower = MockRemoteExceptionThrower();
      _documentDataSourceImpl = DocumentDataSourceImpl(
          _linShareHttpClient,
          _remoteExceptionThrower);
    });

    test('remove document should return success with valid data', () async {
      when(_linShareHttpClient.removeDocument(document1.documentId))
          .thenAnswer((_) async => documentResponse1);

      final result = await _documentDataSourceImpl.remove(document1.documentId);
      expect(result, document1);
    });

    test('remove document should throw DataNotFound when linShareHttpClient response error with 404', () async {
      final error = DioError(
          type: DioErrorType.RESPONSE,
          response: Response(statusCode: 404)
      );
      when(_linShareHttpClient.removeDocument(document1.documentId))
          .thenThrow(error);

      await _documentDataSourceImpl.remove(document1.documentId)
          .catchError((error) => expect(error, isA<DocumentNotFound>()));
    });
  });
}
