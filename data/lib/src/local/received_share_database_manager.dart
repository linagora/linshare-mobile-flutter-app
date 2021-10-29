/*
 * LinShare is an open source filesharing software, part of the LinPKI software
 * suite, developed by Linagora.
 *
 * Copyright (C) 2021 LINAGORA
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

import 'package:data/data.dart';
import 'package:data/src/extensions/received_share_extension.dart';
import 'package:data/src/local/config/received_share_table.dart';
import 'package:domain/domain.dart';

import 'model/received_share_cache.dart';

class ReceivedShareDatabaseManager extends LinShareDatabaseManager<ReceivedShare> {
  final DatabaseClient _databaseClient;

  ReceivedShareDatabaseManager(this._databaseClient);

  @override
  Future<bool> deleteAllData() async {
    final receivedShareCache = await getListData();
    var failedFileCount = 0;

    for (final received in receivedShareCache) {
      if(received.localPath != null) {
        final result = await deleteData(received.shareId.uuid, received.localPath!);
        if(!result) {
          failedFileCount++;
        }
      }
    }
    return failedFileCount == 0;
  }

  @override
  Future<bool> deleteData(String id, String localPath) async {
    await _databaseClient.deleteLocalFile(localPath);
    final res = await _databaseClient.deleteData(ReceivedShareTable.TABLE_NAME, ReceivedShareTable.SHARE_ID, id);
    return res > 0 ? true : false;
  }

  @override
  Future<ReceivedShare?> getData(String id) async {
    final res = await _databaseClient.getData(ReceivedShareTable.TABLE_NAME, ReceivedShareTable.SHARE_ID, id);
    return res.isNotEmpty ? ReceivedShareCache.fromJson(res.first).toReceivedShare() : null;
  }

  @override
  Future<List<ReceivedShare>> getListData() async {
    final res = await _databaseClient.getListData(ReceivedShareTable.TABLE_NAME);
    return res.isNotEmpty
      ? res.map((mapObject) => ReceivedShareCache.fromJson(mapObject).toReceivedShare()).toList()
      : [];
  }

  @override
  Future<bool> insertData(ReceivedShare receivedShare, String localPath) async {
    final receivedOffline = receivedShare.toSyncOffline(localPath: localPath);
    final res = await _databaseClient.insertData(ReceivedShareTable.TABLE_NAME, receivedOffline.toReceivedShareCache().toJson());
    return res > 0 ? true : false;
  }

  @override
  Future<bool> updateData(ReceivedShare receivedShare, String localPath) async {
    final offlineReceivedShare = receivedShare.toSyncOffline(localPath: localPath);
    final res = await _databaseClient.updateData(
        ReceivedShareTable.TABLE_NAME,
        ReceivedShareTable.SHARE_ID,
        offlineReceivedShare.shareId.uuid,
        offlineReceivedShare.toReceivedShareCache().toJson());
    return res > 0 ? true : false;
  }

}