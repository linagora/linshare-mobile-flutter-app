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
//

import 'dart:io';
import 'dart:ui';

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/model/file/selectable_element.dart';
import 'package:linshare_flutter_app/presentation/model/item_selection_type.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/ui_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/datetime_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/media_type_extension.dart';
import 'package:linshare_flutter_app/presentation/view/background_widgets/background_widget_builder.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/work_group_document_context_menu_action_builder.dart';
import 'package:linshare_flutter_app/presentation/view/multiple_selection_bar/multiple_selection_bar_builder.dart';
import 'package:linshare_flutter_app/presentation/view/multiple_selection_bar/workgroupnode_multiple_selection_action_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space/file_surfing/node_surfing_type.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space/file_surfing/workgroup_nodes_surfing_state.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space/file_surfing/workgroup_nodes_surfing_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space/file_surfing/workgroup_nodes_surfling_arguments.dart';

import 'workgroup_nodes_surfing_navigator_widget.dart';

class WorkGroupNodesSurfingWidget extends StatefulWidget {
  final OnNodeClickedCallback nodeClickedCallback;
  final OnBackClickedCallback backClickedCallback;
  final NodeSurfingType nodeSurfingType;

  WorkGroupNodesSurfingWidget(
    this.nodeClickedCallback,
    this.backClickedCallback,
    {this.nodeSurfingType = NodeSurfingType.normal}
  );

  @override
  _WorkGroupNodesSurfingWidgetState createState() => _WorkGroupNodesSurfingWidgetState();
}

