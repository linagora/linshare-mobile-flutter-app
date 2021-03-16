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

import 'dart:async';
import 'dart:io';

import 'package:data/data.dart';
import 'package:data/src/datasource/shared_space_document_datasource.dart';
import 'package:data/src/network/config/endpoint.dart';
import 'package:data/src/network/model/request/copy_body_request.dart';
import 'package:data/src/network/model/request/create_shared_space_node_folder_request.dart';
import 'package:data/src/network/model/sharedspacedocument/work_group_document_dto.dart';
import 'package:data/src/network/model/sharedspacedocument/work_group_folder_dto.dart';
import 'package:data/src/util/constant.dart';
import 'package:dio/dio.dart';
import 'package:domain/domain.dart';
import 'package:domain/src/model/sharedspace/shared_space_id.dart';
import 'package:domain/src/model/sharedspacedocument/work_group_node_id.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

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

  @override
  Future<List<DownloadTaskId>> downloadNodes(List<WorkGroupNode> workgroupNodes, Token token, Uri baseUrl) async {
    var externalStorageDirPath;
    if (Platform.isAndroid) {
        externalStorageDirPath = await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_DOWNLOADS);
    } else if (Platform.isIOS) {
        externalStorageDirPath = (await getApplicationDocumentsDirectory()).absolute.path;
    } else {
        throw DeviceNotSupportedException();
    }

    final taskIds = await Future.wait(workgroupNodes.map((node) async {
      await FlutterDownloader.enqueue(
          url: Endpoint.sharedSpaces
              .withPathParameter(node.sharedSpaceId.uuid)
              .withPathParameter('nodes')
              .downloadServicePath(node.workGroupNodeId.uuid)
              .generateDownloadUrl(baseUrl),
          savedDir: externalStorageDirPath,
          headers: {Constant.authorization: 'Bearer ${token.token}'},
          showNotification: true,
          openFileFromNotification: true);
        }));

    return taskIds.map((taskId) => DownloadTaskId(taskId));
  }

  @override
  Future<Uri> downloadNodeIOS(WorkGroupNode workgroupNode, Token token, Uri baseUrl, CancelToken cancelToken) async {
    final streamController = StreamController<Uri>();
    try {
      await Future.wait([
        _linShareHttpClient.downloadFile(
            Endpoint.sharedSpaces
                .withPathParameter(workgroupNode.sharedSpaceId.uuid)
                .withPathParameter('nodes')
                .withPathParameter(workgroupNode.workGroupNodeId.uuid)
                .withPathParameter(Endpoint.download)
                .generateEndpointPath(),
            cancelToken,
            token),
        getTemporaryDirectory()
      ]).then((values) {
        final fileStream = (values[0] as ResponseBody).stream;
        final tempFilePath = '${(values[1] as Directory).absolute.path}/${workgroupNode.name}';

        final file = File(tempFilePath);
        file.createSync(recursive: true);
        var randomAccessFile = file.openSync(mode: FileMode.write);
        StreamSubscription subscription;

        subscription = fileStream
            .takeWhile((_) => cancelToken == null || !cancelToken.isCancelled)
            .listen((data) {
          subscription.pause();
          randomAccessFile.writeFrom(data).then((_randomAccessFile) {
            randomAccessFile = _randomAccessFile;
            subscription.resume();
          }).catchError((error) async {
            await subscription.cancel();
            streamController.sink.addError(DownloadFileException(error.toString()));
            await streamController.close();
          });
        }, onDone: () async {
          await randomAccessFile.close();
          if (cancelToken.isCancelled) {
            streamController.sink.addError(CancelDownloadFileException(cancelToken.cancelError.message));
          } else {
            streamController.sink.add(Uri.parse(tempFilePath));
          }
          await streamController.close();
        }, onError: (error) async {
          await randomAccessFile.close();
          await file.delete();
          streamController.sink.addError(DownloadFileException(error.toString()));
          await streamController.close();
        });
      });
    } catch(exception) {
      _remoteExceptionThrower.throwRemoteException(exception, handler: (DioError error) {
        if (error.response.statusCode == 404) {
          throw DocumentNotFound();
        } else {
          throw UnknownError(error.response.statusMessage);
        }
      });
    }

    return streamController.stream.first;
  }

  @override
  Future<WorkGroupFolder> createSharedSpaceFolder(
    SharedSpaceId sharedSpaceId,
    CreateSharedSpaceNodeFolderRequest createSharedSpaceNodeRequest) {
    return Future.sync(() async {
      final workGroupNode = await _linShareHttpClient.createSharedSpaceNodeFolder(sharedSpaceId, createSharedSpaceNodeRequest);
      return workGroupNode.toWorkGroupFolder();
    }).catchError((error) {
      _remoteExceptionThrower.throwRemoteException(error, handler: (DioError error) {
        if (error.response.statusCode == 404) {
          throw SharedSpacesNotFound();
        } else if (error.response.statusCode == 403) {
          throw NotAuthorized();
        } else {
          throw UnknownError(error.response.statusMessage);
        }
      });
    });
  }
}
