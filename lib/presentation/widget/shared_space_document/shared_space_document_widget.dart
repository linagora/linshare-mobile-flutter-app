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

import 'dart:io';

import 'package:dartz/dartz.dart' as dartz;
import 'package:domain/domain.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/model/file/selectable_element.dart';
import 'package:linshare_flutter_app/presentation/model/item_selection_type.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/shared_space_document_destination_picker_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/shared_space_document_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/ui_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/datetime_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/media_type_extension.dart';
import 'package:linshare_flutter_app/presentation/util/helper/responsive_widget.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/view/background_widgets/background_widget_builder.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/simple_context_menu_action_builder.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/simple_horizontal_context_menu_action_builder.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/work_group_node_context_menu_action_builder.dart';
import 'package:linshare_flutter_app/presentation/view/multiple_selection_bar/multiple_selection_bar_builder.dart';
import 'package:linshare_flutter_app/presentation/view/multiple_selection_bar/workgroupnode_multiple_selection_action_builder.dart';
import 'package:linshare_flutter_app/presentation/view/order_by/order_by_button.dart';
import 'package:linshare_flutter_app/presentation/view/search/search_bottom_bar_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_document_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_document_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_document_navigator_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_document_type.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_document_ui_type.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/destination_type.dart';

class SharedSpaceDocumentWidget extends StatefulWidget {

  final SharedSpaceDocumentUIType sharedSpaceDocumentUIType;
  final OnBackSharedSpaceClickedCallback onBackSharedSpaceClickedCallback;
  final OnNodeClickedCallback nodeClickedCallback;

  SharedSpaceDocumentWidget(
    this.onBackSharedSpaceClickedCallback,
    this.nodeClickedCallback,
    {this.sharedSpaceDocumentUIType = SharedSpaceDocumentUIType.sharedSpace}
  );

  @override
  _SharedSpaceDocumentWidgetState createState() => _SharedSpaceDocumentWidgetState();
}

class _SharedSpaceDocumentWidgetState extends State<SharedSpaceDocumentWidget> {
  final appNavigation = getIt<AppNavigation>();
  final imagePath = getIt<AppImagePaths>();
  final sharedSpaceDocumentViewModel = getIt<SharedSpaceDocumentNodeViewModel>();

