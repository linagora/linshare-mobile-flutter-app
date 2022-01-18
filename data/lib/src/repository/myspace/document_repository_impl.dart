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

import 'package:data/src/datasource/document_datasource.dart';
import 'package:data/src/datasource/file_upload_datasource.dart';
import 'package:data/src/extensions/uri_extension.dart';
import 'package:data/src/local/model/data_source_type.dart';
import 'package:data/src/network/config/endpoint.dart';
import 'package:dio/src/cancel_token.dart';
import 'package:domain/domain.dart';
import 'package:domain/src/model/share/mailing_list_id.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final Map<DataSourceType, DocumentDataSource> _documentDataSources;
  final FileUploadDataSource _fileUploadDataSource;

  DocumentRepositoryImpl(this._documentDataSources, this._fileUploadDataSource);

  @override
  Future<UploadTaskId> upload(FileInfo fileInfo, Token token, Uri baseUrl, APIVersionSupported apiVersion) async {
    return _fileUploadDataSource.upload(
      fileInfo,
      token,
      baseUrl.withServicePath(Endpoint.documents, apiVersion),
    );
  }

  @override
  Future<List<Document>> getAll() {
    return _documentDataSources[DataSourceType.network]!.getAll();
  }

  @override
  Future<List<DownloadTaskId>> downloadDocuments(List<DocumentId> documentIds, Token token, Uri baseUrl) {
    return _documentDataSources[DataSourceType.network]!.downloadDocuments(documentIds, token, baseUrl);
  }

  @override
  Future<List<Share>> share(List<DocumentId> documentIds, List<MailingListId> mailingListIds, List<GenericUser> recipients) {
    return _documentDataSources[DataSourceType.network]!.share(documentIds, mailingListIds, recipients);
  }

  @override
  Future<String> downloadDocumentIOS(Document document, Token token, Uri baseUrl, CancelToken cancelToken) {
    return _documentDataSources[DataSourceType.network]!.downloadDocumentIOS(document, token, baseUrl, cancelToken);
  }

  @override
  Future<Document> remove(DocumentId documentId) {
    return _documentDataSources[DataSourceType.network]!.remove(documentId);
  }

  @override
  Future<List<Document>> copyToMySpace(CopyRequest copyRequest) {
    return _documentDataSources[DataSourceType.network]!.copyToMySpace(copyRequest);
  }

  @override
  Future<String> downloadPreviewDocument(Document document, DownloadPreviewType downloadPreviewType, Token token, Uri baseUrl, CancelToken cancelToken) {
    return _documentDataSources[DataSourceType.network]!.downloadPreviewDocument(document, downloadPreviewType, token, baseUrl, cancelToken);
  }

  @override
  Future<Document> rename(DocumentId documentId, RenameDocumentRequest renameDocumentRequest) {
    return _documentDataSources[DataSourceType.network]!.rename(documentId, renameDocumentRequest);
  }

  @override
  Future<DocumentDetails> getDocument(DocumentId documentId) {
    return _documentDataSources[DataSourceType.network]!.getDocument(documentId);
  }

  @override
  Future<Document> editDescription(DocumentId documentId, EditDescriptionDocumentRequest request) {
    return _documentDataSources[DataSourceType.network]!.editDescription(documentId, request);
  }

  @override
  Future<bool> makeAvailableOffline(Document document, String localPath) {
    return _documentDataSources[DataSourceType.local]!.makeAvailableOffline(document, localPath);
  }

  @override
  Future<Document?> getDocumentOffline(DocumentId documentId) {
    return _documentDataSources[DataSourceType.local]!.getDocumentOffline(documentId);
  }

  @override
  Future<bool> disableAvailableOffline(DocumentId documentId, String localPath) {
    return _documentDataSources[DataSourceType.local]!.disableAvailableOffline(documentId, localPath);
  }

  @override
  Future<List<Document>> getAllDocumentOffline() {
    return _documentDataSources[DataSourceType.local]!.getAllDocumentOffline();
  }

  @override
  Future<bool> updateDocumentOffline(Document document, String localPath) {
    return _documentDataSources[DataSourceType.local]!.updateDocumentOffline(document, localPath);
  }

  @override
  Future<String> downloadMakeOfflineDocument(DocumentId documentId, String documentName, DownloadPreviewType downloadPreviewType, Token permanentToken, Uri baseUrl) {
    return _documentDataSources[DataSourceType.network]!.downloadMakeOfflineDocument(documentId, documentName, downloadPreviewType, permanentToken, baseUrl);
  }

  @override
  Future<bool> deleteAllData() {
    return _documentDataSources[DataSourceType.local]!.deleteAllData();
  }
}