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

import 'package:dartz/dartz.dart';
import 'package:domain/domain.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_file_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:redux/redux.dart';

class VerifyQuotaManager {
  final Store<AppState> _store;
  final GetQuotaInteractor _getQuotaInteractor;

  VerifyQuotaManager(this._store, this._getQuotaInteractor);

  Future<bool> hasEnoughQuotaAndMaxFileSize({required List<FileInfo> filesInfos}) async {
    if (_store.state.account.user == null) {
      return true;
    }

    if(_store.state.account.user == null) {
      return false;
    }
    final quotaUuid = _store.state.account.user!.quotaUuid;
    final accountQuotaResult = (await _getQuotaInteractor.execute(quotaUuid));

    if (accountQuotaResult.isLeft()) {
      _store.dispatch(UploadFileAction(accountQuotaResult));
      return false;
    }

    if (filesInfos.isEmpty) {
      return false;
    }

    final totalFilesSize = filesInfos.map((fileInfo) => fileInfo.fileSize).reduce((value, element) => value + element);

    final accountQuota = accountQuotaResult.fold((failure) => null, (success) {
      if (success is AccountQuotaViewState) {
        return success.accountQuota;
      } else {
        return null;
      }
    });

    if (accountQuota == null) {
      return false;
    }

    final quotaLeft = accountQuota.quota.size - accountQuota.usedSpace.size;

    if (totalFilesSize > quotaLeft) {
      _store.dispatch(UploadFileAction(Left(NotEnoughQuotaMySpaceFailure(accountQuota.quota.size))));
      return false;
    }

    final tooBigFiles = filesInfos.where((fileInfo) => fileInfo.fileSize > accountQuota.maxFileSize.size);

    if (tooBigFiles.isNotEmpty) {
      _store.dispatch(UploadFileAction(Left(TooBigFilesMySpaceFailure(tooBigFiles.toList(), accountQuota.maxFileSize.size))));
      return false;
    }

    return true;
  }
}
