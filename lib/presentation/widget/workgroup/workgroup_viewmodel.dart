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
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/model/file/selectable_element.dart';
import 'package:linshare_flutter_app/presentation/model/file/shared_space_node_nested_presentation_file.dart';
import 'package:linshare_flutter_app/presentation/model/item_selection_type.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/ui_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/workgroup_action.dart';
import 'package:linshare_flutter_app/presentation/redux/online_thunk_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/ui_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/workgroup_state.dart';
import 'package:linshare_flutter_app/presentation/saas/saas_utils.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/app_toast.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/linshare_node_type_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/suggest_name_type_extension.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/util/router/route_paths.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/context_menu_builder.dart';
import 'package:linshare_flutter_app/presentation/view/header/context_menu_header_builder.dart';
import 'package:linshare_flutter_app/presentation/view/header/simple_bottom_sheet_header_builder.dart';
import 'package:linshare_flutter_app/presentation/view/modal_sheets/confirm_modal_sheet_builder.dart';
import 'package:linshare_flutter_app/presentation/view/modal_sheets/edit_text_modal_sheet_builder.dart';
import 'package:linshare_flutter_app/presentation/view/modal_sheets/modal_card.dart';
import 'package:linshare_flutter_app/presentation/view/modal_sheets/reach_limitation_alert.dart';
import 'package:linshare_flutter_app/presentation/view/order_by/order_by_dialog_bottom_sheet.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_details/shared_space_details_arguments.dart';
import 'package:redux/src/store.dart';
import 'package:redux_thunk/redux_thunk.dart';

/// Handle action for inside selectedParentNode
class WorkGroupViewModel extends BaseViewModel {

  final GetAllWorkgroupsInteractor _getAllWorkgroupsInteractor;
  final GetAllWorkgroupsOfflineInteractor _getAllWorkgroupsOfflineInteractor;
  final SearchWorkgroupInsideSharedSpaceNodeInteractor _searchWorkgroupInsideSharedSpaceNodeInteractor;
  final RemoveMultipleSharedSpacesInteractor _removeMultipleSharedSpacesInteractor;
  final CreateWorkGroupInteractor _createWorkGroupInteractor;
  final VerifyNameInteractor _verifyNameInteractor;
  final AppNavigation _appNavigation;
  final AppToast _appToast;
  final FToast _fToast;
  final SortInteractor _sortInteractor;
  final GetSorterInteractor _getSorterInteractor;
  final SaveSorterInteractor _saveSorterInteractor;
  final RenameWorkGroupInteractor _renameWorkGroupInteractor;
  final AppImagePaths _imagePaths;

  late StreamSubscription _storeStreamSubscription;
  late List<SharedSpaceNodeNested> _currentWorkgroups;

  SearchQuery _searchQuery = SearchQuery('');
  SearchQuery get searchQuery  => _searchQuery;

  SharedSpaceNodeNested? get selectedParentNode => store.state.uiState.selectedParentNode;

  WorkGroupViewModel(
    Store<AppState> store,
    this._appNavigation,
    this._getAllWorkgroupsInteractor,
    this._getAllWorkgroupsOfflineInteractor,
    this._searchWorkgroupInsideSharedSpaceNodeInteractor,
    this._removeMultipleSharedSpacesInteractor,
    this._createWorkGroupInteractor,
    this._appToast,
    this._fToast,
    this._verifyNameInteractor,
    this._sortInteractor,
    this._getSorterInteractor,
    this._saveSorterInteractor,
    this._renameWorkGroupInteractor,
    this._imagePaths
  ) : super(store) {
    _storeStreamSubscription = store.onChange.listen((event) {
      event.workgroupState.viewState.fold((failure) => null, (success) {
          if (success is SearchWorkgroupInsideSharedSpaceNodeNewQuery && event.uiState.searchState.searchStatus == SearchStatus.ACTIVE) {
            _search(success.searchQuery);
          } else if (success is DisableSearchViewState) {
            store.dispatch((WorkgroupInsideSharedSpaceNodeSetSearchResultAction(_currentWorkgroups)));
            _searchQuery = SearchQuery('');
          } else if (success is CreateWorkGroupViewState) {
            getAllWorkgroups(needToGetOldSorter: false);
          }
        });
    });
  }

