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

import 'package:data/data.dart';
import 'package:data/src/datasource/shared_space_document_datasource.dart';
import 'package:data/src/network/model/sharedspacedocument/work_group_document_dto.dart';
import 'package:data/src/network/model/sharedspacedocument/work_group_folder_dto.dart';
import 'package:dio/dio.dart';
import 'package:domain/domain.dart';
import 'package:domain/src/model/sharedspace/shared_space_id.dart';
import 'package:domain/src/model/sharedspacedocument/work_group_node_id.dart';
import 'package:data/src/network/model/request/copy_body_request.dart';

class SharedSpaceDocumentDataSourceImpl implements SharedSpaceDocumentDataSource {
  final LinShareHttpClient _linShareHttpClient;
  final RemoteExceptionThrower _remoteExceptionThrower;

  SharedSpaceDocumentDataSourceImpl(
    this._linShareHttpClient,
    this._remoteExceptionThrower,
  );

  @override
  Future<List<WorkGroupNode>> getAllChildNodes(
      SharedSpaceId sharedSpaceId,
      {WorkGroupNodeId parentNodeId}
  ) {
    return Future.sync(() async {
      return (await _linShareHttpClient.getWorkGroupChildNodes(sharedSpaceId, parentId: parentNodeId))
          .map<WorkGroupNode>((workgroupNode) {
            if (workgroupNode is WorkGroupDocumentDto) return workgroupNode.toWorkGroupDocument();

            if (workgroupNode is WorkGroupNodeFolderDto) return workgroupNode.toWorkGroupFolder();

            return null;
          })
          .where((node) => node != null)
          .toList();
    }).catchError((error) {
      _remoteExceptionThrower.throwRemoteException(error, handler: (DioError error) {
        if (error.response.statusCode == 404) {
          throw GetChildNodesNotFoundException();
        } else if (error.response.statusCode == 403) {
          throw NotAuthorized();
        } else {
          throw UnknownError(error.response.statusMessage);
        }
      });
    });
  }

  @override
  Future<List<WorkGroupNode>> copyToSharedSpace(CopyRequest copyRequest, SharedSpaceId destinationSharedSpaceId, {WorkGroupNodeId destinationParentNodeId}) {
    return Future.sync(() async {
      return (await _linShareHttpClient.copyWorkGroupNodeToSharedSpaceDestination(
            copyRequest.toCopyBodyRequest(),
            destinationSharedSpaceId,
            destinationParentNodeId: destinationParentNodeId))
          .map<WorkGroupNode>((workgroupNode) {
            if (workgroupNode is WorkGroupDocumentDto) {
              return workgroupNode.toWorkGroupDocument();
            }
            if (workgroupNode is WorkGroupNodeFolderDto) {
              return workgroupNode.toWorkGroupFolder();
            }
            return null;
          })
          .where((node) => node != null)
          .toList();
    }).catchError((error) {
      _remoteExceptionThrower.throwRemoteException(error, handler: (DioError error) {
        if (error.response.statusCode == 404) {
          throw WorkGroupNodeNotFoundException();
        } else if (error.response.statusCode == 403) {
          throw NotAuthorized();
        } else {
          throw UnknownError(error.response.statusMessage);
        }
      });
    });
  }

  @override
  Future<WorkGroupNode> removeSharedSpaceNode(SharedSpaceId sharedSpaceId, WorkGroupNodeId sharedSpaceNodeId) {
    return Future.sync(() async {
      final workGroupNode = await _linShareHttpClient.removeSharedSpaceNode(sharedSpaceId, sharedSpaceNodeId);

      if (workGroupNode is WorkGroupDocumentDto) return workGroupNode.toWorkGroupDocument();
      if (workGroupNode is WorkGroupNodeFolderDto) return workGroupNode.toWorkGroupFolder();

      return null;
    }).catchError((error) {
      _remoteExceptionThrower.throwRemoteException(error, handler: (DioError error) {
        if (error.response.statusCode == 404) {
          throw WorkGroupNodeNotFoundException();
        } else if (error.response.statusCode == 403) {
          throw NotAuthorized();
        } else {
          throw UnknownError(error.response.statusMessage);
        }
      });
    });
  }
}
