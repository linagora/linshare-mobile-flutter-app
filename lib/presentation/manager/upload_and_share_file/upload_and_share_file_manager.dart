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

import 'package:async/async.dart';
import 'package:dartz/dartz.dart';
import 'package:domain/domain.dart';
import 'package:linshare_flutter_app/presentation/manager/quota/verify_quota_manager.dart';
import 'package:linshare_flutter_app/presentation/model/upload_and_share/upload_and_share_file_state_list.dart';
import 'package:linshare_flutter_app/presentation/model/upload_and_share/upload_and_share_model.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/my_space_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/share_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_file_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/helper/file_helper.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/upload_file_arguments.dart';
import 'package:redux/redux.dart';
import 'dart:developer' as developer;

class UploadShareFileManager {
  UploadShareFileManager(
    this._store,
    this._flowUploadDocumentInteractor,
    this._shareDocumentInteractor,
    this._flowUploadWorkGroupDocumentInteractor,
    this._fileHelper,
    this._getQuotaInteractor
  ) {
    _verifyQuotaManager = VerifyQuotaManager(_store, _getQuotaInteractor);
    _handleFlowProgressState();
  }

  final Store<AppState> _store;

  final StreamGroup<Either<Failure, Success>> _progressStateStreamGroup
    = StreamGroup<Either<Failure, Success>>.broadcast();

  final UploadAndShareFileStateList _uploadingStateFiles = UploadAndShareFileStateList();
  UploadAndShareFileStateList get uploadingStateFiles => _uploadingStateFiles;

  final FlowUploadDocumentInteractor _flowUploadDocumentInteractor;
  final ShareDocumentInteractor _shareDocumentInteractor;
  final FlowUploadWorkGroupDocumentInteractor _flowUploadWorkGroupDocumentInteractor;
  final FileHelper _fileHelper;

  final GetQuotaInteractor _getQuotaInteractor;
  late VerifyQuotaManager _verifyQuotaManager;

  Future<void> justUploadFiles(List<FileInfo> uploadFiles) async {
    if (!await _verifyQuotaManager.hasEnoughQuotaAndMaxFileSize(filesInfos: uploadFiles)) {
      return;
    }

    uploadFiles.forEach((uploadFile) async {
      await _upload(uploadFile, UploadAndShareAction.upload);
    });
  }

  Future<void> uploadFilesThenShare(
    List<FileInfo> uploadFiles,
    List<AutoCompleteResult>? recipients,
  ) async {
    uploadFiles.forEach((uploadFile) async {
      await _upload(uploadFile, UploadAndShareAction.uploadAndShare, recipients: recipients);
    });
  }

  Future<void> _upload(FileInfo uploadFile, UploadAndShareAction action, {List<AutoCompleteResult>? recipients}) async {
    developer.log('_upload()', name: 'UploadShareFileManager');
    final flowFile = _flowUploadDocumentInteractor.execute(uploadFile);

    _uploadingStateFiles.add(UploadAndShareFileState
        .initial(uploadFile, action, flowFile.uploadTaskId, recipients: recipients ?? <AutoCompleteResult>[]));

    await _progressStateStreamGroup.add(flowFile.progressState);

    _store.dispatch(UploadFilesUpdateAction(_uploadingStateFiles.uploadingStateFiles));
  }

  void uploadToSharedSpace(
    List<FileInfo> uploadFiles,
    SharedSpaceId sharedSpaceId, {
    WorkGroupNodeId? parentNodeId,
  }) async {
    uploadFiles.forEach((uploadFile) async {
      await _uploadToSharedSpace(uploadFile, sharedSpaceId, parentNodeId: parentNodeId);
    });
  }

  Future<void> _uploadToSharedSpace(
    FileInfo uploadFile,
    SharedSpaceId sharedSpaceId, {
    WorkGroupNodeId? parentNodeId,
  }) async {
    developer.log('_uploadToSharedSpace()', name: 'UploadShareFileManager');

    final flowFile = _flowUploadWorkGroupDocumentInteractor
      .execute(uploadFile, sharedSpaceId, parentNodeId: parentNodeId);

    final state = UploadAndShareFileState.initial(uploadFile, UploadAndShareAction.uploadSharedSpace, flowFile.uploadTaskId);
    _uploadingStateFiles.add(state);

    await _progressStateStreamGroup.add(flowFile.progressState);

    _store.dispatch(UploadFilesUpdateAction(_uploadingStateFiles.uploadingStateFiles));
  }

