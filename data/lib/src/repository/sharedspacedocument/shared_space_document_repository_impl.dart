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
import 'package:data/src/network/config/endpoint.dart';
import 'package:data/src/network/model/query/query_parameter.dart';
import 'package:data/src/network/model/request/create_shared_space_node_folder_request.dart';
import 'package:dio/src/cancel_token.dart';
import 'package:domain/domain.dart';
import 'package:domain/src/model/copy/copy_request.dart';

class SharedSpaceDocumentRepositoryImpl implements SharedSpaceDocumentRepository {
  final SharedSpaceDocumentDataSource _sharedSpaceDocumentDataSource;
  final FileUploadDataSource _fileUploadDataSource;

  SharedSpaceDocumentRepositoryImpl(this._sharedSpaceDocumentDataSource, this._fileUploadDataSource);

  @override
  Future<UploadTaskId> uploadSharedSpaceDocument(
      FileInfo fileInfo,
      Token token,
      Uri baseUrl,
      SharedSpaceId sharedSpaceId,
      {WorkGroupNodeId parentNodeId}) {
    final queryParameters = parentNodeId == null
        ? <QueryParameter>[]
        : [StringQueryParameter('parent', parentNodeId.uuid)];
    final url = baseUrl.withServicePath(Endpoint.sharedSpaces
        .withPathParameter('${sharedSpaceId.uuid}${Endpoint.nodes}')
        .withQueryParameters(queryParameters));

    return _fileUploadDataSource.upload(fileInfo, token, url);
  }

  @override
  Future<List<WorkGroupNode>> getAllChildNodes(
      SharedSpaceId sharedSpaceId,
      {WorkGroupNodeId parentNodeId}
  ) {
    return _sharedSpaceDocumentDataSource.getAllChildNodes(sharedSpaceId, parentNodeId: parentNodeId);
  }

  @override
  Future<List<WorkGroupNode>> copyToSharedSpace(
    CopyRequest copyRequest,
    SharedSpaceId destinationSharedSpaceId,
    {WorkGroupNodeId destinationParentNodeId}) {
      return _sharedSpaceDocumentDataSource.copyToSharedSpace(copyRequest, destinationSharedSpaceId, destinationParentNodeId: destinationParentNodeId);
  }

  @override
  Future<WorkGroupNode> removeSharedSpaceNode(SharedSpaceId sharedSpaceId, WorkGroupNodeId sharedSpaceNodeId) {
    return _sharedSpaceDocumentDataSource.removeSharedSpaceNode(sharedSpaceId, sharedSpaceNodeId);
  }

  @override
  Future<List<DownloadTaskId>> downloadNodes(List<WorkGroupNode> workgroupNodes, Token token, Uri baseUrl) {
    return _sharedSpaceDocumentDataSource.downloadNodes(workgroupNodes, token, baseUrl);
  }

  @override
  Future<Uri> downloadNodeIOS(WorkGroupNode workgroupNode, Token token, Uri baseUrl, CancelToken cancelToken) {
    return _sharedSpaceDocumentDataSource.downloadNodeIOS(workgroupNode, token, baseUrl, cancelToken);
  }

  @override
  Future<WorkGroupFolder> createSharedSpaceFolder(
    SharedSpaceId sharedSpaceId,
    CreateSharedSpaceNodeFolderRequest createSharedSpaceNodeRequest
  ) {
    return _sharedSpaceDocumentDataSource.createSharedSpaceFolder(sharedSpaceId, createSharedSpaceNodeRequest);
  }

  @override
  Future<Uri> downloadPreviewWorkGroupDocument(
    WorkGroupDocument workGroupDocument,
    DownloadPreviewType downloadPreviewType,
    Token token,
    Uri baseUrl,
    CancelToken cancelToken
  ) {
    return _sharedSpaceDocumentDataSource.downloadPreviewWorkGroupDocument(workGroupDocument, downloadPreviewType, token, baseUrl, cancelToken);
  }

  @override
  Future<WorkGroupNode> renameSharedSpaceNode(SharedSpaceId sharedSpaceId, WorkGroupNodeId sharedSpaceNodeId, RenameWorkGroupNodeRequest renameWorkGroupNodeRequest) {
    return _sharedSpaceDocumentDataSource.renameSharedSpaceNode(sharedSpaceId, sharedSpaceNodeId, renameWorkGroupNodeRequest);
  }

  @override
  Future<WorkGroupNode> getWorkGroupNode(SharedSpaceId sharedSpaceId, WorkGroupNodeId workGroupNodeId) {
    return _sharedSpaceDocumentDataSource.getWorkGroupNode(sharedSpaceId, workGroupNodeId);
  }
}