  SharedSpaceDocumentArguments _arguments;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _arguments = ModalRoute.of(context).settings.arguments;
      sharedSpaceDocumentViewModel.initial(_arguments);
      sharedSpaceDocumentViewModel.getSorterAndAllWorkGroupNode();
    });
  }

  @override
  void dispose() {
    sharedSpaceDocumentViewModel.onDisposed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: [
            if (widget.sharedSpaceDocumentUIType != SharedSpaceDocumentUIType.destinationPicker)
              ...[
                _buildTopBar(),
                _buildMultipleSelectionTopBar(),
                _buildMenuSorter()
              ],
            _buildLoadingLayout(),
            if (widget.sharedSpaceDocumentUIType != SharedSpaceDocumentUIType.destinationPicker)  _buildResultCount(),
            Expanded(
                child: widget.sharedSpaceDocumentUIType != SharedSpaceDocumentUIType.destinationPicker
                  ? buildWorkGroupListBySearchState()
                  : _buildSharedSpaceDocumentList()
            ),
            if (widget.sharedSpaceDocumentUIType != SharedSpaceDocumentUIType.destinationPicker)
              StoreConnector<AppState, SharedSpaceDocumentState>(
                converter: (store) => store.state.sharedSpaceDocumentState,
                builder: (context, state) => (state.selectMode == SelectMode.ACTIVE && state.getAllSelectedSharedSpaceDocument().isNotEmpty)
                    ? _buildMultipleSelectionBottomBar(context, state.getAllSelectedSharedSpaceDocument())
                    : SizedBox.shrink()
              )
          ]
        ),
        bottomNavigationBar: (widget.sharedSpaceDocumentUIType != SharedSpaceDocumentUIType.destinationPicker)
          ? StoreConnector<AppState, AppState>(
              converter: (store) => store.state,
              builder: (context, appState) => (!appState.uiState.isInSearchState()
                  && appState.sharedSpaceDocumentState.selectMode == SelectMode.INACTIVE)
                  ? SearchBottomBarBuilder()
                      .key(Key('shared_space_document_search_bottom_bar'))
                      .onSearchActionClick(() => sharedSpaceDocumentViewModel.openSearchState())
                      .build()
                  : SizedBox.shrink())
          : SizedBox.shrink()
        ,
        floatingActionButton: (widget.sharedSpaceDocumentUIType != SharedSpaceDocumentUIType.destinationPicker)
          ? StoreConnector<AppState, AppState>(
              converter: (store) => store.state,
              builder: (context, appState) => (!appState.uiState.isInSearchState() && appState.sharedSpaceDocumentState.selectMode == SelectMode.INACTIVE)
                ? FloatingActionButton(
                    key: Key('shared_space_document_upload_button'),
                    onPressed: () => (_arguments == null || _arguments.sharedSpaceNode.sharedSpaceRole.name == SharedSpaceRoleName.READER)
                      ? {}
                      : sharedSpaceDocumentViewModel.openAddNewFileOrFolderMenu(context, addNewFileOrFolderMenuActionTiles(context)),
                    backgroundColor: (_arguments == null || _arguments.sharedSpaceNode.sharedSpaceRole.name == SharedSpaceRoleName.READER)
                      ? AppColor.workgroupDetailFilesUploadDisableColor
                      : AppColor.workgroupDetailFilesUploadActiveColor,
                    child: SvgPicture.asset(
                      imagePath.icPlus,
                      width: 24,
                      height: 24,
                    ))
                : SizedBox.shrink())
          : SizedBox.shrink()
        ,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked
    );
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
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: Offset(0, 4))
            ]
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: GestureDetector(
                  onTap: widget.onBackSharedSpaceClickedCallback,
                  child: SvgPicture.asset(imagePath.icBackBlue, width: 24, height: 24),
                )
              ),
              _buildTitleTopBar()
            ]
          )
        )
      );
  }

  Widget _buildTitleTopBar() {
    return StoreConnector<AppState, SharedSpaceDocumentState>(
      converter: (store) => store.state.sharedSpaceDocumentState,
      builder: (context, documentState) => documentState.documentType == SharedSpaceDocumentType.root
        ? Text(
            AppLocalizations.of(context).workgroup_nodes_surfing_root_back_title,
            style: TextStyle(
              fontSize: 18,
              color: AppColor.workgroupNodesSurfingBackTitleColor,
              fontWeight: FontWeight.w400
            )
          )
        : Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 5.0, right: 45.0),
              child: Text(
                documentState.workGroupNode.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColor.workgroupNodesSurfingFolderNameColor
                )
              )
            )
          )
    );
  }

  Widget _buildMultipleSelectionTopBar() {
    return StoreConnector<AppState, SharedSpaceDocumentState>(
      converter: (store) => store.state.sharedSpaceDocumentState,
      builder: (context, state) => state.selectMode == SelectMode.ACTIVE
        ? ListTile(
          leading: SvgPicture.asset(
            imagePath.icSelectAll,
            width: 28,
            height: 28,
            fit: BoxFit.fill,
            color: state.isAllSharedSpaceDocumentSelected() ? AppColor.unselectedElementColor : AppColor.primaryColor
          ),
          title: Transform(
            transform: Matrix4.translationValues(-16, 0.0, 0.0),
            child: state.isAllSharedSpaceDocumentSelected()
              ? Text(
                  AppLocalizations.of(context).unselect_all,
                  maxLines: 1,
                  style: TextStyle(fontSize: 14, color: AppColor.documentNameItemTextColor)
                )
              : Text(
                  AppLocalizations.of(context).select_all,
                  maxLines: 1,
                  style: TextStyle(fontSize: 14, color: AppColor.documentNameItemTextColor)
                )
          ),
          tileColor: AppColor.topBarBackgroundColor,
          onTap: () => sharedSpaceDocumentViewModel.toggleSelectAllDocuments(),
          trailing: TextButton(
            onPressed: () => sharedSpaceDocumentViewModel.cancelSelection(),
            child: Text(
              AppLocalizations.of(context).cancel,
              maxLines: 1,
              style: TextStyle(fontSize: 14, color: AppColor.primaryColor)
            )
          )
        ) : SizedBox.shrink()
    );
  }

  Widget _buildMenuSorter() {
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, appState) => (!appState.uiState.isInSearchState() && appState.sharedSpaceDocumentState.sorter != null)
        ? OrderByButtonBuilder(context, appState.sharedSpaceDocumentState.sorter)
          .onOpenOrderMenuAction((currentSorter) => sharedSpaceDocumentViewModel.openPopupMenuSorter(context, currentSorter))
          .build()
        : SizedBox.shrink()
    );
  }

  Widget _buildLoadingLayout() {
    return StoreConnector<AppState, dartz.Either<Failure, Success>>(
      converter: (store) => (widget.sharedSpaceDocumentUIType == SharedSpaceDocumentUIType.sharedSpace)
          ? store.state.sharedSpaceDocumentState.viewState
          : store.state.sharedSpaceDocumentDestinationPickerState.viewState,
      builder: (context, viewState) => viewState.fold(
        (failure) => SizedBox.shrink(),
        (success) => (success is LoadingState)
          ? Align(
              alignment: Alignment.topCenter,
              child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor))
                  ))
            )
          : SizedBox.shrink())
    );
  }

  Widget _buildResultCount() {
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, appState) => (appState.uiState.isInSearchState() && sharedSpaceDocumentViewModel.searchQuery.value.isNotEmpty)
        ? _buildResultCountRow(appState.sharedSpaceDocumentState.workGroupNodeList)
        : SizedBox.shrink()
    );
  }

  Widget _buildResultCountRow(List<SelectableElement<WorkGroupNode>> resultList) {
    return Container(
      color: AppColor.topBarBackgroundColor,
      height: 40.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            AppLocalizations.of(context).results_count(resultList.length),
            style: TextStyle(fontSize: 16.0, color: AppColor.searchResultsCountTextColor)
          )
        )
      )
    );
  }

  Widget _buildMultipleSelectionBottomBar(BuildContext context, List<WorkGroupNode> allSelectedWorkGroupNodes) {
    return MultipleSelectionBarBuilder()
        .key(Key('multiple_work_group_node_selection_bar'))
        .text(AppLocalizations.of(context).items(allSelectedWorkGroupNodes.length))
        .actions(_multipleSelectionActions(context, allSelectedWorkGroupNodes))
        .build();
  }

  List<Widget> _multipleSelectionActions(BuildContext context, List<WorkGroupNode> workGroupNodes) {
    return [
      _downloadFileMultipleSelection(workGroupNodes),
      _removeMultipleSelection(workGroupNodes),
      _moreActionMultipleSelection(context, workGroupNodes)
    ];
  }

  Widget _downloadFileMultipleSelection(List<WorkGroupNode> workGroupNodes) {
    if (Platform.isAndroid || workGroupNodes.whereType<WorkGroupFolder>().toList().isNotEmpty) {
      return SizedBox.shrink();
    }
    return WorkGroupNodeMultipleSelectionActionBuilder(
              Key('multiple_selection_download_action'),
              SvgPicture.asset(
                imagePath.icExportFile,
                width: 24,
                height: 24,
                fit: BoxFit.fill,
              ),
              workGroupNodes)
          .onActionClick((documents) => sharedSpaceDocumentViewModel.exportFiles(context, documents, itemSelectionType: ItemSelectionType.multiple))
          .build();
  }

  IconButton _removeMultipleSelection(List<WorkGroupNode> workGroupNodes) {
    return WorkGroupNodeMultipleSelectionActionBuilder(
              Key('multiple_selection_remove_action'),
              SvgPicture.asset(
                imagePath.icDelete,
                width: 24,
                height: 24,
                fit: BoxFit.fill,
              ),
              workGroupNodes)
          .onActionClick((documents) => sharedSpaceDocumentViewModel.removeWorkGroupNode(context, documents, itemSelectionType: ItemSelectionType.multiple))
          .build();
  }

  Widget _moreActionMultipleSelection(BuildContext context, List<WorkGroupNode> workGroupNodes) {
    return WorkGroupNodeMultipleSelectionActionBuilder(
              Key('multiple_selection_more_action'),
              SvgPicture.asset(
                imagePath.icMoreVertical,
                width: 24,
                height: 24,
                fit: BoxFit.fill,
              ),
              workGroupNodes)
          .onActionClick((documents) => sharedSpaceDocumentViewModel.openMoreActionBottomMenu(
              context,
              workGroupNodes,
              _moreActionList(context, documents),
              _removeWorkGroupNodeAction(workGroupNodes, itemSelectionType: ItemSelectionType.multiple)))
          .build();
  }

  List<Widget> _moreActionList(BuildContext context, List<WorkGroupNode> workGroupNodes) {
    return [
      if (Platform.isIOS) _exportFileAction(workGroupNodes, itemSelectionType: ItemSelectionType.multiple),
      if (Platform.isAndroid) _downloadFilesAction(workGroupNodes, itemSelectionType: ItemSelectionType.multiple),
      _copyToAction(context, workGroupNodes, itemSelectionType: ItemSelectionType.multiple)
    ];
  }

  Widget buildWorkGroupListBySearchState() {
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, appState) => (appState.uiState.isInSearchState())
        ? _buildSearchResultWorkGroupList(appState.sharedSpaceDocumentState)
        : _buildSharedSpaceDocumentList()
    );
  }

  Widget _buildSearchResultWorkGroupList(SharedSpaceDocumentState sharedSpaceDocumentState) {
    if (sharedSpaceDocumentViewModel.searchQuery.value.isEmpty) {
      return SizedBox.shrink();
    } else {
      return sharedSpaceDocumentState.workGroupNodeList.isEmpty
        ? _buildNoResultFound()
        : _buildSharedSpaceDocumentList();
    }
  }

  Widget _buildNoResultFound() {
    return BackgroundWidgetBuilder()
      .key(Key('shared_space_document_search_no_result_found'))
      .text(AppLocalizations.of(context).no_results_found)
      .build();
  }

  Widget _buildSharedSpaceDocumentList() {
    if (widget.sharedSpaceDocumentUIType == SharedSpaceDocumentUIType.sharedSpace) {
      return StoreConnector<AppState, SharedSpaceDocumentState>(
        converter: (store) => store.state.sharedSpaceDocumentState,
        builder: (context, documentState) =>
          documentState.viewState.fold(
            (failure) => RefreshIndicator(
              onRefresh: () async => sharedSpaceDocumentViewModel.getAllWorkGroupNode(),
              child: failure is GetChildNodesFailure
                  ? SizedBox.shrink()
                  : _buildSharedSpaceDocumentListView(documentState.workGroupNodeList, documentState.selectMode)),
            (success) => success is LoadingState
              ? _buildSharedSpaceDocumentListView(documentState.workGroupNodeList, documentState.selectMode)
              : RefreshIndicator(
                  onRefresh: () async => sharedSpaceDocumentViewModel.getAllWorkGroupNode(),
                  child: _buildSharedSpaceDocumentListView(documentState.workGroupNodeList, documentState.selectMode))
          )
      );
    } else {
      return StoreConnector<AppState, SharedSpaceDocumentDestinationPickerState>(
        converter: (store) => store.state.sharedSpaceDocumentDestinationPickerState,
        builder: (context, destinationState) =>
          destinationState.viewState.fold(
            (failure) => RefreshIndicator(
              onRefresh: () async => sharedSpaceDocumentViewModel.getAllWorkGroupNode(),
              child: failure is GetChildNodesFailure
                  ? SizedBox.shrink()
                  : _buildSharedSpaceDocumentListView(destinationState.workGroupNodeList, destinationState.selectMode)),
            (success) => success is LoadingState
              ? _buildSharedSpaceDocumentListView(destinationState.workGroupNodeList, destinationState.selectMode)
              : RefreshIndicator(
                  onRefresh: () async => sharedSpaceDocumentViewModel.getAllWorkGroupNode(),
                  child: _buildSharedSpaceDocumentListView(destinationState.workGroupNodeList, destinationState.selectMode))
        )
      );
    }
  }

  Widget _buildSharedSpaceDocumentListView(List<SelectableElement<WorkGroupNode>> workGroupNodes, SelectMode selectMode) {
    return workGroupNodes.isNotEmpty
        ? ListView.builder(
            padding: ResponsiveWidget.isLargeScreen(context)
                ? EdgeInsets.symmetric(horizontal: 132.0)
                : EdgeInsets.zero,
            key: Key('shared_space_document_list'),
            itemCount: workGroupNodes.length,
            itemBuilder: (context, index) => _buildSharedSpaceDocumentListItem(context, workGroupNodes[index], selectMode))
        : _buildEmptyListIndicator();
  }

  Widget _buildEmptyListIndicator() {
    if (widget.sharedSpaceDocumentUIType == SharedSpaceDocumentUIType.destinationPicker || sharedSpaceDocumentViewModel.isInSearchState()) {
      return SizedBox.shrink();
    }
    return BackgroundWidgetBuilder()
      .image(
        SvgPicture.asset(
          imagePath.icUploadFile,
          width: 120,
          height: 120,
          fit: BoxFit.fill,
        ))
      .text(AppLocalizations.of(context).my_space_text_upload_your_files_here)
      .build();
  }

  Widget _buildSharedSpaceDocumentListItem(BuildContext context, SelectableElement<WorkGroupNode> node, SelectMode currentSelectMode) {
    switch (widget.sharedSpaceDocumentUIType) {
      case SharedSpaceDocumentUIType.destinationPicker:
        return _buildNodeItemDestinationPicker(context, node.element);
      default:
        return _buildNodeItemNormal(context, node, currentSelectMode);
    }
  }

  Widget _buildNodeItemNormal(BuildContext context, SelectableElement<WorkGroupNode> node, SelectMode currentSelectMode) {
    return ListTile(
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            node.element.type == WorkGroupNodeType.FOLDER
              ? imagePath.icFolder
              : (node.element as WorkGroupDocument).mediaType.getFileTypeImagePath(imagePath),
            width: 20,
            height: 24,
            fit: BoxFit.fill
          )
        ]
      ),
      title: Transform(
        transform: Matrix4.translationValues(-16, 0.0, 0.0),
        child: Text(
          node.element.name,
          maxLines: 1,
          style: TextStyle(fontSize: 14, color: AppColor.documentNameItemTextColor)
        )
      ),
      subtitle: Transform(
        transform: Matrix4.translationValues(-16, 0.0, 0.0),
        child: Text(
          AppLocalizations.of(context).item_last_modified(node.element.modificationDate.getMMMddyyyyFormatString()),
          maxLines: 1,
          style: TextStyle(fontSize: 13, color: AppColor.documentModifiedDateItemTextColor)
        )
      ),
      trailing: currentSelectMode == SelectMode.ACTIVE
        ? Checkbox(
            value: node.selectMode == SelectMode.ACTIVE,
            onChanged: (bool value) => sharedSpaceDocumentViewModel.selectItem(node),
            activeColor: AppColor.primaryColor)
        : IconButton(
            icon: SvgPicture.asset(
              imagePath.icContextMenu,
              width: 24,
              height: 24,
              fit: BoxFit.fill),
            onPressed: () =>  node.element.type == WorkGroupNodeType.FOLDER
                ? sharedSpaceDocumentViewModel.openWorkGroupNodeContextMenu(
                    context,
                    node.element,
                    _contextMenuFolderActionTiles(context, node.element))
                : sharedSpaceDocumentViewModel.openWorkGroupNodeContextMenu(
                    context,
                    node.element,
                    _contextMenuDocumentActionTiles(context, node.element),
                    footerAction: _removeWorkGroupNodeAction([node.element]))),
      onTap: () {
        if (currentSelectMode == SelectMode.ACTIVE) {
          sharedSpaceDocumentViewModel.selectItem(node);
        } else if (node.element.type == WorkGroupNodeType.DOCUMENT) {
          sharedSpaceDocumentViewModel.previewWorkGroupDocument(context, node.element);
        } else if (node.element.type == WorkGroupNodeType.FOLDER) {
          _goToWorkGroupFolder(node.element);
        }
      },
      onLongPress: () => sharedSpaceDocumentViewModel.selectItem(node)
    );
  }

  Widget _buildNodeItemDestinationPicker(BuildContext context, WorkGroupNode node) {
    return ListTile(
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          node.type == WorkGroupNodeType.FOLDER
          ? SvgPicture.asset(node.type == WorkGroupNodeType.FOLDER
                ? imagePath.icFolder
                : (node as WorkGroupDocument).mediaType.getFileTypeImagePath(imagePath),
              width: 20,
              height: 24,
              fit: BoxFit.fill)
          : Opacity(
              opacity: 0.6,
              child: SvgPicture.asset(node.type == WorkGroupNodeType.FOLDER
                ? imagePath.icFolder
                : (node as WorkGroupDocument).mediaType.getFileTypeImagePath(imagePath),
              width: 20,
              height: 24,
              fit: BoxFit.fill))
        ]
      ),
      title: Text(
        node.name,
        maxLines: 1,
        style: TextStyle(
            fontSize: 14,
            color: node.type == WorkGroupNodeType.FOLDER
                ? AppColor.documentNameItemTextColor
                : AppColor.documentNameItemTextColor.withOpacity(0.6)),
      ),
      onTap: () =>  node is WorkGroupFolder ? _goToWorkGroupFolder(node) : {}
    );
  }

  List<Widget> _contextMenuFolderActionTiles(BuildContext context, WorkGroupFolder workGroupFolder) {
    return [
      _renameWorkGroupNodeAction(workGroupFolder),
      _detailsAction(context, workGroupFolder)
    ];
  }

  List<Widget> _contextMenuDocumentActionTiles(BuildContext context, WorkGroupDocument workGroupDocument) {
    return [
      if (Platform.isIOS) _exportFileAction([workGroupDocument]),
      if (Platform.isAndroid) _downloadFilesAction([workGroupDocument]),
      _previewWorkGroupDocumentAction(workGroupDocument),
      _copyToAction(context, [workGroupDocument]),
      _renameWorkGroupNodeAction(workGroupDocument),
      _detailsAction(context, workGroupDocument),
      _manageVersionsAction(context, workGroupDocument),
    ];
  }

  Widget _detailsAction(BuildContext context, WorkGroupNode workGroupNode) {
    return WorkGroupNodeContextMenuTileBuilder(
          Key('work_group_details_context_menu_action'),
          SvgPicture.asset(imagePath.icInfo, width: 24, height: 24, fit: BoxFit.fill),
          AppLocalizations.of(context).details, workGroupNode)
      .onActionClick((data) => sharedSpaceDocumentViewModel.goToWorkGroupNodeDetails(data))
      .build();
  }

  Widget _manageVersionsAction(BuildContext context, WorkGroupNode workGroupNode) {
    return WorkGroupNodeContextMenuTileBuilder(
          Key('work_group_document_versions_context_menu_action'),
          SvgPicture.asset(imagePath.icHistory, width: 24, height: 24, fit: BoxFit.fill),
          AppLocalizations.of(context).manage_version, workGroupNode)
      .onActionClick((data) => sharedSpaceDocumentViewModel.goToWorkGroupNodeVersions(data))
      .build();
  }

  Widget _copyToAction(BuildContext context, List<WorkGroupNode> nodes,
      {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    return nodes.any((element) => element is WorkGroupFolder)
        ? SizedBox.shrink()
        : WorkGroupNodeContextMenuTileBuilder(
                Key('copy_to_context_menu_action'),
                SvgPicture.asset(imagePath.icSharedSpace, width: 24, height: 24, fit: BoxFit.fill),
                AppLocalizations.of(context).copy_to,
                nodes[0])
          .trailing(SvgPicture.asset(imagePath.icArrowRight,
              width: 24, height: 24, fit: BoxFit.fill))
          .onActionClick((data) => sharedSpaceDocumentViewModel.copyTo(
              context,
              nodes,
              [DestinationType.mySpace, DestinationType.workGroup],
              itemSelectionType: itemSelectionType))
          .build();
  }

  Widget _exportFileAction(List<WorkGroupNode> workGroupNodes,
      {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    return workGroupNodes.any((element) => element is WorkGroupFolder)
        ? SizedBox.shrink()
        : WorkGroupNodeContextMenuTileBuilder(
            Key('export_file_context_menu_action'),
            SvgPicture.asset(imagePath.icExportFile, width: 24, height: 24, fit: BoxFit.fill),
            AppLocalizations.of(context).export_file,
            workGroupNodes.first)
          .onActionClick((data) => sharedSpaceDocumentViewModel.exportFiles(context, workGroupNodes, itemSelectionType: itemSelectionType))
          .build();
  }

  Widget _downloadFilesAction(List<WorkGroupNode> workGroupNodes, {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    return workGroupNodes.any((element) => element is WorkGroupFolder)
        ? SizedBox.shrink()
        : WorkGroupNodeContextMenuTileBuilder(
            Key('download_file_context_menu_action'),
            SvgPicture.asset(imagePath.icFileDownload,
                width: 24, height: 24, fit: BoxFit.fill),
            AppLocalizations.of(context).download_to_device,
            workGroupNodes[0])
          .onActionClick((data) => sharedSpaceDocumentViewModel.downloadNodes(workGroupNodes, itemSelectionType: itemSelectionType))
          .build();
  }

  Widget _previewWorkGroupDocumentAction(WorkGroupDocument workGroupDocument) {
    return WorkGroupNodeContextMenuTileBuilder(
              Key('preview_work_group_document_context_menu_action'),
              SvgPicture.asset(imagePath.icPreview, width: 24, height: 24, fit: BoxFit.fill),
              AppLocalizations.of(context).preview,
              workGroupDocument)
          .onActionClick((data) => sharedSpaceDocumentViewModel.previewWorkGroupDocument(context, workGroupDocument))
          .build();
  }

  Widget _renameWorkGroupNodeAction(WorkGroupNode workGroupNode) {
    return WorkGroupNodeContextMenuTileBuilder(
              Key('rename_work_group_document_context_menu_action'),
              SvgPicture.asset(imagePath.icRename, width: 24, height: 24, fit: BoxFit.fill),
              AppLocalizations.of(context).rename,
              workGroupNode)
          .onActionClick((workgroupNode) => sharedSpaceDocumentViewModel.openRenameWorkGroupNodeModal(context, workgroupNode))
          .build();
  }

  Widget _removeWorkGroupNodeAction(List<WorkGroupNode> workGroupNodes, {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    return WorkGroupNodeContextMenuTileBuilder(
              Key('remove_work_group_document_context_menu_action'),
              SvgPicture.asset(imagePath.icDelete,
                  width: 24, height: 24, fit: BoxFit.fill),
              AppLocalizations.of(context).delete,
              workGroupNodes[0])
          .onActionClick((data) => sharedSpaceDocumentViewModel.removeWorkGroupNode(context, workGroupNodes, itemSelectionType: itemSelectionType))
          .build();
  }

  List<Widget> addNewFileOrFolderMenuActionTiles(BuildContext context) {
    return [
      uploadFileAction(),
      addNewFolderAction()
    ];
  }

  Widget addNewFolderAction() {
    return SimpleHorizontalContextMenuActionBuilder(
              Key('add_new_folder_context_menu_action'),
              SvgPicture.asset(imagePath.icCreateFolder, width: 24, height: 24, fit: BoxFit.fill),
              AppLocalizations.of(context).create_folder)
          .onActionClick((_) => sharedSpaceDocumentViewModel.openCreateFolderModal(context))
          .build();
  }

  Widget uploadFileAction() {
    return SimpleHorizontalContextMenuActionBuilder(
              Key('upload_file_context_menu_action'),
              SvgPicture.asset(imagePath.icPublish,
                  width: 24, height: 24, fit: BoxFit.fill),
              AppLocalizations.of(context).upload_file_title)
          .onActionClick((_) => sharedSpaceDocumentViewModel.openUploadFileMenu(context, uploadFileMenuActionTiles(context)))
          .build();
  }

  List<Widget> uploadFileMenuActionTiles(BuildContext context) {
    return [
      pickPhotoAndVideoAction(),
      browseFileAction()
    ];
  }

  Widget pickPhotoAndVideoAction() {
    return SimpleContextMenuActionBuilder(
              Key('pick_photo_and_video_context_menu_action'),
              SvgPicture.asset(imagePath.icPhotoLibrary, width: 24, height: 24, fit: BoxFit.fill),
              AppLocalizations.of(context).photos_and_videos)
          .onActionClick((_) => sharedSpaceDocumentViewModel.openFilePickerByType(FileType.media))
          .build();
  }

  Widget browseFileAction() {
    return SimpleContextMenuActionBuilder(
              Key('browse_file_context_menu_action'),
              SvgPicture.asset(imagePath.icMore, width: 24, height: 24, fit: BoxFit.fill),
              AppLocalizations.of(context).browse)
          .onActionClick((_) => sharedSpaceDocumentViewModel.openFilePickerByType(FileType.any))
          .build();
  }

  void _goToWorkGroupFolder(WorkGroupNode workGroupNode) {
    sharedSpaceDocumentViewModel.clearWorkGroupNodeListAction();
    widget.nodeClickedCallback(workGroupNode);
  }
}