class _WorkGroupNodesSurfingWidgetState extends State<WorkGroupNodesSurfingWidget> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final WorkGroupNodesSurfingViewModel _model = getIt<WorkGroupNodesSurfingViewModel>();
  final imagePath = getIt<AppImagePaths>();
  WorkGroupNodesSurfingArguments _arguments;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _arguments = ModalRoute.of(context).settings.arguments as WorkGroupNodesSurfingArguments;
      _model.initial(_arguments);
      _model.loadAllChildNodes();
    });
  }

  @override
  void dispose() {
    _model.onDisposed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<WorkGroupNodesSurfingState>(
      stream: _model.stateSubscription,
      builder: (context, snapshot) {
        return Column(
          children: [
            widget.nodeSurfingType == NodeSurfingType.normal ? _buildTopBar() : SizedBox.shrink(),
            snapshot.data?.selectMode == SelectMode.ACTIVE ? _buildMultipleSelectionTopBar(snapshot.data) : SizedBox.shrink(),
            _buildResultCount(),
            Expanded(child: RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: () async => await _model.loadAllChildNodes(),
              child: StreamBuilder<WorkGroupNodesSurfingState>(
                stream: _model.stateSubscription,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return _buildLoadingWidget();

                  final state = snapshot.data;
                  if (state.children.isNotEmpty) {
                    return _buildFileList(state.children, snapshot.data.selectMode);
                  } else if (state.showLoading) {
                    return _buildLoadingWidget();
                  } else {
                    return _buildEmptyListIndicator();
                  }
                },
              ),
            )),
            snapshot.data?.selectMode == SelectMode.ACTIVE && snapshot.data.getAllSelectedDocuments().isNotEmpty ? _buildMultipleSelectionBottomBar(context, snapshot.data.getAllSelectedDocuments()) : SizedBox.shrink(),
          ],
        );
      },
    );
  }

  Widget _buildTopBar() {
    return StoreConnector<AppState, SearchStatus>(
        converter: (store) => store.state.uiState.searchState.searchStatus,
        builder: (context, searchStatus) {
          if (searchStatus == SearchStatus.ACTIVE) {
            return SizedBox.shrink();
          } else {
            return Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: GestureDetector(
                      onTap: widget.backClickedCallback,
                      child: SvgPicture.asset(
                        imagePath.icBackBlue,
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ),
                  StreamBuilder<WorkGroupNodesSurfingState>(
                    stream: _model.stateSubscription,
                    builder: (store, snapshot) {
                      if (!snapshot.hasData) return _buildLoadingWidget();

                      switch (snapshot.data.folderNodeType) {
                        case FolderNodeType.root:
                          return Text(
                            AppLocalizations.of(context).workgroup_nodes_surfing_root_back_title,
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColor.workgroupNodesSurfingBackTitleColor,
                              fontWeight: FontWeight.w400,
                            ),
                          );
                        case FolderNodeType.normal:
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5.0, right: 45.0),
                              child: Text(
                                snapshot.data.node.name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.workgroupNodesSurfingFolderNameColor,
                                ),
                              ),
                            ),
                          );
                      }

                      return SizedBox.shrink();
                    },
                  ),
                ],
              ),
            );
          }
        });
  }


  Widget _buildFileList(List<SelectableElement<WorkGroupNode>> nodes, SelectMode currentSelectMode) {
    return ListView.builder(
      itemCount: nodes.length,
      itemBuilder: (context, index) {
        return _buildNodeItem(context, nodes[index], currentSelectMode);
      },
    );
  }

  Widget _buildNodeItem(BuildContext context, SelectableElement<WorkGroupNode> node, SelectMode currentSelectMode) {
    switch (widget.nodeSurfingType) {
      case NodeSurfingType.normal:
        return _buildNodeItemNormal(context, node, currentSelectMode);
      case NodeSurfingType.destinationPicker:
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
                : (node.element as WorkGroupDocument)
                    .mediaType
                    .getFileTypeImagePath(imagePath),
            width: 20,
            height: 24,
            fit: BoxFit.fill,
          ),
        ],
      ),
      title: Transform(
        transform: Matrix4.translationValues(-16, 0.0, 0.0),
        child: Text(
          node.element.name,
          maxLines: 1,
          style: TextStyle(
              fontSize: 14, color: AppColor.documentNameItemTextColor),
        ),
      ),
      subtitle: Transform(
        transform: Matrix4.translationValues(-16, 0.0, 0.0),
        child: Text(
          AppLocalizations.of(context).item_last_modified(
              node.element.modificationDate.getMMMddyyyyFormatString()),
          maxLines: 1,
          style: TextStyle(
              fontSize: 13, color: AppColor.documentModifiedDateItemTextColor),
        ),
      ),
      trailing: currentSelectMode == SelectMode.ACTIVE
        ? Checkbox(
            value: node.selectMode == SelectMode.ACTIVE,
            onChanged: (bool value) => _model.selectItem(node),
            activeColor: AppColor.primaryColor,
          )
        : IconButton(
            icon: SvgPicture.asset(
              imagePath.icContextMenu,
              width: 24,
              height: 24,
              fit: BoxFit.fill,
            ),
            onPressed: () => node.element.type == WorkGroupNodeType.FOLDER ?
              _model.openFolderContextMenu(context, node.element, _contextMenuFolderActionTiles(context, node.element)) :
              _model.openDocumentContextMenu(context, node.element, _contextMenuDocumentActionTiles(context, node.element), _removeWorkGroupNodeAction([node.element]))
      ),
      onTap: () => currentSelectMode == SelectMode.ACTIVE ? _model.selectItem(node) : widget.nodeClickedCallback(node.element),
      onLongPress: () => _model.selectItem(node),
    );
  }

  Widget _buildNodeItemDestinationPicker(
      BuildContext context, WorkGroupNode node) {
    return ListTile(
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          node.type == WorkGroupNodeType.FOLDER
              ? SvgPicture.asset(
                  node.type == WorkGroupNodeType.FOLDER
                      ? imagePath.icFolder
                      : (node as WorkGroupDocument)
                          .mediaType
                          .getFileTypeImagePath(imagePath),
                  width: 20,
                  height: 24,
                  fit: BoxFit.fill,
                )
              : Opacity(
                  opacity: 0.6,
                  child: SvgPicture.asset(
                    node.type == WorkGroupNodeType.FOLDER
                        ? imagePath.icFolder
                        : (node as WorkGroupDocument)
                            .mediaType
                            .getFileTypeImagePath(imagePath),
                    width: 20,
                    height: 24,
                    fit: BoxFit.fill,
                  ),
                ),
        ],
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
      onTap: () => widget.nodeClickedCallback(node),
    );
  }

  Widget _buildEmptyListIndicator() {
    if (widget.nodeSurfingType == NodeSurfingType.destinationPicker || _model.isInSearchState()) {
      return SizedBox.shrink();
    }
    return BackgroundWidgetBuilder()
        .image(
          SvgPicture.asset(
            imagePath.icUploadFile,
            width: 120,
            height: 120,
            fit: BoxFit.fill,
          ),
        )
        .text(AppLocalizations.of(context).my_space_text_upload_your_files_here)
        .build();
  }

  Widget _buildLoadingWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _contextMenuFolderActionTiles(BuildContext context, WorkGroupFolder workGroupFolder) {
    return [];
  }

  List<Widget> _contextMenuDocumentActionTiles(BuildContext context, WorkGroupDocument workGroupDocument) {
    return [
      _copyToMySpaceAction(context, [workGroupDocument]),
      if (Platform.isIOS) _exportFileAction([workGroupDocument]),
      if (Platform.isAndroid) _downloadFilesAction([workGroupDocument])
    ];
  }

  Widget _removeWorkGroupNodeAction(List<WorkGroupNode> workGroupNodes, {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    return WorkGroupDocumentContextMenuTileBuilder(
      Key('remove_work_group_document_context_menu_action'),
      SvgPicture.asset(imagePath.icDelete,
          width: 24, height: 24, fit: BoxFit.fill),
      AppLocalizations.of(context).delete,
        workGroupNodes[0])
    .onActionClick((data) => _model.removeWorkGroupNode(context, workGroupNodes, itemSelectionType: itemSelectionType))
    .build();
  }

  Widget _buildMultipleSelectionTopBar(WorkGroupNodesSurfingState state) {
    return ListTile(
      leading: SvgPicture.asset(
        imagePath.icSelectAll,
        width: 28,
        height: 28,
        fit: BoxFit.fill,
        color: state.isAllDocumentsSelected() ?
          AppColor.unselectedElementColor :
          AppColor.primaryColor
      ),
      title: Transform(
        transform: Matrix4.translationValues(-16, 0.0, 0.0),
        child: state.isAllDocumentsSelected() ?
          Text(AppLocalizations.of(context).unselect_all,
            maxLines: 1,
            style: TextStyle(fontSize: 14, color: AppColor.documentNameItemTextColor)) :
          Text(AppLocalizations.of(context).select_all,
            maxLines: 1,
            style: TextStyle(fontSize: 14, color: AppColor.documentNameItemTextColor),
          )
      ),
      tileColor: AppColor.topBarBackgroundColor,
      onTap: () => _model.toggleSelectAllWorkGroupNodes(),
      trailing: TextButton(
        onPressed: () => _model.cancelSelection(),
        child: Text(AppLocalizations.of(context).cancel,
        maxLines: 1,
        style: TextStyle(fontSize: 14, color: AppColor.primaryColor),
      )),
    );
  }

  Widget _buildMultipleSelectionBottomBar(BuildContext context, List<WorkGroupNode> allSelectedWorkGroupNodes) {
    return MultipleSelectionBarBuilder()
      .key(Key('multiple_document_selection_bar'))
      .text(
        AppLocalizations
          .of(context)
          .items(allSelectedWorkGroupNodes.length))
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
      .onActionClick((documents) => _model.removeWorkGroupNode(context, documents, itemSelectionType: ItemSelectionType.multiple))
      .build();
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
        .onActionClick((documents) => _model.exportFiles(context, documents, itemSelectionType: ItemSelectionType.multiple))
        .build();
  }

  Widget _copyToMySpaceAction(BuildContext context, List<WorkGroupNode> workGroupNodes) {
    return workGroupNodes.any((element) => element is WorkGroupFolder) ?
      SizedBox.shrink() :
      WorkGroupDocumentContextMenuTileBuilder(
        Key('copy_in_my_space_context_menu_action'),
        SvgPicture.asset(imagePath.icCopy,
            width: 24, height: 24, fit: BoxFit.fill),
        AppLocalizations.of(context).copy_to_my_space,
        workGroupNodes.first)
        .onActionClick((data) => _model.copyToMySpace(workGroupNodes))
        .build();
  }

  Widget _downloadFilesAction(List<WorkGroupNode> workGroupNodes, {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    return workGroupNodes.any((element) => element is WorkGroupFolder)
        ? SizedBox.shrink()
        : WorkGroupDocumentContextMenuTileBuilder(
            Key('download_file_context_menu_action'),
            SvgPicture.asset(imagePath.icFileDownload,
              width: 24, height: 24, fit: BoxFit.fill),
            AppLocalizations.of(context).download_to_device,
            workGroupNodes[0])
          .onActionClick((data) => _model.downloadNodes(workGroupNodes, itemSelectionType: itemSelectionType))
      .build();
  }

  Widget _exportFileAction(List<WorkGroupNode> workGroupNodes,
      {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    return workGroupNodes.any((element) => element is WorkGroupFolder) ?
    SizedBox.shrink() :
    WorkGroupDocumentContextMenuTileBuilder(
        Key('export_file_context_menu_action'),
        SvgPicture.asset(imagePath.icExportFile,
            width: 24, height: 24, fit: BoxFit.fill),
        AppLocalizations.of(context).export_file,
        workGroupNodes.first)
        .onActionClick((data) => _model.exportFiles(context, workGroupNodes, itemSelectionType: itemSelectionType))
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
        .onActionClick((documents) => _model.openMoreActionBottomMenu(
            context, workGroupNodes, _moreActionList(context, documents),
        _removeWorkGroupNodeAction(workGroupNodes, itemSelectionType: ItemSelectionType.multiple)))
        .build();
  }

  List<Widget> _moreActionList(BuildContext context, List<WorkGroupNode> workGroupNodes) {
    return [
      _copyToMySpaceAction(context, workGroupNodes),
      if (Platform.isIOS) _exportFileAction(workGroupNodes, itemSelectionType: ItemSelectionType.multiple),
      if (Platform.isAndroid) _downloadFilesAction(workGroupNodes, itemSelectionType: ItemSelectionType.multiple)
    ];
  }

  Widget _buildResultCount() {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, appState) {
          if (appState.uiState.isInSearchState() && _model.searchQuery.value.isNotEmpty) {
            return _buildResultCountRow(_model.currentState.children);
          }
          return SizedBox.shrink();
        });
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
            style: TextStyle(fontSize: 16.0, color: AppColor.searchResultsCountTextColor),
          ),
        ),
      ),
    );
  }
}
