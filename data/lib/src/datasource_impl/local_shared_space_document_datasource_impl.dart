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

import 'dart:async';

import 'package:data/data.dart';
import 'package:data/src/datasource/shared_space_document_datasource.dart';
import 'package:data/src/local/shared_space_document_database_manager.dart';
import 'package:dio/src/cancel_token.dart';
import 'package:domain/domain.dart';

class LocalSharedSpaceDocumentDataSourceImpl implements SharedSpaceDocumentDataSource {
  final SharedSpaceDocumentDatabaseManager _sharedSpaceDocumentDatabaseManager;

  LocalSharedSpaceDocumentDataSourceImpl(this._sharedSpaceDocumentDatabaseManager);

  @override
  Future<bool> makeAvailableOfflineSharedSpaceDocument(SharedSpaceNodeNested? sharedSpaceNodeNested, WorkGroupDocument workGroupDocument, String localPath, {List<TreeNode>? treeNodes}) {
    return Future.sync(() async {
      if (localPath.isEmpty) {
        return false;
      }
      await Future.wait([
        if (sharedSpaceNodeNested != null) _sharedSpaceDocumentDatabaseManager.insertSharedSpace(sharedSpaceNodeNested),
        if (sharedSpaceNodeNested != null && treeNodes != null && treeNodes.isNotEmpty) _sharedSpaceDocumentDatabaseManager.insertListTreeNode(sharedSpaceNodeNested.sharedSpaceId, treeNodes),
      ]);
      return await _sharedSpaceDocumentDatabaseManager.insertData(workGroupDocument, localPath);
    }).catchError((error) {
      if (error is SQLiteDatabaseException) {
        throw SQLiteDatabaseException();
      } else {
        throw LocalUnknownError(error);
      }
    });
  }

  @override
  Future<WorkGroupDocument?> getSharesSpaceDocumentOffline(WorkGroupNodeId workGroupNodeId) {
    return Future.sync(() async {
      return await _sharedSpaceDocumentDatabaseManager.getData(workGroupNodeId.uuid);
    }).catchError((error) {
      if (error is SQLiteDatabaseException) {
        throw SQLiteDatabaseException();
      } else {
        throw LocalUnknownError(error);
      }
    });
  }

  @override
  Future<bool> disableAvailableOfflineSharedSpaceDocument(SharedSpaceId sharedSpaceId, WorkGroupNodeId? parentNodeId, WorkGroupNodeId workGroupNodeId, String localPath) {
    return Future.sync(() async {
      final result = await _sharedSpaceDocumentDatabaseManager.deleteData(workGroupNodeId.uuid, localPath);
      final listNodeBySharedSpaceId = await _sharedSpaceDocumentDatabaseManager.getListWorkGroupCacheBySharedSpaceID(sharedSpaceId);
      if (listNodeBySharedSpaceId.isEmpty) {
        await _sharedSpaceDocumentDatabaseManager.deleteSharedSpace(sharedSpaceId);
      }
      return result;
    }).catchError((error) {
      throw LocalUnknownError(error);
    });
  }

  @override
  Future<List<WorkGroupNode>> getAllSharedSpaceDocumentOffline(SharedSpaceId sharedSpaceId, WorkGroupNodeId? parentNodeId) {
    return Future.sync(() async {
      return await _sharedSpaceDocumentDatabaseManager.getListWorkGroupCacheInSharedSpace(sharedSpaceId, parentNodeId);
    }).catchError((error) {
      if (error is SQLiteDatabaseException) {
        throw SQLiteDatabaseException();
      } else {
        throw LocalUnknownError(error);
      }
    });
  }

  @override
  Future<bool> updateSharedSpaceDocumentOffline(WorkGroupDocument workGroupDocument, String localPath) {
    return Future.sync(() async {
      return await _sharedSpaceDocumentDatabaseManager.updateData(workGroupDocument, localPath);
    }).catchError((error) {
      if (error is SQLiteDatabaseException) {
        throw SQLiteDatabaseException();
      } else {
        throw LocalUnknownError(error);
      }
    });
  }

  @override
  Future<bool> deleteAllData() {
    return Future.sync(() async {
      return await _sharedSpaceDocumentDatabaseManager.deleteAllData();
    }).catchError((error) {
      if (error is SQLiteDatabaseException) {
        throw SQLiteDatabaseException();
      } else {
        throw LocalUnknownError(error);
      }
    });
  }

  @override
  Future<List<WorkGroupNode>> copyToSharedSpace(CopyRequest copyRequest, SharedSpaceId destinationSharedSpaceId, {WorkGroupNodeId? destinationParentNodeId}) {
    throw UnimplementedError();
  }

  @override
  Future<WorkGroupFolder> createSharedSpaceFolder(SharedSpaceId sharedSpaceId, CreateSharedSpaceNodeFolderRequest createSharedSpaceNodeRequest) {
    throw UnimplementedError();
  }

  @override
  Future<String> downloadMakeOfflineSharedSpaceDocument(SharedSpaceId sharedSpaceId, WorkGroupNodeId workGroupNodeId, String workGroupNodeName, DownloadPreviewType downloadPreviewType, Token permanentToken, Uri baseUrl) {
    throw UnimplementedError();
  }

  @override
  Future<String> downloadNodeIOS(WorkGroupNode workgroupNode, Token token, Uri baseUrl, CancelToken cancelToken) {
    throw UnimplementedError();
  }

  @override
  Future<List<DownloadTaskId>> downloadNodes(List<WorkGroupNode> workgroupNodes, Token token, Uri baseUrl) {
    throw UnimplementedError();
  }

  @override
  Future<String> downloadPreviewWorkGroupDocument(WorkGroupDocument workGroupDocument, DownloadPreviewType downloadPreviewType, Token token, Uri baseUrl, CancelToken cancelToken) {
    throw UnimplementedError();
  }

  @override
  Future<List<WorkGroupNode>> getAllChildNodes(SharedSpaceId sharedSpaceId, {WorkGroupNodeId? parentNodeId}) {
    throw UnimplementedError();
  }

  @override
  Future<WorkGroupNode?> getWorkGroupNode(SharedSpaceId? sharedSpaceId, WorkGroupNodeId workGroupNodeId, {bool hasTreePath = false}) {
    throw UnimplementedError();
  }

  @override
  Future<WorkGroupNode> removeSharedSpaceNode(SharedSpaceId sharedSpaceId, WorkGroupNodeId sharedSpaceNodeId) {
    throw UnimplementedError();
  }

  @override
  Future<WorkGroupNode> renameSharedSpaceNode(SharedSpaceId sharedSpaceId, WorkGroupNodeId sharedSpaceNodeId, RenameWorkGroupNodeRequest renameRequest) {
    throw UnimplementedError();
  }

  @override
  Future<WorkGroupNode> getRealSharedSpaceRootNode(SharedSpaceId sharedSpaceId, {bool hasTreePath = false}) {
    throw UnimplementedError();
  }

  @override
  Future<WorkGroupNode> moveWorkgroupNode(MoveWorkGroupNodeRequest moveRequest, SharedSpaceId sourceSharedSpaceId) {
    throw UnimplementedError();
  }

  @override
  Future<List<WorkGroupNode?>> advanceSearchWorkgroupNode(SharedSpaceId sharedSpaceId, AdvanceSearchRequest searchRequest) {
    throw UnimplementedError();
  }
}