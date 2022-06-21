/*
 * LinShare is an open source filesharing software, part of the LinPKI software
 * suite, developed by Linagora.
 *
 * Copyright (C) 2022 LINAGORA
 *
 * This program is free software: you can redistribute it and/or modify it under the
 * terms of the GNU Affero General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version,
 * provided you comply with the Additional Terms applicable for LinShare software by
 * Linagora pursuant to Section 7 of the GNU Affero General Public License,
 * subsections (b), (c), and (e), pursuant to which you must notably (i) retain the
 * display in the interface of the “LinShare™” trademark/logo, the "Libre & Free" mention,
 * the words “You are using the Free and Open Source version of LinShare™, powered by
 * Linagora © 2009–2021. Contribute to Linshare R&D by subscribing to an Enterprise
 * offer!”. You must also retain the latter notice in all asynchronous messages such as
 * e-mails sent with the Program, (ii) retain all hypertext links between LinShare and
 * http://www.linshare.org, between linagora.com and Linagora, and (iii) refrain from
 * infringing Linagora intellectual property rights over its trademarks and commercial
 * brands. Other Additional Terms apply, see
 * <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf>
 * for more details.
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for
 * more details.
 * You should have received a copy of the GNU Affero General Public License and its
 * applicable Additional Terms for LinShare along with this program. If not, see
 * <http://www.gnu.org/licenses/> for the GNU Affero General Public License version
 *  3 and <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf> for
 *  the Additional Terms applicable to LinShare software.
 */

import 'dart:io';

import 'package:data/src/local/hive/app_mode_cache_client.dart';
import 'package:data/src/local/hive/config/hive_cache_config.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppModeCacheClient _appModeCacheClient;
  late String _ownServerBaseUrl;
  late String _saasServerBaseUrl;

  setUpAll(() {
    HiveCacheConfig().setUp(cachePath: Directory.current.path);
  });

  setUp(() {
    _appModeCacheClient = AppModeCacheClient();
    _ownServerBaseUrl = Uri.parse('http://ownServer.domain.com').toString();
    _saasServerBaseUrl = Uri.parse('http://saas.domain.org').toString();
  });

  group('[delete]', () {
    test('cache should delete item successfully when cache empty', () async {
      await _appModeCacheClient.deleteItem(_ownServerBaseUrl);

      final remainingItems = await _appModeCacheClient.getAll();

      expect(remainingItems.length, equals(0));
    });

    test('cache should not delete item which not in the list', () async {
      await _appModeCacheClient.insertItem(
          _ownServerBaseUrl,
          AppMode.OwnServer);

      await _appModeCacheClient.insertItem(
          _saasServerBaseUrl,
          AppMode.SaaS);

      await _appModeCacheClient.deleteItem(Uri.parse('http://domain.com').toString());

      final remainingItems = await _appModeCacheClient.getAll();

      expect(remainingItems.length, equals(2));
      expect(
          remainingItems,
          containsAll({
            AppMode.OwnServer,
            AppMode.SaaS
          }));
    });

    test('cache should delete item successfully', () async {
      await _appModeCacheClient.insertItem(
          _ownServerBaseUrl,
          AppMode.OwnServer);

      await _appModeCacheClient.insertItem(
          _saasServerBaseUrl,
          AppMode.SaaS);

      await _appModeCacheClient.deleteItem(_saasServerBaseUrl);

      final remainingItems = await _appModeCacheClient.getAll();

      expect(remainingItems.length, equals(1));
      expect(remainingItems.first, equals(AppMode.OwnServer));
    });

    test('cache should not delete item twice', () async {
      await _appModeCacheClient.insertItem(
        _ownServerBaseUrl,
        AppMode.OwnServer);

      await _appModeCacheClient.insertItem(
        _saasServerBaseUrl,
        AppMode.SaaS);

      await _appModeCacheClient.deleteItem(_ownServerBaseUrl);
      await _appModeCacheClient.deleteItem(_ownServerBaseUrl);

      final remainingItems = await _appModeCacheClient.getAll();

      expect(remainingItems.length, equals(1));
      expect(remainingItems.first, equals(AppMode.SaaS));
    });

    test('cache should empty after clearAll', () async {
      await _appModeCacheClient.insertItem(
        _ownServerBaseUrl,
        AppMode.OwnServer);

      await _appModeCacheClient.insertItem(
        _saasServerBaseUrl,
        AppMode.SaaS);

      await _appModeCacheClient.clearAllData();

      final remainingItems = await _appModeCacheClient.getAll();

      expect(remainingItems.length, equals(0));
    });
  });

  group('[add]', () {
    test('cache should add item when cache empty', () async {
      await _appModeCacheClient.insertItem(
          _ownServerBaseUrl,
          AppMode.OwnServer);

      final remainingItems = await _appModeCacheClient.getAll();

      expect(remainingItems.length, equals(1));
      expect(remainingItems.first, equals(AppMode.OwnServer));
    });

    test('cache should add item when cache not empty', () async {
      await _appModeCacheClient.insertItem(
        _ownServerBaseUrl,
        AppMode.OwnServer);

      await _appModeCacheClient.insertItem(
        _saasServerBaseUrl,
        AppMode.SaaS);

      final remainingItems = await _appModeCacheClient.getAll();

      expect(remainingItems.length, equals(2));
      expect(
        remainingItems,
        containsAll({
          AppMode.OwnServer,
          AppMode.SaaS
        }));
    });

    test('cache should not add item twice', () async {
      await _appModeCacheClient.insertItem(
        _ownServerBaseUrl,
        AppMode.OwnServer);

      await _appModeCacheClient.insertItem(
        _ownServerBaseUrl,
        AppMode.OwnServer);

      final remainingItems = await _appModeCacheClient.getAll();

      expect(remainingItems.length, equals(1));
      expect(
        remainingItems,
        containsAll({
          AppMode.OwnServer
        }));
    });
  });

  group('[getItem]', () {
    test('getItem should return null when cache is empty', () async {
      final item = await _appModeCacheClient.getItem(_ownServerBaseUrl);
      expect(item, equals(null));
    });

    test('getItem should return item when cache hit', () async {
      await _appModeCacheClient.insertItem(
        _saasServerBaseUrl,
        AppMode.OwnServer);

      final item = await _appModeCacheClient.getItem(_saasServerBaseUrl);

      expect(item, equals(AppMode.OwnServer));
    });
  });

  tearDown(() async {
    await _appModeCacheClient.deleteBox();
  });
}