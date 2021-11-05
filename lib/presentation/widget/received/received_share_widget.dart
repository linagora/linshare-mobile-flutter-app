/*
 * LinShare is an open source filesharing software, part of the LinPKI software
 * suite, developed by Linagora.
 *
 * Copyright (C) 2021 LINAGORA
 *
 * This program is free software: you can redistribute it and/or modify it under the
 * terms of the GNU Affero General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version,
 * provided you comply with the Additional Terms applicable for LinShare software by
 * Linagora pursuant to Section 7 of the GNU Affero General Public License,
 * subsections (b), (c), and (e), pursuant to which you must notably (i) retain the
 * display in the interface of the “LinShare™” trademark/logo, the "Libre & Free" mention,
 * the words “You are using the Free and Open Source version of LinShare™, powered by
 * Linagora © 2009–2021. Contribute to Linshare R&D by subscribing to an Enterprise
 * offer!”. You must also retain the latter notice in all asynchronous messages such as
 * e-mails sent with the Program, (ii) retain all hypertext links between LinShare and
 * http://www.linshare.org, between linagora.com and Linagora, and (iii) refrain from
 * infringing Linagora intellectual property rights over its trademarks and commercial
 * brands. Other Additional Terms apply, see
 * <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf>
 * for more details.
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for
 * more details.
 * You should have received a copy of the GNU Affero General Public License and its
 * applicable Additional Terms for LinShare along with this program. If not, see
 * <http://www.gnu.org/licenses/> for the GNU Affero General Public License version
 *  3 and <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf> for
 *  the Additional Terms applicable to LinShare software.
 */

import 'dart:io';

import 'package:domain/domain.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/model/file/selectable_element.dart';
import 'package:linshare_flutter_app/presentation/model/item_selection_type.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/functionality_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/received_share_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/ui_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/datetime_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/media_type_extension.dart';
import 'package:linshare_flutter_app/presentation/util/helper/responsive_utils.dart';
import 'package:linshare_flutter_app/presentation/util/helper/responsive_widget.dart';
import 'package:linshare_flutter_app/presentation/view/background_widgets/background_widget_builder.dart';
import 'package:linshare_flutter_app/presentation/view/common/common_view.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/received_share_context_menu_action_builder.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/share_context_menu_action_builder.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/simple_context_menu_action_builder.dart';
import 'package:linshare_flutter_app/presentation/view/multiple_selection_bar/multiple_selection_bar_builder.dart';
import 'package:linshare_flutter_app/presentation/view/multiple_selection_bar/received_share_multiple_selection_action_builder.dart';
import 'package:linshare_flutter_app/presentation/view/order_by/order_by_button.dart';
import 'package:linshare_flutter_app/presentation/view/search/search_bottom_bar_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/received/received_share_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/upload_file_widget.dart';
import 'package:redux/redux.dart';

class ReceivedShareWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ReceivedShareWidgetState();
}

class _ReceivedShareWidgetState extends State<ReceivedShareWidget> {
  final receivedShareViewModel = getIt<ReceivedShareViewModel>();
  final imagePath = getIt<AppImagePaths>();
  final _responsiveUtils = getIt<ResponsiveUtils>();
  final _widgetCommon = getIt<CommonView>();

  @override
  void initState() {
    super.initState();
    receivedShareViewModel.getSorterAndAllReceivedSharesAction();
  }

