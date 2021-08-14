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
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/model/file/upload_request_presentation_file.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/ui_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_request_group_action.dart';
import 'package:linshare_flutter_app/presentation/redux/online_thunk_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/ui_state.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/util/router/route_paths.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/context_menu_builder.dart';
import 'package:linshare_flutter_app/presentation/view/header/context_menu_header_builder.dart';
import 'package:linshare_flutter_app/presentation/view/header/simple_bottom_sheet_header_builder.dart';
import 'package:linshare_flutter_app/presentation/view/order_by/order_by_dialog_bottom_sheet.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_creation/upload_request_creation_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_group/add_recipient_upload_request_group/add_recipients_upload_request_group_arguments.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

class UploadRequestGroupViewModel extends BaseViewModel {
  final AppNavigation _appNavigation;
  final GetAllUploadRequestGroupsInteractor _getAllUploadRequestGroupsInteractor;
  final GetSorterInteractor _getSorterInteractor;
  final SaveSorterInteractor _saveSorterInteractor;
  final SortInteractor _sortInteractor;

  List<UploadRequestGroup> _uploadRequestListPending = [];
  List<UploadRequestGroup> _uploadRequestListActiveClosed = [];
  List<UploadRequestGroup> _uploadRequestListArchived = [];

  final SearchUploadRequestGroupsInteractor _searchUploadRequestGroupsInteractor;
  late StreamSubscription _storeStreamSubscription;

  SearchQuery _searchQuery = SearchQuery('');
  SearchQuery get searchQuery  => _searchQuery;

  int _tabIndex = 0;

  UploadRequestGroupViewModel(
      Store<AppState> store,
      this._appNavigation,
      this._getAllUploadRequestGroupsInteractor,
      this._getSorterInteractor,
      this._saveSorterInteractor,
      this._sortInteractor,
      this._searchUploadRequestGroupsInteractor
  ) : super(store) {
    _storeStreamSubscription = store.onChange.listen((event) {
      event.uploadRequestGroupState.viewState.fold(
        (failure) => null,
        (success) {
          if (success is SearchUploadRequestGroupsNewQuery && event.uiState.searchState.searchStatus == SearchStatus.ACTIVE) {
            _search(success.searchQuery);
          } else if (success is DisableSearchViewState) {
            store.dispatch((UploadRequestGroupSetSearchResultAction([..._uploadRequestListActiveClosed, ..._uploadRequestListArchived, ..._uploadRequestListPending])));
            _searchQuery = SearchQuery('');
          }
      });
    });
  }

  void initState() {
    getUploadRequestCreatedStatusWithSort();
    getUploadRequestActiveClosedStatusWithSort();
    getUploadRequestArchivedStatusWithSort();

    _tabIndex = store.state.uiState.uploadRequestGroupTabIndex;
  }

