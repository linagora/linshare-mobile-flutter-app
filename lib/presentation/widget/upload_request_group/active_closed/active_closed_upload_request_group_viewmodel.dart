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

import 'package:dartz/dartz.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_request_group_active_closed_action.dart';
import 'package:linshare_flutter_app/presentation/redux/online_thunk_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/ui_state.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_group/upload_request_group_tab_common_viewmodel.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

class ActiveClosedUploadRequestGroupViewModel extends UploadRequestGroupTabViewModel {
  final AppNavigation _appNavigation;
  final GetAllUploadRequestGroupsInteractor _getAllUploadRequestGroupsInteractor;
  final UpdateMultipleUploadRequestGroupStateInteractor _multipleUploadRequestGroupStateInteractor;
  final GetSorterInteractor _getSorterInteractor;
  final SaveSorterInteractor _saveSorterInteractor;
  final SortInteractor _sortInteractor;
  final SearchUploadRequestGroupsInteractor _searchUploadRequestGroupsInteractor;
  late StreamSubscription _storeStreamSubscription;

  SearchQuery _searchQuery = SearchQuery('');
  SearchQuery get searchQuery => _searchQuery;
  List<UploadRequestGroup> _uploadRequestListActiveClosed = [];

	ActiveClosedUploadRequestGroupViewModel(
		Store<AppState> store, 
		this._appNavigation, 
		this._getAllUploadRequestGroupsInteractor, 
		this._getSorterInteractor,
    this._saveSorterInteractor, 
		this._sortInteractor, 
		this._searchUploadRequestGroupsInteractor,
    this._multipleUploadRequestGroupStateInteractor) : super(
      store,
      _appNavigation,
      _multipleUploadRequestGroupStateInteractor) {
			_storeStreamSubscription = store.onChange.listen((event) {
				event.uploadRequestGroupState.viewState.fold((failure) => null, (success) {
					if (success is SearchUploadRequestGroupsNewQuery && event.uiState.searchState.searchStatus == SearchStatus.ACTIVE) {
						_search(success.searchQuery);
					} else if (success is DisableSearchViewState) {
						store.dispatch((UploadRequestGroupActiveClosedSetSearchResultAction(_uploadRequestListActiveClosed)));
						_searchQuery = SearchQuery('');
					}
				});
			});
  }

  void initState() {
    getUploadRequestActiveClosedStatusWithSort();
  }

  void openPopupMenuSorterActiveClosed(BuildContext context, Sorter currentSorter) {
    openPopupMenuSorter(context, currentSorter, (sorterSelected) => _sortFilesActiveClosed(sorterSelected));
  }

  void _sortFilesActiveClosed(Sorter sorter) {
    final newSorter = store.state.activeClosedUploadRequestGroupState.activeClosedSorter == sorter 
			? sorter.getSorterByOrderType(sorter.orderType) 
			: sorter;
    _appNavigation.popBack();
    store.dispatch(_sortFilesActionActiveClosed(newSorter));
  }

  ThunkAction<AppState> _sortFilesActionActiveClosed(Sorter sorter) {
    return (Store<AppState> store) async {
      await Future.wait([_saveSorterInteractor.execute(sorter), _sortInteractor.execute(_uploadRequestListActiveClosed, sorter)])
          .then((response) => response[1].fold((failure) {
                _uploadRequestListActiveClosed = [];
                store.dispatch(UploadRequestGroupActiveClosedSortAction(_uploadRequestListActiveClosed, sorter));
              }, (success) {
                _uploadRequestListActiveClosed = success is UploadRequestGroupViewState ? success.uploadRequestGroups : [];
                store.dispatch(UploadRequestGroupActiveClosedSortAction(_uploadRequestListActiveClosed, sorter));
              }));
    };
  }

  void getUploadRequestActiveClosedStatusWithSort() {
    store.dispatch(OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(StartActiveClosedUploadRequestGroupLoadingAction());

      await Future.wait([
        _getSorterInteractor.execute(OrderScreen.uploadRequestGroupsActiveClosed),
        _getAllUploadRequestGroupsInteractor.execute([UploadRequestStatus.ENABLED, UploadRequestStatus.CLOSED])
      ]).then((response) async {
        response[0].fold((failure) {
          store.dispatch(UploadRequestGroupActiveClosedGetSorterAction(Sorter.fromOrderScreen(OrderScreen.uploadRequestGroupsActiveClosed)));
        }, (success) {
          store.dispatch(UploadRequestGroupActiveClosedGetSorterAction(
              success is GetSorterSuccess ? success.sorter : Sorter.fromOrderScreen(OrderScreen.uploadRequestGroupsActiveClosed)));
        });

        response[1].fold((failure) {
          _uploadRequestListActiveClosed = [];
          store.dispatch(UploadRequestGroupGetAllActiveClosedAction(Left(failure)));
        }, (success) {
          _uploadRequestListActiveClosed = success is UploadRequestGroupViewState ? success.uploadRequestGroups : [];
          store.dispatch(UploadRequestGroupGetAllActiveClosedAction(Right(success)));
        });
      });

      store.dispatch(_sortFilesActionActiveClosed(store.state.activeClosedUploadRequestGroupState.activeClosedSorter));
    }));
  }

  void getUploadRequestActiveClosedStatus() {
    store.dispatch(OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(StartActiveClosedUploadRequestGroupLoadingAction());

      await _getAllUploadRequestGroupsInteractor.execute([UploadRequestStatus.ENABLED, UploadRequestStatus.CLOSED]).then((result) => result.fold((failure) {
            store.dispatch(UploadRequestGroupGetAllActiveClosedAction(Left(failure)));
            _uploadRequestListActiveClosed = [];
            store.dispatch(_sortFilesActionActiveClosed(store.state.activeClosedUploadRequestGroupState.activeClosedSorter));
          }, (success) {
            _uploadRequestListActiveClosed = success is UploadRequestGroupViewState ? success.uploadRequestGroups : [];
            store.dispatch(UploadRequestGroupGetAllActiveClosedAction(Right(success)));
            store.dispatch(_sortFilesActionActiveClosed(store.state.activeClosedUploadRequestGroupState.activeClosedSorter));
          }));
    }));
  }

  void _search(SearchQuery searchQuery) {
    _searchQuery = searchQuery;
    if (searchQuery.value.isNotEmpty) {
      store.dispatch(_searchUploadRequestGroupsAction(_uploadRequestListActiveClosed, searchQuery));
    } else {
      store.dispatch(UploadRequestGroupActiveClosedSetSearchResultAction([]));
    }
  }

  ThunkAction<AppState> _searchUploadRequestGroupsAction(List<UploadRequestGroup> uploadRequestGroupsList, SearchQuery searchQuery) {
    return (Store<AppState> store) async {
      await _searchUploadRequestGroupsInteractor.execute(uploadRequestGroupsList, searchQuery).then((result) => 
					result.fold(
						(failure) {
							if (isInSearchState()) {
								store.dispatch(UploadRequestGroupActiveClosedSetSearchResultAction([]));
							}
						}, 
						(success) {
							if (isInSearchState()) {
								store.dispatch(UploadRequestGroupActiveClosedSetSearchResultAction(
									success is SearchUploadRequestGroupsSuccess 
										? success.uploadRequestGroupList 
										: []));
							}
						}));
    };
  }

  @override
  void onDisposed() {
    _storeStreamSubscription.cancel();
    super.onDisposed();
  }
}
