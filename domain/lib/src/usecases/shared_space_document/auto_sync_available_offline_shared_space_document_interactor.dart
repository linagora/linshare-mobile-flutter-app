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
import 'package:domain/src/state/failure.dart';
import 'package:domain/src/state/success.dart';

class AutoSyncAvailableOfflineSharedSpaceDocumentInteractor {
  final SharedSpaceDocumentRepository _sharedSpaceDocumentRepository;
  final TokenRepository _tokenRepository;
  final CredentialRepository _credentialRepository;

  AutoSyncAvailableOfflineSharedSpaceDocumentInteractor(this._sharedSpaceDocumentRepository, this._tokenRepository, this._credentialRepository);

  Future<Either<Failure, Success>> execute(WorkGroupDocument workGroupDocument) async {
    try {
      final workGroupOffline = await _sharedSpaceDocumentRepository.getSharesSpaceDocumentOffline(workGroupDocument.workGroupNodeId);

      var filePath = workGroupDocument.localPath;
      final shaLocal = workGroupOffline?.sha256sum;

      if (shaLocal != workGroupDocument.sha256sum) {
        final downloadPreviewType = workGroupDocument.mediaType.isImageFile() ? DownloadPreviewType.image : DownloadPreviewType.original;

        filePath = await Future.wait([_tokenRepository.getToken(), _credentialRepository.getBaseUrl()], eagerError: true)
            .then((List responses) async {
          final token = responses[0];
          final baseUrl = responses[1];

          return await _sharedSpaceDocumentRepository.downloadMakeOfflineSharedSpaceDocument(
              workGroupDocument.sharedSpaceId,
              workGroupDocument.workGroupNodeId,
              workGroupDocument.name,
              downloadPreviewType,
              token,
              baseUrl);
        });
      }

      final resultUpdate = await _sharedSpaceDocumentRepository.updateSharedSpaceDocumentOffline(workGroupDocument, filePath!);

      if (resultUpdate) {
        return Right<Failure, Success>(MakeAvailableOfflineSharedSpaceDocumentViewState(OfflineModeActionResult.successful, filePath));
      } else {
        return Left<Failure, Success>(MakeAvailableOfflineSharedSpaceDocumentFailure(OfflineModeActionResult.failure));
      }
    } catch (exception) {
      return Left<Failure, Success>(MakeAvailableOfflineSharedSpaceDocumentFailure(exception));
    }
  }
}