  void _handleFlowProgressState() {
    developer.log('_handleFlowProgressState()', name: 'UploadShareFileManager');
    _progressStateStreamGroup.stream.listen((flowUploadState) {
      flowUploadState.fold(
        (failure) {
          if (failure is ErrorFlowUploadState) {
            _uploadingStateFiles.updateElementByUploadTaskId(
              failure.flowFile.uploadTaskId,
              (currentState) => currentState?.copyWith(uploadStatus: UploadFileStatus.uploadFailed));

            _handleFlowUploadFileFailure(failure);
            // neu upload and share thi sao
          }
        },
        (success) {
          if (success is UploadingFlowUploadState) {
            developer.log('_handleFlowProgressState(): uploading: ${success.progress}', name: 'UploadShareFileManager');

            _uploadingStateFiles.updateElementByUploadTaskId(
              success.flowFile.uploadTaskId,
              (currentState) => (currentState?.uploadStatus.completed ?? false)
                ? currentState
                : currentState?.copyWith(
                    uploadingProgress: (success.progress * 100 / success.total).floor(),
                    uploadStatus: UploadFileStatus.uploading)
            );

          } else if (success is SuccessFlowUploadState) {
            _handleUploadFileSucceed(success);
          }

          _store.dispatch(UploadFilesUpdateAction(_uploadingStateFiles.uploadingStateFiles));
        });
    });
  }

  void _handleUploadFileSucceed(SuccessFlowUploadState uploadSuccess) {
    developer.log('_handleUploadFileSucceed()', name: 'UploadShareFileManager');
    final fileState = _uploadingStateFiles.getElementByUploadTaskId(uploadSuccess.flowFile.uploadTaskId);
    if (fileState != null) {
      _fileHelper.deleteFile(fileState.file);
      if (fileState.action == UploadAndShareAction.uploadAndShare && fileState.recipients.isNotEmpty) {
        if (uploadSuccess is SuccessWithResourceFlowUploadState) {
          _shareAfterUploaded(uploadSuccess, fileState.recipients);
        }
      } else {
        _uploadingStateFiles.updateElementByUploadTaskId(
          uploadSuccess.flowFile.uploadTaskId,
          (currentState) {
            final newState = currentState?.copyWith(
              uploadingProgress: 100,
              uploadStatus: UploadFileStatus.succeed,
            );
            return newState;
          },
        );
      }
      _store.dispatch(UploadFileAction(Right(uploadSuccess)));
    }
  }

  void _handleFlowUploadFileFailure(ErrorFlowUploadState errorFlowUploadState) {
    final fileState = _uploadingStateFiles.getElementByUploadTaskId(errorFlowUploadState.flowFile.uploadTaskId);
    if (fileState != null) {
      _fileHelper.deleteFile(fileState.file);
    }
  }

  void _shareAfterUploaded(
    SuccessWithResourceFlowUploadState fileUploadSuccess,
    List<AutoCompleteResult> recipients,
  ) async {
    final uploadedDocumentId = DocumentId(fileUploadSuccess.resourceId);
    final shareResult = await _share(recipients, [uploadedDocumentId]);

    shareResult.fold(
      (failure) {
        _uploadingStateFiles.updateElementByUploadTaskId(
          fileUploadSuccess.flowFile.uploadTaskId,
          (currentState) => currentState?.copyWith(uploadStatus: UploadFileStatus.shareFailed),
        );
      },
      (success) {
        _uploadingStateFiles.updateElementByUploadTaskId(
          fileUploadSuccess.flowFile.uploadTaskId,
          (currentState) => currentState?.copyWith(uploadStatus: UploadFileStatus.succeed),
        );
      },
    );

    _store.dispatch(UploadFilesUpdateAction(_uploadingStateFiles.uploadingStateFiles));
  }

  Future<void> justShare(
    List<AutoCompleteResult>? recipients,
    List<DocumentId>? shareDocuments,
    {ShareDestination? shareDestination}
  ) async {
    if(recipients == null || shareDocuments == null) {
      return;
    }
    await _share(recipients, shareDocuments)
        .then((shareResult) => shareResult.fold(
            (failure) => _store.dispatch(ShareAction(shareResult)),
            (success) {
              _store.dispatch(ShareAction(shareResult));
              _pushNotifyUpdateDataInShareDestination(shareDestination, success);
            }));
  }

  void _pushNotifyUpdateDataInShareDestination(ShareDestination? shareDestination, Success success) {
    if (shareDestination == ShareDestination.mySpace) {
      _store.dispatch(MySpaceAction(Right(success)));
    }
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
