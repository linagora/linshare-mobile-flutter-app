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
import 'package:dio/dio.dart';
import 'package:domain/domain.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:testshared/fixture/my_space_fixture.dart';

import 'package:testshared/fixture/upload_request_group_fixture.dart';
import 'fixture/mock/mock_fixtures.dart';

void main() {
  getAllUploadRequestGroupsTest();
  addRecipientsTest();
  cancelUploadRequestGroupTest();
  archiveUploadRequestGroupTest();
  closeUploadRequestGroupTest();
}

void getAllUploadRequestGroupsTest() {
  group('upload_request_group_datasource_impl getAll test', () {
    late MockLinShareHttpClient _linShareHttpClient;
    MockRemoteExceptionThrower _remoteExceptionThrower;
    late UploadRequestGroupDataSourceImpl _uploadRequestGroupDataSourceImpl;

    setUp(() {
      _linShareHttpClient = MockLinShareHttpClient();
      _remoteExceptionThrower = MockRemoteExceptionThrower();
      _uploadRequestGroupDataSourceImpl =
          UploadRequestGroupDataSourceImpl(_linShareHttpClient, _remoteExceptionThrower);
    });

    test('getAllUploadRequestGroups should return success with valid data', () async {
      when(_linShareHttpClient.getAllUploadRequestGroups([UploadRequestStatus.CREATED]))
          .thenAnswer((_) async => [uploadRequestGroupResponse1]);

      final result = await _uploadRequestGroupDataSourceImpl
          .getUploadRequestGroups([UploadRequestStatus.CREATED]);
      expect(result, [uploadRequestGroupResponse1.toUploadRequestGroup()]);
    });

    test('getAllUploadRequestGroups should throw MissingRequiredFields when linShareHttpClient response error with 400', () async {
      final error = DioError(
          type: DioErrorType.response,
          response: Response(statusCode: 400, requestOptions: RequestOptions(path: '')),
          requestOptions: RequestOptions(path: ''));

      when(_linShareHttpClient.getAllUploadRequestGroups([UploadRequestStatus.CREATED]))
          .thenThrow(error);

      await _uploadRequestGroupDataSourceImpl
          .getUploadRequestGroups([UploadRequestStatus.CREATED]).catchError((error) {
        expect(error, isA<MissingRequiredFields>());
      });
    });

    test('addNewUploadRequest should return success with valid Collective request', () async {
      when(_linShareHttpClient.addNewUploadRequest(UploadRequestCreationType.COLLECTIVE, addUploadRequest1))
          .thenAnswer((_) async => uploadRequestGroupResponse1);

      final result = await _uploadRequestGroupDataSourceImpl
          .addNewUploadRequest(UploadRequestCreationType.COLLECTIVE, addUploadRequest1);
      expect(result, uploadRequestGroupResponse1.toUploadRequestGroup());
    });

    test('addNewUploadRequest should return success with valid Individual request', () async {
      when(_linShareHttpClient.addNewUploadRequest(UploadRequestCreationType.INDIVIDUAL, addUploadRequest1))
          .thenAnswer((_) async => uploadRequestGroupResponse1);

      final result = await _uploadRequestGroupDataSourceImpl
          .addNewUploadRequest(UploadRequestCreationType.INDIVIDUAL, addUploadRequest1);
      expect(result, uploadRequestGroupResponse1.toUploadRequestGroup());
    });

    test('addNewUploadRequest should throw exception when linShareHttpClient response error with 404', () async {
      final error = DioError(
          type: DioErrorType.response,
          response: Response(statusCode: 404, requestOptions: RequestOptions(path: '')),
          requestOptions: RequestOptions(path: ''));

      when(_linShareHttpClient.addNewUploadRequest(UploadRequestCreationType.INDIVIDUAL, addUploadRequest1))
          .thenThrow(error);

      await _uploadRequestGroupDataSourceImpl
          .addNewUploadRequest(UploadRequestCreationType.INDIVIDUAL, addUploadRequest1).catchError((error) {
        expect(error, isA<ServerNotFound>());
      });
    });

  });
}

