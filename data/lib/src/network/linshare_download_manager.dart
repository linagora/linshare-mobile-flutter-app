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
// Linagora © 2009–2021. Contribute to Linshare R&D by subscribing to an Enterprise
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
import 'dart:io';

import 'package:dio/dio.dart';

import 'package:domain/domain.dart';
import 'linshare_http_client.dart';
import 'remote_exception_thrower.dart';

class LinShareDownloadManager {
  final RemoteExceptionThrower _remoteExceptionThrower;
  final LinShareHttpClient _linShareHttpClient;

  LinShareDownloadManager(this._remoteExceptionThrower, this._linShareHttpClient);

  Future<String> downloadFile(
      String downloadUrl,
      Future<Directory> directoryToSave,
      String filename,
      Token permanentToken,
      {CancelToken cancelToken}) async {
    final streamController = StreamController<String>();

    try {
      await Future.wait([
        _linShareHttpClient.downloadFile(downloadUrl, cancelToken, permanentToken),
        directoryToSave])
      .then((values) {
        final fileStream = (values[0] as ResponseBody).stream;
        final tempFilePath = '${(values[1] as Directory).absolute.path}/${filename}';

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
                streamController.sink.addError(CommonDownloadFileException(error.toString()));
                await streamController.close();
              });
        }, onDone: () async {
          await randomAccessFile.close();
          if (cancelToken != null && cancelToken.isCancelled) {
            streamController.sink.addError(CancelDownloadFileException(cancelToken.cancelError.message));
          } else {
            streamController.sink.add(tempFilePath);
          }
          await streamController.close();
        }, onError: (error) async {
          await randomAccessFile.close();
          await file.delete();
          streamController.sink.addError(CommonDownloadFileException(error.toString()));
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
}
