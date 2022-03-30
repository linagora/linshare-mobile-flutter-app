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
import 'package:data/src/network/model/request/copy_body_request.dart';
import 'package:dio/dio.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:testshared/testshared.dart';

import 'document_datasource_impl_test.mocks.dart';

@GenerateMocks([LinShareHttpClient, LinShareDownloadManager, DocumentDatabaseManager])
void main() {
  getAllDocumentTest();
  shareDocumentTest();
  removeDocumentTest();
  renameDocumentTest();
  getDocumentTest();
  editDescriptionDocumentTest();
  makeAvailableOfflineDocumentTest();
  deleteAllOfflineDocumentsTest();
}

void getAllDocumentTest() {
  group('document_datasource_impl getAll test', () {
    late MockLinShareHttpClient _linShareHttpClient;
    late DocumentDataSourceImpl _documentDataSourceImpl;
    RemoteExceptionThrower _remoteExceptionThrower;
    MockLinShareDownloadManager _linShareDownloadManager;

    setUp(() {
      _linShareHttpClient = MockLinShareHttpClient();
      _remoteExceptionThrower = RemoteExceptionThrower();
      _linShareDownloadManager = MockLinShareDownloadManager();
      _documentDataSourceImpl = DocumentDataSourceImpl(
          _linShareHttpClient,
          _remoteExceptionThrower,
          _linShareDownloadManager);
    });

    test('getAllDocument should return success with valid data', () async {
      when(_linShareHttpClient.getAllDocument())
          .thenAnswer((_) async => [documentResponse1, documentResponse2, documentResponse3]);

      final result = await _documentDataSourceImpl.getAll();
      expect(result, [documentResponse1.toDocument(), documentResponse2.toDocument(), documentResponse3.toDocument()]);
    });

    test('getAllDocument should throw MissingRequiredFields when linShareHttpClient response error with 400', () async {
      final error = DioError(
          type: DioErrorType.response,
          response: Response(statusCode: 400, requestOptions: RequestOptions(path: '')), requestOptions: RequestOptions(path: '')
      );
      when(_linShareHttpClient.getAllDocument())
          .thenThrow(error);

      try {
        await _documentDataSourceImpl.getAll();
      } catch(error) {
        expect(error, isA<MissingRequiredFields>());
      }
    });

    test('getAllDocument should throw DataNotFound when linShareHttpClient response error with 404', () async {
      final error = DioError(
          type: DioErrorType.response,
          response: Response(statusCode: 404, requestOptions: RequestOptions(path: '')), requestOptions: RequestOptions(path: '')
      );
      when(_linShareHttpClient.getAllDocument())
          .thenThrow(error);
      try {
        await _documentDataSourceImpl.getAll();
      } catch(error) {
        expect(error, isA<DocumentNotFound>());
      }
    });

    test('getAllDocument should throw InternalServerError when linShareHttpClient response error with 500', () async {
      final error = DioError(
          type: DioErrorType.response,
          response: Response(statusCode: 500, requestOptions: RequestOptions(path: '')), requestOptions: RequestOptions(path: '')
      );
      when(_linShareHttpClient.getAllDocument())
          .thenThrow(error);

      try {
        await _documentDataSourceImpl.getAll();
      } catch(error) {
        expect(error, isA<InternalServerError>());
      }
    });

    test('getAllDocument should throw ServerNotFound when linShareHttpClient response server not found', () async {
      final error = DioError(type: DioErrorType.other, requestOptions: RequestOptions(path: ''));
      when(_linShareHttpClient.getAllDocument())
          .thenThrow(error);

      try {
        await _documentDataSourceImpl.getAll();
      } catch(error) {
        expect(error, isA<ServerNotFound>());
      }
    });

    test('getAllDocument should throw ConnectError when linShareHttpClient response connect timeout', () async {
      final error = DioError(type: DioErrorType.connectTimeout, requestOptions: RequestOptions(path: ''));
      when(_linShareHttpClient.getAllDocument())
          .thenThrow(error);

      try {
        await _documentDataSourceImpl.getAll();
      } catch(error) {
        expect(error, isA<ConnectError>());
      }
    });

    test('getAllDocument should throw UnknownError when linShareHttpClient throw exception', () async {
      when(_linShareHttpClient.getAllDocument())
          .thenThrow(Exception());

      try {
        await _documentDataSourceImpl.getAll();
      } catch(error) {
        expect(error, isA<UnknownError>());
      }
    });
  });
}