void addRecipientsTest() {
  group('upload_request_group_datasource_impl addRecipients test', () {
    late MockLinShareHttpClient _linShareHttpClient;
    MockRemoteExceptionThrower _remoteExceptionThrower;
    late UploadRequestGroupDataSourceImpl _uploadRequestGroupDataSourceImpl;

    setUp(() {
      _linShareHttpClient = MockLinShareHttpClient();
      _remoteExceptionThrower = MockRemoteExceptionThrower();
      _uploadRequestGroupDataSourceImpl =
          UploadRequestGroupDataSourceImpl(_linShareHttpClient, _remoteExceptionThrower);
    });

    test('addRecipients should return success with valid data', () async {
      when(_linShareHttpClient.addRecipientsToUploadRequestGroup(uploadRequestGroup1.uploadRequestGroupId, [genericUser1, genericUser]))
          .thenAnswer((_) async => uploadRequestGroupResponse1);

      final result = await _uploadRequestGroupDataSourceImpl
          .addRecipients(uploadRequestGroup1.uploadRequestGroupId, [genericUser1, genericUser]);
      expect(result, uploadRequestGroupResponse1.toUploadRequestGroup());
    });

    test('addRecipients should throw MissingRequiredFields when linShareHttpClient response error with 400', () async {
      final error = DioError(
          type: DioErrorType.response,
          response: Response(statusCode: 400, requestOptions: RequestOptions(path: '')),
          requestOptions: RequestOptions(path: ''));

      when(_linShareHttpClient.addRecipientsToUploadRequestGroup(uploadRequestGroup1.uploadRequestGroupId, [genericUser1, genericUser]))
          .thenThrow(error);

      await _uploadRequestGroupDataSourceImpl
          .addRecipients(uploadRequestGroup1.uploadRequestGroupId, [genericUser1, genericUser]).catchError((error) {
        expect(error, isA<MissingRequiredFields>());
      });
    });

    test('addRecipients should throw exception when linShareHttpClient response error with 404', () async {
      final error = DioError(
          type: DioErrorType.response,
          response: Response(statusCode: 404, requestOptions: RequestOptions(path: '')),
          requestOptions: RequestOptions(path: ''));

      when(_linShareHttpClient.addRecipientsToUploadRequestGroup(uploadRequestGroup1.uploadRequestGroupId, [genericUser1, genericUser]))
          .thenThrow(error);

      await _uploadRequestGroupDataSourceImpl
          .addRecipients(uploadRequestGroup1.uploadRequestGroupId, [genericUser1, genericUser]).catchError((error) {
        expect(error, isA<ServerNotFound>());
      });
    });
  });
}

void cancelUploadRequestGroupTest() {
  group('cancel upload_request_group test', () {
    late MockLinShareHttpClient _linShareHttpClient;
    late UploadRequestGroupDataSourceImpl _uploadRequestGroupDataSourceImpl;
    MockRemoteExceptionThrower _remoteExceptionThrower;

    setUp(() {
      _linShareHttpClient = MockLinShareHttpClient();
      _remoteExceptionThrower = MockRemoteExceptionThrower();
      _uploadRequestGroupDataSourceImpl = UploadRequestGroupDataSourceImpl(
          _linShareHttpClient,
          _remoteExceptionThrower);
    });

    test('cancel upload_request_group should return success with valid data', () async {
      when(_linShareHttpClient.updateUploadRequestGroupStatus(uploadRequestGroup1.uploadRequestGroupId, UploadRequestStatus.CANCELED))
          .thenAnswer((_) async => uploadRequestGroupResponseCanceled1);

      final result = await _uploadRequestGroupDataSourceImpl.updateUploadRequestGroupState(
          uploadRequestGroup1, UploadRequestStatus.CANCELED);
      expect(result, uploadRequestGroupResponseCanceled1.toUploadRequestGroup());
    });

    test('cancel upload_request_group should throw UploadRequestGroupsNotFound when linShareHttpClient response error with 404', () async {
      final error = DioError(
          type: DioErrorType.response,
          response: Response(statusCode: 404, requestOptions: RequestOptions(path: '')), requestOptions: RequestOptions(path: '')
      );
      when(_linShareHttpClient.updateUploadRequestGroupStatus(uploadRequestGroup1.uploadRequestGroupId, UploadRequestStatus.CANCELED))
          .thenThrow(error);

      await _uploadRequestGroupDataSourceImpl.updateUploadRequestGroupState(
          uploadRequestGroup1, UploadRequestStatus.CANCELED).catchError((error) {
            expect(error, isA<UploadRequestGroupsNotFound>());
      });
    });

  });
}

