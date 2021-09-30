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

class SharedSpaceDocumentDatabaseManager implements LinShareDatabaseManager<WorkGroupDocument> {
  final DatabaseClient _databaseClient;

  SharedSpaceDocumentDatabaseManager(this._databaseClient);

  @override
  Future<bool> deleteData(String id, String localPath) async {
    await _databaseClient.deleteLocalFile(localPath);
    final res = await _databaseClient.deleteData(WorkGroupNodeTable.TABLE_NAME, WorkGroupNodeTable.NODE_ID, id);
    return res > 0 ? true : false;
  }

  @override
  Future<WorkGroupDocument?> getData(String id) async {
    final res = await _databaseClient.getData(WorkGroupNodeTable.TABLE_NAME, WorkGroupNodeTable.NODE_ID, id);
    return res.isNotEmpty ? WorkGroupNodeCache.fromJson(res.first).toWorkGroupDocument() : null;
  }

  @override
  Future<List<WorkGroupDocument>> getListData() async {
    final res = await _databaseClient.getListData(WorkGroupNodeTable.TABLE_NAME);
    return res.isNotEmpty
        ? res.map((mapObject) => WorkGroupNodeCache.fromJson(mapObject).toWorkGroupDocument()).toList()
        : [];
  }

  @override
  Future<bool> insertData(WorkGroupDocument newObject, String localPath) async {
    final res = await _databaseClient.insertData(
        WorkGroupNodeTable.TABLE_NAME,
        newObject.toWorkGroupNodeCache(localPath).toJson());
    return res > 0 ? true : false;
  }

  @override
  Future<bool> updateData(WorkGroupDocument newObject, String localPath) async {
    final res = await _databaseClient.updateData(
        WorkGroupNodeTable.TABLE_NAME,
        WorkGroupNodeTable.NODE_ID,
        newObject.workGroupNodeId.uuid,
        newObject.toWorkGroupNodeCache(localPath).toJson());
    return res > 0 ? true : false;
  }

  @override
  Future<bool> deleteAllData() async {
    final listWorkGroupDocument = await getListData();
    var failedFileCount = 0;
    listWorkGroupDocument.forEach((document) async {
      if(document.localPath != null) {
        final result = await deleteData(document.workGroupNodeId.uuid, document.localPath!);
        if(!result) {
          failedFileCount++;
        }
      }
    });

    final listSharedSpace = await getListSharedSpace();
    listSharedSpace.forEach((sharedSpace) async {
      final listWorkGroupNode = await getListWorkGroupCacheBySharedSpaceID(sharedSpace.sharedSpaceId);
      listWorkGroupNode.forEach((node) async {
        final result = await deleteWorkGroupNode(node.nodeId);
        if(!result) {
          failedFileCount++;
        }
      });
      final result = await deleteSharedSpace(sharedSpace.sharedSpaceId);
      if(!result) {
        failedFileCount++;
      }
    });

    return failedFileCount == 0;
  }

  Future<bool> insertSharedSpace(SharedSpaceNodeNested sharedSpaceNodeNested) async {
    final sharedSpaceExist = await _databaseClient.getData(
        SharedSpaceTable.TABLE_NAME,
        SharedSpaceTable.SHARED_SPACE_ID,
        sharedSpaceNodeNested.sharedSpaceId.uuid);

    if (sharedSpaceExist.isEmpty) {
      final res = await _databaseClient.insertData(SharedSpaceTable.TABLE_NAME, sharedSpaceNodeNested.toSharedSpaceDto().toJson());
      return res > 0 ? true : false;
    } else {
      return true;
    }
  }

  Future insertListTreeNode(SharedSpaceId sharedSpaceId, List<TreeNode> treeNodes) async {
    var listParentId = treeNodes.map<WorkGroupNodeId?>((node) => node.workGroupNodeId).toList();
    listParentId.insert(0, null);

    final listWorkGroupNodeCache = treeNodes.map((node) {
      final index = treeNodes.indexOf(node);
      return node.toWorkGroupNodeCache(sharedSpaceId, listParentId[index]);
    });

    final listWorkGroupNodeNotExist = await Future.wait(listWorkGroupNodeCache.map((node) async {
      final workGroupNodeExist = await _databaseClient.getData(
          WorkGroupNodeTable.TABLE_NAME,
          WorkGroupNodeTable.NODE_ID,
          node.nodeId.uuid);
      return workGroupNodeExist.isEmpty ? node : null;
    }).toList());

    final mapObjects = listWorkGroupNodeNotExist.map((node) {
      return node != null ? node.toJson() : null;
    }).toList();

    mapObjects.removeWhere((element) => element == null);

    await _databaseClient.insertMultipleData(WorkGroupNodeTable.TABLE_NAME, mapObjects);
  }

  Future<bool> deleteSharedSpace(SharedSpaceId sharedSpaceId) async {
    final res = await _databaseClient.deleteData(SharedSpaceTable.TABLE_NAME, SharedSpaceTable.SHARED_SPACE_ID, sharedSpaceId.uuid);
    return res > 0 ? true : false;
  }

  Future<List<WorkGroupNodeCache>> getListWorkGroupCacheBySharedSpaceID(SharedSpaceId sharedSpaceId) async {
    final res = await _databaseClient.getListDataWithCondition(
        WorkGroupNodeTable.TABLE_NAME,
        '${WorkGroupNodeTable.SHARED_SPACE_ID} = ?',
        [sharedSpaceId.uuid]
    );

    return res.isNotEmpty? res.map((mapObject) => WorkGroupNodeCache.fromJson(mapObject)).toList(): [];
  }

  Future<bool> deleteWorkGroupNode(WorkGroupNodeId parentNodeId) async {
    final res = await _databaseClient.deleteData(WorkGroupNodeTable.TABLE_NAME, WorkGroupNodeTable.NODE_ID, parentNodeId.uuid);
    return res > 0 ? true : false;
  }

  Future<List<WorkGroupNode>> getListWorkGroupCacheInSharedSpace(SharedSpaceId sharedSpaceId, WorkGroupNodeId? parentNodeId) async {
    final keyCondition = parentNodeId == null
        ? '${WorkGroupNodeTable.SHARED_SPACE_ID} = ? AND ${WorkGroupNodeTable.PARENT_NODE_ID} IS NULL'
        : '${WorkGroupNodeTable.SHARED_SPACE_ID} = ? AND ${WorkGroupNodeTable.PARENT_NODE_ID} = ?';

    final listValueCondition = parentNodeId == null ? [sharedSpaceId.uuid] : [sharedSpaceId.uuid, parentNodeId.uuid];
    final res = await _databaseClient.getListDataWithCondition(WorkGroupNodeTable.TABLE_NAME, keyCondition, listValueCondition);
    return res.isNotEmpty
      ? res.map((mapObject) => _convertToWorkGroupNode(mapObject)).toList()
      : <WorkGroupNode>[];
  }

  WorkGroupNode _convertToWorkGroupNode(Map<String, dynamic> mapObject) {
    if (mapObject[WorkGroupNodeTable.NODE_TYPE] == WorkGroupNodeType.FOLDER.value) {
      return WorkGroupNodeCache.fromJson(mapObject).toWorkGroupFolder();
    }
    return WorkGroupNodeCache.fromJson(mapObject).toWorkGroupDocument();
  }

  Future<List<SharedSpaceCache>> getListSharedSpace() async {
    final res = await _databaseClient.getListData(SharedSpaceTable.TABLE_NAME);
    return res.isNotEmpty
      ? res.map((mapObject) => SharedSpaceCache.fromJson(mapObject)).toList()
      : [];
  }
}