void shareDocumentTest() {
  group('document_datasource_impl share document test', () {
    late MockLinShareHttpClient _linShareHttpClient;
    late DocumentDataSourceImpl _documentDataSourceImpl;
    MockLinShareDownloadManager _linShareDownloadManager;
    RemoteExceptionThrower _remoteExceptionThrower;

    setUp(() {
      _linShareHttpClient = MockLinShareHttpClient();
      _remoteExceptionThrower = RemoteExceptionThrower();
      _linShareDownloadManager = MockLinShareDownloadManager();
      _documentDataSourceImpl = DocumentDataSourceImpl(
          _linShareHttpClient,
          _remoteExceptionThrower,
          _linShareDownloadManager);
    });

    //TODO: Null-safety : Wait a solution replace for argThat
    /*
    test('shareDocument should return success with valid data', () async {
      when(_linShareHttpClient.shareDocument(argThat(isA<ShareDocumentBodyRequest>())!))
          .thenAnswer((_) async => [shareDto1]);

      final result = await _documentDataSourceImpl.share([document1.documentId], [mailingListId1], [genericUser1]);
      expect(result, [shareDto1.toShare()]);
    });

    test('shareDocument should throw MissingRequiredFields when linShareHttpClient response error with 400', () async {
      final error = DioError(
          type: DioErrorType.response,
          response: Response(statusCode: 400, requestOptions: RequestOptions(path: '')), requestOptions: RequestOptions(path: '')
      );
      when(_linShareHttpClient.shareDocument(argThat(isA<ShareDocumentBodyRequest>())!))
          .thenThrow(error);

      await _documentDataSourceImpl.share([document1.documentId], [mailingListId1], [genericUser1])
          .catchError((error) {
            expect(error, isA<MissingRequiredFields>());
          });
    });

    test('shareDocument should throw DataNotFound when linShareHttpClient response error with 404', () async {
      final error = DioError(
          type: DioErrorType.response,
          response: Response(statusCode: 404, requestOptions: RequestOptions(path: '')), requestOptions: RequestOptions(path: '')
      );
      when(_linShareHttpClient.shareDocument(argThat(isA<ShareDocumentBodyRequest>())!))
          .thenThrow(error);

      await _documentDataSourceImpl.share([document1.documentId], [mailingListId1], [genericUser1])
          .catchError((error) {
            expect(error, isA<DocumentNotFound>());
          });
    });

    test('shareDocument should throw ShareDocumentNoPermissionException when linShareHttpClient response error with 403', () async {
      final error = DioError(
          type: DioErrorType.response,
          response: Response(statusCode: 403, requestOptions: RequestOptions(path: '')), requestOptions: RequestOptions(path: '')
      );
      when(_linShareHttpClient.shareDocument(argThat(isA<ShareDocumentBodyRequest>())!))
          .thenThrow(error);

      await _documentDataSourceImpl.share([document1.documentId], [mailingListId1], [genericUser1])
          .catchError((error) {
            expect(error, isA<ShareDocumentNoPermissionException>());
          });
    });

    test('shareDocument should throw InternalServerError when linShareHttpClient response error with 500', () async {
      final error = DioError(
          type: DioErrorType.response,
          response: Response(statusCode: 500, requestOptions: RequestOptions(path: '')), requestOptions: RequestOptions(path: '')
      );
      when(_linShareHttpClient.shareDocument(argThat(isA<ShareDocumentBodyRequest>())!))
          .thenThrow(error);

      await _documentDataSourceImpl.share([document1.documentId], [mailingListId1], [genericUser1])
          .catchError((error) {
            expect(error, isA<InternalServerError>());
          });
    });

    test('shareDocument should throw ServerNotFound when linShareHttpClient response server not found', () async {
      final error = DioError(type: DioErrorType.other, requestOptions: RequestOptions(path: ''));
      when(_linShareHttpClient.shareDocument(argThat(isA<ShareDocumentBodyRequest>())!))
          .thenThrow(error);

      await _documentDataSourceImpl.share([document1.documentId], [mailingListId1], [genericUser1])
          .catchError((error) {
            expect(error, isA<ServerNotFound>());
          });
    });

    test('shareDocument should throw ConnectError when linShareHttpClient response connect timeout', () async {
      final error = DioError(type: DioErrorType.connectTimeout, requestOptions: RequestOptions(path: ''));
      when(_linShareHttpClient.shareDocument(argThat(isA<ShareDocumentBodyRequest>())!))
          .thenThrow(error);

      await _documentDataSourceImpl.share([document1.documentId], [mailingListId1], [genericUser1])
          .catchError((error) {
            expect(error, isA<ConnectError>());
          });
    });

    test('shareDocument should throw UnknownError when linShareHttpClient throw exception', () async {
      when(_linShareHttpClient.shareDocument(argThat(isA<ShareDocumentBodyRequest>())!))
          .thenThrow(Exception());

      await _documentDataSourceImpl.share([document1.documentId], [mailingListId1], [genericUser1])
          .catchError((error) {
            expect(error, isA<UnknownError>());
          });
    });*/
  });
}

