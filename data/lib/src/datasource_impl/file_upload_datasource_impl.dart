// LinShare is an open source filesharing software, part of the LinPKI software
// suite, developed by Linagora.
//
// Copyright (C) 2021 LINAGORA
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
import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:data/data.dart';
import 'package:data/src/network/model/response/document_response.dart';
import 'package:data/src/util/constant.dart';
import 'package:domain/domain.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:rxdart/rxdart.dart';
import 'package:data/src/datasource/file_upload_datasource.dart';
import 'package:domain/src/model/authentication/token.dart';
import 'package:domain/src/model/file_info.dart';
import 'package:domain/src/usecases/upload_file/file_upload_state.dart';

class FileUploadDataSourceImpl implements FileUploadDataSource {
  final FlutterUploader _uploader;

  Stream<Either<Failure, Success>> _uploadingFileStream;

  @override
  Stream<Either<Failure, Success>> get uploadingFileStream => _uploadingFileStream;

  FileUploadDataSourceImpl(this._uploader) {
    _uploadingFileStream = Rx.merge([_uploader.result, _uploader.progress]).map<Either<Failure, Success>>((event) {
      if (event is UploadTaskResponse) {
        if (event.statusCode == 200) {
          final jsonMap = json.decode(event.response);
          final workgroupDocument = jsonMap['workGroup'] != null;

          return workgroupDocument
              ? Right(FileUploadSuccess(UploadTaskId(event.taskId), uploadedWorkGroupDocument: WorkGroupDocumentDto.fromJson(jsonMap).toWorkGroupDocument()))
              : Right(FileUploadSuccess(UploadTaskId(event.taskId), uploadedDocument: DocumentResponse.fromJson(jsonMap).toDocument()));
        }
        return Left(FileUploadFailure(UploadTaskId(event.taskId), Exception('Response code failed: ${event.response}')));
      } else if (event is UploadTaskProgress) {
        return Right(UploadingProgress(UploadTaskId(event.taskId), event.progress));
      } else {
        return Left(FileUploadFailure(UploadTaskId.undefined(), Exception('Something wrong with response: ${event.toString()}')));
      }
    });
  }

  @override
  Future<UploadTaskId> upload(FileInfo fileInfo, Token token, String url) async {
    final file = File(fileInfo.filePath + fileInfo.fileName);
    final taskId = await _uploader.enqueue(
        url: url,
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

    return UploadTaskId(taskId);
  }

}