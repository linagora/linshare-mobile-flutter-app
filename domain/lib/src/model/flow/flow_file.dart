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
import 'package:domain/src/model/flow/flow_chunk.dart';
import 'package:domain/src/model/flow/flow_chunk_upload_state.dart';
import 'package:domain/src/repository/flow/flow_uploader.dart';
import 'package:domain/src/usecases/upload_file/flow_upload_state.dart';
import 'package:equatable/equatable.dart';

class FlowFile extends Equatable {
  final UploadTaskId uploadTaskId;
  final FileInfo fileInfo;
  final FlowUploader flowUploader;
  final SharedSpaceId? sharedSpaceId;
  final WorkGroupNodeId? parentNodeId;

  final int chunkSize = 1024 * 1024;
  final List<FlowChunk> chunks = List.empty(growable: true);
  int uploadedByte = 0;

  final StreamController<Either<Failure, Success>> _progressStateController = StreamController<Either<Failure, Success>>.broadcast();

  FlowFile(this.uploadTaskId, this.fileInfo, this.flowUploader, {this.sharedSpaceId, this.parentNodeId});

  Stream<Either<Failure, Success>> get progressState => _progressStateController.stream;

  void readFile(File file, FlowUploader flowUploader) {
    var chunkCount = (fileInfo.fileSize / chunkSize).ceil();
    for (var offset = 0; offset < chunkCount; offset++) {
      chunks.add(FlowChunk(offset, this, file, uploadTaskId, flowUploader));
    }
  }

  Future<FlowChunk?> uploadNextChunk() async {
    if (chunks.first.status == FlowChunkUploadState.pending) {
      developer.log('uploadNextChunk(): upload first chunk', name: 'FlowFile');
      await chunks.first.upload(uploadedByte, _progressStateController);
      return chunks.first;
    }

    try {
      final chunk = chunks.firstWhere((chunk) => chunk.status == FlowChunkUploadState.pending);
      developer.log('uploadNextChunk(): upload chunk $chunk', name: 'FlowFile');
      await chunk.upload(uploadedByte, _progressStateController);
      return chunk;
    } catch (e) {
      developer.log('uploadNextChunk(): error: $e', name: 'FlowFile');
      return null;
    }
  }

  void updateProgress(FlowChunk chunk) {
    developer.log('updateProgress(): currentProgress = $uploadedByte', name: 'FlowFile');
    uploadedByte += chunk.currentChunkSize;
    updateEvent(Right(UploadingFlowUploadState(this, uploadedByte, fileInfo.fileSize)));
  }

  void updateEvent(Either<Failure, Success> flowUploadState) {
    _progressStateController.add(flowUploadState);
  }

  void handleCompleted() {
    if (chunks.every((chunk) => chunk.status == FlowChunkUploadState.success)) {
      developer.log('handleCompleted(): all success', name: 'FlowFile');
      updateEvent(Right(SuccessFlowUploadState(this)));
    } else {
      developer.log('handleCompleted(): error', name: 'FlowFile');
      updateEvent(Left(ErrorFlowUploadState(this)));
    }
    _progressStateController.close();
  }

  Future<void> upload() async {
    developer.log('upload(): $uploadTaskId', name: 'FlowFile');
    updateEvent(Right(PendingFlowUploadState(this, 0, fileInfo.fileSize)));
    final file = File(fileInfo.filePath + fileInfo.fileName);
    readFile(file, flowUploader);

    while (chunks.isNotEmpty) {
      final chunk = await uploadNextChunk();
      if (chunk == null) {
        handleCompleted();
        break;
      }

      final success = await chunk.test();
      if (success) {
        updateProgress(chunk);
      }
    }
  }

  @override
  List<Object?> get props => [uploadTaskId, fileInfo];
}