void removeDocumentTest() {
  group('remove document test', () {
    late MockLinShareHttpClient _linShareHttpClient;
    late DocumentDataSourceImpl _documentDataSourceImpl;
    MockLinShareDownloadManager _linShareDownloadManager;
    RemoteExceptionThrower _remoteExceptionThrower;

    setUp(() {
      _linShareHttpClient = MockLinShareHttpClient();
      _remoteExceptionThrower = RemoteExceptionThrower();
      _linShareDownloadManager = MockLinShareDownloadManager();
      _documentDataSourceImpl = DocumentDataSourceImpl(
          _linShareHttpClient,
          _remoteExceptionThrower,
          _linShareDownloadManager);
    });

    test('remove document should return success with valid data', () async {
      when(_linShareHttpClient.removeDocument(document1.documentId))
          .thenAnswer((_) async => documentResponse1);

      final result = await _documentDataSourceImpl.remove(document1.documentId);
      expect(result, documentResponse1.toDocument());
    });

    test('remove document should throw DataNotFound when linShareHttpClient response error with 404', () async {
      final error = DioError(
          type: DioErrorType.response,
          response: Response(statusCode: 404, requestOptions: RequestOptions(path: '')), requestOptions: RequestOptions(path: '')
      );
      when(_linShareHttpClient.removeDocument(document1.documentId))
          .thenThrow(error);

      try {
        await _documentDataSourceImpl.remove(document1.documentId);
      } catch(error) {
        expect(error, isA<DocumentNotFound>());
      }
    });

    test('copy to my space should return success with valid data', () async {
      final copyRequest = CopyRequest(workGroupDocument1.workGroupNodeId.uuid, SpaceType.SHARED_SPACE, contextUuid: workGroupDocument1.sharedSpaceId.uuid);
      when(_linShareHttpClient.copyToMySpace(copyRequest.toCopyBodyRequest()))
          .thenAnswer((_) async => [documentResponse1]);

      final result = await _documentDataSourceImpl.copyToMySpace(copyRequest);
      expect(result, [documentResponse1.toDocument()]);
    });

    test('copy to my sapce throw no document found when linShareHttpClient response error with 404', () async {
      final error = DioError(
          type: DioErrorType.response,
          response: Response(statusCode: 404, requestOptions: RequestOptions(path: '')), requestOptions: RequestOptions(path: '')
      );
      final copyRequest = CopyRequest(workGroupDocument1.workGroupNodeId.uuid, SpaceType.SHARED_SPACE, contextUuid: workGroupDocument1.sharedSpaceId.uuid);
      when(_linShareHttpClient.copyToMySpace(copyRequest.toCopyBodyRequest()))
          .thenThrow(error);

      try {
        await _documentDataSourceImpl.copyToMySpace(copyRequest);
      } catch(error) {
        expect(error, isA<DocumentNotFound>());
      }
    });
  });
}

