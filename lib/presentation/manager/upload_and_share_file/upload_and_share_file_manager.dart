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

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:domain/domain.dart';
import 'package:linshare_flutter_app/presentation/model/upload_and_share/upload_and_share_file_state_list.dart';
import 'package:linshare_flutter_app/presentation/model/upload_and_share/upload_and_share_model.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/share_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_file_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:redux/redux.dart';

class UploadShareFileManager {
  UploadShareFileManager(
    this._store,
    this._uploadingFileStream,
    this._uploadMySpaceDocumentInteractor,
    this._shareDocumentInteractor,
    this._uploadWorkGroupDocumentInteractor,
  ) {
    _handleUploadingFileStream(_uploadingFileStream);
  }

  final Store<AppState> _store;

  final Stream<Either<Failure, Success>> _uploadingFileStream;

  final UploadAndShareFileStateList _uploadingStateFiles = UploadAndShareFileStateList();
  UploadAndShareFileStateList get uploadingStateFiles => _uploadingStateFiles;

  final UploadMySpaceDocumentInteractor _uploadMySpaceDocumentInteractor;
  final ShareDocumentInteractor _shareDocumentInteractor;
  final UploadWorkGroupDocumentInteractor _uploadWorkGroupDocumentInteractor;

  void justUploadFiles(List<FileInfo> uploadFiles) async {
    uploadFiles.forEach((uploadFile) async {
      await _upload(uploadFile, UploadAndShareAction.upload);
    });
  }

  void uploadFilesThenShare(
    List<FileInfo> uploadFiles,
    List<AutoCompleteResult> recipients,
  ) async {
    uploadFiles.forEach((uploadFile) async {
      await _upload(uploadFile, UploadAndShareAction.uploadAndShare, recipients: recipients);
    });
  }

  Future<void> _upload(FileInfo uploadFile, UploadAndShareAction action, {List<AutoCompleteResult> recipients}) async {
    (await _uploadMySpaceDocumentInteractor.execute(uploadFile)).fold(
      (failure) {
        final state = UploadAndShareFileState.initial(uploadFile, action, UploadTaskId.undefined(), recipients: recipients)
            .copyWith(uploadStatus: UploadFileStatus.uploadFailed);
        _uploadingStateFiles.add(state);

        _store.dispatch(UploadFilesUpdateAction(_uploadingStateFiles.uploadingStateFiles));
      },
      (success) {
        final uploadTaskId = (success as FileUploadState).taskId;
        _uploadingStateFiles.add(UploadAndShareFileState.initial(uploadFile, action, uploadTaskId, recipients: recipients));

        _store.dispatch(UploadFilesUpdateAction(_uploadingStateFiles.uploadingStateFiles));
      },
    );
  }

  void uploadToSharedSpace(
    List<FileInfo> uploadFiles,
    SharedSpaceId sharedSpaceId, {
    WorkGroupNodeId parentNodeId,
  }) async {
    uploadFiles.forEach((uploadFile) async {
      await _uploadToSharedSpace(uploadFile, sharedSpaceId, parentNodeId: parentNodeId);
    });
  }

  Future<void> _uploadToSharedSpace(
    FileInfo uploadFile,
    SharedSpaceId sharedSpaceId, {
    WorkGroupNodeId parentNodeId,
  }) async {
    (await _uploadWorkGroupDocumentInteractor.execute(uploadFile, sharedSpaceId, parentNodeId: parentNodeId)).fold(
      (failure) {
        final state = UploadAndShareFileState.initial(uploadFile, UploadAndShareAction.uploadSharedSpace, UploadTaskId.undefined())
            .copyWith(uploadStatus: UploadFileStatus.uploadFailed);
        _uploadingStateFiles.add(state);

        _store.dispatch(UploadFilesUpdateAction(_uploadingStateFiles.uploadingStateFiles));
      },
      (success) {
        final uploadTaskId = (success as FileUploadState).taskId;
        _uploadingStateFiles.add(UploadAndShareFileState.initial(uploadFile, UploadAndShareAction.uploadSharedSpace, uploadTaskId));

        _store.dispatch(UploadFilesUpdateAction(_uploadingStateFiles.uploadingStateFiles));
      },
    );
  }

  void _handleUploadingFileStream(Stream<Either<Failure, Success>> uploadingFileStream) {
    uploadingFileStream.listen((resultEvent) {
        resultEvent.fold(
          (failure) => null,
          (success) {
            if (success is UploadingProgress) {
              _uploadingStateFiles.updateElementByUploadTaskId(
                success.uploadTaskId,
                (currentState) {
                  return currentState.uploadStatus.completed ? currentState : currentState.copyWith(
                    uploadingProgress: success.progress,
                    uploadStatus: UploadFileStatus.uploading,
                  );
                },
              );
            } else if (success is FileUploadSuccess) {
              _handleUploadFileSucceed(success);
            }

            _store.dispatch(UploadFilesUpdateAction(_uploadingStateFiles.uploadingStateFiles));
          },
        );
      },
      onError: null,
    );
  }

  void _handleUploadFileSucceed(FileUploadSuccess uploadSuccess) {
    final fileState = _uploadingStateFiles.getElementByUploadTaskId(uploadSuccess.uploadTaskId);
    if (fileState.action == UploadAndShareAction.uploadAndShare) {
      _shareAfterUploaded(uploadSuccess, fileState.recipients);
    } else {
      _uploadingStateFiles.updateElementByUploadTaskId(
        uploadSuccess.uploadTaskId,
        (currentState) {
          final newState = currentState.copyWith(
            uploadingProgress: 100,
            uploadStatus: UploadFileStatus.succeed,
          );

          return newState;
        },
      );
    }
  }

  void _shareAfterUploaded(
    FileUploadSuccess fileUploadSuccess,
    List<AutoCompleteResult> recipients,
  ) async {
    final uploadedDocument = fileUploadSuccess.uploadedDocument;
    final shareResult = await _share(recipients, [uploadedDocument.documentId]);

    shareResult.fold(
      (failure) {
        _uploadingStateFiles.updateElementByUploadTaskId(
          fileUploadSuccess.uploadTaskId,
          (currentState) => currentState.copyWith(uploadStatus: UploadFileStatus.shareFailed),
        );
      },
      (success) {
        _uploadingStateFiles.updateElementByUploadTaskId(
          fileUploadSuccess.uploadTaskId,
          (currentState) => currentState.copyWith(uploadStatus: UploadFileStatus.succeed),
        );
      },
    );

    _store.dispatch(UploadFilesUpdateAction(_uploadingStateFiles.uploadingStateFiles));
  }

  void justShare(
    List<AutoCompleteResult> recipients,
    List<DocumentId> shareDocuments,
  ) async {
    await _share(recipients, shareDocuments)
        .then((shareResult) => _store.dispatch(ShareAction(shareResult)));
  }

  Future<Either<Failure, Success>> _share(
    List<AutoCompleteResult> recipients,
    List<DocumentId> shareDocuments,
  ) async {
    final genericUsers = recipients
        .where(
          (element) =>
              element is UserAutoCompleteResult ||
              element is SimpleAutoCompleteResult,
        )
        .map(
          (data) => GenericUser(
            data.getSuggestionMail(),
            firstName: none(),
            lastName: none(),
          ),
        )
        .toList();
    final mailingListIds = recipients
        .whereType<MailingListAutoCompleteResult>()
        .map((data) => MailingListId(data.identifier))
        .toList();

    return await _shareDocumentInteractor.execute(
      shareDocuments,
      mailingListIds,
      genericUsers,
    );
  }
}
