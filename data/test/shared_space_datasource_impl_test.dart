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
import 'package:data/src/network/model/sharedspace/versioning_parameter_dto.dart';
import 'package:dio/dio.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:testshared/testshared.dart';

import 'fixture/mock/mock_fixtures.dart';

void main() {
  group('test shared spaces dataSource', () {
    late MockLinShareHttpClient _linShareHttpClient;
    MockRemoteExceptionThrower _remoteExceptionThrower;
    late SharedSpaceDataSourceImpl _sharedSpaceDataSourceImpl;

    setUp(() {
      _linShareHttpClient = MockLinShareHttpClient();
      _remoteExceptionThrower = MockRemoteExceptionThrower();
      _sharedSpaceDataSourceImpl = SharedSpaceDataSourceImpl(
        _linShareHttpClient,
        _remoteExceptionThrower
      );
    });

    test('getAllSharedSpaces should return success with valid data', () async {
      when(_linShareHttpClient.getSharedSpaces())
          .thenAnswer((_) async => [sharedSpaceResponse1, sharedSpaceResponse2]);

      final result = await _sharedSpaceDataSourceImpl.getSharedSpaces();
      expect(result, [sharedSpace1, sharedSpace2]);
    });

    test('getAllSharedSpaces should throw SharedSpacesNotFound when linShareHttpClient response error with 404', () async {
      final error = DioError(
          type: DioErrorType.response,
          response: Response(statusCode: 404, requestOptions: RequestOptions(path: '')), requestOptions: RequestOptions(path: '')
      );
      when(_linShareHttpClient.getSharedSpaces())
          .thenThrow(error);

      await _sharedSpaceDataSourceImpl.getSharedSpaces()
          .catchError((error) {
            expect(error, isA<SharedSpaceNotFound>());
          });
    });

    test('getAllSharedSpaces should throw SharedSpacesNotFound when linShareHttpClient response error with 403', () async {
      final error = DioError(
          type: DioErrorType.response,
          response: Response(statusCode: 403, requestOptions: RequestOptions(path: '')), requestOptions: RequestOptions(path: '')
      );
      when(_linShareHttpClient.getSharedSpaces())
          .thenThrow(error);

      await _sharedSpaceDataSourceImpl.getSharedSpaces()
          .catchError((error) {
            expect(error, isA<NotAuthorized>());
          });
    });

    test('delete shared space should return success with valid data', () async {
      when(_linShareHttpClient.deleteSharedSpace(sharedSpace1.sharedSpaceId))
          .thenAnswer((_) async => sharedSpaceResponse1);

      final result = await _sharedSpaceDataSourceImpl.deleteSharedSpace(sharedSpace1.sharedSpaceId);
      expect(result, sharedSpace1);
    });

    test('delete shared space should throw SharedSpacesNotFound when linShareHttpClient response error with 404', () async {
      final error = DioError(
          type: DioErrorType.response,
          response: Response(statusCode: 404, requestOptions: RequestOptions(path: '')), requestOptions: RequestOptions(path: '')
      );
      when(_linShareHttpClient.deleteSharedSpace(sharedSpace1.sharedSpaceId))
          .thenThrow(error);

      await _sharedSpaceDataSourceImpl.deleteSharedSpace(sharedSpace1.sharedSpaceId)
          .catchError((error) {
            expect(error, isA<SharedSpaceNotFound>());
          });
    });

    test('delete shared space should throw SharedSpacesNotFound when linShareHttpClient response error with 403', () async {
      final error = DioError(
          type: DioErrorType.response,
          response: Response(statusCode: 403, requestOptions: RequestOptions(path: '')), requestOptions: RequestOptions(path: '')
      );
      when(_linShareHttpClient.deleteSharedSpace(sharedSpace1.sharedSpaceId))
          .thenThrow(error);

      await _sharedSpaceDataSourceImpl.deleteSharedSpace(sharedSpace1.sharedSpaceId)
          .catchError((error) {
            expect(error, isA<NotAuthorized>());
          });
    });

    test('getSharedSpace should return success with valid data', () async {
      when(_linShareHttpClient.getSharedSpace(
        sharedSpaceId1
      )).thenAnswer((_) async => sharedSpaceResponse1);

      final result = await _sharedSpaceDataSourceImpl.getSharedSpace(sharedSpaceId1);
      expect(result, sharedSpace1);
    });

    test('getSharedSpace should return success with complete data', () async {
      when(_linShareHttpClient.getSharedSpace(
        sharedSpaceId1,
        membersParameter: MembersParameter.withMembers,
        rolesParameter: RolesParameter.withRole
      )).thenAnswer((_) async => sharedSpaceResponse1);

      final result = await _sharedSpaceDataSourceImpl.getSharedSpace(
        sharedSpaceId1,
        membersParameter: MembersParameter.withMembers,
        rolesParameter: RolesParameter.withRole
      );
      expect(result, sharedSpace1);
    });

    test('getSharedSpace should throw SharedSpacesNotFound when linShareHttpClient response error with 404', () async {
      final error = DioError(
          type: DioErrorType.response,
          response: Response(statusCode: 404, requestOptions: RequestOptions(path: '')), requestOptions: RequestOptions(path: '')
      );
      when(_linShareHttpClient.getSharedSpace(
        sharedSpaceId1
      )).thenThrow(error);

      await _sharedSpaceDataSourceImpl.getSharedSpace(sharedSpaceId1)
          .catchError((error) {
            expect(error, isA<SharedSpaceNotFound>());
          });
    });

    test('getSharedSpace should throw SharedSpacesNotFound when linShareHttpClient response error with 403', () async {
      final error = DioError(
          type: DioErrorType.response,
          response: Response(statusCode: 403, requestOptions: RequestOptions(path: '')), requestOptions: RequestOptions(path: '')
      );
      when(_linShareHttpClient.getSharedSpace(sharedSpaceId1))
          .thenThrow(error);

      await _sharedSpaceDataSourceImpl.getSharedSpace(sharedSpaceId1)
          .catchError((error) {
            expect(error, isA<NotAuthorized>());
          });
    });

    test('create shared space work group should return success with valid data', () async {
      when(_linShareHttpClient.createSharedSpaceWorkGroup(CreateWorkGroupBodyRequest(sharedSpace1.name, LinShareNodeType.WORK_GROUP)))
          .thenAnswer((_) async => sharedSpaceResponse1);

      final result = await _sharedSpaceDataSourceImpl.createSharedSpaceWorkGroup(CreateWorkGroupRequest(sharedSpace1.name, LinShareNodeType.WORK_GROUP));
      expect(result, sharedSpaceResponse1.toSharedSpaceNodeNested());
    });

    test('create shared space work group should throw SharedSpacesNotFound when linShareHttpClient response error with 404', () async {
      final error = DioError(
          type: DioErrorType.response,
          response: Response(statusCode: 404, requestOptions: RequestOptions(path: '')), requestOptions: RequestOptions(path: '')
      );
      when(_linShareHttpClient.createSharedSpaceWorkGroup(CreateWorkGroupBodyRequest(sharedSpace1.name, LinShareNodeType.WORK_GROUP)))
          .thenThrow(error);

      await _sharedSpaceDataSourceImpl.createSharedSpaceWorkGroup(CreateWorkGroupRequest(sharedSpace1.name, LinShareNodeType.WORK_GROUP))
          .catchError((error) {
            expect(error, isA<SharedSpaceNotFound>());
          });
    });

    test('create shared space should throw SharedSpacesNotFound when linShareHttpClient response error with 403', () async {
      final error = DioError(
          type: DioErrorType.response,
          response: Response(statusCode: 403, requestOptions: RequestOptions(path: '')), requestOptions: RequestOptions(path: '')
      );
      when(_linShareHttpClient.createSharedSpaceWorkGroup(CreateWorkGroupBodyRequest(sharedSpace1.name, LinShareNodeType.WORK_GROUP)))
          .thenThrow(error);

      await _sharedSpaceDataSourceImpl.createSharedSpaceWorkGroup(CreateWorkGroupRequest(sharedSpace1.name, LinShareNodeType.WORK_GROUP))
          .catchError((error) {
            expect(error, isA<NotAuthorized>());
          });
    });

    test('Rename WorkGroup Should Return Success Renamed', () async {
      when(_linShareHttpClient.renameWorkGroup(
        sharedSpace1.sharedSpaceId,
        RenameWorkGroupBodyRequest(sharedSpace1.name, VersioningParameterDto(sharedSpace1.versioningParameters.enable), sharedSpace1.nodeType)
      )).thenAnswer((_) async => sharedSpaceResponse1);

      final result = await _sharedSpaceDataSourceImpl.renameWorkGroup(
        sharedSpace1.sharedSpaceId,
        RenameWorkGroupRequest(sharedSpace1.name, sharedSpace1.versioningParameters, sharedSpace1.nodeType)
      );

      expect(result, sharedSpaceResponse1.toSharedSpaceNodeNested());
    });

    test('Rename WorkGroup Should Throw Exception When Renamed Failed', () async {
      final error = DioError(
        type: DioErrorType.RESPONSE,
        response: Response(statusCode: 404)
      );

      when(_linShareHttpClient.renameWorkGroup(
        sharedSpace1.sharedSpaceId,
        RenameWorkGroupBodyRequest(sharedSpace1.name, VersioningParameterDto(sharedSpace1.versioningParameters.enable), sharedSpace1.nodeType)
      )).thenThrow(error);

      await _sharedSpaceDataSourceImpl.renameWorkGroup(
        sharedSpace1.sharedSpaceId,
        RenameWorkGroupRequest(sharedSpace1.name, sharedSpace1.versioningParameters, sharedSpace1.nodeType)
      ).catchError((error) => expect(error, isA<SharedSpaceNotFound>()));
    });
  });
}