void renameDocumentTest() {
  group('rename document test', () {
    late MockLinShareHttpClient _linShareHttpClient;
    late DocumentDataSourceImpl _documentDataSourceImpl;
    RemoteExceptionThrower _remoteExceptionThrower;
    MockLinShareDownloadManager _linShareDownloadManager;

    setUp(() {
      _linShareHttpClient = MockLinShareHttpClient();
      _remoteExceptionThrower = RemoteExceptionThrower();
      _linShareDownloadManager = MockLinShareDownloadManager();
      _documentDataSourceImpl = DocumentDataSourceImpl(
          _linShareHttpClient,
          _remoteExceptionThrower,
          _linShareDownloadManager);
    });

    test('rename document should return success with valid data', () async {
      when(_linShareHttpClient.renameDocument(document1.documentId, RenameDocumentRequest(document1.name)))
          .thenAnswer((_) async => documentResponse1);

      final result = await _documentDataSourceImpl.rename(document1.documentId, RenameDocumentRequest(document1.name));
      expect(result, documentResponse1.toDocument());
    });

    test('rename document should throw DataNotFound when linShareHttpClient response error with 404', () async {
      final error = DioError(
          type: DioErrorType.response,
          response: Response(statusCode: 404, requestOptions: RequestOptions(path: '')), requestOptions: RequestOptions(path: '')
      );
      when(_linShareHttpClient.renameDocument(document1.documentId, RenameDocumentRequest(document1.name)))
          .thenThrow(error);

      try {
        await _documentDataSourceImpl.rename(
            document1.documentId, RenameDocumentRequest(document1.name));
      } catch(error) {
        expect(error, isA<DocumentNotFound>());
      }
    });
  });
}

void getDocumentTest() {
  group('get document test', () {
    late MockLinShareHttpClient _linShareHttpClient;
    late DocumentDataSourceImpl _documentDataSourceImpl;
    RemoteExceptionThrower _remoteExceptionThrower;
    MockLinShareDownloadManager _linShareDownloadManager;

    setUp(() {
      _linShareHttpClient = MockLinShareHttpClient();
      _remoteExceptionThrower = RemoteExceptionThrower();
      _linShareDownloadManager = MockLinShareDownloadManager();
      _documentDataSourceImpl = DocumentDataSourceImpl(
          _linShareHttpClient,
          _remoteExceptionThrower,
          _linShareDownloadManager);
    });

    test('get document should return success with valid data', () async {
      when(_linShareHttpClient.getDocument(documentDetailsResponse1.documentId))
          .thenAnswer((_) async => documentDetailsResponse1);

      final result = await _documentDataSourceImpl.getDocument(documentDetailsResponse1.documentId);
      expect(result, documentDetailsResponse1.toDocumentDetails());
    });

    test('get document should throw DataNotFound when linShareHttpClient response error with 404', () async {
      final error = DioError(
          type: DioErrorType.response,
          response: Response(statusCode: 404, requestOptions: RequestOptions(path: '')), requestOptions: RequestOptions(path: '')
      );
      when(_linShareHttpClient.getDocument(documentDetailsResponse1.documentId))
          .thenThrow(error);

      try {
        await _documentDataSourceImpl.getDocument(
            documentDetailsResponse1.documentId);
      } catch(error) {
        expect(error, isA<DocumentNotFound>());
      }
    });
  });
}

