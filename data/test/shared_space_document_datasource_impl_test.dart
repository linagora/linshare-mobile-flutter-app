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

import 'shared_space_document_datasource_impl_test.mocks.dart';

@GenerateMocks([LinShareHttpClient, LinShareDownloadManager])
void main() {
  group('test shared spaces documents', () {
    late MockLinShareHttpClient _linShareHttpClient;
    late RemoteExceptionThrower _remoteExceptionThrower;
    late SharedSpaceDocumentDataSourceImpl _sharedSpaceDataSourceImpl;
    late MockLinShareDownloadManager _linShareDownloadManager;

    setUp(() {
      _linShareHttpClient = MockLinShareHttpClient();
      _remoteExceptionThrower = RemoteExceptionThrower();
      _linShareDownloadManager = MockLinShareDownloadManager();
      _sharedSpaceDataSourceImpl = SharedSpaceDocumentDataSourceImpl(
          _linShareHttpClient,
          _remoteExceptionThrower,
          _linShareDownloadManager
      );
    });

    test('getAllChildNodes should return success with valid data', () async {
      when(_linShareHttpClient.getWorkGroupChildNodes(sharedSpaceId1))
          .thenAnswer((_) async => [sharedSpaceFolder1, sharedSpaceFolder2]);

      final result = await _sharedSpaceDataSourceImpl.getAllChildNodes(sharedSpaceId1);
      expect(result, [sharedSpaceFolder1.toWorkGroupFolder(), sharedSpaceFolder2.toWorkGroupFolder()]);
    });

    test('getAllChildNodes should throw GetChildNodesNotFoundException when linShareHttpClient response error with 404', () async {
      final error = DioError(
          type: DioErrorType.response,
          response: Response(statusCode: 404, requestOptions: RequestOptions(path: '')), requestOptions: RequestOptions(path: '')
      );
      when(_linShareHttpClient.getWorkGroupChildNodes(sharedSpaceId1))
          .thenThrow(error);

      try {
        await _sharedSpaceDataSourceImpl.getAllChildNodes(sharedSpaceId1);
      } catch(error) {
        expect(error, isA<GetChildNodesNotFoundException>());
      }
    });

    test('Copy To SharedSpace Should Return Success Copied Document', () async {
      when(_linShareHttpClient.copyWorkGroupNodeToSharedSpaceDestination(
        CopyBodyRequest(document1.documentId.uuid, SpaceType.SHARED_SPACE),
        sharedSpaceId1,
        destinationParentNodeId: workGroupDocument1.workGroupNodeId
      )).thenAnswer((_) async => [sharedSpaceFolder1]);

      final result = await _sharedSpaceDataSourceImpl.copyToSharedSpace(
          CopyRequest(document1.documentId.uuid, SpaceType.SHARED_SPACE),
          sharedSpaceId1,
          destinationParentNodeId: workGroupDocument1.workGroupNodeId);
      expect(result, [sharedSpaceFolder1.toWorkGroupFolder()]);
    });

    test('Copy To SharedSpace Should Return Success Copied Document Without Destination Parent NodeId', () async {
      when(_linShareHttpClient.copyWorkGroupNodeToSharedSpaceDestination(
        CopyBodyRequest(document1.documentId.uuid, SpaceType.SHARED_SPACE),
        sharedSpaceId1
      )).thenAnswer((_) async => [sharedSpaceFolder1]);

      final result = await _sharedSpaceDataSourceImpl.copyToSharedSpace(
          CopyRequest(document1.documentId.uuid, SpaceType.SHARED_SPACE),
          sharedSpaceId1);
      expect(result, [sharedSpaceFolder1.toWorkGroupFolder()]);
    });

    test('Copy To SharedSpace Should Throw Exception When Copy Failed', () async {
      final error = DioError(
          type: DioErrorType.response,
          response: Response(statusCode: 404, requestOptions: RequestOptions(path: '')), requestOptions: RequestOptions(path: '')
      );
      when(_linShareHttpClient.copyWorkGroupNodeToSharedSpaceDestination(
        CopyBodyRequest(document1.documentId.uuid, SpaceType.SHARED_SPACE),
          sharedSpaceId1,
      )).thenThrow(error);

      try {
        await _sharedSpaceDataSourceImpl.copyToSharedSpace(
            CopyRequest(document1.documentId.uuid, SpaceType.SHARED_SPACE),
            sharedSpaceId1
        );
      } catch(error) {
        expect(error, isA<WorkGroupNodeNotFoundException>());
      }
    });

    test('Remove Shared Space Node Should Return Success Deleted Node', () async {
      when(_linShareHttpClient.removeSharedSpaceNode(
        sharedSpaceFolder1.sharedSpaceId,
        sharedSpaceFolder1.workGroupNodeId
      )).thenAnswer((_) async => sharedSpaceFolder1);

      final result = await _sharedSpaceDataSourceImpl.removeSharedSpaceNode(
        sharedSpaceFolder1.sharedSpaceId,
        sharedSpaceFolder1.workGroupNodeId
      );

      expect(result, sharedSpaceFolder1.toWorkGroupFolder());
    });

    test('Remove Shared Space Node Should Throw Exception When Remove Failed', () async {
      final error = DioError(
          type: DioErrorType.response,
          response: Response(statusCode: 404, requestOptions: RequestOptions(path: '')), requestOptions: RequestOptions(path: '')
      );

      when(_linShareHttpClient.removeSharedSpaceNode(
        sharedSpaceFolder1.sharedSpaceId,
        sharedSpaceFolder1.workGroupNodeId
      )).thenThrow(error);

      try {
        await _sharedSpaceDataSourceImpl.removeSharedSpaceNode(
            sharedSpaceFolder1.sharedSpaceId,
            sharedSpaceFolder1.workGroupNodeId
        );
      } catch(error) {
        expect(error, isA<WorkGroupNodeNotFoundException>());
      }
    });

    test('Create Folder Should Return Success Created Folder', () async {
      final createdFolder = WorkGroupNodeFolderDto(
        workGroupNodeId2,
        parentWorkGroupNodeId1,
        WorkGroupNodeType.FOLDER,
        sharedSpaceId1,
        DateTime.now(),
        DateTime.now(),
        'Dat is good',
        'description',
        accountDto1,
        []
      );

      final request = CreateSharedSpaceNodeFolderRequest('Dat is good', sharedSpaceFolder1.workGroupNodeId);

      when(_linShareHttpClient.createSharedSpaceNodeFolder(
        sharedSpaceFolder1.sharedSpaceId,
        request
      )).thenAnswer((_) async => createdFolder);

      final result = await _sharedSpaceDataSourceImpl.createSharedSpaceFolder(
        sharedSpaceFolder1.sharedSpaceId,
        request
      );

      expect(result, createdFolder.toWorkGroupFolder());
    });

    test('Create Folder Should Return Success Created Folder when parent is null', () async {
      final createdFolder = WorkGroupNodeFolderDto(
        workGroupNodeId2,
        parentWorkGroupNodeId1,
        WorkGroupNodeType.FOLDER,
        sharedSpaceId1,
        DateTime.now(),
        DateTime.now(),
        'Dat is good',
        'description',
        accountDto1,
        []
      );

      final request = CreateSharedSpaceNodeFolderRequest('Dat is good');

      when(_linShareHttpClient.createSharedSpaceNodeFolder(
        sharedSpaceFolder1.sharedSpaceId,
        request
      )).thenAnswer((_) async => createdFolder);

      final result = await _sharedSpaceDataSourceImpl.createSharedSpaceFolder(
        sharedSpaceFolder1.sharedSpaceId,
        request
      );

      expect(result, createdFolder.toWorkGroupFolder());
    });

    test('Created Folder Should Throw Exception When Fail', () async {
      final error = DioError(type: DioErrorType.response, response: Response(statusCode: 404, requestOptions: RequestOptions(path: '')), requestOptions: RequestOptions(path: ''));
      when(_linShareHttpClient.createSharedSpaceNodeFolder(
        argThat(isA<SharedSpaceId>()),
        argThat(isA<CreateSharedSpaceNodeFolderRequest>())
      )).thenThrow(error);

      try {
        await _sharedSpaceDataSourceImpl
          .createSharedSpaceFolder(
            sharedSpaceFolder1.sharedSpaceId,
            CreateSharedSpaceNodeFolderRequest('Dat is good', sharedSpaceFolder1.workGroupNodeId)
        );
      } catch(error) {
        expect(error, isA<SharedSpaceNotFound>());
      }
    });

    test('Rename Shared Space Node Should Return Success Renamed Node', () async {
      when(_linShareHttpClient.renameSharedSpaceNode(
          workGroupDocumentDto.sharedSpaceId,
          workGroupDocumentDto.workGroupNodeId,
          RenameWorkGroupNodeBodyRequest(workGroupDocumentDto.name, WorkGroupNodeType.DOCUMENT)
      )).thenAnswer((_) async => workGroupDocumentDto);

      final result = await _sharedSpaceDataSourceImpl.renameSharedSpaceNode(
          workGroupDocumentDto.sharedSpaceId,
          workGroupDocumentDto.workGroupNodeId,
          RenameWorkGroupNodeRequest(workGroupDocumentDto.name, WorkGroupNodeType.DOCUMENT)
      );

      expect(result, workGroupDocumentDto.toWorkGroupDocument());
    });

    test('Rename Shared Space Node Should Throw Exception When Renamed Failed', () async {
      final error = DioError(
          type: DioErrorType.response,
          response: Response(statusCode: 404, requestOptions: RequestOptions(path: '')), requestOptions: RequestOptions(path: '')
      );

      when(_linShareHttpClient.renameSharedSpaceNode(
          workGroupDocumentDto.sharedSpaceId,
          workGroupDocumentDto.workGroupNodeId,
          RenameWorkGroupNodeBodyRequest(workGroupDocumentDto.name, WorkGroupNodeType.DOCUMENT)
      )).thenThrow(error);

      try {
        await _sharedSpaceDataSourceImpl.renameSharedSpaceNode(
            workGroupDocumentDto.sharedSpaceId,
            workGroupDocumentDto.workGroupNodeId,
            RenameWorkGroupNodeRequest(
                workGroupDocumentDto.name!, WorkGroupNodeType.DOCUMENT)
        );
      } catch(error) {
        expect(error, isA<WorkGroupNodeNotFoundException>());
      }
    });

    test('Get Shared Space Node Should Return Success Node', () async {
      when(_linShareHttpClient.getWorkGroupNode(
          workGroupDocumentDto.sharedSpaceId,
          workGroupDocumentDto.workGroupNodeId,
      )).thenAnswer((_) async => workGroupDocumentDto);

      final result = await _sharedSpaceDataSourceImpl.getWorkGroupNode(
          workGroupDocumentDto.sharedSpaceId,
          workGroupDocumentDto.workGroupNodeId,
      );

      expect(result, workGroupDocumentDto.toWorkGroupDocument());
    });

    test('Get Shared Space Node Should Throw Exception When Get Failed', () async {
      final error = DioError(
          type: DioErrorType.response,
          response: Response(statusCode: 404, requestOptions: RequestOptions(path: '')), requestOptions: RequestOptions(path: '')
      );

      when(_linShareHttpClient.getWorkGroupNode(
          workGroupDocumentDto.sharedSpaceId,
          workGroupDocumentDto.workGroupNodeId,
      )).thenThrow(error);

      try {
        await _sharedSpaceDataSourceImpl.getWorkGroupNode(
          workGroupDocumentDto.sharedSpaceId,
          workGroupDocumentDto.workGroupNodeId,
        );
      } catch(error) {
        expect(error, isA<WorkGroupNodeNotFoundException>());
      }
    });

    test('GetWorkGroupNode With hasTreePath is true Should Return Success Node', () async {
      when(_linShareHttpClient.getWorkGroupNode(
        workGroupFolderDto.sharedSpaceId,
        workGroupFolderDto.workGroupNodeId,
        hasTreePath: true)
      ).thenAnswer((_) async => workGroupFolderDto);

      final result = await _sharedSpaceDataSourceImpl.getWorkGroupNode(
        workGroupFolderDto.sharedSpaceId,
        workGroupFolderDto.workGroupNodeId,
        hasTreePath: true
      );

      expect(result, workGroupFolderDto.toWorkGroupFolder());
    });

    test('GetWorkGroupNode With hasTreePath is true  Should Throw Exception When Get Failed', () async {
      final error = DioError(
        type: DioErrorType.response,
        response: Response(statusCode: 404, requestOptions: RequestOptions(path: '')), requestOptions: RequestOptions(path: '')
      );

      when(_linShareHttpClient.getWorkGroupNode(
        workGroupFolderDto.sharedSpaceId,
        workGroupFolderDto.workGroupNodeId,
        hasTreePath: true
      )).thenThrow(error);

      try {
        await _sharedSpaceDataSourceImpl.getWorkGroupNode(
            workGroupFolderDto.sharedSpaceId,
            workGroupFolderDto.workGroupNodeId,
            hasTreePath: true
        );
      } catch(error) {
        expect(error, isA<WorkGroupNodeNotFoundException>());
      }
    });

    test('getRealSharedSpaceRootNode should return success with complete data', () async {
      when(_linShareHttpClient.getWorkGroupNode(
          sharedSpaceId1,
          sharedSpaceId1.toWorkGroupNodeId(),
          hasTreePath: true
      )).thenAnswer((_) async => workGroupDocumentDto);

      final result = await _sharedSpaceDataSourceImpl.getRealSharedSpaceRootNode(
          sharedSpaceId1,
          hasTreePath: true
      );
      expect(result, workGroupDocumentDto.toWorkGroupDocument());
    });

    test('getRealSharedSpaceRootNode should throw SharedSpacesNotFound when linShareHttpClient response error with 404', () async {
      final error = DioError(
          type: DioErrorType.response,
          response: Response(statusCode: 404, requestOptions: RequestOptions(path: '')), requestOptions: RequestOptions(path: '')
      );
      when(_linShareHttpClient.getWorkGroupNode(
          sharedSpaceId1,
          sharedSpaceId1.toWorkGroupNodeId(),
          hasTreePath: true
      )).thenThrow(error);

      try {
        await _sharedSpaceDataSourceImpl.getRealSharedSpaceRootNode(
            sharedSpaceId1);
      } catch(error) {
        expect(error, isA<SharedSpaceNodeNotFound>());
      }
    });

    test('getRealSharedSpaceRootNode should throw SharedSpacesNotFound when linShareHttpClient response error with 403', () async {
      final error = DioError(
          type: DioErrorType.response,
          response: Response(statusCode: 403, requestOptions: RequestOptions(path: '')), requestOptions: RequestOptions(path: '')
      );
      when(_linShareHttpClient.getWorkGroupNode(
          sharedSpaceId1,
          sharedSpaceId1.toWorkGroupNodeId(),
          hasTreePath: true
      )).thenThrow(error);

      try {
        await _sharedSpaceDataSourceImpl.getRealSharedSpaceRootNode(
            sharedSpaceId1);
      } catch(error) {
        expect(error, isA<NotAuthorized>());
      }
    });

    test('Move Shared Space Node Should Return Success Node', () async {
      when(_linShareHttpClient.moveWorkgroupNode(
        moveWorkGroupNodeBodyRequest,
        sharedSpaceId1
      )).thenAnswer((_) async => workGroupDocumentDto);

      final result = await _sharedSpaceDataSourceImpl.moveWorkgroupNode(
          moveWorkGroupNodeRequest,
          sharedSpaceId1
      );

      expect(result, workGroupDocumentDto.toWorkGroupDocument());
    });

    test('Move Shared Space Node Should Throw Exception When Get Failed', () async {
      final error = DioError(
          type: DioErrorType.response,
          response: Response(statusCode: 404, requestOptions: RequestOptions(path: '')), requestOptions: RequestOptions(path: '')
      );

      when(_linShareHttpClient.moveWorkgroupNode(
          moveWorkGroupNodeBodyRequest,
          sharedSpaceId1
      )).thenThrow(error);

      try {
        await _sharedSpaceDataSourceImpl.moveWorkgroupNode(
            moveWorkGroupNodeRequest,
            sharedSpaceId1);
      } catch(error) {
        expect(error, isA<WorkGroupNodeNotFoundException>());
      }
    });

  });
}