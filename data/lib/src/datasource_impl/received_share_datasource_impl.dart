/*
 * LinShare is an open source filesharing software, part of the LinPKI software
 * suite, developed by Linagora.
 *
 * Copyright (C) 2021 LINAGORA
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

import 'dart:io';

import 'package:data/src/datasource/received_share_datasource.dart';
import 'package:data/src/network/config/endpoint.dart';
import 'package:data/src/network/linshare_download_manager.dart';
import 'package:data/src/network/linshare_http_client.dart';
import 'package:data/src/network/remote_exception_thrower.dart';
import 'package:data/src/util/constant.dart';
import 'package:dio/dio.dart';
import 'package:domain/domain.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

class ReceivedShareDataSourceImpl extends ReceivedShareDataSource {
  final LinShareHttpClient _linShareHttpClient;
  final RemoteExceptionThrower _remoteExceptionThrower;
  final LinShareDownloadManager _linShareDownloadManager;

  ReceivedShareDataSourceImpl(
    this._linShareHttpClient,
    this._remoteExceptionThrower,
    this._linShareDownloadManager
 );

  @override
  Future<List<ReceivedShare>> getAllReceivedShares() async {
    return Future.sync(() async {
      return await _linShareHttpClient.getReceivedShares();
    }).catchError((error) {
      _remoteExceptionThrower.throwRemoteException(error, handler: (DioError error) {
        if (error.response.statusCode == 403) {
          throw NotAuthorized();
        } else {
          throw UnknownError(error.response.statusMessage);
        }
      });
    });
  }

  @override
  Future<List<DownloadTaskId>> downloadReceivedShares(List<ShareId> shareIds, Token token, Uri baseUrl) async {
    var externalStorageDirPath;
    if (Platform.isAndroid) {
      externalStorageDirPath = await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_DOWNLOADS);
    } else if (Platform.isIOS) {
      externalStorageDirPath = (await getApplicationDocumentsDirectory()).absolute.path;
    } else {
      throw DeviceNotSupportedException();
    }

    final taskIds = await Future.wait(
        shareIds.map((shareId) async => await FlutterDownloader.enqueue(
            url: Endpoint.receivedShares
              .downloadServicePath(shareId.uuid)
              .generateDownloadUrl(baseUrl),
            savedDir: externalStorageDirPath,
            headers: {Constant.authorization: 'Bearer ${token.token}'},
            showNotification: true,
            openFileFromNotification: true)));

    return taskIds.map((taskId) => DownloadTaskId(taskId)).toList();
  }

  @override
  Future<Uri> downloadPreviewReceivedShare(ReceivedShare receivedShare,
      DownloadPreviewType downloadPreviewType, Token permanentToken, Uri baseUrl, CancelToken cancelToken) {
    var downloadUrl;
    if (downloadPreviewType == DownloadPreviewType.original) {
      downloadUrl = Endpoint.receivedShares
          .downloadServicePath(receivedShare.shareId.uuid)
          .generateDownloadUrl(baseUrl);
    } else {
      downloadUrl = Endpoint.receivedShares
          .withPathParameter(receivedShare.shareId.uuid)
          .withPathParameter(Endpoint.thumbnail)
          .withPathParameter(downloadPreviewType == DownloadPreviewType.image ? 'medium?base64=false' : 'pdf')
          .generateEndpointPath();
    }
    return _linShareDownloadManager.downloadFile(
        downloadUrl,
        getTemporaryDirectory(),
        receivedShare.name + '${downloadPreviewType == DownloadPreviewType.thumbnail ? '.pdf' : ''}',
        permanentToken,
        cancelToken: cancelToken);
  }
}
