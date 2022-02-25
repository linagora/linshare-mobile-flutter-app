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

import 'package:dartz/dartz.dart';
import 'package:domain/domain.dart';
import 'package:domain/src/model/async_task/async_task.dart';
import 'package:domain/src/model/async_task/async_task_exception.dart';
import 'package:domain/src/model/async_task/async_task_status.dart';
import 'package:domain/src/model/flow/flow_chunk.dart';
import 'package:domain/src/model/flow/flow_chunk_upload_state.dart';
import 'package:domain/src/repository/flow/flow_uploader.dart';
import 'package:domain/src/usecases/upload_file/flow_upload_state.dart';
import 'package:equatable/equatable.dart';
import 'package:retry/retry.dart';

class FlowFile extends Equatable {
  final UploadTaskId uploadTaskId;
  final FileInfo fileInfo;
  final FlowUploader _flowUploader;
  final SharedSpaceId? sharedSpaceId;
  final WorkGroupNodeId? parentNodeId;

  final int chunkSize = 1024 * 1024;
  final List<FlowChunk> chunks = List.empty(growable: true);

  final StreamController<Either<Failure, Success>> _progressStateController = StreamController<Either<Failure, Success>>.broadcast();

  int _uploadedByte = 0;
  Flow? _latestFlow;

  FlowFile(this.uploadTaskId, this.fileInfo, this._flowUploader, {this.sharedSpaceId, this.parentNodeId});

  Stream<Either<Failure, Success>> get progressState => _progressStateController.stream;

  void _readFile(File file, FlowUploader flowUploader) {
    var chunkCount = (fileInfo.fileSize / chunkSize).ceil();
    for (var offset = 0; offset < chunkCount; offset++) {
      chunks.add(FlowChunk(offset, this, file, uploadTaskId, flowUploader));
    }
  }

  Future<FlowChunk?> _uploadNextChunk() async {
    if (chunks.first.status == FlowChunkUploadState.pending) {
      developer.log('uploadNextChunk(): upload first chunk', name: 'FlowFile');
      _latestFlow = await chunks.first.upload(_uploadedByte, _progressStateController);
      return chunks.first;
    }

    try {
      final chunk = chunks.firstWhere((chunk) => chunk.status == FlowChunkUploadState.pending);
      developer.log('uploadNextChunk(): upload chunk $chunk', name: 'FlowFile');
      _latestFlow = await chunk.upload(_uploadedByte, _progressStateController);
      return chunk;
    } catch (e) {
      developer.log('uploadNextChunk(): error: $e', name: 'FlowFile');
      return null;
    }
  }

  void _updateProgress(FlowChunk chunk) {
    developer.log('updateProgress(): currentProgress = $_uploadedByte', name: 'FlowFile');
    _uploadedByte += chunk.currentChunkSize;
    _updateEvent(Right(UploadingFlowUploadState(this, _uploadedByte, fileInfo.fileSize)));
  }

  Future<AsyncTask> _getFlowTask(String asyncTaskId) async {
    developer.log('_getFlowTask(): $asyncTaskId', name: 'FlowFile');
    final asyncTask = await _flowUploader.getFlowTask(asyncTaskId);
    if (asyncTask.status == AsyncTaskStatus.PROCESSING) {
      throw UnderProcessingException();
    }
    if (asyncTask.status == AsyncTaskStatus.FAILED) {
      throw AsyncTaskException(status: asyncTask.status);
    }
    return asyncTask;
  }

  void _updateEvent(Either<Failure, Success> flowUploadState) {
    _progressStateController.add(flowUploadState);
  }

  void _handleCompleted() {
    if (chunks.every((chunk) => chunk.status == FlowChunkUploadState.success)) {
      final asyncTaskId = _getProcessingTaskId();
      if (asyncTaskId != null) {
        _handleProcessing(asyncTaskId);
      } else {
        _handleSuccess();
      }
    } else {
      developer.log('handleCompleted(): error', name: 'FlowFile');
      _updateEvent(Left(ErrorFlowUploadState(this)));
      _progressStateController.close();
    }
  }

  Future<void> _handleProcessing(String asyncTaskId) async {
    _updateEvent(Right(WaitingForProcessingState(this)));
    try {
      final asyncTask = await RetryOptions(
          delayFactor: Duration(milliseconds: 1000),
          maxAttempts: 3)
        .retry(
          () => _getFlowTask(asyncTaskId),
          retryIf: (exception) => exception is UnderProcessingException
        );
      if (asyncTask.resourceUuid != null) {
        developer.log('_handleProcessing(): success with resourceId = ${asyncTask.resourceUuid}', name: 'FlowFile');
        _updateEvent(Right(SuccessWithResourceFlowUploadState(this, asyncTask.resourceUuid!)));
        await _progressStateController.close();
      }
    } catch (exception) {
      developer.log('_handleProcessing(): can not get resourceId: $exception', name: 'FlowFile');
      _updateEvent(Right(SuccessFlowUploadState(this)));
      await _progressStateController.close();
    }
  }

  void _handleSuccess() {
    developer.log('_handleSuccess()', name: 'FlowFile');
    _updateEvent(Right(SuccessFlowUploadState(this)));
    _progressStateController.close();
  }

  String? _getProcessingTaskId() {
    return _latestFlow?.asyncTaskUuid;
  }

  Future<void> upload() async {
    developer.log('upload(): $uploadTaskId', name: 'FlowFile');
    _updateEvent(Right(PendingFlowUploadState(this, 0, fileInfo.fileSize)));
    final file = File(fileInfo.filePath + fileInfo.fileName);
    _readFile(file, _flowUploader);

    while (chunks.isNotEmpty) {
      final chunk = await _uploadNextChunk();
      if (chunk == null) {
        _handleCompleted();
        break;
      }

      final success = await chunk.test();
      if (success) {
        _updateProgress(chunk);
      }
    }
  }

  @override
  List<Object?> get props => [uploadTaskId, fileInfo];
}