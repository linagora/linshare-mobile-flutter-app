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
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/model/file/selectable_element.dart';
import 'package:linshare_flutter_app/presentation/model/file/shared_space_node_nested_presentation_file.dart';
import 'package:linshare_flutter_app/presentation/model/item_selection_type.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/share_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/shared_space_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/ui_action.dart';
import 'package:linshare_flutter_app/presentation/redux/online_thunk_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/functionality_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/shared_space_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/ui_state.dart';
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
import 'package:linshare_flutter_app/presentation/widget/shared_space_details/add_shared_space_node_member/add_member_destination.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_details/add_shared_space_node_member/add_shared_space_node_member_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_details/shared_space_details_arguments.dart';
import 'package:redux/src/store.dart';
import 'package:redux_thunk/redux_thunk.dart';

class SharedSpaceViewModel extends BaseViewModel {
  final GetAllSharedSpacesInteractor _getAllSharedSpacesInteractor;
  final SearchSharedSpaceNodeNestedInteractor _searchSharedSpaceNodeNestedInteractor;
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
  final RenameDriveInteractor _renameDriveInteractor;
  final GetAllSharedSpaceOfflineInteractor _getAllSharedSpaceOfflineInteractor;
  final CreateNewDriveInteractor _createNewDriveInteractor;
  final CreateNewWorkSpaceInteractor _createNewWorkSpaceInteractor;
  final RenameWorkSpaceInteractor _renameWorkSpaceInteractor;

  late StreamSubscription _storeStreamSubscription;
  late List<SharedSpaceNodeNested> _sharedSpaceNodes;

  SearchQuery _searchQuery = SearchQuery('');
  SearchQuery get searchQuery  => _searchQuery;
  final _imagePath = getIt<AppImagePaths>();

