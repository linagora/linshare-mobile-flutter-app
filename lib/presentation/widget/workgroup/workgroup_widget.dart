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

import 'package:dartz/dartz.dart' as dartz;
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/model/file/selectable_element.dart';
import 'package:linshare_flutter_app/presentation/model/item_selection_type.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/workgroup_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/ui_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/datetime_extension.dart';
import 'package:linshare_flutter_app/presentation/util/helper/responsive_utils.dart';
import 'package:linshare_flutter_app/presentation/util/helper/responsive_widget.dart';
import 'package:linshare_flutter_app/presentation/view/background_widgets/background_widget_builder.dart';
import 'package:linshare_flutter_app/presentation/view/common/common_view.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/simple_context_menu_action_builder.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/work_group_context_menu_action_builder.dart';
import 'package:linshare_flutter_app/presentation/view/multiple_selection_bar/multiple_selection_bar_builder.dart';
import 'package:linshare_flutter_app/presentation/view/multiple_selection_bar/shared_space_multiple_selection_action_builder.dart';
import 'package:linshare_flutter_app/presentation/view/order_by/order_by_button.dart';
import 'package:linshare_flutter_app/presentation/view/search/search_bottom_bar_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/workgroup/workgroup_viewmodel.dart';
import 'package:redux/redux.dart';

/// Display view for inside shared space node (Ex: Drive, Workspace)
class WorkGroupWidget extends StatefulWidget {
  @override
  _WorkGroupWidgetState createState() => _WorkGroupWidgetState();
}

class _WorkGroupWidgetState extends State<WorkGroupWidget> {
  final _viewModel = getIt<WorkGroupViewModel>();
  final _imagePath = getIt<AppImagePaths>();
  final _responsiveUtils = getIt<ResponsiveUtils>();
  final _widgetCommon = getIt<CommonView>();

  @override
  void initState() {
    super.initState();
    _viewModel.setDefaultSorter();
    _viewModel.getAllWorkgroups(needToGetOldSorter: true);
  }

