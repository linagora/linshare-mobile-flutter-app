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

import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:async/async.dart';
import 'package:dartz/dartz.dart';
import 'package:data/src/network/config/endpoint.dart';
import 'package:data/src/network/dio_client.dart';
import 'package:data/src/network/model/async_task/async_task_response.dart';
import 'package:data/src/network/model/query/query_parameter.dart';
import 'package:data/src/repository/flow/flow_response.dart';
import 'package:dio/dio.dart';
import 'package:domain/domain.dart';

class FlowUploaderImpl extends FlowUploader {
  final DioClient _dioClient;
  static final String CHUNK_NUMBER = 'flowChunkNumber';
  static final String TOTAL_CHUNKS = 'flowTotalChunks';
  static final String CHUNK_SIZE = 'flowChunkSize';
  static final String CURRENT_CHUNK_SIZE = 'flowCurrentChunkSize';
  static final String TOTAL_SIZE = 'flowTotalSize';
  static final String IDENTIFIER = 'flowIdentifier';
  static final String FILENAME = 'flowFilename';
  static final String RELATIVE_PATH = 'flowRelativePath';
  static final String FILE = 'file';
  static final String WORK_GROUP_UUID = 'workGroupUuid';
  static final String WORK_GROUP_PARENT_NODE_UUID = 'workGroupParentNodeUuid';
  static final String ASYNC_TASK = 'asyncTask';

  FlowUploaderImpl(this._dioClient);
  
  @override
  Future<bool> testChunk(
    FlowFile flowFile,
    int chunkNumber,
    int chunkSize,
    int currentChunkSize,
    String identifier,
    FileInfo fileInfo,
    int totalChunk,
    {String? sharedSpaceId,
    String? parentNodeId}
  ) async {
    final response = await _dioClient.getFlow(
      Endpoint.flow
        .withQueryParameters([
          BooleanQueryParameter(ASYNC_TASK, true), 
          IntQueryParameter(CHUNK_NUMBER, chunkNumber),
          IntQueryParameter(CHUNK_SIZE, chunkSize),
          IntQueryParameter(CURRENT_CHUNK_SIZE, currentChunkSize),
          IntQueryParameter(TOTAL_SIZE, fileInfo.fileSize),
          StringQueryParameter(IDENTIFIER, identifier),
          StringQueryParameter(FILENAME, fileInfo.fileName),
          StringQueryParameter(RELATIVE_PATH, fileInfo.fileName),
          IntQueryParameter(TOTAL_CHUNKS, totalChunk),
          if (sharedSpaceId != null) StringQueryParameter(WORK_GROUP_UUID, sharedSpaceId),
          if (parentNodeId != null) StringQueryParameter(WORK_GROUP_PARENT_NODE_UUID, parentNodeId)
        ])
        .generateEndpointPath());

    developer.log('testChunk(): ${response.statusCode}', name: 'FlowUploaderImpl');

    if (response.statusCode == null) {
      return false;
    }

    return (response.statusCode! == HttpStatus.ok || response.statusCode! == HttpStatus.accepted);
  }

  @override
  Future<Flow> uploadChunk(
      ChunkedStreamReader<int> chunkedStreamReaderFile,
      int chunkNumber,
      int chunkSize,
      int currentChunkSize,
      int startByte,
      int endByte,
      String flowIdentifier,
      FlowFile flowFile,
      int totalChunk,
      int uploadedByte,
      StreamController<Either<Failure, Success>> onSendController,
      {String? sharedSpaceId,
      String? parentNodeId}
  ) async {
    try {
      final _fileSize = flowFile.fileInfo.fileSize;
      developer.log(
        'uploadChunk(): chunk: $chunkNumber - currentChunkSize: $currentChunkSize',
        name: 'FlowUploaderImpl');

      final formData = generateFormData(
        chunkedStreamReaderFile,
        chunkNumber,
        chunkSize,
        currentChunkSize,
        startByte,
        endByte,
        _fileSize,
        flowIdentifier,
        flowFile,
        totalChunk,
        uploadedByte,
        onSendController,
        sharedSpaceId: sharedSpaceId,
        parentNodeId: parentNodeId);

      final response = await _dioClient.post(
        Endpoint.flow.generateEndpointPath(),
        data: formData,
        options: Options(
          headers: _getRangeHeadersForChunkUpload(startByte, endByte, _fileSize)
        ),
        onSendProgress: (progress, total) {
          onSendController.add(Right(UploadingFlowUploadState(
            flowFile, uploadedByte + progress,
            flowFile.fileInfo.fileSize)));
        }
      );
      final flowResponse = FlowResponse.fromJson(response);
      developer.log('uploadChunk(): ${flowResponse.toString()}', name: 'FlowUploaderImpl');
      return flowResponse.toFlow();
    } catch (e) {
      developer.log('uploadChunk(): exception ${e}', name: 'FlowUploaderImpl');
      rethrow;
    }
  }

  FormData generateFormData(
    ChunkedStreamReader<int> chunkedStreamReaderFile,
    int chunkNumber,
    int chunkSize,
    int currentChunkSize,
    int startByte,
    int endByte,
    int fileSize,
    String flowIdentifier,
    FlowFile flowFile,
    int totalChunk,
    int uploadedByte,
    StreamController<Either<Failure, Success>> onSendController,
    {String? sharedSpaceId,
    String? parentNodeId}
  ) {
    final formData = <String, dynamic>{
      CHUNK_NUMBER: chunkNumber,
      TOTAL_CHUNKS: totalChunk,
      CHUNK_SIZE: chunkSize,
      CURRENT_CHUNK_SIZE: currentChunkSize,
      TOTAL_SIZE: fileSize,
      IDENTIFIER: flowIdentifier,
      FILENAME: flowFile.fileInfo.fileName,
      RELATIVE_PATH: flowFile.fileInfo.fileName,
      FILE: MultipartFile(chunkedStreamReaderFile.readStream(currentChunkSize), currentChunkSize),
      ASYNC_TASK: true,
    };

    if (sharedSpaceId != null) {
      formData.addAll({
        WORK_GROUP_UUID: sharedSpaceId
      });
    }

    if (parentNodeId != null) {
      formData.addAll({
        WORK_GROUP_PARENT_NODE_UUID: parentNodeId
      });
    }

    return FormData.fromMap(formData);
  }

  Map<String, dynamic> _getRangeHeadersForChunkUpload(int start, int end, int fileSize) =>
      {'Content-Range': 'bytes $start-${end - 1}/$fileSize'};

  @override
  Future<AsyncTask> getFlowTask(String asyncTaskUuid) async {
    final asyncTaskJson = await _dioClient.get(
      Endpoint.flow.withPathParameter(asyncTaskUuid).generateEndpointPath()
    );

    developer.log('getFlowTask(): 1', name: 'FlowUploaderImpl');
    return AsyncTaskResponse.fromJson(asyncTaskJson).toAsyncTask();
  }
}