  void getListUploadRequests(UploadRequestGroup requestGroup) {
    store.dispatch(OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(DisableSearchStateAction());
      store.dispatch(UploadRequestGroupAction(Right(DisableSearchViewState())));
      store.dispatch(CleanUploadRequestGroupAction());
      store.dispatch(UploadRequestInsideView(RoutePaths.uploadRequestInside, requestGroup));
    }));
  }

  void setTabIndex(int index) {
    _tabIndex = index;
  }

  void openUploadRequestAddMenu(BuildContext context, List<Widget> actionTiles) {
    store.dispatch(_handleUploadRequestAddMenuAction(context, actionTiles));
  }

  ThunkAction<AppState> _handleUploadRequestAddMenuAction(
      BuildContext context, List<Widget> actionTiles) {
    return (Store<AppState> store) async {
      ContextMenuBuilder(context, areTilesHorizontal: true)
          .addHeader(
              SimpleBottomSheetHeaderBuilder(Key('add_upload_request_bottom_sheet_header_builder'))
                  .addLabel(AppLocalizations.of(context).add_new_upload_request)
                  .build())
          .addTiles(actionTiles)
          .build();
    };
  }

  void addNewUploadRequest(UploadRequestCreationType type, List<Functionality?> uploadRequestFunctionalities) {
    _appNavigation.popBack();
    _appNavigation.push(
      RoutePaths.createUploadRequest,
      arguments: UploadRequestCreationArguments(type, uploadRequestFunctionalities),
    );
  }

  // Upload Request Groups Active / Closed
  void openPopupMenuSorterActiveClosed(BuildContext context, Sorter currentSorter) {
    ContextMenuBuilder(context)
        .addHeader(SimpleBottomSheetHeaderBuilder(Key('order_by_menu_header'))
            .addLabel(AppLocalizations.of(context).order_by)
            .build())
        .addTiles(OrderByDialogBottomSheetBuilder(context, currentSorter)
            .onSelectSorterAction((sorterSelected) => _sortFilesActiveClosed(sorterSelected))
            .build())
        .build();
  }

  void _sortFilesActiveClosed(Sorter sorter) {
    final newSorter = store.state.uploadRequestGroupState.activeClosedSorter == sorter
        ? sorter.getSorterByOrderType(sorter.orderType)
        : sorter;
    _appNavigation.popBack();
    store.dispatch(_sortFilesActionActiveClosed(newSorter));
  }

  ThunkAction<AppState> _sortFilesActionActiveClosed(Sorter sorter) {
    return (Store<AppState> store) async {
      await Future.wait([
        _saveSorterInteractor.execute(sorter),
        _sortInteractor.execute(_uploadRequestListActiveClosed, sorter)
      ]).then((response) => response[1].fold((failure) {
            _uploadRequestListActiveClosed = [];
            store.dispatch(
                UploadRequestGroupSortActiveClosedAction(_uploadRequestListActiveClosed, sorter));
          }, (success) {
            _uploadRequestListActiveClosed =
                success is UploadRequestGroupViewState ? success.uploadRequestGroups : [];
            store.dispatch(
                UploadRequestGroupSortActiveClosedAction(_uploadRequestListActiveClosed, sorter));
          }));
    };
  }

  void getUploadRequestActiveClosedStatusWithSort() {
    store.dispatch(OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(StartUploadRequestGroupLoadingAction());

      await Future.wait([
        _getSorterInteractor.execute(OrderScreen.uploadRequestGroupsActiveClosed),
        _getAllUploadRequestGroupsInteractor
            .execute([UploadRequestStatus.ENABLED, UploadRequestStatus.CLOSED])
      ]).then((response) async {
        response[0].fold((failure) {
          store.dispatch(UploadRequestGroupGetSorterActiveClosedAction(
              Sorter.fromOrderScreen(OrderScreen.uploadRequestGroupsActiveClosed)));
        }, (success) {
          store.dispatch(UploadRequestGroupGetSorterActiveClosedAction(success is GetSorterSuccess
              ? success.sorter
              : Sorter.fromOrderScreen(OrderScreen.uploadRequestGroupsActiveClosed)));
        });

        response[1].fold((failure) {
          _uploadRequestListActiveClosed = [];
          store.dispatch(UploadRequestGroupGetAllActiveClosedAction(Left(failure)));
        }, (success) {
          _uploadRequestListActiveClosed =
              success is UploadRequestGroupViewState ? success.uploadRequestGroups : [];
          store.dispatch(UploadRequestGroupGetAllActiveClosedAction(Right(success)));
        });
      });

      store.dispatch(_sortFilesActionActiveClosed(store.state.uploadRequestGroupState.activeClosedSorter));
    }));
  }

  void getUploadRequestActiveClosedStatus() {
    store.dispatch(OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(StartUploadRequestGroupLoadingAction());

      await _getAllUploadRequestGroupsInteractor
          .execute([UploadRequestStatus.ENABLED, UploadRequestStatus.CLOSED]).then(
              (result) => result.fold((failure) {
                    store.dispatch(UploadRequestGroupGetAllActiveClosedAction(Left(failure)));
                    _uploadRequestListActiveClosed = [];
                    store.dispatch(_sortFilesActionActiveClosed(
                        store.state.uploadRequestGroupState.activeClosedSorter));
                  }, (success) {
                    _uploadRequestListActiveClosed =
                        success is UploadRequestGroupViewState ? success.uploadRequestGroups : [];
                    store.dispatch(UploadRequestGroupGetAllActiveClosedAction(Right(success)));
                    store.dispatch(_sortFilesActionActiveClosed(
                        store.state.uploadRequestGroupState.activeClosedSorter));
                  }));
    }));
  }

  // Upload Request Groups Pending
  void openPopupMenuSorterPending(BuildContext context, Sorter currentSorter) {
    ContextMenuBuilder(context)
        .addHeader(SimpleBottomSheetHeaderBuilder(Key('order_by_menu_header'))
            .addLabel(AppLocalizations.of(context).order_by)
            .build())
        .addTiles(OrderByDialogBottomSheetBuilder(context, currentSorter)
            .onSelectSorterAction((sorterSelected) => _sortFilesPending(sorterSelected))
            .build())
        .build();
  }

  void _sortFilesPending(Sorter sorter) {
    final newSorter = store.state.uploadRequestGroupState.pendingSorter == sorter
        ? sorter.getSorterByOrderType(sorter.orderType)
        : sorter;
    _appNavigation.popBack();
    store.dispatch(_sortFilesActionPending(newSorter));
  }

  ThunkAction<AppState> _sortFilesActionPending(Sorter sorter) {
    return (Store<AppState> store) async {
      await Future.wait([
        _saveSorterInteractor.execute(sorter),
        _sortInteractor.execute(_uploadRequestListPending, sorter)
      ]).then((response) => response[1].fold((failure) {
            _uploadRequestListPending = [];
            store.dispatch(UploadRequestGroupSortPendingAction(_uploadRequestListPending, sorter));
          }, (success) {
            _uploadRequestListPending =
                success is UploadRequestGroupViewState ? success.uploadRequestGroups : [];
            store.dispatch(UploadRequestGroupSortPendingAction(_uploadRequestListPending, sorter));
          }));
    };
  }

  void getUploadRequestCreatedStatusWithSort() {
    store.dispatch(OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(StartUploadRequestGroupLoadingAction());

      await Future.wait([
        _getSorterInteractor.execute(OrderScreen.uploadRequestGroupsCreated),
        _getAllUploadRequestGroupsInteractor.execute([UploadRequestStatus.CREATED])
      ]).then((response) async {
        response[0].fold((failure) {
          store.dispatch(UploadRequestGroupGetSorterCreatedAction(
              Sorter.fromOrderScreen(OrderScreen.uploadRequestGroupsCreated)));
        }, (success) {
          store.dispatch(UploadRequestGroupGetSorterCreatedAction(success is GetSorterSuccess
              ? success.sorter
              : Sorter.fromOrderScreen(OrderScreen.uploadRequestGroupsCreated)));
        });

        response[1].fold((failure) {
          _uploadRequestListPending = [];
          store.dispatch(UploadRequestGroupGetAllCreatedAction(Left(failure)));
        }, (success) {
          _uploadRequestListPending =
              success is UploadRequestGroupViewState ? success.uploadRequestGroups : [];
          store.dispatch(UploadRequestGroupGetAllCreatedAction(Right(success)));
        });
      });

      store.dispatch(_sortFilesActionPending(store.state.uploadRequestGroupState.pendingSorter));
    }));
  }

  void getUploadRequestCreatedStatus() {
    store.dispatch(OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(StartUploadRequestGroupLoadingAction());

      await _getAllUploadRequestGroupsInteractor
          .execute([UploadRequestStatus.CREATED]).then((result) => result.fold((failure) {
                store.dispatch(UploadRequestGroupGetAllCreatedAction(Left(failure)));
                _uploadRequestListPending = [];
                store.dispatch(
                    _sortFilesActionPending(store.state.uploadRequestGroupState.pendingSorter));
              }, (success) {
                _uploadRequestListPending =
                    success is UploadRequestGroupViewState ? success.uploadRequestGroups : [];
                store.dispatch(UploadRequestGroupGetAllCreatedAction(Right(success)));
                store.dispatch(
                    _sortFilesActionPending(store.state.uploadRequestGroupState.pendingSorter));
              }));
    }));
  }

  // Upload Request Groups Archived
  void openPopupMenuSorterArchived(BuildContext context, Sorter currentSorter) {
    ContextMenuBuilder(context)
        .addHeader(SimpleBottomSheetHeaderBuilder(Key('order_by_menu_header'))
            .addLabel(AppLocalizations.of(context).order_by)
            .build())
        .addTiles(OrderByDialogBottomSheetBuilder(context, currentSorter)
            .onSelectSorterAction((sorterSelected) => _sortFilesArchived(sorterSelected))
            .build())
        .build();
  }

  void _sortFilesArchived(Sorter sorter) {
    final newSorter = store.state.uploadRequestGroupState.archivedSorter == sorter
        ? sorter.getSorterByOrderType(sorter.orderType)
        : sorter;
    _appNavigation.popBack();
    store.dispatch(_sortFilesActionArchived(newSorter));
  }

  ThunkAction<AppState> _sortFilesActionArchived(Sorter sorter) {
    return (Store<AppState> store) async {
      await Future.wait([
        _saveSorterInteractor.execute(sorter),
        _sortInteractor.execute(_uploadRequestListArchived, sorter)
      ]).then((response) => response[1].fold((failure) {
            _uploadRequestListArchived = [];
            store
                .dispatch(UploadRequestGroupSortArchivedAction(_uploadRequestListArchived, sorter));
          }, (success) {
            _uploadRequestListArchived =
                success is UploadRequestGroupViewState ? success.uploadRequestGroups : [];
            store
                .dispatch(UploadRequestGroupSortArchivedAction(_uploadRequestListArchived, sorter));
          }));
    };
  }

  void getUploadRequestArchivedStatusWithSort() {
    store.dispatch(OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(StartUploadRequestGroupLoadingAction());

      await Future.wait([
        _getSorterInteractor.execute(OrderScreen.uploadRequestGroupsArchived),
        _getAllUploadRequestGroupsInteractor.execute([UploadRequestStatus.ARCHIVED])
      ]).then((response) async {
        response[0].fold((failure) {
          store.dispatch(UploadRequestGroupGetSorterArchivedAction(
              Sorter.fromOrderScreen(OrderScreen.uploadRequestGroupsArchived)));
        }, (success) {
          store.dispatch(UploadRequestGroupGetSorterArchivedAction(success is GetSorterSuccess
              ? success.sorter
              : Sorter.fromOrderScreen(OrderScreen.uploadRequestGroupsArchived)));
        });

        response[1].fold((failure) {
          _uploadRequestListArchived = [];
          store.dispatch(UploadRequestGroupGetAllArchivedAction(Left(failure)));
        }, (success) {
          _uploadRequestListArchived =
              success is UploadRequestGroupViewState ? success.uploadRequestGroups : [];
          store.dispatch(UploadRequestGroupGetAllArchivedAction(Right(success)));
        });
      });

      store.dispatch(_sortFilesActionArchived(store.state.uploadRequestGroupState.archivedSorter));
    }));
  }

  void getUploadRequestArchivedStatus() {
    store.dispatch(OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(StartUploadRequestGroupLoadingAction());

      await _getAllUploadRequestGroupsInteractor
          .execute([UploadRequestStatus.ARCHIVED]).then((result) => result.fold((failure) {
                store.dispatch(UploadRequestGroupGetAllArchivedAction(Left(failure)));
                _uploadRequestListArchived = [];
                store.dispatch(
                    _sortFilesActionArchived(store.state.uploadRequestGroupState.archivedSorter));
              }, (success) {
                _uploadRequestListArchived =
                    success is UploadRequestGroupViewState ? success.uploadRequestGroups : [];
                store.dispatch(UploadRequestGroupGetAllArchivedAction(Right(success)));
                store.dispatch(
                    _sortFilesActionArchived(store.state.uploadRequestGroupState.archivedSorter));
              }));
    }));
  }

  // Search
  void _search(SearchQuery searchQuery) {
    _searchQuery = searchQuery;
    if (searchQuery.value.isNotEmpty) {
      store.dispatch(_searchUploadRequestGroupsAction([..._uploadRequestListActiveClosed, ..._uploadRequestListArchived, ..._uploadRequestListPending], searchQuery));
    } else {
      store.dispatch(UploadRequestGroupSetSearchResultAction([]));
    }
  }

  ThunkAction<AppState> _searchUploadRequestGroupsAction(List<UploadRequestGroup> uploadRequestGroupsList, SearchQuery searchQuery) {
    return (Store<AppState> store) async {
      await _searchUploadRequestGroupsInteractor.execute(uploadRequestGroupsList, searchQuery).then((result) => result.fold(
              (failure) {
                if (isInSearchState()) {
                  store.dispatch(UploadRequestGroupSetSearchResultAction([]));
                }
              },
              (success) {
                if (isInSearchState()) {
                  store.dispatch(UploadRequestGroupSetSearchResultAction(success is SearchUploadRequestGroupsSuccess ? success.uploadRequestGroupList : []));
                }
              })
      );
    };
  }

  bool isInSearchState() {
    return store.state.uiState.isInSearchState();
  }

  void openSearchState() {
    store.dispatch(EnableSearchStateAction(SearchDestination.uploadRequestGroups));
    store.dispatch((UploadRequestGroupSetSearchResultAction([])));
  }

  void openContextMenu(BuildContext context, UploadRequestGroup uploadRequestGroup, List<Widget> actionTiles, {Widget? footerAction}) {
    store.dispatch(_handleContextMenuAction(context, uploadRequestGroup, actionTiles, footerAction: footerAction));
  }

  ThunkAction<AppState> _handleContextMenuAction(
      BuildContext context,
      UploadRequestGroup uploadRequestGroup,
      List<Widget> actionTiles,
      {Widget? footerAction}) {
    return (Store<AppState> store) async {
      ContextMenuBuilder(context)
          .addHeader(ContextMenuHeaderBuilder(
            Key('context_menu_header'),
            UploadRequestGroupPresentationFile.fromUploadRequestGroup(uploadRequestGroup)).build())
          .addTiles(actionTiles)
          .addFooter(footerAction ?? SizedBox.shrink())
          .build();
      store.dispatch(UploadRequestGroupAction(Right(UploadRequestGroupContextMenuItemViewState(uploadRequestGroup))));
    };
  }

  void goToAddRecipients(UploadRequestGroup request) {
    _appNavigation.popBack();
    _appNavigation.push(
      RoutePaths.addRecipientsUploadRequestGroup,
      arguments: AddRecipientsUploadRequestGroupArgument(request),
    );
    store.dispatch(UIStateSetUploadRequestGroupIndexAction(_tabIndex));
  }

  @override
  void onDisposed() {
    store.dispatch(UIStateSetUploadRequestGroupIndexAction(_tabIndex));
    super.onDisposed();
    _storeStreamSubscription.cancel();
  }
}
