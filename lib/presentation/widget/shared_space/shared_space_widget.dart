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
import 'package:linshare_flutter_app/presentation/redux/states/functionality_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/shared_space_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/ui_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/datetime_extension.dart';
import 'package:linshare_flutter_app/presentation/util/helper/responsive_utils.dart';
import 'package:linshare_flutter_app/presentation/util/helper/responsive_widget.dart';
import 'package:linshare_flutter_app/presentation/view/background_widgets/background_widget_builder.dart';
import 'package:linshare_flutter_app/presentation/view/common/common_view.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/simple_context_menu_action_builder.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/simple_horizontal_context_menu_action_builder.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/work_group_context_menu_action_builder.dart';
import 'package:linshare_flutter_app/presentation/view/multiple_selection_bar/multiple_selection_bar_builder.dart';
import 'package:linshare_flutter_app/presentation/view/multiple_selection_bar/shared_space_multiple_selection_action_builder.dart';
import 'package:linshare_flutter_app/presentation/view/order_by/order_by_button.dart';
import 'package:linshare_flutter_app/presentation/view/search/search_bottom_bar_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space/shared_space_viewmodel.dart';
import 'package:redux/redux.dart';

class SharedSpaceWidget extends StatefulWidget {
  @override
  _SharedSpaceWidgetState createState() => _SharedSpaceWidgetState();
}

class _SharedSpaceWidgetState extends State<SharedSpaceWidget> {
  final sharedSpaceViewModel = getIt<SharedSpaceViewModel>();
  final imagePath = getIt<AppImagePaths>();
  final _responsiveUtils = getIt<ResponsiveUtils>();
  final _widgetCommon = getIt<CommonView>();

  @override
  void initState() {
    super.initState();
    sharedSpaceViewModel.getAllSharedSpaces(needToGetOldSorter: true);
  }

  @override
  void dispose() {
    super.dispose();
    sharedSpaceViewModel.onDisposed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: [
            StoreConnector<AppState, SharedSpaceState>(
              converter: (store) => store.state.sharedSpaceState,
              builder: (context, state) {
                return state.selectMode == SelectMode.ACTIVE
                    ? ListTile(
                        leading: SvgPicture.asset(imagePath.icSelectAll,
                            width: 28,
                            height: 28,
                            fit: BoxFit.fill,
                            color: state.isAllSharedSpacesSelected()
                                ? AppColor.unselectedElementColor
                                : AppColor.primaryColor),
                        title: Transform(
                            transform: Matrix4.translationValues(-16, 0.0, 0.0),
                            child: state.isAllSharedSpacesSelected()
                                ? Text(AppLocalizations.of(context).unselect_all,
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontSize: 14, color: AppColor.documentNameItemTextColor))
                                : Text(
                                    AppLocalizations.of(context).select_all,
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontSize: 14, color: AppColor.documentNameItemTextColor),
                                  )),
                        tileColor: AppColor.topBarBackgroundColor,
                        onTap: () => sharedSpaceViewModel.toggleSelectAllSharedSpaces(),
                        trailing: TextButton(
                            onPressed: () => sharedSpaceViewModel.cancelSelection(),
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
                converter: (store) => store.state.sharedSpaceState.viewState,
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
            StoreConnector<AppState, SharedSpaceState>(
                converter: (store) => store.state.sharedSpaceState,
                builder: (context, state) {
                  return state.selectMode == SelectMode.ACTIVE &&
                          state.getAllSelectedSharedSpaces().isNotEmpty
                      ? MultipleSelectionBarBuilder()
                          .key(Key('multiple_shared_space_selection_bar'))
                          .text(AppLocalizations.of(context)
                              .items(state.getAllSelectedSharedSpaces().length))
                          .actions(_multipleSelectionActions(state.getAllSelectedSharedSpaces()))
                          .build()
                      : SizedBox.shrink();
                })
          ],
        ),
        bottomNavigationBar: StoreConnector<AppState, AppState>(
            converter: (store) => store.state,
            builder: (context, state) {
              if (!state.uiState.isInSearchState() &&
                  state.sharedSpaceState.selectMode == SelectMode.INACTIVE) {
                return SearchBottomBarBuilder()
                    .key(Key('search_bottom_bar_shared_space'))
                    .onSearchActionClick(() => sharedSpaceViewModel.openSearchState(context))
                    .build();
              }
              return SizedBox.shrink();
            }),
        floatingActionButton: StoreConnector<AppState, AppState>(
          converter: (store) => store.state,
          builder: (context, appState) {
            if (!appState.uiState.isInSearchState() &&
                appState.sharedSpaceState.selectMode == SelectMode.INACTIVE) {
              return FloatingActionButton(
                key: Key('shared_space_create_new_workgroup_button'),
                onPressed: () => _onPressCreateNewButton(context, appState),
                backgroundColor: _bindingCreateNewButtonColor(appState),
                child: SvgPicture.asset(
                  imagePath.icPlus,
                  width: 24,
                  height: 24,
                ),
              );
            }
            return SizedBox.shrink();
          }),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Color _bindingCreateNewButtonColor(AppState appState) {
    if (!appState.functionalityState.isDriveCreationEnabled() && !appState.functionalityState.isCreateWorkgroupEnabled()) {
      return AppColor.disableColor;
    }
    return AppColor.primaryColor;
  }

  void _onPressCreateNewButton(BuildContext context, AppState appState) {
    if (_driveCreationEnable(appState) && _workgroupCreationEnable(appState)) {
      sharedSpaceViewModel.openCreateNewSharedSpaceMenu(context, _createNewSharedSpaceActionTiles(context));
    } else if (_driveCreationEnable(appState) && !_workgroupCreationEnable(appState)) {
      sharedSpaceViewModel.openCreateNewDrive(context);
    } else if (!_driveCreationEnable(appState) && _workgroupCreationEnable(appState)) {
      sharedSpaceViewModel.openCreateNewWorkGroupModal(context);
    }
  }

  bool _driveCreationEnable(AppState appState) {
    return (appState.functionalityState.isDriveEnabled() && appState.functionalityState.isDriveCreationEnabled());
  }

  bool _workgroupCreationEnable(AppState appState) {
    return (appState.functionalityState.isWorkGroupEnabled() && appState.functionalityState.isCreateWorkgroupEnabled());
  }

  Widget buildSharedSpaceListBySearchState() {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, appState) {
          if (appState.uiState.isInSearchState()) {
            return _buildSearchResultSharedSpacesList(appState.sharedSpaceState);
          }
          return _buildNormalSharedSpacesList(appState.sharedSpaceState);
        });
  }

