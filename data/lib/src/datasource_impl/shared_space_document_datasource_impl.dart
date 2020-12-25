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

import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:data/data.dart';
import 'package:data/src/datasource/shared_space_document_datasource.dart';
import 'package:data/src/network/config/endpoint.dart';
import 'package:data/src/extensions/uri_extension.dart';
import 'package:data/src/network/model/query/query_parameter.dart';
import 'package:data/src/network/model/sharedspacedocument/work_group_document_dto.dart';
import 'package:data/src/network/model/sharedspacedocument/work_group_folder_dto.dart';
import 'package:data/src/util/constant.dart';
import 'package:dio/dio.dart';
import 'package:domain/domain.dart';
import 'package:domain/src/model/authentication/token.dart';
import 'package:domain/src/model/file_info.dart';
import 'package:domain/src/model/sharedspace/shared_space_id.dart';
import 'package:domain/src/model/sharedspacedocument/work_group_node_id.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:rxdart/rxdart.dart';

class SharedSpaceDocumentDataSourceImpl implements SharedSpaceDocumentDataSource {
  final FlutterUploader _uploader;
  final LinShareHttpClient _linShareHttpClient;
  final RemoteExceptionThrower _remoteExceptionThrower;

  SharedSpaceDocumentDataSourceImpl(
    this._uploader,
    this._linShareHttpClient,
    this._remoteExceptionThrower,
  );

  @override
  Future<FileUploadState> uploadSharedSpaceDocument(
      FileInfo fileInfo,
      Token token,
      Uri baseUrl,
      SharedSpaceId sharedSpaceId,
      {WorkGroupNodeId parentNodeId}) async {
    final file = File(fileInfo.filePath + fileInfo.fileName);
    final queryParameters = parentNodeId == null
        ? <QueryParameter>[]
        : [StringQueryParameter('parent', parentNodeId.uuid)];
    final taskId = await _uploader.enqueue(
        url: baseUrl.withServicePath(Endpoint.sharedSpaces
            .withPathParameter('${sharedSpaceId.uuid}${Endpoint.nodes}')
            .withQueryParameters(queryParameters)),
        files: [
          FileItem(savedDir: fileInfo.filePath, filename: fileInfo.fileName)
        ],
        headers: {
          Constant.authorization: 'Bearer ${token.token}',
          Constant.accept: 'application/json',
        },
        data: {
    Constant.fileSizeDataForm: (await file.length()).toString()
    });

    final mergedStream = Rx.merge([_uploader.result, _uploader.progress]).map<Either<Failure, Success>>((event) {
      if (event is UploadTaskResponse) {
        if (event.statusCode == 200) {
          final response = WorkGroupDocumentDto.fromJson(json.decode(event.response));
          return Right(WorkGroupDocumentUploadSuccess(response.toWorkGroupDocument()));
        }
        return Left(WorkGroupDocumentUploadFailure(fileInfo, Exception('Response code failed: ${event.response}')));
      } else if (event is UploadTaskProgress) {
        return Right(UploadingProgress(event.progress, fileInfo));
      } else {
        return Left(WorkGroupDocumentUploadFailure(fileInfo, Exception('Something wrong with response: ${event.toString()}')));
      }
    });

    return FileUploadState(mergedStream, UploadTaskId(taskId));
  }

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
}
