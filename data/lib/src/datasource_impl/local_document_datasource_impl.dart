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

import 'package:data/data.dart';
import 'package:dio/src/cancel_token.dart';
import 'package:domain/domain.dart';

class LocalDocumentDataSourceImpl extends DocumentDataSource {
  final DocumentDatabaseManager _documentDatabaseManager;

  LocalDocumentDataSourceImpl(this._documentDatabaseManager);

  @override
  Future<Document?> getDocumentOffline(DocumentId documentId) {
    return Future.sync(() async {
      return await _documentDatabaseManager.getData(documentId.uuid);
    }).catchError((error) {
      throw LocalUnknownError(error);
    });
  }

  @override
  Future<bool> makeAvailableOffline(Document document, String localPath) {
    return Future.sync(() async {
      return await _documentDatabaseManager.insertData(document, localPath);
    }).catchError((error) {
      throw LocalUnknownError(error);
    });
  }

  @override
  Future<bool> disableAvailableOffline(DocumentId documentId, String localPath) {
    return Future.sync(() async {
      return await _documentDatabaseManager.deleteData(documentId.uuid, localPath);
    }).catchError((error) {
      throw LocalUnknownError(error);
    });
  }

  @override
  Future<bool> updateDocumentOffline(Document document, String localPath) {
    return Future.sync(() async {
      return await _documentDatabaseManager.updateData(document, localPath);
    }).catchError((error) {
      throw LocalUnknownError(error);
    });
  }

  @override
  Future<List<Document>> getAllDocumentOffline() {
    return Future.sync(() async {
      return await _documentDatabaseManager.getListData();
    }).catchError((error) {
      throw LocalUnknownError(error);
    });
  }

  @override
  Future<bool> deleteAllData() {
    return Future.sync(() async {
      return await _documentDatabaseManager.deleteAllData();
    }).catchError((error) {
      if (error is SQLiteDatabaseException) {
        throw SQLiteDatabaseException();
      } else {
        throw LocalUnknownError(error);
      }
    });
  }

  @override
  Future<List<Document>> copyToMySpace(CopyRequest copyRequest) {
    throw UnimplementedError();
  }

  @override
  Future<String> downloadDocumentIOS(Document document, Token token, Uri baseUrl, CancelToken cancelToken) {
    throw UnimplementedError();
  }

  @override
  Future<List<DownloadTaskId>> downloadDocuments(List<DocumentId> documentIds, Token token, Uri baseUrl, APIVersionSupported apiVersion) {
    throw UnimplementedError();
  }

  @override
  Future<String> downloadMakeOfflineDocument(DocumentId documentId, String documentName, DownloadPreviewType downloadPreviewType, Token permanentToken, Uri baseUrl) {
    throw UnimplementedError();
  }

  @override
  Future<String> downloadPreviewDocument(Document document, DownloadPreviewType downloadPreviewType, Token token, Uri baseUrl, CancelToken cancelToken) {
    throw UnimplementedError();
  }

  @override
  Future<Document> editDescription(DocumentId documentId, EditDescriptionDocumentRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<List<Document>> getAll() {
    throw UnimplementedError();
  }

  @override
  Future<DocumentDetails> getDocument(DocumentId documentId) {
    throw UnimplementedError();
  }

  @override
  Future<Document> remove(DocumentId documentId) {
    throw UnimplementedError();
  }

  @override
  Future<Document> rename(DocumentId documentId, RenameDocumentRequest renameDocumentRequest) {
    throw UnimplementedError();
  }

  @override
  Future<List<Share>> share(List<DocumentId> documentIds, List<MailingListId> mailingListIds, List<GenericUser> recipients) {
    throw UnimplementedError();
  }
}