  @override
  void dispose() {
    super.dispose();
    _viewModel.onDisposed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: [
            _buildTopBar(),
            StoreConnector<AppState, WorkgroupState>(
              converter: (store) => store.state.workgroupState,
              builder: (context, state) {
                return state.selectMode == SelectMode.ACTIVE
                  ? ListTile(
                      leading: SvgPicture.asset(_imagePath.icSelectAll,
                          width: 28,
                          height: 28,
                          fit: BoxFit.fill,
                          color: state.isAllWorkgroupsSelected()
                              ? AppColor.unselectedElementColor
                              : AppColor.primaryColor),
                      title: Transform(
                          transform: Matrix4.translationValues(-16, 0.0, 0.0),
                          child: state.isAllWorkgroupsSelected()
                              ? Text(AppLocalizations.of(context).unselect_all,
                                  maxLines: 1,
                                  style: TextStyle(fontSize: 14, color: AppColor.documentNameItemTextColor))
                              : Text(
                                  AppLocalizations.of(context).select_all,
                                  maxLines: 1,
                                  style: TextStyle(fontSize: 14, color: AppColor.documentNameItemTextColor),
                                )),
                      tileColor: AppColor.topBarBackgroundColor,
                      onTap: () => _viewModel.toggleSelectAllSharedSpaces(),
                      trailing: TextButton(
                          onPressed: () => _viewModel.cancelSelection(),
                          child: Text(
                            AppLocalizations.of(context).cancel,
                            maxLines: 1,
                            style: TextStyle(fontSize: 14, color: AppColor.primaryColor),
                          )),
                    )
                  : SizedBox.shrink();
              },
            ),
            _buildMenuSorter(),
            StoreConnector<AppState, dartz.Either<Failure, Success>>(
                converter: (store) => store.state.workgroupState.viewState,
                distinct: true,
                builder: (context, viewState) {
                  return viewState.fold(
                      (failure) => SizedBox.shrink(),
                      (success) => (success is LoadingState)
                          ? Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: SizedBox(
                                width: 30,
                                height: 30,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
                                ),
                              ))
                          : SizedBox.shrink());
                }),
            _buildResultCount(),
            Expanded(child: buildSharedSpaceListBySearchState()),
            StoreConnector<AppState, WorkgroupState>(
                converter: (store) => store.state.workgroupState,
                builder: (context, state) {
                  return state.selectMode == SelectMode.ACTIVE && state.getAllSelectedWorkgroups().isNotEmpty
                      ? MultipleSelectionBarBuilder()
                          .key(Key('multiple_workgroups_selection_bar'))
                          .text(AppLocalizations.of(context).items(state.getAllSelectedWorkgroups().length))
                          .actions(_multipleSelectionActions(state.getAllSelectedWorkgroups()))
                          .build()
                      : SizedBox.shrink();
                })
          ],
        ),
        bottomNavigationBar: StoreConnector<AppState, AppState>(
            converter: (store) => store.state,
            builder: (context, state) {
              if (!state.uiState.isInSearchState() &&
                  state.workgroupState.selectMode == SelectMode.INACTIVE) {
                return SearchBottomBarBuilder()
                    .key(Key('search_bottom_bar_inside_shared_space_node'))
                    .onSearchActionClick(() => _viewModel.openSearchState(context))
                    .build();
              }
              return SizedBox.shrink();
            }),
        floatingActionButton: StoreConnector<AppState, AppState>(
          converter: (store) => store.state,
          builder: (context, appState) {
            if (_validateDisplayAddWorkgroupButton(appState)) {
              return FloatingActionButton(
                key: Key('create_new_workgroup_inside_shared_space_node_button'),
                onPressed: () => _viewModel.openCreateNewWorkGroupModal(context),
                backgroundColor: AppColor.primaryColor,
                child: SvgPicture.asset(_imagePath.icPlus, width: 24, height: 24,),
              );
            }
            return SizedBox.shrink();
          }),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  bool _validateDisplayAddWorkgroupButton(AppState appState) {
    if (!appState.uiState.isInSearchState() &&
        appState.workgroupState.selectMode == SelectMode.INACTIVE &&
        (SharedSpaceOperationRole.addWorkgroupInsideDrive.contains(appState.uiState.selectedParentNode!.sharedSpaceRole.name) ||
        SharedSpaceOperationRole.addWorkgroupInsideWorkspace.contains(appState.uiState.selectedParentNode!.sharedSpaceRole.name))) {
      return true;
    }
    return false;
  }

  Widget _buildTopBar() {
    return StoreConnector<AppState, SearchStatus>(
      converter: (store) => store.state.uiState.searchState.searchStatus,
      builder: (context, searchStatus) => searchStatus == SearchStatus.ACTIVE
        ? SizedBox.shrink()
        : Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: Offset(0, 4))]),
            child: Row(children: [
                GestureDetector(
                  onTap: () => _viewModel.backToSharedSpace(),
                  child: Container(
                    width: 48,
                    height: 48,
                    child: Align(
                      alignment: Alignment.center,
                      heightFactor: 24,
                      widthFactor: 24,
                      child: SvgPicture.asset(_imagePath.icBackBlue, width: 24, height: 24),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _viewModel.backToSharedSpace(),
                  child: Container(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                          AppLocalizations.of(context).workgroup_nodes_surfing_root_back_title,
                          style: TextStyle(
                              fontSize: 18,
                              color: AppColor.workgroupNodesSurfingBackTitleColor,
                              fontWeight: FontWeight.w400
                          )
                      ),
                    ),
                  )
                )
              ]
            )
      )
    );
  }

  Widget buildSharedSpaceListBySearchState() {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, appState) {
          if (appState.uiState.isInSearchState()) {
            return _buildSearchResultSharedSpacesList(appState.workgroupState);
          }
          return _buildNormalSharedSpacesList(appState.workgroupState);
        });
  }

  Widget _buildResultCount() {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, appState) {
          if (appState.uiState.isInSearchState() && _viewModel.searchQuery.value.isNotEmpty) {
            return _widgetCommon.buildResultCountRow(context, appState.workgroupState.selectableWorkgroups.length);
          }
          return SizedBox.shrink();
        });
  }

  Widget _buildSearchResultSharedSpacesList(WorkgroupState state) {
    if (_viewModel.searchQuery.value.isEmpty) {
      return SizedBox.shrink();
    } else {
      if (state.selectableWorkgroups.isEmpty) {
        return _widgetCommon.buildNoResultFound(context);
      }
      return _buildSharedSpacesListView(state.selectableWorkgroups, state.selectMode);
    }
  }

  Widget _buildNormalSharedSpacesList(WorkgroupState state) {
    return state.viewState.fold(
      (failure) =>
        RefreshIndicator(
          onRefresh: () async => _viewModel.getAllWorkgroups(needToGetOldSorter: false),
          child: failure is SharedSpacesFailure ? 
            BackgroundWidgetBuilder(context)
                .key(Key('workgroup_error_background'))
                .image(SvgPicture.asset(_imagePath.icUnexpectedError, width: 120, height: 120, fit: BoxFit.fill))
                .text(AppLocalizations.of(context).common_error_occured_message)
                .build() : _buildSharedSpacesListView(state.selectableWorkgroups, state.selectMode)
        ),
      (success) => success is LoadingState ?
        _buildSharedSpacesListView(state.selectableWorkgroups, state.selectMode) :
        RefreshIndicator(
          onRefresh: () async => _viewModel.getAllWorkgroups(needToGetOldSorter: false),
          child: _buildSharedSpacesListView(state.selectableWorkgroups, state.selectMode)
        )
    );
  }

  Widget _buildSharedSpacesListView(List<SelectableElement<SharedSpaceNodeNested>> selectableWorkgroups, SelectMode selectMode) {
    if (selectableWorkgroups.isEmpty) {
      return _buildNoWorkgroupYet(context);
    } else {
      return ListView.builder(
        key: Key('workgroups_list'),
        padding: _responsiveUtils.getPaddingListItemForScreen(context),
        itemCount: selectableWorkgroups.length,
        itemBuilder: (context, index) {
          return _buildSharedSpaceListItem(context, selectableWorkgroups[index], selectMode);
        },
      );
    }
  }

  Widget _buildNoWorkgroupYet(BuildContext context) {
    return BackgroundWidgetBuilder(context)
      .key(Key('shared_space_node_no_workgroup_yet'))
      .image(SvgPicture.asset(_imagePath.icSharedSpaceNoWorkGroup, width: 120, height: 120, fit: BoxFit.fill))
      .text(AppLocalizations.of(context).do_not_have_any_workgroup).build();
  }

  Widget _buildSharedSpaceListItem(
      BuildContext context, SelectableElement<SharedSpaceNodeNested> selectableWorkgroup, SelectMode selectMode) {
    return ListTile(
        leading: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          SvgPicture.asset(_imagePath.icWorkgroup, width: 24, height: 24, fit: BoxFit.fill)
        ]),
        title: ResponsiveWidget(
          smallScreen: Transform(
            transform: Matrix4.translationValues(-16, 0.0, 0.0),
            child: _buildSharedSpaceName(selectableWorkgroup.element.name),
          ),
          mediumScreen: Transform(
            transform: Matrix4.translationValues(-16, 0.0, 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    flex: 1,
                    child: _buildSharedSpaceName(selectableWorkgroup.element.name)),
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildModifiedSharedSpaceText(AppLocalizations.of(context).item_last_modified(
                      selectableWorkgroup.element.modificationDate.getMMMddyyyyFormatString())))
              ]),
          ),
          largeScreen: Transform(
            transform: Matrix4.translationValues(-16, 0.0, 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    flex: 1,
                    child: _buildSharedSpaceName(selectableWorkgroup.element.name)),
                Align(
                    alignment: Alignment.centerRight,
                    child: _buildModifiedSharedSpaceText(AppLocalizations.of(context).item_last_modified(
                        selectableWorkgroup.element.modificationDate.getMMMddyyyyFormatString())))
              ]),
          ),
          responsiveUtil: _responsiveUtils,
        ),
        subtitle: _responsiveUtils.isSmallScreen(context)
          ? Transform(
              transform: Matrix4.translationValues(-16, 0.0, 0.0),
              child: Row(
                children: [
                  _buildModifiedSharedSpaceText(AppLocalizations.of(context).item_last_modified(
                      selectableWorkgroup.element.modificationDate.getMMMddyyyyFormatString()))
                ],
              ))
          : null,
        onTap: () {
          if(selectMode == SelectMode.ACTIVE) {
            _viewModel.selectItem(selectableWorkgroup);
          } else {
            _viewModel.openWorkgroup(selectableWorkgroup.element);
          }
        },
        trailing: StoreConnector<AppState, SelectMode>(
            converter: (store) => store.state.workgroupState.selectMode,
            builder: (context, selectMode) {
              return selectMode == SelectMode.ACTIVE
                  ? Checkbox(
                      value: selectableWorkgroup.selectMode == SelectMode.ACTIVE,
                      onChanged: (bool? value) => _viewModel.selectItem(selectableWorkgroup),
                      activeColor: AppColor.primaryColor)
                  : IconButton(
                      icon: SvgPicture.asset(
                        _imagePath.icContextMenu,
                        width: 24,
                        height: 24,
                        fit: BoxFit.fill,
                      ),
                      onPressed: () => _viewModel.openContextMenu(
                          context,
                          selectableWorkgroup.element,
                          _contextMenuActionTiles(context, selectableWorkgroup),
                          footerAction: _contextMenuFooterAction(selectableWorkgroup.element)));
            }),
        onLongPress: () => _viewModel.selectItem(selectableWorkgroup));
  }

  List<Widget> _contextMenuActionTiles(BuildContext context, SelectableElement<SharedSpaceNodeNested> sharedSpace) {
    return [
      if (SharedSpaceOperationRole.renameWorkGroupSharedSpaceRoles.contains(sharedSpace.element.sharedSpaceRole.name))
        _renameWorkgroupAction(context, sharedSpace.element),
      _sharedSpaceDetailsAction(sharedSpace.element)
    ];
  }

  Widget _contextMenuFooterAction(SharedSpaceNodeNested sharedSpace) {
    return SharedSpaceOperationRole.deleteSharedSpaceRoles.contains(sharedSpace.sharedSpaceRole.name)
        ? SimpleContextMenuActionBuilder(
                Key('delete_shared_space_context_menu_action'),
                SvgPicture.asset(_imagePath.icDelete, width: 24, height: 24, fit: BoxFit.fill),
                AppLocalizations.of(context).delete)
            .onActionClick((data) => _viewModel.removeSharedSpaces(context, [sharedSpace]))
            .build()
        : SizedBox.shrink();
  }

  Widget _renameWorkgroupAction(BuildContext context, SharedSpaceNodeNested sharedSpace) {
    return WorkgroupContextMenuTileBuilder(
        Key('rename_workgroup_context_menu_action'),
        SvgPicture.asset(_imagePath.icRename, width: 24, height: 24, fit: BoxFit.fill),
        AppLocalizations.of(context).rename, sharedSpace)
      .onActionClick((sharedSpace) => _viewModel.openRenameWorkGroupModal(context, sharedSpace))
      .build();
  }

  Widget _sharedSpaceDetailsAction(SharedSpaceNodeNested sharedSpace) {
    return SimpleContextMenuActionBuilder(
            Key('shared_space_details_context_menu_action'),
            SvgPicture.asset(_imagePath.icInfo, width: 24, height: 24, fit: BoxFit.fill),
            AppLocalizations.of(context).details)
        .onActionClick((data) => _viewModel.clickOnDetails(sharedSpace))
        .build();
  }

  Widget _buildSharedSpaceName(String sharedSpaceName) {
    return Text(
      sharedSpaceName,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 14, color: AppColor.documentNameItemTextColor),
    );
  }

  Widget _buildModifiedSharedSpaceText(String modificationDate) {
    return Text(
      modificationDate,
      style: TextStyle(fontSize: 13, color: AppColor.documentModifiedDateItemTextColor),
    );
  }

  List<Widget> _multipleSelectionActions(List<SharedSpaceNodeNested> sharedSpaces) {
    return [
      _removeMultipleSelection(sharedSpaces)
    ];
  }

  Widget _removeMultipleSelection(List<SharedSpaceNodeNested> sharedSpaces) {
    return SharedSpaceMultipleSelectionActionBuilder(
        Key('multiple_selection_remove_action'),
        SvgPicture.asset(_imagePath.icDelete, width: 24, height: 24, fit: BoxFit.fill,),
        sharedSpaces)
    .onActionClick((documents) => _viewModel.removeSharedSpaces(context, documents, itemSelectionType: ItemSelectionType.multiple))
    .build();
  }

  Widget _buildMenuSorter() {
    return StoreConnector<AppState, AppState>(
      converter: (Store<AppState> store) => store.state,
      builder: (context, appState) {
        return !appState.uiState.isInSearchState()
            ? OrderByButtonBuilder(context, appState.workgroupState.sorter)
                .onOpenOrderMenuAction((currentSorter) => _viewModel.openPopupMenuSorter(context, currentSorter))
                .build()
            : SizedBox.shrink();
      },
    );
  }
}
