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

import 'dart:async';
import 'dart:io';

import 'package:data/src/datasource/document_datasource.dart';
import 'package:data/src/network/config/endpoint.dart';
import 'package:data/src/network/linshare_download_manager.dart';
import 'package:data/src/network/linshare_http_client.dart';
import 'package:data/src/network/model/generic_user_dto.dart';
import 'package:data/src/network/model/request/share_document_body_request.dart';
import 'package:data/src/network/model/response/document_response.dart';
import 'package:data/src/network/model/response/document_details_response.dart';
import 'package:data/src/network/model/share/mailing_list_id_dto.dart';
import 'package:data/src/network/model/share/share_dto.dart';
import 'package:data/src/network/model/share/share_id_dto.dart';
import 'package:data/src/network/remote_exception_thrower.dart';
import 'package:data/src/util/constant.dart';
import 'package:dio/dio.dart';
import 'package:domain/domain.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:data/src/network/model/request/copy_body_request.dart';

class DocumentDataSourceImpl implements DocumentDataSource {
  final LinShareHttpClient _linShareHttpClient;
  final RemoteExceptionThrower _remoteExceptionThrower;
  final LinShareDownloadManager _linShareDownloadManager;

  DocumentDataSourceImpl(this._linShareHttpClient, this._remoteExceptionThrower, this._linShareDownloadManager);

  @override
  Future<List<Document>> getAll() async {
    return Future.sync(() async {
      final documentResponseList = await _linShareHttpClient.getAllDocument();
      return documentResponseList.map((documentResponse) => documentResponse.toDocument()).toList();
    }).catchError((error) {
      _remoteExceptionThrower.throwRemoteException(error, handler: (DioError error) {
        if (error.response.statusCode == 404) {
          throw DocumentNotFound();
        } else {
          throw UnknownError(error.response.statusMessage);
        }
      });
    });
  }

  @override
  Future<List<DownloadTaskId>> downloadDocuments(List<DocumentId> documentIds, Token token, Uri baseUrl) async {
    var externalStorageDirPath;
    if (Platform.isAndroid) {
      externalStorageDirPath = await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_DOWNLOADS);
    } else if (Platform.isIOS) {
      externalStorageDirPath = (await getApplicationDocumentsDirectory()).absolute.path;
    } else {
      throw DeviceNotSupportedException();
    }

    final taskIds = await Future.wait(
        documentIds.map((documentId) async => await FlutterDownloader.enqueue(
            url: Endpoint.documents
              .downloadServicePath(documentId.uuid)
              .generateDownloadUrl(baseUrl),
            savedDir: externalStorageDirPath,
            headers: {Constant.authorization: 'Bearer ${token.token}'},
            showNotification: true,
            openFileFromNotification: true)));

    return taskIds.map((taskId) => DownloadTaskId(taskId)).toList();
  }

  @override
  Future<List<Share>> share(List<DocumentId> documentIds, List<MailingListId> mailingListIds, List<GenericUser> recipients) {
    return Future.sync(() async {
      final shareDocumentBodyRequest = ShareDocumentBodyRequest(
          documentIds.map((data) => ShareIdDto(data.uuid)).toList(),
          mailingListIds.map((data) => MailingListIdDto(data.uuid)).toList(),
          recipients.map((data) => GenericUserDto(data.mail, lastName: data.lastName, firstName: data.firstName)).toList());
      final shareList = await _linShareHttpClient.shareDocument(shareDocumentBodyRequest);
      return shareList.map((data) => data.toShare()).toList();
    }).catchError((error) {
      _remoteExceptionThrower.throwRemoteException(error,
          handler: (DioError error) => _handleShareException(error));
    });
  }

  void _handleShareException(DioError error) {
    if (error.response.statusCode == 404) {
      throw DocumentNotFound();
    } else if (error.response.statusCode == 403) {
      throw ShareDocumentNoPermissionException();
    } else {
      throw UnknownError(error.response.statusMessage);
    }
  }

  @override
  Future<Uri> downloadDocumentIOS(Document document, Token permanentToken, Uri baseUrl, CancelToken cancelToken) async {
    return _linShareDownloadManager.downloadFile(
        Endpoint.documents
            .downloadServicePath(document.documentId.uuid)
            .generateDownloadUrl(baseUrl),
        getTemporaryDirectory(),
        document.name,
        permanentToken,
        cancelToken: cancelToken);
  }

  @override
  Future<Document> remove(DocumentId documentId) async {
    return Future.sync(() async {
      final documentResponse = await _linShareHttpClient.removeDocument(documentId);
      return documentResponse.toDocument();
    }).catchError((error) {
      _remoteExceptionThrower.throwRemoteException(error, handler: (DioError error) {
        if (error.response.statusCode == 404) {
          throw DocumentNotFound();
        } else {
          throw UnknownError(error.response.statusMessage);
        }
      });
    });
  }

  @override
  Future<List<Document>> copyToMySpace(CopyRequest copyRequest) async {
    return Future.sync(() async {
      final documentsResponse = await _linShareHttpClient.copyToMySpace(copyRequest.toCopyBodyRequest());
      return documentsResponse.map((response) => response.toDocument()).toList();
    }).catchError((error) {
      _remoteExceptionThrower.throwRemoteException(error, handler: (DioError error) {
        if (error.response.statusCode == 404) {
          throw DocumentNotFound();
        } if (error.response.statusCode == 403) {
          throw NotAuthorized();
        } else {
          throw UnknownError(error.response.statusMessage);
        }
      });
    });
  }

  @override
  Future<Uri> downloadPreviewDocument(Document document, DownloadPreviewType downloadPreviewType, Token permanentToken, Uri baseUrl, CancelToken cancelToken) {
    var downloadUrl;
    if (downloadPreviewType == DownloadPreviewType.original) {
      downloadUrl = Endpoint.documents
          .downloadServicePath(document.documentId.uuid)
          .generateDownloadUrl(baseUrl);
    } else {
      downloadUrl = Endpoint.documents
          .withPathParameter(document.documentId.uuid)
          .withPathParameter(Endpoint.thumbnail)
          .withPathParameter(downloadPreviewType == DownloadPreviewType.image ? 'medium?base64=false' : 'pdf')
          .generateEndpointPath();
    }
    return _linShareDownloadManager.downloadFile(
        downloadUrl,
        getTemporaryDirectory(),
        document.name + '${downloadPreviewType == DownloadPreviewType.thumbnail ? '.pdf' : ''}',
        permanentToken,
        cancelToken: cancelToken);
  }

  @override
  Future<Document> rename(DocumentId documentId, RenameDocumentRequest renameDocumentRequest) {
    return Future.sync(() async {
      final documentResponse = await _linShareHttpClient.renameDocument(documentId, renameDocumentRequest);
      return documentResponse.toDocument();
    }).catchError((error) {
      _remoteExceptionThrower.throwRemoteException(error, handler: (DioError error) {
        if (error.response.statusCode == 404) {
          throw DocumentNotFound();
        } else {
          throw UnknownError(error.response.statusMessage);
        }
      });
    });
  }

  @override
  Future<DocumentDetails> getDocument(DocumentId documentId) {
    return Future.sync(() async {
      return (await _linShareHttpClient.getDocument(documentId)).toDocumentDetails();
    }).catchError((error) {
      _remoteExceptionThrower.throwRemoteException(error, handler: (DioError error) {
        if (error.response.statusCode == 404) {
          throw DocumentNotFound();
        } else {
          throw UnknownError(error.response.statusMessage);
        }
      });
    });
  }
}