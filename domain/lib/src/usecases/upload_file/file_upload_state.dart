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

import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';

class FileUploadState extends Success {
  final UploadTaskId taskId;

  FileUploadState(this.taskId);

  @override
  List<Object> get props => [taskId];
}

class UploadingProgress extends Success {
  final UploadTaskId uploadTaskId;
  final int progress;

  UploadingProgress(this.uploadTaskId, this.progress);

  @override
  List<Object> get props => [uploadTaskId, progress];
}

class FileUploadSuccess extends Success {
  final UploadTaskId uploadTaskId;
  final Document? uploadedDocument;
  final WorkGroupDocument? uploadedWorkGroupDocument;

  FileUploadSuccess(this.uploadTaskId, {this.uploadedDocument, this.uploadedWorkGroupDocument});

  @override
  List<Object> get props => [uploadTaskId];
}

class FileUploadFailure extends Failure {
  final UploadTaskId uploadTaskId;
  final Object exception;

  FileUploadFailure(this.uploadTaskId, this.exception);

  @override
  List<Object> get props => [uploadTaskId, exception];
}

class WorkGroupDocumentUploadSuccess extends Success {
  final WorkGroupDocument workGroupDocument;

  WorkGroupDocumentUploadSuccess(this.workGroupDocument);

  @override
  List<Object> get props => [];
}

class WorkGroupDocumentUploadFailure extends Failure {
  final FileInfo fileInfo;
  final Object exception;

  WorkGroupDocumentUploadFailure(this.fileInfo, this.exception);

  @override
  List<Object> get props => [fileInfo, exception];
}

class FileUploadProgress extends Success {
  final int progress;

  FileUploadProgress(this.progress);

  @override
  List<Object> get props => [progress];
}

class UploadTaskId extends Equatable {
  final String id;

  UploadTaskId(this.id);

  factory UploadTaskId.undefined() => UploadTaskId('');

  @override
  List<Object> get props => [id];
}

class SharingAfterUploadState extends Success {
  final List<AutoCompleteResult> recipients;
  final Document uploadedDocument;

  SharingAfterUploadState(this.recipients, this.uploadedDocument);

  @override
  List<Object> get props => [uploadedDocument, recipients];
}

class ShareAfterUploadSuccess extends SharingAfterUploadState {
  ShareAfterUploadSuccess(
    List<AutoCompleteResult> recipients,
    Document uploadedDocument,
  ) : super(recipients, uploadedDocument);
}

class ShareAfterUploadFailure extends Failure {
  final Exception exception;
  final List<AutoCompleteResult> recipients;
  final Document uploadedDocument;

  ShareAfterUploadFailure(
    this.exception,
    this.recipients,
    this.uploadedDocument,
  );

  @override
  List<Object> get props => [exception, uploadedDocument, recipients];
}
