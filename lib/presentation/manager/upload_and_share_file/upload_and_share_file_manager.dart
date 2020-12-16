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
import 'package:linshare_flutter_app/presentation/redux/actions/share_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_file_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:redux/redux.dart';

class UploadShareFileManager {
  UploadShareFileManager(
    this._store,
    this._uploadFileInteractor,
    this._shareDocumentInteractor,
  );

  final Store<AppState> _store;

  final UploadFileInteractor _uploadFileInteractor;
  final ShareDocumentInteractor _shareDocumentInteractor;

  void justUpload(FileInfo uploadFile) async {
    await _upload(uploadFile).forEach((uploadState) {
      _store.dispatch(UploadFileAction(uploadState));
    });
  }

  void uploadThenShare(
    FileInfo uploadFile,
    List<AutoCompleteResult> recipients,
  ) async {
    await _upload(uploadFile).forEach((uploadState) {
      uploadState.fold(
        (failure) => _store.dispatch(UploadFileAction(uploadState)),
        (success) async {
          if (success is FileUploadSuccess) {
            await _shareAfterUploaded(success.uploadedDocument, recipients);
          } else {
            _store.dispatch(UploadFileAction(uploadState));
          }
        },
      );
    });
  }

  void _shareAfterUploaded(
    Document uploadedDocument,
    List<AutoCompleteResult> recipients,
  ) async {
    _store.dispatch(UploadFileAction(Right(SharingAfterUploadState(recipients, uploadedDocument))));

    final shareResult = await _share(recipients, [uploadedDocument.documentId]);

    shareResult.fold(
      (failure) => _store.dispatch(
        ShareAction(Left(ShareAfterUploadFailure(Exception(), recipients, uploadedDocument))),
      ),
      (success) => _store.dispatch(
        ShareAction(Right(ShareAfterUploadSuccess(recipients, uploadedDocument))),
      ),
    );
  }

  void justShare(
    List<AutoCompleteResult> recipients,
    List<DocumentId> shareDocuments,
  ) async {
    await _share(recipients, shareDocuments)
        .then((shareResult) => _store.dispatch(ShareAction(shareResult)));
  }

  Stream<Either<Failure, Success>> _upload(FileInfo uploadFile) {
    return _uploadFileInteractor.execute(uploadFile);
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
