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
// <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf
//
// for more details.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for
// more details.
// You should have received a copy of the GNU Affero General Public License and its
// applicable Additional Terms for LinShare along with this program. If not, see
// <http://www.gnu.org/licenses
// for the GNU Affero General Public License version
//
// 3 and <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf
// for
//
// the Additional Terms applicable to LinShare software.

import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';

class UploadAndShareFileState extends Equatable {
  final FileInfo file;

  final UploadTaskId uploadTaskId;

  final UploadAndShareAction action;

  final UploadFileStatus uploadStatus;

  final int uploadingProgress;

  final List<AutoCompleteResult> recipients;

  UploadAndShareFileState(
    this.file,
    this.action,
    this.uploadTaskId, {
    this.uploadStatus = UploadFileStatus.waiting,
    this.uploadingProgress = 0,
    this.recipients = const <AutoCompleteResult>[],
  });

  factory UploadAndShareFileState.initial(
    FileInfo file,
    UploadAndShareAction action,
    UploadTaskId uploadTaskId, {
    List<AutoCompleteResult> recipients = const <AutoCompleteResult>[],
  }) {
    return UploadAndShareFileState(file, action, uploadTaskId, recipients: recipients);
  }

  UploadAndShareFileState copyWith({
    FileInfo? file,
    UploadTaskId? uploadTaskId,
    UploadFileStatus? uploadStatus,
    int? uploadingProgress,
    List<AutoCompleteResult>? recipients
  }) {
    return UploadAndShareFileState(
      file ?? this.file,
      action,
      uploadTaskId ?? this.uploadTaskId,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      uploadingProgress: uploadingProgress ?? this.uploadingProgress,
      recipients: recipients ?? this.recipients,
    );
  }

  @override
  List<Object?> get props => [file, action, uploadTaskId, uploadStatus, uploadingProgress, recipients];
}

enum UploadFileStatus { waiting, uploading, uploadFailed, shareFailed, succeed }

extension UploadFileStatusExtension on UploadFileStatus {
  bool get completed => this == UploadFileStatus.uploadFailed ||
      this == UploadFileStatus.shareFailed ||
      this == UploadFileStatus.succeed;
}

enum UploadAndShareAction { upload, uploadAndShare, uploadSharedSpace }

extension UploadAndShareFileStateListExtension on List<UploadAndShareFileState?> {
  List<UploadAndShareFileState?> replaceBy(
    CompareStateCallback compareCallback,
    GetNewStateCallback getNewStateCallback,
  ) {
    final matchIndex = indexWhere((element) => compareCallback(element));
    if (matchIndex >= 0) {
      this[matchIndex] = getNewStateCallback(this[matchIndex]);
    }
    return this;
  }

  List<UploadAndShareFileState?> replaceByUploadTaskId(
    UploadTaskId uploadTaskId,
    GetNewStateCallback getNewStateCallback,
  ) {
    return replaceBy(
      (state) => state?.uploadTaskId == uploadTaskId,
      getNewStateCallback,
    );
  }
}

typedef GetNewStateCallback = UploadAndShareFileState? Function(UploadAndShareFileState? currentState);
typedef CompareStateCallback = bool Function(UploadAndShareFileState? state);
