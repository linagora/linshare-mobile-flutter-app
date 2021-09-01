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

import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:dartz/dartz.dart';
import 'package:domain/domain.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/account_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/functionality_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/my_space_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/network_connectivity_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/received_share_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/shared_space_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/ui_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_request_group_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_request_group_active_closed_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_request_group_archived_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_request_group_created_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_request_inside_action.dart';
import 'package:linshare_flutter_app/presentation/redux/online_thunk_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/ui_state.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/util/router/route_paths.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/upload_file_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/upload_file_manager.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

class HomeViewModel extends BaseViewModel {
  final AppNavigation _appNavigation;
  final UploadFileManager _uploadFileManager;
  final Connectivity _connectivity;
  final GetAuthorizedInteractor _getAuthorizedInteractor;
  final GetAllFunctionalityInteractor _getAllFunctionalityInteractor;
  late StreamSubscription _uploadFileManagerStreamSubscription;
  late StreamSubscription _connectivityStreamSubscription;

  HomeViewModel(
      Store<AppState> store,
      this._appNavigation,
      this._getAuthorizedInteractor,
      this._uploadFileManager,
      this._connectivity,
      this._getAllFunctionalityInteractor
  ) : super(store) {
    _registerPendingUploadFile();
    _registerNetworkConnectivityState();
    _getAllFunctionality();
    _getAuthorizedUser();
  }

  void _getAllFunctionality() {
    store.dispatch(_getAllFunctionalityAction());
  }

  OnlineThunkAction _getAllFunctionalityAction() {
    return OnlineThunkAction((Store<AppState> store) async {
      await _getAllFunctionalityInteractor.execute()
          .then((result) => result.fold(
              (failure) => store.dispatch(FunctionalityGetAllAction(Left(failure))),
              (success) => store.dispatch(FunctionalityGetAllAction(Right(success)))));
    });
  }

  void _getAuthorizedUser() {
    store.dispatch(_getAuthorizedUserAction());
  }

  OnlineThunkAction _getAuthorizedUserAction() {
    return OnlineThunkAction((Store<AppState> store) async {
      await _getAuthorizedInteractor.execute().then((result) => result.fold(
        (left) => null,
        (right) {
          if(right is GetAuthorizedUserViewState) {
            return store.dispatch(_getAuthorizedUserSuccessAction((right)));
          }
        }));
    });
  }

  ThunkAction<AppState> _getAuthorizedUserSuccessAction(GetAuthorizedUserViewState success) {
    return (Store<AppState> store) async {
      store.dispatch(SetAccountInformationsAction(success.user));
    };
  }

  void _registerPendingUploadFile() {
    _uploadFileManagerStreamSubscription =
        _uploadFileManager.pendingListFileInfo.stream.listen((listFileInfo) {
      if (listFileInfo != null && listFileInfo.isNotEmpty) {
        _uploadFileManager.clearPendingFile();
        _appNavigation.push(
          RoutePaths.uploadDocumentRoute,
          arguments: UploadFileArguments(listFileInfo, shareType: ShareType.uploadFromOutside),
        );
      }
    });
  }

  void _registerNetworkConnectivityState() async {
    store.dispatch(SetNetworkConnectivityStateAction(await _connectivity.checkConnectivity()));
    _connectivityStreamSubscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      store.dispatch(SetNetworkConnectivityStateAction(result));
      if (store.state.account.user == null && result != ConnectivityResult.none) {
        _getAuthorizedUser();
      }
    });
  }

  void clickViewCurrentUploads() {
    _appNavigation.push(
      RoutePaths.currentUploads,
    );
  }

  void cancelSearchState() {
    store.dispatch(DisableSearchStateAction());
    if (store.state.uiState.searchState.searchDestination == SearchDestination.mySpace) {
      store.dispatch(MySpaceAction(Right(DisableSearchViewState())));
      store.dispatch(CleanMySpaceStateAction());
    } else if (store.state.uiState.searchState.searchDestination == SearchDestination.sharedSpace ||
        store.state.uiState.searchState.searchDestination == SearchDestination.allSharedSpaces) {
      store.dispatch(SharedSpaceAction(Right(DisableSearchViewState())));
      store.dispatch(CleanSharedSpaceStateAction());
    } else if (store.state.uiState.searchState.searchDestination == SearchDestination.receivedShares) {
      store.dispatch(ReceivedShareAction(Right(DisableSearchViewState())));
      store.dispatch(CleanReceivedShareStateAction());
    } else if (store.state.uiState.searchState.searchDestination == SearchDestination.uploadRequestGroups) {
      store.dispatch(UploadRequestGroupAction(Right(DisableSearchViewState())));
      store.dispatch(CleanUploadRequestGroupAction());
      store.dispatch(CleanCreatedUploadRequestGroupAction());
      store.dispatch(CleanArchivedUploadRequestGroupAction());
      store.dispatch(CleanActiveClosedUploadRequestGroupAction());
    } else if (store.state.uiState.searchState.searchDestination == SearchDestination.uploadRequestInside) {
      store.dispatch(UploadRequestInsideAction(Right(DisableSearchViewState())));
      store.dispatch(CleanUploadRequestInsideAction());
    }
  }

  void search(String text) {
    if (store.state.uiState.searchState.searchDestination == SearchDestination.mySpace) {
      store.dispatch(MySpaceAction(Right(SearchDocumentNewQuery(SearchQuery(text.trim())))));
      store.dispatch(CleanMySpaceStateAction());
    } else if (store.state.uiState.searchState.searchDestination == SearchDestination.sharedSpace) {
      store.dispatch(SharedSpaceAction(Right(SearchWorkGroupNodeNewQuery(SearchQuery(text.trim())))));
      store.dispatch(CleanSharedSpaceStateAction());
    } else if (store.state.uiState.searchState.searchDestination == SearchDestination.allSharedSpaces) {
      store.dispatch(SharedSpaceAction(Right(SearchSharedSpaceNodeNestedNewQuery(SearchQuery(text.trim())))));
      store.dispatch(CleanSharedSpaceStateAction());
    } else if (store.state.uiState.searchState.searchDestination == SearchDestination.receivedShares) {
      store.dispatch(ReceivedShareAction(Right(SearchReceivedSharesNewQuery(SearchQuery(text.trim())))));
      store.dispatch(CleanReceivedShareStateAction());
    } else if (store.state.uiState.searchState.searchDestination == SearchDestination.uploadRequestGroups) {
      store.dispatch(UploadRequestGroupAction(Right(SearchUploadRequestGroupsNewQuery(SearchQuery(text.trim())))));
      store.dispatch(CleanUploadRequestGroupAction());
			store.dispatch(CleanCreatedUploadRequestGroupAction());
			store.dispatch(CleanArchivedUploadRequestGroupAction());
			store.dispatch(CleanActiveClosedUploadRequestGroupAction());
    } else if (store.state.uiState.searchState.searchDestination == SearchDestination.uploadRequestInside) {
      store.dispatch(UploadRequestInsideAction(Right(SearchUploadRequestEntriesNewQuery(SearchQuery(text.trim())))));
      store.dispatch(CleanUploadRequestInsideAction());
    }
  }

  @override
  void onDisposed() {
    _uploadFileManager.closeUploadFileManagerStream();
    _uploadFileManagerStreamSubscription.cancel();
    _connectivityStreamSubscription.cancel();
    super.onDisposed();
  }
}