  void getAllWorkgroups({required bool needToGetOldSorter}) {
    if (store.state.networkConnectivityState.connectivityResult == ConnectivityResult.none) {
      if (needToGetOldSorter) {
        store.dispatch(_getAllWorkgroupsOfflineAndSortAction());
      } else {
        store.dispatch(_getAllWorkgroupsOfflineAction());
      }
    } else {
      if (needToGetOldSorter) {
        store.dispatch(_getAllWorkgroupsAndSortAction());
      } else {
        store.dispatch(_getAllWorkgroupsAction());
      }
    }
  }

  void setDefaultSorter() {
    store.dispatch(SetDefaultSorterInsideSharedSpaceNodeAction(
        Sorter.fromOrderScreen(selectedParentNode!.nodeType!.orderScreen)));
  }

  OnlineThunkAction _getAllWorkgroupsAndSortAction() {
    return OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(StartWorkgroupLoadingAction());

      await Future.wait([
        _getSorterInteractor.execute(selectedParentNode!.nodeType!.orderScreen),
        _getAllWorkgroupsInteractor.execute(selectedParentNode!.sharedSpaceId)
      ]).then((response) async {
        response[0].fold((failure) {
          store.dispatch(GetSorterInsideSharedSpaceNodeAction(
              Sorter.fromOrderScreen(selectedParentNode!.nodeType!.orderScreen)));
        }, (success) {
          store.dispatch(GetSorterInsideSharedSpaceNodeAction(success is GetSorterSuccess
            ? success.sorter
            : Sorter.fromOrderScreen(selectedParentNode!.nodeType!.orderScreen)));
        });
        response[1].fold((failure) {
          store.dispatch(GetAllWorkgroupsAction(Left(failure)));
          _currentWorkgroups = List.empty();
        }, (success) {
          store.dispatch(GetAllWorkgroupsAction(Right(success)));
          _currentWorkgroups = success is GetAllWorkgroupsViewState ? success.workgroups : List.empty();
        });
      });

      store.dispatch(_sortFilesAction(store.state.workgroupState.sorter));

    });
  }

  OnlineThunkAction _getAllWorkgroupsAction() {
    return OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(StartWorkgroupLoadingAction());

      await _getAllWorkgroupsInteractor.execute(selectedParentNode!.sharedSpaceId)
        .then((result) => result.fold(
          (failure) {
            store.dispatch(GetAllWorkgroupsAction(Left(failure)));
            _currentWorkgroups = List.empty();
          },
          (success) {
            store.dispatch(GetAllWorkgroupsAction(Right(success)));
            _currentWorkgroups = (success is GetAllWorkgroupsViewState) ? success.workgroups : List.empty();
          }));

      store.dispatch(_sortFilesAction(store.state.workgroupState.sorter));

    });
  }

  ThunkAction<AppState> _getAllWorkgroupsOfflineAndSortAction() {
    return (Store<AppState> store) async {
      store.dispatch(StartWorkgroupLoadingAction());

      await Future.wait([
        _getSorterInteractor.execute(selectedParentNode!.nodeType!.orderScreen),
        _getAllWorkgroupsOfflineInteractor.execute(selectedParentNode!.sharedSpaceId)
      ]).then((response) async {
        response.first.fold(
          (failure) => store.dispatch(GetSorterInsideSharedSpaceNodeAction(
              Sorter.fromOrderScreen(selectedParentNode!.nodeType!.orderScreen))),
          (success) => store.dispatch(GetSorterInsideSharedSpaceNodeAction(success is GetSorterSuccess
            ? success.sorter
            : Sorter.fromOrderScreen(selectedParentNode!.nodeType!.orderScreen)))
          );
        response.last.fold(
          (failure) {
            store.dispatch(GetAllWorkgroupsAction(Left(failure)));
            _currentWorkgroups = List.empty();
          },
          (success) {
            store.dispatch(GetAllWorkgroupsAction(Right(success)));
            _currentWorkgroups = success is GetAllWorkgroupsViewState ? success.workgroups : List.empty();
          });
      });

      store.dispatch(_sortFilesAction(store.state.workgroupState.sorter));
    };
  }

  ThunkAction<AppState> _getAllWorkgroupsOfflineAction() {
    return (Store<AppState> store) async {
      store.dispatch(StartWorkgroupLoadingAction());

      await _getAllWorkgroupsOfflineInteractor.execute(selectedParentNode!.sharedSpaceId)
        .then((result) => result.fold(
          (failure) {
            store.dispatch(GetAllWorkgroupsAction(Left(failure)));
            _currentWorkgroups = List.empty();
          },
          (success) {
            store.dispatch(GetAllWorkgroupsAction(Right(success)));
            _currentWorkgroups = (success is GetAllWorkgroupsViewState) ? success.workgroups : List.empty();
          }));

      store.dispatch(_sortFilesAction(store.state.workgroupState.sorter));
    };
  }

  void openWorkgroup(SharedSpaceNodeNested workgroup) {
    if (_isInSearchState()) {
      store.dispatch(DisableSearchStateAction());
      store.dispatch((WorkgroupInsideSharedSpaceNodeSetSearchResultAction(_currentWorkgroups)));
      _searchQuery = SearchQuery('');
    }
    store.dispatch(SharedSpaceInsideView(RoutePaths.sharedSpaceInside, workgroup, parentNode: selectedParentNode));
  }

  void openSearchState(BuildContext context) {
    final destinationName = selectedParentNode?.name ?? AppLocalizations.of(context).shared_space;
    store.dispatch(EnableSearchStateAction(SearchDestination.insideSharedSpaceNode, AppLocalizations.of(context).search_in(destinationName)));
    store.dispatch((WorkgroupInsideSharedSpaceNodeSetSearchResultAction(List.empty())));
  }

  void _search(SearchQuery searchQuery) {
    _searchQuery = searchQuery;
    if (searchQuery.value.isNotEmpty) {
      store.dispatch(_searchWorkgroupInsideSharedSpaceNodeAction(_currentWorkgroups, searchQuery));
    } else {
      store.dispatch(WorkgroupInsideSharedSpaceNodeSetSearchResultAction(List.empty()));
    }
  }

  ThunkAction<AppState> _searchWorkgroupInsideSharedSpaceNodeAction(List<SharedSpaceNodeNested> sharedSpaceNodes, SearchQuery searchQuery) {
    return (Store<AppState> store) async {
      await _searchWorkgroupInsideSharedSpaceNodeInteractor.execute(sharedSpaceNodes, searchQuery)
        .then((result) => result.fold(
          (failure) {
            if (_isInSearchState()) {
              store.dispatch(WorkgroupInsideSharedSpaceNodeSetSearchResultAction(List.empty()));
            }},
          (success) {
            if (_isInSearchState()) {
              store.dispatch(WorkgroupInsideSharedSpaceNodeSetSearchResultAction(
                  success is SearchWorkgroupInsideSharedSpaceNodeSuccess ? success.workgroups : List.empty()));
            }
          })
      );
    };
  }

  bool _isInSearchState() {
    return store.state.uiState.isInSearchState();
  }

  void openContextMenu(BuildContext context, SharedSpaceNodeNested sharedSpace, List<Widget> actionTiles, {Widget? footerAction}) {
    store.dispatch(_handleContextMenuAction(context, sharedSpace, actionTiles, footerAction: footerAction));
  }

  ThunkAction<AppState> _handleContextMenuAction(
      BuildContext context,
      SharedSpaceNodeNested sharedSpace,
      List<Widget> actionTiles,
      {Widget? footerAction}) {
    return (Store<AppState> store) async {
      ContextMenuBuilder(context)
        .addHeader(ContextMenuHeaderBuilder(
            Key('shared_space_context_menu_header'),
            SharedSpaceNodeNestedPresentationFile.fromSharedSpaceNodeNested(sharedSpace)).build())
        .addTiles(actionTiles)
        .addFooter(footerAction ?? SizedBox.shrink())
        .build();
    };
  }

  void removeSharedSpaces(
    BuildContext context,
    List<SharedSpaceNodeNested> sharedSpaces,
    {ItemSelectionType itemSelectionType = ItemSelectionType.single}
  ) {
    if (itemSelectionType == ItemSelectionType.single) {
      _appNavigation.popBack();
    }

    final deleteTitle = AppLocalizations.of(context).are_you_sure_you_want_to_delete_multiple(
        sharedSpaces.length, sharedSpaces.first.name);

    ConfirmModalSheetBuilder(_appNavigation)
      .key(Key('delete_shared_space_confirm_modal'))
      .title(deleteTitle)
      .cancelText(AppLocalizations.of(context).cancel)
      .onConfirmAction(AppLocalizations.of(context).delete, (_) {
        _appNavigation.popBack();
        if (itemSelectionType == ItemSelectionType.multiple) {
          cancelSelection();
        }
        store.dispatch(_removeSharedSpacesAction(
            sharedSpaces.map((sharedSpace) => sharedSpace.sharedSpaceId).toList()));
    }).show(context);
  }

  ThunkAction<AppState> _removeSharedSpacesAction(List<SharedSpaceId> sharedSpaceIds) {
    return (Store<AppState> store) async {
      await _removeMultipleSharedSpacesInteractor.execute(sharedSpaceIds)
          .then((result) => result.fold(
              (failure) => store.dispatch(WorkgroupAction(Left(failure))),
              (success) => {
                store.dispatch(WorkgroupAction(Right(success))),
                getAllWorkgroups(needToGetOldSorter: false)
              }));
    };
  }

  void selectItem(SelectableElement<SharedSpaceNodeNested> selectedSharedSpace) {
    store.dispatch(SelectWorkgroupInsideSharedSpaceNodeAction(selectedSharedSpace));
  }

  void toggleSelectAllSharedSpaces() {
    if (store.state.workgroupState.isAllWorkgroupsSelected()) {
      store.dispatch(UnselectAllWorkgroupsInsideSharedSpaceNodeAction());
    } else {
      store.dispatch(SelectAllWorkgroupsInsideSharedSpaceNodeAction());
    }
  }

  void cancelSelection() {
    store.dispatch(ClearSelectedWorkgroupsInsideSharedSpaceNodeAction());
  }

  void clickOnDetails(SharedSpaceNodeNested sharedSpaceNodeNested) {
    store.dispatch(OnlineThunkAction((Store<AppState> store) async {
      _goToSharedSpaceDetails(sharedSpaceNodeNested);
    }));
  }

  void _goToSharedSpaceDetails(SharedSpaceNodeNested sharedSpaceNodeNested) {
    _appNavigation.popBack();
    _appNavigation.push(
      RoutePaths.sharedSpaceDetails,
      arguments: SharedSpaceDetailsArguments(sharedSpaceNodeNested)
    );
  }

  void openCreateNewWorkGroupModal(BuildContext context) {
    store.dispatch(_handleCreateNewWorkgroupModalAction(context));
  }

  void openPopupMenuSorter(BuildContext context, Sorter currentSorter) {
    ContextMenuBuilder(context)
      .addHeader(SimpleBottomSheetHeaderBuilder(Key('order_by_menu_header'))
          .addLabel(AppLocalizations.of(context).order_by)
          .build())
      .addTiles(OrderByDialogBottomSheetBuilder(context, currentSorter)
          .onSelectSorterAction((sorterSelected) => _sortFiles(sorterSelected))
          .build())
      .build();
  }

  void _sortFiles(Sorter sorter) {
    final newSorter = store.state.workgroupState.sorter == sorter ? sorter.getSorterByOrderType(sorter.orderType) : sorter;
    _appNavigation.popBack();
    store.dispatch(_sortFilesAction(newSorter));
  }

  ThunkAction<AppState> _sortFilesAction(Sorter sorter) {
    return (Store<AppState> store) async {
      await Future.wait([
        _saveSorterInteractor.execute(sorter),
        _sortInteractor.execute(_currentWorkgroups, sorter)
      ]).then((response) => response[1].fold((failure) {
        _currentWorkgroups = List.empty();
        store.dispatch(SortAllWorkgroupsInsideSharedSpaceNodeAction(_currentWorkgroups, sorter));
      }, (success) {
        _currentWorkgroups =
        success is GetAllWorkgroupsViewState ? success.workgroups : List.empty();
        store.dispatch(SortAllWorkgroupsInsideSharedSpaceNodeAction(_currentWorkgroups, sorter));
      }));
    };
  }

  ThunkAction<AppState> _handleCreateNewWorkgroupModalAction(BuildContext context) {
    final suggestName = SuggestNameType.WORKGROUP.suggestNewName(
        context,
        _currentWorkgroups.map((sharedSpaced) => sharedSpaced.name).toList());
    return (Store<AppState> store) async {
      EditTextModalSheetBuilder()
          .key(Key('create_new_workgroup_modal'))
          .title(AppLocalizations.of(context).create_new_workgroup)
          .cancelText(AppLocalizations.of(context).cancel)
          .onConfirmAction(
              AppLocalizations.of(context).create,
              (value) => this.store.dispatch(_createNewWorkGroupAction(context, value)))
          .setErrorString((value) => getErrorString(context, value))
          .setTextController(
            TextEditingController.fromValue(
              TextEditingValue(
                text: suggestName,
                selection: TextSelection(
                  baseOffset: 0,
                  extentOffset: suggestName.length
                )
              ),
            ))
          .show(context);
    };
  }

  String? getErrorString(BuildContext context, String value) {
    return _verifyNameInteractor
      .execute(
        value,
        [
          EmptyNameValidator(),
          DuplicateNameValidator(_currentWorkgroups.map((node) => node.name).toList()),
          SpecialCharacterValidator()
        ]
      )
      .fold((failure) {
        if (failure is VerifyNameFailure) {
          if (failure.exception is EmptyNameException) {
            return AppLocalizations.of(context).node_name_not_empty(AppLocalizations.of(context).workgroup);
          } else if (failure.exception is DuplicatedNameException) {
            return AppLocalizations.of(context).node_name_already_exists(AppLocalizations.of(context).workgroup);
          } else if (failure.exception is SpecialCharacterException) {
            return AppLocalizations.of(context).node_name_contain_special_character(AppLocalizations.of(context).workgroup);
          } else {
            return null;
          }
        } else {
          return null;
        }
    }, (success) => null);
  }

  OnlineThunkAction _createNewWorkGroupAction(BuildContext context, String newName) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _createWorkGroupInteractor
          .execute(CreateWorkGroupRequest(newName, LinShareNodeType.WORK_GROUP, parentId: selectedParentNode?.sharedSpaceId))
          .then((result) => result.fold(
              (failure) => {
                if (failure is NestedWorkgroupLimitation) {
                  _showNestedWorkgroupLimitationMessage(context, store)
                } else {
                  store.dispatch(WorkgroupAction(Left(failure)))
                }
              },
              (success) => store.dispatch(WorkgroupAction(Right(success)))));
    });
  }

  void openRenameWorkGroupModal(BuildContext context, SharedSpaceNodeNested sharedSpace) {
    _appNavigation.popBack();

    EditTextModalSheetBuilder()
      .key(Key('rename_work_group_modal'))
      .title(AppLocalizations.of(context).rename_node(AppLocalizations.of(context).workgroup.toLowerCase()))
      .cancelText(AppLocalizations.of(context).cancel)
      .onConfirmAction(
          AppLocalizations.of(context).rename,
          (value) => store.dispatch(_renameWorkGroupAction(context, value, sharedSpace)))
      .setErrorString((value) => getErrorString(context, value))
      .setTextSelection(
          TextSelection(baseOffset: 0, extentOffset: sharedSpace.name.length),
          value: sharedSpace.name)
      .show(context);
  }

  OnlineThunkAction _renameWorkGroupAction(BuildContext context, String newName, SharedSpaceNodeNested sharedSpaceNodeNested) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _renameWorkGroupInteractor
        .execute(
          sharedSpaceNodeNested.sharedSpaceId,
          RenameWorkGroupRequest(newName, sharedSpaceNodeNested.versioningParameters, sharedSpaceNodeNested.nodeType!))
        .then((result) => getAllWorkgroups(needToGetOldSorter: true));
    });
  }

  void backToSharedSpace() {
    store.dispatch(ClearAllListWorkgroupAction());
    store.dispatch(SetCurrentView(RoutePaths.sharedSpace));
  }

  @override
  void onDisposed() {
    store.dispatch(ClearAllListWorkgroupAction());
    cancelSelection();
    store.dispatch(DisableSearchStateAction());
    _storeStreamSubscription.cancel();
    _searchQuery = SearchQuery('');
    super.onDisposed();
  }

  void _showNestedWorkgroupLimitationMessage(BuildContext context, Store<AppState> store) {
    if (store.state.settingsState.appMode == AppMode.SaaS) {
      showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return ModalCardWidget(
              child: ReachLimitationAlert(
              AppLocalizations.of(context).failed_request,
              AppLocalizations.of(context).reach_nested_workgroup_limit_message_saas,
              AppLocalizations.of(context).contact_now,
              _appNavigation,
              onContactNowPress: () => SaaSUtils.goToConsoleHomepage(_appNavigation, context),
            )
          );
        }
      );
    } else {
      _appToast.showToastWithIcon(
          context,
          _fToast,
          AppLocalizations.of(context).reach_nested_workgroup_limit_message_own_server,
          _imagePaths.icWarningLimitationToast,
          duration: Duration(milliseconds: 1500)
      );
    }
  }
}
