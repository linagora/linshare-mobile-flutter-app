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
import 'package:linshare_flutter_app/presentation/redux/actions/share_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/shared_space_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/ui_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/ui_state.dart';
import 'package:linshare_flutter_app/presentation/util/router/route_paths.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:redux/src/store.dart';
import 'package:redux_thunk/redux_thunk.dart';

class SharedSpaceViewModel extends BaseViewModel {
  final GetAllSharedSpacesInteractor _getAllSharedSpacesInteractor;
  final SearchSharedSpaceNodeNestedInteractor _searchSharedSpaceNodeNestedInteractor;
  StreamSubscription _storeStreamSubscription;
  List<SharedSpaceNodeNested> _sharedSpaceNodes;

  SearchQuery _searchQuery = SearchQuery('');
  SearchQuery get searchQuery  => _searchQuery;

  SharedSpaceViewModel(
    Store<AppState> store,
    this._getAllSharedSpacesInteractor,
    this._searchSharedSpaceNodeNestedInteractor
  ) : super(store) {
    _storeStreamSubscription = store.onChange.listen((event) {
      event.sharedSpaceState.viewState.fold(
              (failure) => null,
              (success) {
            if (success is SearchSharedSpaceNodeNestedNewQuery && event.uiState.searchState.searchStatus == SearchStatus.ACTIVE) {
              _search(success.searchQuery);
            } else if (success is DisableSearchViewState) {
              store.dispatch((SharedSpaceSetSearchResultAction(_sharedSpaceNodes)));
              _searchQuery = SearchQuery('');
            }
          });
    });
  }

  void getAllSharedSpaces() {
    store.dispatch(_getAllSharedSpacesAction());
  }

  ThunkAction<AppState> _getAllSharedSpacesAction() {
    return (Store<AppState> store) async {
      store.dispatch(StartSharedSpaceLoadingAction());
      await _getAllSharedSpacesInteractor.execute().then((result) => result.fold(
        (failure) {
          store.dispatch(SharedSpaceGetAllSharedSpacesAction(Left(failure)));
          _sharedSpaceNodes = [];
        },
        (success) {
          store.dispatch(SharedSpaceGetAllSharedSpacesAction(Right(success)));
          _sharedSpaceNodes = (success is SharedSpaceViewState) ? success.sharedSpacesList : [];
        }));
    };
  }

  void openSharedSpace(SharedSpaceNodeNested sharedSpace) {
    if (_isInSearchState()) {
      store.dispatch(DisableSearchStateAction());
      store.dispatch((SharedSpaceSetSearchResultAction(_sharedSpaceNodes)));
      _searchQuery = SearchQuery('');
    }
    store.dispatch(SharedSpaceInsideView(RoutePaths.sharedSpaceInside, sharedSpace));
  }

  void openSearchState() {
    store.dispatch(EnableSearchStateAction(SearchDestination.ALL_SHARED_SPACES));
    store.dispatch((SharedSpaceSetSearchResultAction([])));
  }

  void _search(SearchQuery searchQuery) {
    _searchQuery = searchQuery;
    if (searchQuery.value.isNotEmpty) {
      store.dispatch(_searchSharedSpaceAction(_sharedSpaceNodes, searchQuery));
    } else {
      store.dispatch(SharedSpaceSetSearchResultAction([]));
    }
  }

  ThunkAction<AppState> _searchSharedSpaceAction(List<SharedSpaceNodeNested> sharedSpaceNodes, SearchQuery searchQuery) {
    return (Store<AppState> store) async {
      await _searchSharedSpaceNodeNestedInteractor.execute(sharedSpaceNodes, searchQuery).then((result) => result.fold(
              (failure) {
                if (_isInSearchState()) {
                  store.dispatch(SharedSpaceSetSearchResultAction([]));
                }
          },
              (success) {
                if (_isInSearchState()) {
                  store.dispatch(SharedSpaceSetSearchResultAction(
                      success is SearchSharedSpaceNodeNestedSuccess
                          ? success.sharedSpaceNodes
                          : []));
                }
              })
      );
    };
  }

  bool _isInSearchState() {
    return store.state.uiState.isInSearchState();
  }

  @override
  void onDisposed() {
    store.dispatch(CleanShareStateAction());
    _storeStreamSubscription.cancel();
  }
}