  SharedSpaceViewModel(
    Store<AppState> store,
    this._appNavigation,
    this._appToast,
    this._fToast,
    this._getAllSharedSpacesInteractor,
    this._searchSharedSpaceNodeNestedInteractor,
    this._removeMultipleSharedSpacesInteractor,
    this._createWorkGroupInteractor,
    this._verifyNameInteractor,
    this._sortInteractor,
    this._getSorterInteractor,
    this._saveSorterInteractor,
    this._renameWorkGroupInteractor,
    this._renameDriveInteractor,
    this._getAllSharedSpaceOfflineInteractor,
    this._createNewDriveInteractor,
    this._createNewWorkSpaceInteractor,
    this._renameWorkSpaceInteractor,
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
                } else if (success is CreateWorkGroupViewState ||
                    success is CreateNewDriveViewState ||
                    success is CreateNewWorkSpaceViewState ||
                    success is UpdateWorkspaceMemberViewState ||
                    success is UpdateDriveMemberViewState ||
                    success is DeleteSharedSpaceMemberViewState) {
                  getAllSharedSpaces(needToGetOldSorter: false);
                }
              });
    });
  }

  void getAllSharedSpaces({required bool needToGetOldSorter}) {
    if (store.state.networkConnectivityState.connectivityResult == ConnectivityResult.none) {
      needToGetOldSorter
        ? store.dispatch(_getAllSharedSpaceOfflineActionAndSort())
        : store.dispatch(_getAllSharedSpaceOfflineAction());
    } else {
      needToGetOldSorter
        ? store.dispatch(_getAllSharedSpacesActionAndSort())
        : store.dispatch(_getAllSharedSpacesAction());
    }
  }

  OnlineThunkAction _getAllSharedSpacesActionAndSort() {
    return OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(StartSharedSpaceLoadingAction());

      await Future.wait([
        _getSorterInteractor.execute(OrderScreen.workGroup),
        _getAllSharedSpacesInteractor.execute()
      ]).then((response) async {
        response[0].fold((failure) {
          store.dispatch(SharedSpaceGetSorterAction(
              Sorter.fromOrderScreen(OrderScreen.workGroup)));
        }, (success) {
          store.dispatch(SharedSpaceGetSorterAction(success is GetSorterSuccess
              ? success.sorter
              : Sorter.fromOrderScreen(OrderScreen.workGroup)));
        });
        response[1].fold((failure) {
          store.dispatch(SharedSpaceGetAllSharedSpacesAction(Left(failure)));
          _sharedSpaceNodes = [];
        }, (success) {
          if (_validateShowingDrive()) {
            store.dispatch(SharedSpaceGetAllSharedSpacesAction(Right(success)));
            _sharedSpaceNodes = (success is SharedSpacesViewState) ? success.sharedSpacesList : [];
          } else {
            _sharedSpaceNodes = (success is SharedSpacesViewState)
                ? success.sharedSpacesList.where((sharedSpace) => sharedSpace.nodeType != LinShareNodeType.DRIVE).toList()
                : [];
            store.dispatch(SharedSpaceGetAllSharedSpacesAction(Right(SharedSpacesViewState(_sharedSpaceNodes))));
          }
        });
      });

      store.dispatch(_sortFilesAction(store.state.sharedSpaceState.sorter));

    });
  }

  OnlineThunkAction _getAllSharedSpacesAction() {
    return OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(StartSharedSpaceLoadingAction());
      await _getAllSharedSpacesInteractor.execute().then((result) => result.fold(
        (failure) {
          store.dispatch(SharedSpaceGetAllSharedSpacesAction(Left(failure)));
          _sharedSpaceNodes = [];
        },
        (success) {
          if (_validateShowingDrive()) {
            store.dispatch(SharedSpaceGetAllSharedSpacesAction(Right(success)));
            _sharedSpaceNodes = (success is SharedSpacesViewState) ? success.sharedSpacesList : [];
          } else {
            _sharedSpaceNodes = (success is SharedSpacesViewState)
                ? success.sharedSpacesList.where((sharedSpace) => sharedSpace.nodeType != LinShareNodeType.DRIVE).toList()
                : [];
            store.dispatch(SharedSpaceGetAllSharedSpacesAction(Right(SharedSpacesViewState(_sharedSpaceNodes))));
          }
        }));

      store.dispatch(_sortFilesAction(store.state.sharedSpaceState.sorter));

    });
  }

  void openWorkgroup(SharedSpaceNodeNested sharedSpace) {
    if (_isInSearchState()) {
      store.dispatch(DisableSearchStateAction());
      store.dispatch((SharedSpaceSetSearchResultAction(_sharedSpaceNodes)));
      _searchQuery = SearchQuery('');
    }
    store.dispatch(SharedSpaceInsideView(RoutePaths.sharedSpaceInside, sharedSpace));
  }

  void openSharedSpaceNode(SharedSpaceNodeNested nodeNested) {
    if (_isInSearchState()) {
      store.dispatch(DisableSearchStateAction());
      store.dispatch((SharedSpaceSetSearchResultAction(_sharedSpaceNodes)));
      _searchQuery = SearchQuery('');
    }
    store.dispatch(WorkgroupView(RoutePaths.insideSharedSpaceNode, nodeNested));
  }

  void openSearchState(BuildContext context) {
    store.dispatch(EnableSearchStateAction(SearchDestination.allSharedSpaces, AppLocalizations.of(context).search_in_shared_space));
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

  bool _validateShowingDrive() {
    return _isDriveEnable() || store.state.functionalityState.isSharedSpaceEnabledV5();
  }

  bool _isDriveEnable() {
    return store.state.functionalityState.isDriveEnabled();
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

  void openDriveContextMenu(BuildContext context, SharedSpaceNodeNested nodeNested, List<Widget> actionTiles, {Widget? footerAction}) {
    store.dispatch(
      _handleDriveContextMenuAction(
        context,
        nodeNested,
        actionTiles,
        footerAction: footerAction));
  }

  ThunkAction<AppState> _handleDriveContextMenuAction(
      BuildContext context,
      SharedSpaceNodeNested nodeNested,
      List<Widget> actionTiles,
      {Widget? footerAction}
  ) {
    return (Store<AppState> store) async {
      ContextMenuBuilder(context)
        .addHeader(ContextMenuHeaderBuilder(
          Key('drive_context_menu_header'),
          SharedSpaceNodeNestedPresentationFile.fromSharedSpaceNodeNested(nodeNested)).build())
        .addTiles(actionTiles)
        .addFooter(footerAction ?? SizedBox.shrink())
        .build();
    };
  }

  void openWorkspaceContextMenu(BuildContext context, SharedSpaceNodeNested nodeNested, List<Widget> actionTiles, {Widget? footerAction}) {
    store.dispatch(
        _handleWorkspaceContextMenuAction(
            context,
            nodeNested,
            actionTiles,
            footerAction: footerAction));
  }

  ThunkAction<AppState> _handleWorkspaceContextMenuAction(
      BuildContext context,
      SharedSpaceNodeNested nodeNested,
      List<Widget> actionTiles,
      {Widget? footerAction}) {
    return (Store<AppState> store) async {
      ContextMenuBuilder(context)
        .addHeader(ContextMenuHeaderBuilder(
            Key('work_space_context_menu_header'),
            SharedSpaceNodeNestedPresentationFile.fromSharedSpaceNodeNested(nodeNested))
          .build())
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

    final deleteTitle = AppLocalizations.of(context).are_you_sure_you_want_to_delete_multiple(sharedSpaces.length, sharedSpaces.first.name);

    ConfirmModalSheetBuilder(_appNavigation)
      .key(Key('delete_shared_space_confirm_modal'))
      .title(deleteTitle)
      .cancelText(AppLocalizations.of(context).cancel)
      .onConfirmAction(AppLocalizations.of(context).delete, (_) {
        _appNavigation.popBack();
        if (itemSelectionType == ItemSelectionType.multiple) {
          cancelSelection();
        }
        store.dispatch(_removeSharedSpacesAction(sharedSpaces.map((sharedSpace) => sharedSpace.sharedSpaceId).toList()));
    }).show(context);
  }

  ThunkAction<AppState> _removeSharedSpacesAction(List<SharedSpaceId> sharedSpaceIds) {
    return (Store<AppState> store) async {
      await _removeMultipleSharedSpacesInteractor.execute(sharedSpaceIds)
        .then((result) => result.fold(
          (failure) => store.dispatch(SharedSpaceAction(Left(failure))),
          (success) => {
            store.dispatch(SharedSpaceAction(Right(success))),
            getAllSharedSpaces(needToGetOldSorter: false)
          }));
    };
  }

  void selectItem(SelectableElement<SharedSpaceNodeNested> selectedSharedSpace) {
    store.dispatch(SharedSpaceSelectSharedSpaceAction(selectedSharedSpace));
  }

  void toggleSelectAllSharedSpaces() {
    if (store.state.sharedSpaceState.isAllSharedSpacesSelected()) {
      store.dispatch(SharedSpaceUnselectAllSharedSpacesAction());
    } else {
      store.dispatch(SharedSpaceSelectAllSharedSpacesAction());
    }
  }

  void cancelSelection() {
    store.dispatch(SharedSpaceClearSelectedSharedSpacesAction());
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

  void clickOnAddSharedSpaceNodeMember(SharedSpaceNodeNested nodeNested) {
    store.dispatch(OnlineThunkAction((Store<AppState> store) async {
      _goToAddSharedSpaceNodeMember(nodeNested);
    }));
  }

  void _goToAddSharedSpaceNodeMember(SharedSpaceNodeNested nodeNested) {
    _appNavigation.popBack();
    _appNavigation.push(
        RoutePaths.addSharedSpaceNodeMember,
        arguments: AddSharedSpaceNodeMemberArguments(nodeNested, AddMemberDestination.sharedSpaceView)
    );
  }

  void openCreateNewSharedSpaceNode(BuildContext context, LinShareNodeType nodeType, {bool fromContextMenu = false}) {
    if (fromContextMenu) {
      _appNavigation.popBack();
    }
    store.dispatch(_handleCreateNewSharedSpaceNodeModalAction(context, nodeType));
  }

  OnlineThunkAction _createNewDriveAction(String newName) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _createNewDriveInteractor
        .execute(CreateDriveRequest(newName, LinShareNodeType.DRIVE))
        .then((result) => result.fold(
          (failure) => store.dispatch(SharedSpaceAction(Left(failure))),
          (success) => store.dispatch(SharedSpaceAction(Right(success)))));
    });
  }

  String _getSuggestName(BuildContext context, LinShareNodeType nodeType) {
    return nodeType.suggestNameType
        .suggestNewName(context, _sharedSpaceNodes
        .where((sharedSpaced) => sharedSpaced.nodeType == nodeType)
        .map((sharedSpaced) => sharedSpaced.name)
        .toList());
  }

  ThunkAction<AppState> _handleCreateNewSharedSpaceNodeModalAction(
      BuildContext context, LinShareNodeType nodeType) {
    final suggestName = _getSuggestName(context, nodeType);
    return (Store<AppState> store) async {
      EditTextModalSheetBuilder()
          .key(Key('create_new_shared_space_node_modal'))
          .title(nodeType.getTitleBottomSheetCreation(context))
          .cancelText(AppLocalizations.of(context).cancel)
          .onConfirmAction(AppLocalizations.of(context).create,
              (value) {
                switch(nodeType) {
                  case LinShareNodeType.DRIVE:
                    this.store.dispatch(_createNewDriveAction(value));
                    break;
                  case LinShareNodeType.WORK_GROUP:
                    this.store.dispatch(_createNewWorkGroupAction(value));
                    break;
                  case LinShareNodeType.WORK_SPACE:
                    this.store.dispatch(_createNewWorkspaceAction(context, value));
                    break;
                }
              })
          .setErrorString((value) => getErrorString(context, value, nodeType))
          .setTextController(TextEditingController.fromValue(
            TextEditingValue(
                text: suggestName,
                selection: TextSelection(baseOffset: 0, extentOffset: suggestName.length)
            )))
          .show(context);
    };
  }

  OnlineThunkAction _createNewWorkspaceAction(BuildContext context, String newName) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _createNewWorkSpaceInteractor
          .execute(CreateWorkSpaceRequest(newName, LinShareNodeType.WORK_SPACE))
          .then((result) => result.fold(
              (failure) {
                if (failure is WorkSpaceReachLimitFailure) {
                  _showWorkSpaceLimitationMessage(context, store);
                } else {
                  store.dispatch(SharedSpaceAction(Left(failure)));
                }
              },
              (success) => store.dispatch(SharedSpaceAction(Right(success)))));
    });
  }

  void _showWorkSpaceLimitationMessage(BuildContext context, Store<AppState> store) {
    if (store.state.settingsState.appMode == AppMode.SaaS) {
      showModalBottomSheet(
          backgroundColor: Colors.transparent,
          context: context,
          builder: (context) {
            return ModalCardWidget(
              child: ReachLimitationAlert(
                AppLocalizations.of(context).failed_request,
                AppLocalizations.of(context).reach_workspace_limit_message,
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
        AppLocalizations.of(context).reach_workspace_limit_message_own_server,
        _imagePath.icWarningLimitationToast,
        duration: Duration(milliseconds: 1500)
      );
    }
  }

  void openCreateNewSharedSpaceMenu(BuildContext context, List<Widget> actionTiles) {
    store.dispatch(_handleCreateNewSharedSpaceMenuAction(context, actionTiles));
  }

  ThunkAction<AppState> _handleCreateNewSharedSpaceMenuAction(BuildContext context, List<Widget> actionTiles) {
    return (Store<AppState> store) async {
      ContextMenuBuilder(context, areTilesHorizontal: true, alignment: MainAxisAlignment.spaceEvenly)
        .addTiles(actionTiles)
        .build();
    };
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
    final newSorter = store.state.sharedSpaceState.sorter == sorter ? sorter.getSorterByOrderType(sorter.orderType) : sorter;
    _appNavigation.popBack();
    store.dispatch(_sortFilesAction(newSorter));
  }

  ThunkAction<AppState> _sortFilesAction(Sorter sorter) {
    return (Store<AppState> store) async {
      await Future.wait([
        _saveSorterInteractor.execute(sorter),
        _sortInteractor.execute(_sharedSpaceNodes, sorter)
      ]).then((response) => response[1].fold((failure) {
        _sharedSpaceNodes = [];
        store.dispatch(SharedSpaceSortWorkGroupAction(_sharedSpaceNodes, sorter));
      }, (success) {
        _sharedSpaceNodes =
        success is SharedSpacesViewState ? success.sharedSpacesList : [];
        store.dispatch(SharedSpaceSortWorkGroupAction(_sharedSpaceNodes, sorter));
      }));
    };
  }

  String? getErrorString(BuildContext context, String value, LinShareNodeType nodeType) {
    return _verifyNameInteractor
        .execute(value, nodeType.getListValidator(_sharedSpaceNodes))
        .fold((failure) {
          if (failure is VerifyNameFailure) {
            return nodeType.getErrorVerifyName(context, failure.exception);
          } else {
            return null;
          }
    }, (success) => null);
  }

  OnlineThunkAction _createNewWorkGroupAction(String newName) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _createWorkGroupInteractor
          .execute(CreateWorkGroupRequest(newName, LinShareNodeType.WORK_GROUP))
          .then((result) => result.fold(
              (failure) => store.dispatch(SharedSpaceAction(Left(failure))),
              (success) => store.dispatch(SharedSpaceAction(Right(success)))));
    });
  }

  OnlineThunkAction _renameWorkGroupAction(BuildContext context, String newName, SharedSpaceNodeNested sharedSpaceNodeNested) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _renameWorkGroupInteractor
        .execute(
          sharedSpaceNodeNested.sharedSpaceId,
          RenameWorkGroupRequest(newName, sharedSpaceNodeNested.versioningParameters, sharedSpaceNodeNested.nodeType!))
        .then((result) => getAllSharedSpaces(needToGetOldSorter: true));
    });
  }

  OnlineThunkAction _renameDriveAction(BuildContext context, String newName, SharedSpaceNodeNested drive) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _renameDriveInteractor
        .execute(
          drive.sharedSpaceId,
          RenameDriveRequest(newName, drive.nodeType!))
        .then((result) => getAllSharedSpaces(needToGetOldSorter: true));
    });
  }

  void openRenameSharedSpaceNodeModal(BuildContext context,
      SharedSpaceNodeNested nodeNested, LinShareNodeType nodeType) {
    _appNavigation.popBack();

    EditTextModalSheetBuilder()
        .key(Key('rename_shared_space_node_modal'))
        .title(nodeType.getTitleBottomSheetRename(context))
        .cancelText(AppLocalizations.of(context).cancel)
        .onConfirmAction(AppLocalizations.of(context).rename,
            (value) {
              switch(nodeType) {
                case LinShareNodeType.DRIVE:
                  store.dispatch(_renameDriveAction(context, value, nodeNested));
                  break;
                case LinShareNodeType.WORK_GROUP:
                  store.dispatch(_renameWorkGroupAction(context, value, nodeNested));
                  break;
                case LinShareNodeType.WORK_SPACE:
                  store.dispatch(_renameWorkspaceAction(context, value, nodeNested));
                  break;
              }
            })
        .setErrorString((value) => getErrorString(context, value, nodeType))
        .setTextSelection(TextSelection(baseOffset: 0, extentOffset: nodeNested.name.length), value: nodeNested.name)
        .show(context);
  }

  OnlineThunkAction _renameWorkspaceAction(BuildContext context, String newName, SharedSpaceNodeNested nodeNested) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _renameWorkSpaceInteractor
        .execute(nodeNested.sharedSpaceId, RenameWorkSpaceRequest(newName, nodeNested.nodeType!))
        .then((result) => getAllSharedSpaces(needToGetOldSorter: true));
    });
  }

  ThunkAction<AppState> _getAllSharedSpaceOfflineAction() {
    return (Store<AppState> store) async {
      store.dispatch(StartSharedSpaceLoadingAction());

      await _getAllSharedSpaceOfflineInteractor.execute().then((result) => result.fold(
        (failure) {
          store.dispatch(SharedSpaceGetAllSharedSpacesAction(Left(failure)));
          _sharedSpaceNodes = [];
        },
        (success) {
          if (_validateShowingDrive()) {
            store.dispatch(SharedSpaceGetAllSharedSpacesAction(Right(success)));
            _sharedSpaceNodes = (success is SharedSpacesViewState) ? success.sharedSpacesList : [];
          } else {
            _sharedSpaceNodes = (success is SharedSpacesViewState)
                ? success.sharedSpacesList.where((sharedSpace) => sharedSpace.nodeType != LinShareNodeType.DRIVE).toList()
                : [];
            store.dispatch(SharedSpaceGetAllSharedSpacesAction(Right(SharedSpacesViewState(_sharedSpaceNodes))));
          }
        }));

      store.dispatch(_sortFilesAction(store.state.sharedSpaceState.sorter));
    };
  }

   ThunkAction<AppState> _getAllSharedSpaceOfflineActionAndSort() {
    return (Store<AppState> store) async {
      store.dispatch(StartSharedSpaceLoadingAction());

      await Future.wait([
        _getSorterInteractor.execute(OrderScreen.workGroup),
        _getAllSharedSpaceOfflineInteractor.execute()
      ]).then((response) async {
        response[0].fold((failure) {
          store.dispatch(SharedSpaceGetSorterAction(Sorter.fromOrderScreen(OrderScreen.workGroup)));
        }, (success) {
          store.dispatch(SharedSpaceGetSorterAction(success is GetSorterSuccess
            ? success.sorter
            : Sorter.fromOrderScreen(OrderScreen.workGroup)));
        });
        response[1].fold((failure) {
          store.dispatch(SharedSpaceGetAllSharedSpacesAction(Left(failure)));
          _sharedSpaceNodes = [];
        }, (success) {
          if (_validateShowingDrive()) {
            store.dispatch(SharedSpaceGetAllSharedSpacesAction(Right(success)));
            _sharedSpaceNodes = (success is SharedSpacesViewState) ? success.sharedSpacesList : [];
          } else {
            _sharedSpaceNodes = (success is SharedSpacesViewState)
                ? success.sharedSpacesList.where((sharedSpace) => sharedSpace.nodeType != LinShareNodeType.DRIVE).toList()
                : [];
            store.dispatch(SharedSpaceGetAllSharedSpacesAction(Right(SharedSpacesViewState(_sharedSpaceNodes))));
          }
        });
      });

      store.dispatch(_sortFilesAction(store.state.sharedSpaceState.sorter));
    };
  }

  @override
  void onDisposed() {
    store.dispatch(CleanShareStateAction());
    cancelSelection();
    _storeStreamSubscription.cancel();
  }
}