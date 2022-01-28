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

import 'dart:io';

import 'package:data/src/local/config/database_config.dart';
import 'package:data/src/local/config/document_table.dart';
import 'package:data/src/local/config/received_share_table.dart';
import 'package:data/src/local/config/shared_space_table.dart';
import 'package:data/src/local/config/work_group_node_table.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseClient {

  Database? _database;
  Batch? _batch;

  Future<Database> get database async {
    return _database ?? await _initDatabase();
  }

  Future<Batch> get batch async {
    return _batch ?? (await database).batch();
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, DatabaseConfig.databaseName);
    return await openDatabase(
      path,
      version: DatabaseConfig.dbVersion4_0,
      onOpen: (db) {},
      onCreate: (db, version) async {
        final batch = db.batch();
        batch.execute(DocumentTable.CREATE);
        batch.execute(SharedSpaceTable.CREATE);
        batch.execute(WorkGroupNodeTable.CREATE);
        batch.execute(ReceivedShareTable.CREATE);
        await batch.commit();
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (newVersion > oldVersion && oldVersion < DatabaseConfig.dbVersion2_0) {
          final batch = db.batch();
          batch.execute(ReceivedShareTable.CREATE);
          batch.execute(SharedSpaceTable.ADD_NEW_COLUMN_DRIVE_ID);
          await batch.commit();
        }
      });
  }

  Future closeDatabase() async {
    final db = await database;
    _database = null;
    await db.close();
  }

  Future<int> insertData(String tableName, Map<String, dynamic> mapObject) async {
    final db = await database;
    return await db.insert(tableName, mapObject);
  }

  Future<int> deleteData(String tableName, String key, String value) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: '$key = ?',
      whereArgs: [value]);
  }

  Future<int> updateData(String tableName, String key, String value, Map<String, dynamic> mapObject) async {
    final db = await database;
    return await db.update(
      tableName,
      mapObject,
      where: '$key = ?',
      whereArgs: [value]);
  }

  Future<List<Map<String, dynamic>>> getData(String tableName, String key, String value) async {
    final db = await database;
    return await db.query(
      tableName,
      where: '$key = ?',
      whereArgs: [value]);
  }

  Future<List<Map<String, dynamic>>> getListData(String tableName) async {
    final db = await database;
    return await db.query(tableName);
  }

  Future deleteLocalFile(String localPath) async {
    final fileSaved = File(localPath);
    final fileExist = await fileSaved.exists();
    if (fileExist) {
      await fileSaved.delete();
    }
  }

  Future<List<Map<String, dynamic>>> getListDataWithCondition(String tableName, String condition, List<dynamic>? values) async {
    final db = await database;
    return await db.query(
        tableName,
        where: condition,
        whereArgs: values);
  }

  Future insertMultipleData(String tableName, List<Map<String, dynamic>?> mapObjects) async {
    final batchInsert = await batch;
    mapObjects.forEach((element) {
      if (element != null) {
        batchInsert.insert(tableName, element);
      }
    });
    await batchInsert.commit(noResult: true);
  }

  Future<int> clearAllData(String tableName) async {
    final db = await database;
    return await db.delete(tableName);
  }

  Future deleteListFile(List<String> listLocalPath) async {
    for (var path in listLocalPath) {
      final fileSaved = File(path);
      final fileExist = await fileSaved.exists();
      if (fileExist) {
        await fileSaved.delete();
      }
    }
  }
}