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
import 'dart:math';

import 'package:async/async.dart';
import 'package:dartz/dartz.dart';
import 'package:domain/domain.dart';
import 'package:domain/src/model/flow/flow_chunk_upload_state.dart';
import 'package:domain/src/model/flow/flow_file.dart';
import 'package:domain/src/repository/flow/flow_uploader.dart';
import 'package:equatable/equatable.dart';

class FlowChunk extends Equatable {
  final int offset;
  final FlowFile flowFile;
  final File file;

  int get totalChunk => flowFile.chunks.length;
  late int chunkSize;
  late int currentChunkSize;
  late int totalSize;
  final UploadTaskId identifier;
  bool tested = false;
  late int startByte;
  late int endByte;
  FlowChunkUploadState status = FlowChunkUploadState.pending;

  bool error = false;
  ChunkedStreamReader<int>? _chunkedStreamReader;

  final FlowUploader _flowUploader;

  FlowChunk(this.offset, this.flowFile, this.file, this.identifier, this._flowUploader) {
    chunkSize = flowFile.chunkSize;
    totalSize = flowFile.fileInfo.fileSize;
    startByte = offset * chunkSize;
    endByte = _computeEndByte(flowFile, offset);
    currentChunkSize = endByte - startByte;
  }
  
  int _computeEndByte(FlowFile flowFile, int offset) {
    return min(flowFile.fileInfo.fileSize, (offset + 1) * chunkSize);
  }

  Future<Flow> upload(int uploadedByte, StreamController<Either<Failure, Success>> onSendController) async {
    status = FlowChunkUploadState.uploading;
    _chunkedStreamReader = ChunkedStreamReader(file.openRead(startByte, endByte));
    return _flowUploader.uploadChunk(
      _chunkedStreamReader!,
      offset + 1,
      chunkSize,
      currentChunkSize,
      startByte,
      endByte,
      flowFile.uploadTaskId.id,
      flowFile,
      flowFile.chunks.length,
      uploadedByte,
      onSendController,
      sharedSpaceId: flowFile.sharedSpaceId?.uuid,
      parentNodeId: flowFile.parentNodeId?.uuid
    );
  }

  Future<bool> test() async {
    tested = true;
    final isSuccess = await _flowUploader.testChunk(
      flowFile,
      offset + 1,
      chunkSize,
      currentChunkSize,
      flowFile.uploadTaskId.id,
      flowFile.fileInfo,
      totalChunk,
      sharedSpaceId: flowFile.sharedSpaceId?.uuid,
      parentNodeId: flowFile.parentNodeId?.uuid
    );
    if (isSuccess) {
      status = FlowChunkUploadState.success;
    } else {
      developer.log('test(): update status error for offset $offset', name: 'FlowChunk');
      status = FlowChunkUploadState.error;
    }
    return isSuccess;
  }

  void completed() {
    developer.log('completed()', name: 'FlowChunk');
    _chunkedStreamReader?.cancel();
  }

  @override
  List<Object?> get props => [offset, flowFile, identifier];
}