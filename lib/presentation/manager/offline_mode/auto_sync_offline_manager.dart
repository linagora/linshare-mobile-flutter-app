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

import 'package:connectivity/connectivity.dart';
import 'package:dartz/dartz.dart';
import 'package:domain/domain.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/my_space_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/shared_space_document_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:redux/redux.dart';

class AutoSyncOfflineManager {

  final Store<AppState> _store;
  final AutoSyncAvailableOfflineMultipleDocumentInteractor _autoSyncAvailableOfflineMultipleDocumentInteractor;
  final AutoSyncAvailableOfflineMultipleSharedSpaceDocumentInteractor _autoSyncAvailableOfflineMultipleSharedSpaceDocumentInteractor;

  AutoSyncOfflineManager(
    this._store,
    this._autoSyncAvailableOfflineMultipleDocumentInteractor,
    this._autoSyncAvailableOfflineMultipleSharedSpaceDocumentInteractor,
  );

  void syncOfflineDocument(List<Document> documents) async {
    if (_store.state.networkConnectivityState.connectivityResult != ConnectivityResult.none) {
      await _autoSyncAvailableOfflineMultipleDocumentInteractor.execute(documents)
        .then((response) => response.fold(
          (failure) {
            if (failure is MakeAvailableOfflineMultipleDocumentsAllFailure
              || failure is MakeAvailableOfflineMultipleDocumentsThrowExceptionFailure) {
              _store.dispatch(MySpaceAction(Left<Failure, Success>(failure)));
            }
          },
          (success) {
            if (success is MakeAvailableOfflineMultipleDocumentsAllSuccessViewState
              || success is MakeAvailableOfflineMultipleDocumentsHasSomeFilesFailedViewState) {
              _store.dispatch(MySpaceAction(Right<Failure, Success>(success)));
            }
          }
        ));
      }
  }

  void syncOfflineSharedSpaceDocument(List<WorkGroupDocument> workGroupDocuments) async {
    if (_store.state.networkConnectivityState.connectivityResult != ConnectivityResult.none) {
      await _autoSyncAvailableOfflineMultipleSharedSpaceDocumentInteractor.execute(workGroupDocuments)
        .then((response) => response.fold(
          (failure) {
            if (failure is MakeAvailableOfflineMultipleSharedSpaceDocumentsAllFailure
                || failure is MakeAvailableOfflineMultipleSharedSpaceDocumentsThrowExceptionFailure) {
              _store.dispatch(SharedSpaceDocumentAction(Left<Failure, Success>(failure)));
            }
          },
          (success) {
            if (success is MakeAvailableOfflineMultipleSharedSpaceDocumentsAllSuccessViewState
                || success is MakeAvailableOfflineMultipleSharedSpaceDocumentsHasSomeFilesFailedViewState) {
              _store.dispatch(SharedSpaceDocumentAction(Right<Failure, Success>(success)));
            }
          }));
    }
  }

}