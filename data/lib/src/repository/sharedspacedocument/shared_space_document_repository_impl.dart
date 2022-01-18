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
//

import 'package:data/src/datasource/file_upload_datasource.dart';
import 'package:data/src/datasource/shared_space_document_datasource.dart';
import 'package:data/src/extensions/uri_extension.dart';
import 'package:data/src/local/model/data_source_type.dart';
import 'package:data/src/network/config/endpoint.dart';
import 'package:data/src/network/model/query/query_parameter.dart';
import 'package:data/src/network/model/request/create_shared_space_node_folder_request.dart';
import 'package:dio/src/cancel_token.dart';
import 'package:domain/domain.dart';
import 'package:domain/src/model/copy/copy_request.dart';

class SharedSpaceDocumentRepositoryImpl implements SharedSpaceDocumentRepository {
  final Map<DataSourceType, SharedSpaceDocumentDataSource> _sharedSpaceDocumentDataSources;
  final FileUploadDataSource _fileUploadDataSource;

  SharedSpaceDocumentRepositoryImpl(this._sharedSpaceDocumentDataSources, this._fileUploadDataSource);

  @override
  Future<UploadTaskId> uploadSharedSpaceDocument(
      FileInfo fileInfo,
      Token token,
      Uri baseUrl,
      APIVersionSupported apiVersion,
      SharedSpaceId sharedSpaceId,
      {WorkGroupNodeId? parentNodeId}) {
    final queryParameters = parentNodeId == null
        ? <QueryParameter>[]
        : [StringQueryParameter('parent', parentNodeId.uuid)];
    final url = baseUrl.withServicePath(
      Endpoint.sharedSpaces
        .withPathParameter('${sharedSpaceId.uuid}${Endpoint.nodes}')
        .withQueryParameters(queryParameters),
      apiVersion
    );

    return _fileUploadDataSource.upload(fileInfo, token, url);
  }

  @override
  Future<List<WorkGroupNode?>> getAllChildNodes(
      SharedSpaceId sharedSpaceId,
      {WorkGroupNodeId? parentNodeId}
  ) {
    return _sharedSpaceDocumentDataSources[DataSourceType.network]!.getAllChildNodes(sharedSpaceId, parentNodeId: parentNodeId);
  }

  @override
  Future<List<WorkGroupNode>> copyToSharedSpace(
    CopyRequest copyRequest,
    SharedSpaceId destinationSharedSpaceId,
    {WorkGroupNodeId? destinationParentNodeId}
  ) {
      return _sharedSpaceDocumentDataSources[DataSourceType.network]!.copyToSharedSpace(copyRequest, destinationSharedSpaceId, destinationParentNodeId: destinationParentNodeId);
  }

  @override
  Future<WorkGroupNode> removeSharedSpaceNode(SharedSpaceId sharedSpaceId, WorkGroupNodeId sharedSpaceNodeId) {
    return _sharedSpaceDocumentDataSources[DataSourceType.network]!.removeSharedSpaceNode(sharedSpaceId, sharedSpaceNodeId);
  }

  @override
  Future<List<DownloadTaskId>> downloadNodes(List<WorkGroupNode> workgroupNodes, Token token, Uri baseUrl, APIVersionSupported apiVersion) {
    return _sharedSpaceDocumentDataSources[DataSourceType.network]!.downloadNodes(workgroupNodes, token, baseUrl, apiVersion);
  }

  @override
  Future<String> downloadNodeIOS(WorkGroupNode workgroupNode, Token token, Uri baseUrl, CancelToken cancelToken) {
    return _sharedSpaceDocumentDataSources[DataSourceType.network]!.downloadNodeIOS(workgroupNode, token, baseUrl, cancelToken);
  }

  @override
  Future<WorkGroupFolder> createSharedSpaceFolder(
    SharedSpaceId sharedSpaceId,
    CreateSharedSpaceNodeFolderRequest createSharedSpaceNodeRequest
  ) {
    return _sharedSpaceDocumentDataSources[DataSourceType.network]!.createSharedSpaceFolder(sharedSpaceId, createSharedSpaceNodeRequest);
  }

  @override
  Future<String> downloadPreviewWorkGroupDocument(
    WorkGroupDocument workGroupDocument,
    DownloadPreviewType downloadPreviewType,
    Token token,
    Uri baseUrl,
    CancelToken cancelToken
  ) {
    return _sharedSpaceDocumentDataSources[DataSourceType.network]!.downloadPreviewWorkGroupDocument(workGroupDocument, downloadPreviewType, token, baseUrl, cancelToken);
  }