  Widget _buildResultCount() {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, appState) {
          if (appState.uiState.isInSearchState() && sharedSpaceViewModel.searchQuery.value.isNotEmpty) {
            return _widgetCommon.buildResultCountRow(context, appState.sharedSpaceState.sharedSpacesList.length);
          }
          return SizedBox.shrink();
        });
  }

  Widget _buildSearchResultSharedSpacesList(SharedSpaceState state) {
    if (sharedSpaceViewModel.searchQuery.value.isEmpty) {
      return SizedBox.shrink();
    } else {
      if (state.sharedSpacesList.isEmpty) {
        return _widgetCommon.buildNoResultFound(context);
      }
      return _buildSharedSpacesListView(state.sharedSpacesList, state.selectMode);
    }
  }

  Widget _buildNormalSharedSpacesList(SharedSpaceState state) {
    return state.viewState.fold(
      (failure) =>
        RefreshIndicator(
          onRefresh: () async => sharedSpaceViewModel.getAllSharedSpaces(needToGetOldSorter: false),
          child: failure is SharedSpacesFailure ? 
            BackgroundWidgetBuilder(context)
                .key(Key('shared_space_error_background'))
                .image(SvgPicture.asset(
                  imagePath.icUnexpectedError,
                  width: 120,
                  height: 120,
                  fit: BoxFit.fill))
                .text(AppLocalizations.of(context).common_error_occured_message)
                .build() : _buildSharedSpacesListView(state.sharedSpacesList, state.selectMode)
        ),
      (success) => success is LoadingState ?
        _buildSharedSpacesListView(state.sharedSpacesList, state.selectMode) :
        RefreshIndicator(
          onRefresh: () async => sharedSpaceViewModel.getAllSharedSpaces(needToGetOldSorter: false),
          child: _buildSharedSpacesListView(state.sharedSpacesList, state.selectMode)
        )
    );
  }

  Widget _buildSharedSpacesListView(List<SelectableElement<SharedSpaceNodeNested>> sharedSpacesList, SelectMode selectMode) {
    if (sharedSpacesList.isEmpty) {
      return _buildNoWorkgroupYet(context);
    } else {
      return ListView.builder(
        key: Key('shared_spaces_list'),
        padding: _responsiveUtils.getPaddingListItemForScreen(context),
        itemCount: sharedSpacesList.length,
        itemBuilder: (context, index) {
          return _buildSharedSpaceListItem(context, sharedSpacesList[index], selectMode);
        },
      );
    }
  }

  Widget _buildNoWorkgroupYet(BuildContext context) {
    return BackgroundWidgetBuilder(context)
      .key(Key('shared_space_no_workgroup_yet'))
      .image(SvgPicture.asset(
        imagePath.icSharedSpaceNoWorkGroup,
        width: 120,
        height: 120,
        fit: BoxFit.fill))
      .text(AppLocalizations.of(context).do_not_have_any_workgroup).build();
  }

  Widget _buildSharedSpaceListItem(
      BuildContext context, SelectableElement<SharedSpaceNodeNested> sharedSpace, SelectMode selectMode) {
    return ListTile(
        leading: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          SvgPicture.asset(
              sharedSpace.element.nodeType == LinShareNodeType.WORK_GROUP ? imagePath.icWorkgroup : imagePath.icDrive,
              width: 24,
              height: 24,
              fit: BoxFit.fill)
        ]),
        title: ResponsiveWidget(
          smallScreen: Transform(
            transform: Matrix4.translationValues(-10, 0.0, 0.0),
            child: _buildSharedSpaceName(sharedSpace.element.name),
          ),
          mediumScreen: Transform(
            transform: Matrix4.translationValues(-10, 0.0, 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    flex: 1,
                    child: _buildSharedSpaceName(sharedSpace.element.name)),
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildModifiedSharedSpaceText(AppLocalizations.of(context).item_last_modified(
                      sharedSpace.element.modificationDate.getMMMddyyyyFormatString())))
              ]),
          ),
          largeScreen: Transform(
            transform: Matrix4.translationValues(-10, 0.0, 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    flex: 1,
                    child: _buildSharedSpaceName(sharedSpace.element.name)),
                Align(
                    alignment: Alignment.centerRight,
                    child: _buildModifiedSharedSpaceText(AppLocalizations.of(context).item_last_modified(
                        sharedSpace.element.modificationDate.getMMMddyyyyFormatString())))
              ]),
          ),
          responsiveUtil: _responsiveUtils,
        ),
        subtitle: _responsiveUtils.isSmallScreen(context)
          ? Transform(
              transform: Matrix4.translationValues(-10, 0.0, 0.0),
              child: Row(
                children: [
                  _buildModifiedSharedSpaceText(AppLocalizations.of(context).item_last_modified(
                      sharedSpace.element.modificationDate.getMMMddyyyyFormatString()))
                ],
              ))
          : null,
        onTap: () {
          if(selectMode == SelectMode.ACTIVE) {
            sharedSpaceViewModel.selectItem(sharedSpace);
          } else {
            if (sharedSpace.element.nodeType == LinShareNodeType.DRIVE) {
              sharedSpaceViewModel.openDrive(sharedSpace.element);
            } else {
              sharedSpaceViewModel.openSharedSpace(sharedSpace.element);
            }
          }
        },
        trailing: StoreConnector<AppState, SelectMode>(
            converter: (store) => store.state.sharedSpaceState.selectMode,
            builder: (context, selectMode) {
              return selectMode == SelectMode.ACTIVE
                  ? Checkbox(
                      value: sharedSpace.selectMode == SelectMode.ACTIVE,
                      onChanged: (bool? value) => sharedSpaceViewModel.selectItem(sharedSpace),
                      activeColor: AppColor.primaryColor,
                    )
                  : IconButton(
                      icon: SvgPicture.asset(
                        imagePath.icContextMenu,
                        width: 24,
                        height: 24,
                        fit: BoxFit.fill,
                      ),
                      onPressed: () => _onPressContextMenu(context, sharedSpace));
            }),
        onLongPress: () => sharedSpaceViewModel.selectItem(sharedSpace));
  }

  void _onPressContextMenu(BuildContext context, SelectableElement<SharedSpaceNodeNested> sharedSpace) {
    switch (sharedSpace.element.nodeType) {
      case LinShareNodeType.DRIVE:
        sharedSpaceViewModel.openDriveContextMenu(
            context,
            sharedSpace.element,
            _contextDriveMenuActionTiles(context, sharedSpace));
        break;
      default:
        sharedSpaceViewModel.openContextMenu(
          context,
          sharedSpace.element,
          _contextMenuActionTiles(context, sharedSpace),
          footerAction: _contextMenuFooterAction(sharedSpace.element));
    }
  }

  List<Widget> _contextDriveMenuActionTiles(BuildContext context, SelectableElement<SharedSpaceNodeNested> sharedSpace) {
    return [
      _sharedSpaceDetailsAction(sharedSpace.element),
      if (SharedSpaceOperationRole.addDriveMemberRoles.contains(sharedSpace.element.sharedSpaceRole.name))
        _addDriveMemberAction(sharedSpace.element),
    ];
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
                SvgPicture.asset(imagePath.icDelete, width: 24, height: 24, fit: BoxFit.fill),
                AppLocalizations.of(context).delete)
            .onActionClick((data) => sharedSpaceViewModel.removeSharedSpaces(context, [sharedSpace]))
            .build()
        : SizedBox.shrink();
  }

  Widget _renameWorkgroupAction(BuildContext context, SharedSpaceNodeNested sharedSpace) {
    return WorkgroupContextMenuTileBuilder(
        Key('rename_workgroup_context_menu_action'),
        SvgPicture.asset(imagePath.icRename, width: 24, height: 24, fit: BoxFit.fill),
        AppLocalizations.of(context).rename, sharedSpace)
      .onActionClick((sharedSpace) => sharedSpaceViewModel.openRenameWorkGroupModal(context, sharedSpace))
      .build();
  }

  Widget _sharedSpaceDetailsAction(SharedSpaceNodeNested sharedSpace) {
    return SimpleContextMenuActionBuilder(
            Key('shared_space_details_context_menu_action'),
            SvgPicture.asset(imagePath.icInfo, width: 24, height: 24, fit: BoxFit.fill),
            AppLocalizations.of(context).details)
        .onActionClick((data) => sharedSpaceViewModel.clickOnDetails(sharedSpace))
        .build();
  }

  Widget _addDriveMemberAction(SharedSpaceNodeNested drive) {
    return SimpleContextMenuActionBuilder(
          Key('add_drive_member_context_menu_action'),
          Icon(Icons.person_add, size: 24.0),
          AppLocalizations.of(context).add_a_member)
      .onActionClick((data) => sharedSpaceViewModel.clickOnAddDriveMember(drive))
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
        SvgPicture.asset(
          imagePath.icDelete,
          width: 24,
          height: 24,
          fit: BoxFit.fill,
        ),
        sharedSpaces)
        .onActionClick((documents) => sharedSpaceViewModel.removeSharedSpaces(context, documents, itemSelectionType: ItemSelectionType.multiple))
        .build();
  }

  Widget _buildMenuSorter() {
    return StoreConnector<AppState, AppState>(
      converter: (Store<AppState> store) => store.state,
      builder: (context, appState) {
        return !appState.uiState.isInSearchState()
            ? OrderByButtonBuilder(context, appState.sharedSpaceState.sorter)
                .onOpenOrderMenuAction((currentSorter) => sharedSpaceViewModel.openPopupMenuSorter(context, currentSorter))
                .build()
            : SizedBox.shrink();
      },
    );
  }

  List<Widget> _createNewSharedSpaceActionTiles(BuildContext context) {
    return [
      _createNewDrive(context),
      _createNewWorkgroup(context)
    ];
  }

  Widget _createNewWorkgroup(BuildContext context) => SimpleHorizontalContextMenuActionBuilder(
        Key('create_new_workgroup_context_menu_action'),
        SvgPicture.asset(imagePath.icWorkgroup, width: 30, height: 30, fit: BoxFit.fill),
        AppLocalizations.of(context).create_workgroup,
        spaceCenterHeight: 16)
    .onActionClick((_) => sharedSpaceViewModel.openCreateNewWorkGroup(context))
    .build();

  Widget _createNewDrive(BuildContext context) => SimpleHorizontalContextMenuActionBuilder(
        Key('create_new_drive_context_menu_action'),
        SvgPicture.asset(imagePath.icDrive, width: 30, height: 30, fit: BoxFit.fill),
        AppLocalizations.of(context).create_drive,
        spaceCenterHeight: 16)
    .onActionClick((_) => sharedSpaceViewModel.openCreateNewDrive(context))
    .build();
}
