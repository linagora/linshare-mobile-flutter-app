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

import 'package:dartz/dartz.dart';
import 'package:domain/domain.dart';
import 'package:domain/src/model/document/document.dart';

class UploadButtonClick extends ViewEvent {
  @override
  List<Object> get props => [];
}

class MySpaceViewState extends ViewState {
  final List<Document> documentList;

  MySpaceViewState(this.documentList);

  @override
  List<Object> get props => [documentList];
}

class MySpaceFailure extends FeatureFailure {
  final Exception exception;

  MySpaceFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

class DownloadFileViewState extends ViewState {
  final List<DownloadTaskId> taskIds;

  DownloadFileViewState(this.taskIds);

  @override
  List<Object> get props => [taskIds];
}

class DownloadFileFailure extends FeatureFailure {
  final Exception downloadFileException;

  DownloadFileFailure(this.downloadFileException);

  @override
  List<Object> get props => [downloadFileException];
}

class ContextMenuItemViewState extends ViewState {
  final Document document;

  ContextMenuItemViewState(this.document);

  @override
  List<Object> get props => [document];
}

class DownloadFileIOSViewState extends ViewState {
  final Uri filePath;
  DownloadFileIOSViewState(this.filePath);

  @override
  List<Object> get props => [filePath];
}

class DownloadFileIOSFailure extends FeatureFailure {
  final Exception downloadFileException;

  DownloadFileIOSFailure(this.downloadFileException);

  @override
  List<Object> get props => [downloadFileException];
}

class DownloadFileIOSAllSuccessViewState extends ViewState {
  final List<Either<Failure, Success>> resultList;

  DownloadFileIOSAllSuccessViewState(this.resultList);

  @override
  List<Object> get props => [resultList];
}

class DownloadFileIOSHasSomeFilesFailureViewState extends ViewState {
  final List<Either<Failure, Success>> resultList;

  DownloadFileIOSHasSomeFilesFailureViewState(this.resultList);

  @override
  List<Object> get props => [resultList];
}

class DownloadFileIOSAllFailureViewState extends FeatureFailure {
  final List<Either<Failure, Success>> resultList;

  DownloadFileIOSAllFailureViewState(this.resultList);

  @override
  List<Object> get props => [resultList];
}

class RemoveDocumentViewState extends ViewState {
  final Document document;

  RemoveDocumentViewState(this.document);

  @override
  List<Object> get props => [document];
}

class RemoveDocumentFailure extends FeatureFailure {
  final Exception removeDocumentFailure;

  RemoveDocumentFailure(this.removeDocumentFailure);

  @override
  List<Object> get props => [removeDocumentFailure];
}

class RemoveMultipleDocumentsAllSuccessViewState extends ViewState {
  final List<Either<Failure, Success>> resultList;

  RemoveMultipleDocumentsAllSuccessViewState(this.resultList);

  @override
  List<Object> get props => [resultList];
}

class RemoveMultipleDocumentsHasSomeFilesFailedViewState extends ViewState {
  final List<Either<Failure, Success>> resultList;

  RemoveMultipleDocumentsHasSomeFilesFailedViewState(this.resultList);

  @override
  List<Object> get props => [resultList];
}

class RemoveMultipleDocumentsAllFailureViewState extends FeatureFailure {
  final List<Either<Failure, Success>> resultList;

  RemoveMultipleDocumentsAllFailureViewState(this.resultList);

  @override
  List<Object> get props => [resultList];
}

class CopyToMySpaceViewState extends ViewState {
  final List<Document> documentsList;

  CopyToMySpaceViewState(this.documentsList);

  @override
  List<Object> get props => [documentsList];
}

class CopyToMySpaceFailure extends FeatureFailure {
  final Exception exception;

  CopyToMySpaceFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

class CopyMultipleToMySpaceAllSuccessViewState extends ViewState {
  final List<Either<Failure, Success>> resultList;

  CopyMultipleToMySpaceAllSuccessViewState(this.resultList);

  @override
  List<Object> get props => [resultList];
}

class CopyMultipleToMySpaceHasSomeFilesViewState extends ViewState {
  final List<Either<Failure, Success>> resultList;

  CopyMultipleToMySpaceHasSomeFilesViewState(this.resultList);

  @override
  List<Object> get props => [resultList];
}

class CopyMultipleToMySpaceAllFailure extends FeatureFailure {
  final List<Either<Failure, Success>> resultList;

  CopyMultipleToMySpaceAllFailure(this.resultList);

  @override
  List<Object> get props => [resultList];
}

class CopyMultipleContainsFoldersToMySpaceFailure extends FeatureFailure {
  CopyMultipleContainsFoldersToMySpaceFailure();

  @override
  List<Object> get props => [];
}

class RenameDocumentViewState extends ViewState {
  final Document document;

  RenameDocumentViewState(this.document);

  @override
  List<Object> get props => [document];
}

class RenameDocumentFailure extends FeatureFailure {
  final exception;

  RenameDocumentFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

class GetDocumentViewState extends ViewState {
  final DocumentDetails document;

  GetDocumentViewState(this.document);

  @override
  List<Object> get props => [document];
}

class GetDocumentFailure extends FeatureFailure {
  final exception;

  GetDocumentFailure(this.exception);

  @override
  List<Object> get props => [exception];
}