  @override
  Future<WorkGroupNode> renameSharedSpaceNode(SharedSpaceId sharedSpaceId, WorkGroupNodeId sharedSpaceNodeId, RenameWorkGroupNodeRequest renameWorkGroupNodeRequest) {
    return _sharedSpaceDocumentDataSources[DataSourceType.network]!.renameSharedSpaceNode(sharedSpaceId, sharedSpaceNodeId, renameWorkGroupNodeRequest);
  }

  @override
  Future<WorkGroupNode?> getWorkGroupNode(SharedSpaceId sharedSpaceId, WorkGroupNodeId workGroupNodeId, {bool hasTreePath = false}) {
    return _sharedSpaceDocumentDataSources[DataSourceType.network]!.getWorkGroupNode(sharedSpaceId, workGroupNodeId, hasTreePath: hasTreePath);
  }

  @override
  Future<String> downloadMakeOfflineSharedSpaceDocument(SharedSpaceId sharedSpaceId, WorkGroupNodeId workGroupNodeId, String workGroupNodeName, DownloadPreviewType downloadPreviewType, Token permanentToken, Uri baseUrl) {
    return _sharedSpaceDocumentDataSources[DataSourceType.network]!.downloadMakeOfflineSharedSpaceDocument(sharedSpaceId, workGroupNodeId, workGroupNodeName, downloadPreviewType, permanentToken, baseUrl);
  }

  @override
  Future<List<WorkGroupNode?>> doAdvancedSearch(SharedSpaceId sharedSpaceId, AdvancedSearchRequest searchRequest) {
    return _sharedSpaceDocumentDataSources[DataSourceType.network]!.doAdvancedSearch(sharedSpaceId, searchRequest);
  }

  @override
  Future<bool> makeAvailableOfflineSharedSpaceDocument(
      SharedSpaceNodeNested? drive,
      SharedSpaceNodeNested sharedSpaceNodeNested,
      WorkGroupDocument workGroupDocument,
      String localPath,
      {List<TreeNode>? treeNodes}
  ) {
    return _sharedSpaceDocumentDataSources[DataSourceType.local]!.makeAvailableOfflineSharedSpaceDocument(
        drive,
        sharedSpaceNodeNested,
        workGroupDocument,
        localPath,
        treeNodes: treeNodes);
  }

  @override
  Future<WorkGroupDocument?> getSharesSpaceDocumentOffline(WorkGroupNodeId workGroupNodeId) {
    return _sharedSpaceDocumentDataSources[DataSourceType.local]!.getSharesSpaceDocumentOffline(workGroupNodeId);
  }

  @override
  Future<bool> disableAvailableOfflineSharedSpaceDocument(
      SharedSpaceId? parentId,
      SharedSpaceId sharedSpaceId,
      WorkGroupNodeId? parentNodeId,
      WorkGroupNodeId workGroupNodeId,
      String localPath
  ) {
    return _sharedSpaceDocumentDataSources[DataSourceType.local]!.disableAvailableOfflineSharedSpaceDocument(
      parentId,
      sharedSpaceId,
      parentNodeId,
      workGroupNodeId,
      localPath);
  }

  @override
  Future<List<WorkGroupNode>> getAllSharedSpaceDocumentOffline(SharedSpaceId sharedSpaceId, WorkGroupNodeId? parentNodeId) {
    return _sharedSpaceDocumentDataSources[DataSourceType.local]!.getAllSharedSpaceDocumentOffline(sharedSpaceId, parentNodeId);
  }

  @override
  Future<bool> updateSharedSpaceDocumentOffline(WorkGroupDocument workGroupDocument, String localPath) {
    return _sharedSpaceDocumentDataSources[DataSourceType.local]!.updateSharedSpaceDocumentOffline(workGroupDocument, localPath);
  }

  @override
  Future<bool> deleteAllData() {
    return _sharedSpaceDocumentDataSources[DataSourceType.local]!.deleteAllData();
  }

  @override
  Future<WorkGroupNode> getRealSharedSpaceRootNode(SharedSpaceId sharedSpaceId, {bool hasTreePath = false}) {
    return _sharedSpaceDocumentDataSources[DataSourceType.network]!.getRealSharedSpaceRootNode(sharedSpaceId, hasTreePath: hasTreePath);
  }

  @override
  Future<WorkGroupNode> moveWorkgroupNode(MoveWorkGroupNodeRequest moveRequest, SharedSpaceId sourceSharedSpaceId) {
    return _sharedSpaceDocumentDataSources[DataSourceType.network]!.moveWorkgroupNode(moveRequest, sourceSharedSpaceId);
  }
}