void editDescriptionDocumentTest() {
  group('edit description document test', () {
    late MockLinShareHttpClient _linShareHttpClient;
    RemoteExceptionThrower _remoteExceptionThrower;
    late DocumentDataSourceImpl _documentDataSourceImpl;
    MockLinShareDownloadManager _linShareDownloadManager;

    setUp(() {
      _linShareHttpClient = MockLinShareHttpClient();
      _remoteExceptionThrower = RemoteExceptionThrower();
      _linShareDownloadManager = MockLinShareDownloadManager();
      _documentDataSourceImpl = DocumentDataSourceImpl(
          _linShareHttpClient,
          _remoteExceptionThrower,
          _linShareDownloadManager);
    });

    test('edit description document should return success with valid data', () async {
      when(_linShareHttpClient.editDescriptionDocument(document1.documentId, EditDescriptionDocumentRequest(document1.name, 'A New Description')))
        .thenAnswer((_) async => documentResponse1);

      final result = await _documentDataSourceImpl.editDescription(document1.documentId, EditDescriptionDocumentRequest(document1.name, 'A New Description'));
      expect(result, documentResponse1.toDocument());
    });

    test('edit description document should throw DataNotFound when linShareHttpClient response error with 404', () async {
      final error = DioError(
          type: DioErrorType.response,
          response: Response(statusCode: 404, requestOptions: RequestOptions(path: '')), requestOptions: RequestOptions(path: '')
      );

      when(_linShareHttpClient.editDescriptionDocument(document1.documentId, EditDescriptionDocumentRequest(document1.name, 'A New Description')))
          .thenThrow(error);

      try {
        await _documentDataSourceImpl.editDescription(document1.documentId,
            EditDescriptionDocumentRequest(
                document1.name, 'A New Description'));
      } catch(error) {
        expect(error, isA<DocumentNotFound>());
      }
    });
  });
}

void makeAvailableOfflineDocumentTest() {
  group('make available offline document test', () {
    late LocalDocumentDataSourceImpl _localDocumentDataSourceImpl;
    late MockDocumentDatabaseManager _documentDatabaseManager;

    setUp(() {
      _documentDatabaseManager = MockDocumentDatabaseManager();
      _localDocumentDataSourceImpl = LocalDocumentDataSourceImpl(_documentDatabaseManager);
    });

    test('make available offline document should return success with valid data', () async {
      when(_documentDatabaseManager.insertData(document1, '')).thenAnswer((_) async => true);

      final result = await _localDocumentDataSourceImpl.makeAvailableOffline(document1, '');

      expect(result, true);
    });
  });
}

void deleteAllOfflineDocumentsTest() {
  group('delete all offline documents test', () {
    late LocalDocumentDataSourceImpl _localDocumentDataSourceImpl;
    late MockDocumentDatabaseManager _documentDatabaseManager;

    setUp(() {
      _documentDatabaseManager = MockDocumentDatabaseManager();
      _localDocumentDataSourceImpl = LocalDocumentDataSourceImpl(_documentDatabaseManager);
    });

    test('deleteAllData should return success', () async {
      when(_documentDatabaseManager.deleteAllData()).thenAnswer((_) async => true);

      final result = await _localDocumentDataSourceImpl.deleteAllData();

      expect(result, true);
    });

    test('deleteAllData should throw Exception when deleting failed', () async {
      final error = SQLiteDatabaseException();
      when(_documentDatabaseManager.deleteAllData()).thenThrow(error);

      try {
        await _localDocumentDataSourceImpl.deleteAllData();
      } catch(error) {
        expect(error, isA<SQLiteDatabaseException>());
      }
    });
  });
}