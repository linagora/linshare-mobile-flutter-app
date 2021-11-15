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
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:testshared/testshared.dart';

import 'fixture/mock/mock_fixtures.dart';

void main() {
  group('test local shared spaces documents datasource impl', () {
    late MockSharedSpaceDocumentDatabaseManager _sharedSpaceDocumentDatabaseManager;
    late LocalSharedSpaceDocumentDataSourceImpl _localSharedSpaceDocumentDataSourceImpl;

    setUp(() {
      _sharedSpaceDocumentDatabaseManager = MockSharedSpaceDocumentDatabaseManager();
      _localSharedSpaceDocumentDataSourceImpl = LocalSharedSpaceDocumentDataSourceImpl(_sharedSpaceDocumentDatabaseManager);
    });

    test('makeAvailableOfflineSharedSpaceDocument Should Return Success TRUE', () async {
      when(_sharedSpaceDocumentDatabaseManager.insertSharedSpace(sharedSpaceNodeNested))
          .thenAnswer((_) async => true);
      when(_sharedSpaceDocumentDatabaseManager.insertData(workGroupDocument, '123'))
          .thenAnswer((_) async => true);

      final result = await _localSharedSpaceDocumentDataSourceImpl.makeAvailableOfflineSharedSpaceDocument(
        null,
        sharedSpaceNodeNested,
        workGroupDocument,
        '123'
      );

      expect(result, true);
    });

    test('makeAvailableOfflineSharedSpaceDocument Should Throw Exception When insertData Failed', () async {
      final error = SQLiteDatabaseException();

      when(_sharedSpaceDocumentDatabaseManager.insertSharedSpace(sharedSpaceNodeNested))
          .thenAnswer((_) async => true);
      when(_sharedSpaceDocumentDatabaseManager.insertData(workGroupDocument, '123'))
          .thenThrow(error);

      await _localSharedSpaceDocumentDataSourceImpl.makeAvailableOfflineSharedSpaceDocument(
          null,
          sharedSpaceNodeNested,
          workGroupDocument,
          '123'
      ).catchError((error) => expect(error, isA<SQLiteDatabaseException>()));
    });

    test('getSharesSpaceDocumentOffline Should Return Success Node', () async {
      when(_sharedSpaceDocumentDatabaseManager.getData(workGroupDocument.workGroupNodeId.uuid))
          .thenAnswer((_) async => workGroupDocument);

      final result = await _localSharedSpaceDocumentDataSourceImpl.getSharesSpaceDocumentOffline(
          workGroupDocument.workGroupNodeId
      );

      expect(result, workGroupDocument);
    });

    test('getSharesSpaceDocumentOffline Should Throw Exception When getData Failed', () async {
      final error = SQLiteDatabaseException();

      when(_sharedSpaceDocumentDatabaseManager.getData(workGroupDocument.workGroupNodeId.uuid))
          .thenThrow(error);

      await _localSharedSpaceDocumentDataSourceImpl.getSharesSpaceDocumentOffline(
          workGroupDocument.workGroupNodeId
      ).catchError((error) => expect(error, isA<SQLiteDatabaseException>()));
    });

    test('getAllSharedSpaceDocumentOffline Should Return Success List Node', () async {
      when(_sharedSpaceDocumentDatabaseManager.getAllSharedSpaceDocumentOffline(
          sharedSpaceIdOffline1,
          workGroupNodeIdOffline1,
      )).thenAnswer((_) async => [workGroupNode1, workGroupNode2]);

      final result = await _localSharedSpaceDocumentDataSourceImpl.getAllSharedSpaceDocumentOffline(
        sharedSpaceIdOffline1,
        workGroupNodeIdOffline1,
      );

      expect(result, [workGroupNode1, workGroupNode2]);
    });

    test('getAllSharedSpaceDocumentOffline Should Throw Exception When getListWorkGroupCacheInSharedSpace Failed', () async {
      final error = SQLiteDatabaseException();

      when(_sharedSpaceDocumentDatabaseManager.getAllSharedSpaceDocumentOffline(
        sharedSpaceIdOffline1,
        workGroupNodeIdOffline1
      )).thenThrow(error);

      await _localSharedSpaceDocumentDataSourceImpl.getAllSharedSpaceDocumentOffline(
        sharedSpaceIdOffline1,
        workGroupNodeIdOffline1
      ).catchError((error) {
        expect(error, isA<SQLiteDatabaseException>());
      });
    });

    test('deleteAllData Should Return Success TRUE', () async {
      when(_sharedSpaceDocumentDatabaseManager.deleteAllData())
          .thenAnswer((_) async => true);
      final result = await _localSharedSpaceDocumentDataSourceImpl.deleteAllData();

      expect(result, true);
    });

    test('deleteAllData Should Throw Exception When deleting data failed', () async {
      final error = SQLiteDatabaseException();

      when(_sharedSpaceDocumentDatabaseManager.deleteAllData()).thenThrow(error);

      await _localSharedSpaceDocumentDataSourceImpl.deleteAllData().catchError((error) {
        expect(error, isA<SQLiteDatabaseException>());
      });
    });

  });
}