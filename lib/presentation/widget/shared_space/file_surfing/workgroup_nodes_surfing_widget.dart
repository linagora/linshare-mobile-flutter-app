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

import 'dart:ui';

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/work_group_document_context_menu_action_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space/file_surfing/node_surfing_type.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space/file_surfing/workgroup_nodes_surfing_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/view/background_widgets/background_widget_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space/file_surfing/workgroup_nodes_surfing_model.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/media_type_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/datetime_extension.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space/file_surfing/workgroup_nodes_surfling_arguments.dart';

import 'workgroup_nodes_surfing_navigator.dart';

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
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: widget.nodeSurfingType == NodeSurfingType.normal ? EdgeInsets.only(top: 48) : EdgeInsets.only(top: 0),
          color: Colors.white,
          child: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: () async => await _model.loadAllChildNodes(),
            child: StreamBuilder<WorkGroupNodesSurfingState>(
              stream: _model.stateSubscription,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return _buildLoadingWidget();

                final state = snapshot.data;
                if (state.children.isNotEmpty) {
                  return _buildFileList(state.children);
                } else if (state.showLoading) {
                  return _buildLoadingWidget();
                } else {
                  return _buildEmptyListIndicator();
                }
              },
            ),
          ),
        ),
        widget.nodeSurfingType == NodeSurfingType.normal ? _buildTopBar() : SizedBox.shrink(),
      ],
    );
  }

  Widget _buildTopBar() {
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

  Widget _buildFileList(List<WorkGroupNode> nodes) {
    return ListView.builder(
      itemCount: nodes.length,
      itemBuilder: (context, index) {
        return _buildNodeItem(context, nodes[index]);
      },
    );
  }

  Widget _buildNodeItem(BuildContext context, WorkGroupNode node) {
    switch (widget.nodeSurfingType) {
      case NodeSurfingType.normal:
        return _buildNodeItemNormal(context, node);
      case NodeSurfingType.destinationPicker:
        return _buildNodeItemDestinationPicker(context, node);
      default:
        return _buildNodeItemNormal(context, node);
    }
  }

  Widget _buildNodeItemNormal(BuildContext context, WorkGroupNode node) {
    return ListTile(
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            node.type == WorkGroupNodeType.FOLDER
                ? imagePath.icFolder
                : (node as WorkGroupDocument)
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
          node.name,
          maxLines: 1,
          style: TextStyle(
              fontSize: 14, color: AppColor.documentNameItemTextColor),
        ),
      ),
      subtitle: Transform(
        transform: Matrix4.translationValues(-16, 0.0, 0.0),
        child: Text(
          AppLocalizations.of(context).item_last_modified(
              node.modificationDate.getMMMddyyyyFormatString()),
          maxLines: 1,
          style: TextStyle(
              fontSize: 13, color: AppColor.documentModifiedDateItemTextColor),
        ),
      ),
      trailing: IconButton(
        icon: SvgPicture.asset(
          imagePath.icContextMenu,
          width: 24,
          height: 24,
          fit: BoxFit.fill,
        ),
        onPressed: () => node.type == WorkGroupNodeType.FOLDER ?
          _model.openFolderContextMenu(context, node, _contextMenuFolderActionTiles(context, node)) :
          _model.openDocumentContextMenu(context, node, _contextMenuDocumentActionTiles(context, node), _removeDocumentAction(node))
      ),
      onTap: () => widget.nodeClickedCallback(node),
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
    if (widget.nodeSurfingType == NodeSurfingType.destinationPicker) {
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
    return [];
  }

  Widget _removeDocumentAction(WorkGroupDocument workGroupDocument) {
    return WorkGroupDocumentContextMenuTileBuilder(
      Key('remove_work_group_document_context_menu_action'),
      SvgPicture.asset(imagePath.icDelete,
          width: 24, height: 24, fit: BoxFit.fill),
      AppLocalizations.of(context).delete,
      workGroupDocument)
    .onActionClick((data) => _model.removeWorkGroupNode(context, [workGroupDocument]))
    .build();
  }
}