void archiveUploadRequestGroupTest() {
  group('archive upload_request_group test', () {
    late MockLinShareHttpClient _linShareHttpClient;
    MockRemoteExceptionThrower _remoteExceptionThrower;
    late UploadRequestGroupDataSourceImpl _uploadRequestGroupDataSourceImpl;

    setUp(() {
      _linShareHttpClient = MockLinShareHttpClient();
      _remoteExceptionThrower = MockRemoteExceptionThrower();
      _uploadRequestGroupDataSourceImpl =
          UploadRequestGroupDataSourceImpl(_linShareHttpClient, _remoteExceptionThrower);
    });

    test('archive upload_request_group should return success with valid data', () async {
      when(_linShareHttpClient.updateUploadRequestGroupStatus(uploadRequestGroup1.uploadRequestGroupId, UploadRequestStatus.ARCHIVED))
          .thenAnswer((_) async => uploadRequestGroupResponse1);

      final result = await _uploadRequestGroupDataSourceImpl
          .updateUploadRequestGroupState(uploadRequestGroup1, UploadRequestStatus.ARCHIVED);
      expect(result, uploadRequestGroupResponse1.toUploadRequestGroup());
    });

    test('archive upload_request_group should throw exception when linShareHttpClient response error with 404', () async {
      final error = DioError(
          type: DioErrorType.response,
          response: Response(statusCode: 404, requestOptions: RequestOptions(path: '')),
          requestOptions: RequestOptions(path: ''));

      when(_linShareHttpClient.updateUploadRequestGroupStatus(uploadRequestGroup1.uploadRequestGroupId, UploadRequestStatus.ARCHIVED))
          .thenThrow(error);

      await _uploadRequestGroupDataSourceImpl
          .updateUploadRequestGroupState(uploadRequestGroup1, UploadRequestStatus.ARCHIVED).catchError((error) {
        expect(error, isA<UploadRequestGroupsNotFound>());
      });
    });
  });
}

void closeUploadRequestGroupTest() {
  group('close upload_request_group test', () {
    late MockLinShareHttpClient _linShareHttpClient;
    MockRemoteExceptionThrower _remoteExceptionThrower;
    late UploadRequestGroupDataSourceImpl _uploadRequestGroupDataSourceImpl;

    setUp(() {
      _linShareHttpClient = MockLinShareHttpClient();
      _remoteExceptionThrower = MockRemoteExceptionThrower();
      _uploadRequestGroupDataSourceImpl =
          UploadRequestGroupDataSourceImpl(_linShareHttpClient, _remoteExceptionThrower);
    });

    test('close upload_request_group should return success with valid data', () async {
      when(_linShareHttpClient.updateUploadRequestGroupStatus(uploadRequestGroup1.uploadRequestGroupId, UploadRequestStatus.CLOSED))
          .thenAnswer((_) async => uploadRequestGroupResponse1);

      final result = await _uploadRequestGroupDataSourceImpl
          .updateUploadRequestGroupState(uploadRequestGroup1, UploadRequestStatus.CLOSED);
      expect(result, uploadRequestGroupResponse1.toUploadRequestGroup());
    });

    test('close upload_request_group should throw exception when linShareHttpClient response error with 404', () async {
      final error = DioError(
          type: DioErrorType.response,
          response: Response(statusCode: 404, requestOptions: RequestOptions(path: '')),
          requestOptions: RequestOptions(path: ''));

      when(_linShareHttpClient.updateUploadRequestGroupStatus(uploadRequestGroup1.uploadRequestGroupId, UploadRequestStatus.CLOSED))
          .thenThrow(error);

      await _uploadRequestGroupDataSourceImpl
          .updateUploadRequestGroupState(uploadRequestGroup1, UploadRequestStatus.CLOSED).catchError((error) {
        expect(error, isA<UploadRequestGroupsNotFound>());
      });
    });
  });
}