  @override
  void dispose() {
    receivedShareViewModel.onDisposed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ReceivedShareState>(
      converter: (store) => store.state.receivedShareState,
      builder: (context, state) {
        return Scaffold(
          body: Column(children: [
            state.selectMode == SelectMode.ACTIVE
                ? ListTile(
                    leading: SvgPicture.asset(imagePath.icSelectAll,
                        width: 28,
                        height: 28,
                        fit: BoxFit.fill,
                        color: state.isAllReceivedSharesSelected()
                            ? AppColor.unselectedElementColor
                            : AppColor.primaryColor),
                    title: Transform(
                        transform: Matrix4.translationValues(-16, 0.0, 0.0),
                        child: state.isAllReceivedSharesSelected()
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
                    onTap: () => receivedShareViewModel.toggleSelectAllReceivedShares(),
                    trailing: TextButton(
                        onPressed: () => receivedShareViewModel.cancelSelection(),
                        child: Text(
                          AppLocalizations.of(context).cancel,
                          maxLines: 1,
                          style: TextStyle(fontSize: 14, color: AppColor.primaryColor),
                        )),
                  )
                : SizedBox.shrink(),
            _buildMenuSorter(),
            state.viewState.fold(
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
                    : SizedBox.shrink()),
            _buildResultCount(),
            Expanded(child: buildReceivedSharesListBySearchState(context)),
            state.selectMode == SelectMode.ACTIVE && state.getAllSelectedReceivedShares().isNotEmpty
                ? MultipleSelectionBarBuilder()
                    .key(Key('multiple_received_shares_selection_bar'))
                    .text(AppLocalizations.of(context)
                        .items(state.getAllSelectedReceivedShares().length))
                    .actions(_multipleSelectionActions(context, state.getAllSelectedReceivedShares()))
                    .build()
                : SizedBox.shrink()
          ]),
          bottomNavigationBar: StoreConnector<AppState, AppState>(
            converter: (store) => store.state,
            builder: (context, appState) {
              if (!appState.uiState.isInSearchState() &&
                  appState.receivedShareState.selectMode == SelectMode.INACTIVE) {
                return SearchBottomBarBuilder()
                    .key(Key('search_bottom_bar'))
                    .onSearchActionClick(() => receivedShareViewModel.openSearchState(context))
                    .build();
              }
              return SizedBox.shrink();
            }),
        );
      },
    );
  }

  Widget _buildNormalReceivedShareList(BuildContext context, ReceivedShareState state) {
    return state.viewState.fold(
        (failure) => RefreshIndicator(
            onRefresh: () async => receivedShareViewModel.getAllReceivedShare(),
            child: failure is SharedSpacesFailure
                ? BackgroundWidgetBuilder()
                    .key(Key('received_share_error_background'))
                    .image(SvgPicture.asset(imagePath.icUnexpectedError,
                        width: 120, height: 120, fit: BoxFit.fill))
                    .text(AppLocalizations.of(context).common_error_occured_message)
                    .build()
                : _buildReceivedShareListView(context, state.receivedSharesList, state.selectMode)),
        (success) => success is LoadingState
            ? _buildReceivedShareListView(context, state.receivedSharesList, state.selectMode)
            : RefreshIndicator(
                onRefresh: () async => receivedShareViewModel.getAllReceivedShare(),
                child: _buildReceivedShareListView(context, state.receivedSharesList, state.selectMode)));
  }

  Widget buildReceivedSharesListBySearchState(BuildContext context) {
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, appState) {
        if (appState.uiState.isInSearchState()) {
          return _buildSearchResultReceivedShareList(appState.receivedShareState);
        }

        return _buildNormalReceivedShareList(context, appState.receivedShareState);
      });
  }

  Widget _buildSearchResultReceivedShareList(ReceivedShareState receivedShareState) {
    if (receivedShareViewModel.searchQuery.value.isEmpty) {
      return SizedBox.shrink();
    } else if (receivedShareState.receivedSharesList.isEmpty) {
      return _widgetCommon.buildNoResultFound(context);
    }

    return _buildReceivedShareListView(context, receivedShareState.receivedSharesList, receivedShareState.selectMode);
  }

  Widget _buildReceivedShareListView(
      BuildContext context, List<SelectableElement<ReceivedShare>> receivedList, SelectMode currentSelectMode) {
    if (receivedList.isEmpty) {
      return _buildNoReceivedShareYet(context);
    } else {
      return ListView.builder(
        key: Key('received_share_list'),
        padding: _responsiveUtils.getPaddingListItemForScreen(context),
        itemCount: receivedList.length,
        itemBuilder: (context, index) {
          return _buildReceivedShareListItem(context, receivedList[index], currentSelectMode, index);
        },
      );
    }
  }

  Widget _buildNoReceivedShareYet(BuildContext context) {
    return BackgroundWidgetBuilder()
        .key(Key('no_received_share_yet'))
        .image(
            SvgPicture.asset(imagePath.icNotReceivedYet, width: 120, height: 120, fit: BoxFit.fill))
        .text(AppLocalizations.of(context).not_have_received_yet)
        .build();
  }

  Widget _buildReceivedShareListItem(
      BuildContext context, SelectableElement<ReceivedShare> receivedShareItem, SelectMode currentSelectMode, int position) {
    return ListTile(
        leading: Transform.translate(
          offset: _responsiveUtils.isSmallScreen(context) ? Offset(0, -12) : Offset(0, 0),
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              receivedShareItem.element.mediaType.getFileTypeImagePath(imagePath),
              width: 20,
              height: 24,
              fit: BoxFit.fill)
          ]),
        ),
        title: ResponsiveWidget(
          smallScreen: Transform(
            transform: Matrix4.translationValues(-16, 0.0, 0.0),
            child: _buildFileName(receivedShareItem.element.name)
          ),
          mediumScreen: Transform.translate(
            offset: Offset(-16, 0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(child:
                        Align(alignment: Alignment.centerLeft,
                          child: _buildFileName(receivedShareItem.element.name))),
                      _buildOfflineModeIcon(receivedShareItem.element.syncOfflineState),
                  ])),
                Expanded(
                  flex: 2,
                  child: Align(alignment: Alignment.centerRight, child: _buildSenderName(receivedShareItem.element.sender.fullName()))),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _buildModifiedDateText(
                      AppLocalizations.of(context)
                        .item_created_date(receivedShareItem.element.creationDate.getMMMddyyyyFormatString()))
                  )
                ),
              ]
            ),
          ),
          responsiveUtil: _responsiveUtils,
        ),
        subtitle: _responsiveUtils.isSmallScreen(context)
          ? Transform(
            transform: Matrix4.translationValues(-16, 0.0, 0.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSenderName(receivedShareItem.element.sender.fullName()),
                      Row(children: [
                        _buildModifiedDateText(AppLocalizations.of(context).item_created_date(
                            receivedShareItem.element.creationDate.getMMMddyyyyFormatString())),
                        _buildOfflineModeIcon(receivedShareItem.element.syncOfflineState)
                      ])
                    ],
                  ),
                )
              ],
            ))
          : null,
        trailing: StoreConnector<AppState, SelectMode>(
            converter: (store) => store.state.receivedShareState.selectMode,
            builder: (context, selectMode) {
              return selectMode == SelectMode.ACTIVE
                  ? Checkbox(
                      value: receivedShareItem.selectMode == SelectMode.ACTIVE,
                      onChanged: (bool? value) => receivedShareViewModel.selectItem(receivedShareItem),
                      activeColor: AppColor.primaryColor,
                    )
                  : IconButton(
                      icon: SvgPicture.asset(
                        imagePath.icContextMenu,
                        width: 24,
                        height: 24,
                        fit: BoxFit.fill,
                      ),
                      onPressed: () => receivedShareViewModel.openContextMenu(
                        context,
                        receivedShareItem.element,
                        _contextMenuActionTiles(context, receivedShareItem.element, position),
                        footerAction: _removeFileAction([receivedShareItem.element])));
            }),
        onTap: () {
          if (currentSelectMode == SelectMode.ACTIVE) {
            receivedShareViewModel.selectItem(receivedShareItem);
          } else {
            receivedShareViewModel.onClickPreviewFile(context, receivedShareItem.element);
          }
        },
        onLongPress: () => receivedShareViewModel.selectItem(receivedShareItem));
  }

  Widget _buildFileName(String fileName) {
    return Padding(
      padding: _responsiveUtils.isSmallScreen(context)
        ? EdgeInsets.only(top: 16.0)
        : EdgeInsets.zero,
      child: CustomPaint(
        size: Size(double.infinity, 14),
        painter: EllipsisTextPainter(
          text: TextSpan(
            text: fileName,
            style: TextStyle(fontSize: 14, color: AppColor.documentNameItemTextColor)),
          ellipsis: fileName.toMiddleEllipsis(),
          maxLines: 1,
        ),
      ),
    );
  }

  Widget _buildModifiedDateText(String modificationDate) {
    return Text(
        modificationDate,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 13, color: AppColor.documentModifiedDateItemTextColor),
      );
  }

  Widget _buildSenderName(String sender) {
    return Padding(
      padding: _responsiveUtils.isSmallScreen(context)
        ? EdgeInsets.only(top: 12.0, bottom: 8.0)
        : EdgeInsets.only(left: 32, right: 32),
      child: Text(
        sender,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 13, color: AppColor.documentModifiedDateItemTextColor),
      ),
    );
  }

  List<Widget> _contextMenuActionTiles(BuildContext context, ReceivedShare receivedShare, int position) {
    return [
      _exportFileAction([receivedShare]),
      _makeAvailableOffline(receivedShare, position),
      if (Platform.isAndroid) _downloadAction([receivedShare]),
      _copyToMySpaceAction([receivedShare]),
      _copyToWorkGroupAction(context, [receivedShare]),
      _previewReceivedShareAction(receivedShare),
      _detailsAction(receivedShare)
    ];
  }

  Widget _exportFileAction(List<ReceivedShare> receivedShares, {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    return ReceivedShareContextMenuTileBuilder(
        Key('export_context_menu_action'),
        SvgPicture.asset(imagePath.icExportFile, width: 24, height: 24, fit: BoxFit.fill),
        AppLocalizations.of(context).export_file,
        receivedShares.first)
    .onActionClick((_) => receivedShareViewModel.exportFile(context, receivedShares, itemSelectionType: itemSelectionType))
    .build();
  }

  Widget _downloadAction(List<ReceivedShare> receivedShares, {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    return SimpleContextMenuActionBuilder(
            Key('download_context_menu_action'),
            SvgPicture.asset(imagePath.icFileDownload,
                width: 24, height: 24, fit: BoxFit.fill),
            AppLocalizations.of(context).download_to_device)
        .onActionClick((_) => receivedShareViewModel.downloadFileClick(
            receivedShares.map((share) => share.shareId).toList(),
            itemSelectionType: itemSelectionType))
        .build();
  }

  Widget _makeAvailableOffline(ReceivedShare receivedShare, int position) {
    return ReceivedShareContextMenuTileBuilder(
        Key('make_available_offline_context_menu_action'),
        SvgPicture.asset(receivedShare.isAvailableOffline() ? imagePath.icAvailableOfflineEnabled : imagePath.icAvailableOffline, width: 24, height: 24, fit: BoxFit.fill),
        AppLocalizations.of(context).available_offline,
        receivedShare)
      .onActionClick((data) {
        if (!data.isAvailableOffline()) {
          receivedShareViewModel.makeAvailableOffline(context, receivedShare, position);
        } else {
          receivedShareViewModel.disableOffline(context, receivedShare);
        }})
      .build();
  }

  Widget _copyToMySpaceAction(List<ReceivedShare> receivedShares,
      {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    return ShareContextMenuTileBuilder(
          Key('copy_to_my_space_context_menu_action'),
          SvgPicture.asset(imagePath.icCopy, width: 24, height: 24, fit: BoxFit.fill),
          AppLocalizations.of(context).copy_to_my_space,
          receivedShares.first)
      .onActionClick((data) => receivedShareViewModel.copyToMySpace(
          receivedShares,
          fromMoreAction: true,
          itemSelectionType: itemSelectionType))
      .build();
  }

  List<Widget> _multipleSelectionActions(BuildContext context, List<ReceivedShare> receivedShares) {
    return [
      if (Platform.isAndroid) _downloadMultipleSelection(receivedShares),
      _exportMultipleSelection(receivedShares),
      _copyToMySpaceMultipleSelection(receivedShares),
      _removeMultipleSelection(receivedShares),
      _moreActionMultipleSelection(context, receivedShares)
    ];
  }

  Widget _copyToMySpaceMultipleSelection(List<ReceivedShare> receivedShares) {
    return ReceivedShareMultipleSelectionActionBuilder(
          Key('multiple_selection_copy_action'),
          SvgPicture.asset(imagePath.icCopy, width: 24, height: 24, fit: BoxFit.fill,),
          receivedShares)
      .onActionClick((receivedShares) => receivedShareViewModel.copyToMySpace(receivedShares, itemSelectionType: ItemSelectionType.multiple))
      .build();
  }

  Widget _downloadMultipleSelection(List<ReceivedShare> shares) {
    return ReceivedShareMultipleSelectionActionBuilder(
            Key('multiple_selection_download_action_received_share'),
            SvgPicture.asset(imagePath.icFileDownload, width: 24, height: 24, fit: BoxFit.fill),
            shares)
        .onActionClick((shares) => receivedShareViewModel.downloadFileClick(
            shares.map((share) => share.shareId).toList(),
            itemSelectionType: ItemSelectionType.multiple))
        .build();
  }

  Widget _exportMultipleSelection(List<ReceivedShare> shares) {
    return ReceivedShareMultipleSelectionActionBuilder(
          Key('multiple_selection_export_action_received_share'),
          SvgPicture.asset(imagePath.icExportFile, width: 24, height: 24, fit: BoxFit.fill),
          shares)
      .onActionClick((shares) => receivedShareViewModel.exportFile(
          context,
          shares,
          itemSelectionType: ItemSelectionType.multiple))
      .build();
  }

  Widget _previewReceivedShareAction(ReceivedShare receivedShare) {
    return ReceivedShareContextMenuTileBuilder(
          Key('preview_received_share_context_menu_action'),
          SvgPicture.asset(imagePath.icPreview, width: 24, height: 24, fit: BoxFit.fill),
          AppLocalizations.of(context).preview,
          receivedShare)
       .onActionClick((data) => receivedShareViewModel.onClickPreviewFile(context, receivedShare))
       .build();
  }

  Widget _detailsAction(ReceivedShare receivedShare) {
    return ReceivedShareContextMenuTileBuilder(
          Key('details_received_share_context_menu_action'),
          SvgPicture.asset(imagePath.icInfo, width: 24, height: 24, fit: BoxFit.fill),
          AppLocalizations.of(context).details,
          receivedShare)
       .onActionClick((data) => receivedShareViewModel.goToDetails(receivedShare))
       .build();
  }

  Widget _buildMenuSorter() {
    return StoreConnector<AppState, AppState>(
      converter: (Store<AppState> store) => store.state,
      builder: (context, appState) {
        return !appState.uiState.isInSearchState()
            ? OrderByButtonBuilder(context, appState.receivedShareState.sorter)
                .onOpenOrderMenuAction((currentSorter) => receivedShareViewModel.openPopupMenuSorter(context, currentSorter))
                .build()
            : SizedBox.shrink();
      });
  }

  Widget _buildResultCount() {
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, appState) {
        if (appState.uiState.isInSearchState() && receivedShareViewModel.searchQuery.value.isNotEmpty) {
            return _widgetCommon.buildResultCountRow(context, appState.receivedShareState.receivedSharesList.length);
        }
        return SizedBox.shrink();
      });
  }

  Widget _removeFileAction(List<ReceivedShare> receivedShares, {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    if (receivedShares.isEmpty) {
      return SizedBox.shrink();
    }

    return ReceivedShareContextMenuTileBuilder(
      Key('delete_received_share_context_menu_action'),
      SvgPicture.asset(imagePath.icDelete, width: 24, height: 24, fit: BoxFit.fill),
      AppLocalizations.of(context).delete,
      receivedShares.first)
      .onActionClick(
          (data) => receivedShareViewModel.removeReceivedShare(context, receivedShares, itemSelectionType: itemSelectionType))
      .build();
  }

  Widget _removeMultipleSelection(List<ReceivedShare> receivedShares) {
    return ReceivedShareMultipleSelectionActionBuilder(
          Key('multiple_selection_remove_action'),
          SvgPicture.asset(imagePath.icDelete, width: 24, height: 24, fit: BoxFit.fill),
          receivedShares)
      .onActionClick((receivedShares) => receivedShareViewModel.removeReceivedShare(
          context, receivedShares, itemSelectionType: ItemSelectionType.multiple))
      .build();
  }

  Widget _moreActionMultipleSelection(BuildContext context, List<ReceivedShare> receivedShares) {
    return ReceivedShareMultipleSelectionActionBuilder(
        Key('multiple_selection_more_action'),
        SvgPicture.asset(imagePath.icMoreVertical, width: 24, height: 24, fit: BoxFit.fill,),
        receivedShares)
    .onActionClick((receivedShares) => receivedShareViewModel.openMoreActionBottomMenu(
        context,
        receivedShares,
        _moreActionList(context, receivedShares),
        _removeFileAction(receivedShares, itemSelectionType: ItemSelectionType.multiple)))
    .build();
  }

  List<Widget> _moreActionList(BuildContext context, List<ReceivedShare> receivedShares) {
    return [
      if (Platform.isAndroid) _downloadAction(receivedShares, itemSelectionType: ItemSelectionType.multiple),
      _exportFileAction(receivedShares, itemSelectionType: ItemSelectionType.multiple),
      _copyToMySpaceAction(receivedShares, itemSelectionType: ItemSelectionType.multiple),
      _copyToWorkGroupAction(context, receivedShares, itemSelectionType: ItemSelectionType.multiple),
    ];
  }

  Widget _copyToWorkGroupAction(BuildContext context, List<ReceivedShare> receivedShares,
      {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    return StoreConnector<AppState, FunctionalityState>(
      converter: (Store<AppState> store) => store.state.functionalityState,
      builder: (context, state) => state.isSharedSpaceEnable()
        ? ReceivedShareContextMenuTileBuilder(
              Key('copy_to_workgroup_context_menu_action'),
              SvgPicture.asset(imagePath.icSharedSpace, width: 24, height: 24, fit: BoxFit.fill),
              AppLocalizations.of(context).copy_to_a_workgroup,
              receivedShares.first)
          .onActionClick((data) => receivedShareViewModel.clickOnCopyToAWorkGroup(
              context,
              receivedShares,
              itemSelectionType: itemSelectionType))
          .build()
       : SizedBox.shrink());
  }

  Widget _buildOfflineModeIcon(SyncOfflineState? syncOfflineState) {
    switch (syncOfflineState) {
      case SyncOfflineState.waiting:
        return Padding(
            padding: EdgeInsets.only(left: 8),
            child: SizedBox(
                width: 16,
                height: 16,
                child: CupertinoActivityIndicator()
            ));
      case SyncOfflineState.completed:
        return Padding(
            padding: EdgeInsets.only(left: 8),
            child: SvgPicture.asset(
              imagePath.icAvailableOfflineEnabled,
              width: 16,
              height: 16,
              fit: BoxFit.fill,
            ));
      default:
        return SizedBox.shrink();
    }
  }
}
