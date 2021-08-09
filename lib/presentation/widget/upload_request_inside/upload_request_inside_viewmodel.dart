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
import 'package:linshare_flutter_app/presentation/redux/actions/upload_request_inside_action.dart';
import 'package:linshare_flutter_app/presentation/redux/online_thunk_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/upload_request_document_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/upload_request_document_type.dart';
import 'package:redux/src/store.dart';

class UploadRequestInsideViewModel extends BaseViewModel {
  final GetAllUploadRequestsInteractor _getAllUploadRequestsInteractor;
  final GetAllUploadRequestEntriesInteractor _getAllUploadRequestEntriesInteractor;
  late UploadRequestArguments _arguments;

  UploadRequestInsideViewModel(
      Store<AppState> store,
      this._getAllUploadRequestsInteractor,
      this._getAllUploadRequestEntriesInteractor
  ) : super(store);

  void initState(UploadRequestArguments arguments) {
    _arguments = arguments;
    store.dispatch(SetUploadRequestsArgumentsAction(_arguments));
    requestToGetUploadRequestAndEntries();
  }

  void requestToGetUploadRequestAndEntries() {
    store.dispatch(_getAllUploadRequests(_arguments.uploadRequestGroup.uploadRequestGroupId));
  }

  OnlineThunkAction _getAllUploadRequests(UploadRequestGroupId uploadRequestGroupId) {
    return OnlineThunkAction((Store<AppState> store) async {
      _showLoading();

      await _getAllUploadRequestsInteractor.execute(uploadRequestGroupId).then(
          (result) => result.fold(
            (failure) {
              if(failure is UploadRequestFailure) {
                _handleFailedAction(failure);
              }
            },
            (success) {
              if(success is UploadRequestViewState) {
                if(_arguments.uploadRequestGroup.collective) {
                  _loadListFilesCollectiveUploadRequest(success);
                } else {
                  if(_arguments.documentType == UploadRequestDocumentType.recipients) {
                    _loadListRecipientsIndividualUploadRequest(success);
                  } else if (_arguments.documentType == UploadRequestDocumentType.files &&
                    _arguments.selectedUploadRequest != null) {
                    _loadUploadRequestEntriesByRecipient(_arguments.selectedUploadRequest!);
                  }
                }
              }
            })
      );
    });
  }

  void _loadListFilesCollectiveUploadRequest(UploadRequestViewState uploadRequestViewState) {
    if(uploadRequestViewState.uploadRequests.isEmpty) {
      _handleFailedAction(UploadRequestFailure(UploadRequestNotFound()));
    } else {
      return store.dispatch(_getAllUploadRequestEntries(uploadRequestViewState.uploadRequests.first));
    }
  }

  void _loadListRecipientsIndividualUploadRequest(UploadRequestViewState uploadRequestViewState) {
    store.dispatch(GetAllUploadRequestsAction(Right(uploadRequestViewState)));
  }

  void _loadUploadRequestEntriesByRecipient(UploadRequest uploadRequest) {
    store.dispatch(SetSelectedUploadRequestAction(uploadRequest));
    store.dispatch(_getAllUploadRequestEntries(uploadRequest));
  }

  OnlineThunkAction _getAllUploadRequestEntries(UploadRequest uploadRequest) {
    return OnlineThunkAction((Store<AppState> store) async {
      _showLoading();
      await _getAllUploadRequestEntriesInteractor.execute(uploadRequest.uploadRequestId).then(
        (result) => result.fold(
          (failure) {
            if(failure is UploadRequestEntryFailure) {
              _handleFailedAction(failure);
            }
          },
          (success) {
            if(success is UploadRequestEntryViewState) {
              store.dispatch(GetAllUploadRequestEntriesAction(Right(success)));
            }
          })
      );
    });
  }

  void _handleFailedAction(FeatureFailure failure) {
    store.dispatch(UploadRequestInsideAction(Left(failure)));
  }

  void _showLoading() {
    store.dispatch(StartUploadRequestInsideLoadingAction());
  }
}