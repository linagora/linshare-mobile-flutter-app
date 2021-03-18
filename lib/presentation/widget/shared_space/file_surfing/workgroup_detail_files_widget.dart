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

import 'package:domain/domain.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/simple_context_menu_action_builder.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/simple_horizontal_context_menu_action_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space/file_surfing/node_surfing_type.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space/file_surfing/workgroup_detail_files_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space/file_surfing/workgroup_nodes_surfing_navigator_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space/file_surfing/workgroup_nodes_surfling_arguments.dart';
import 'package:rxdart/rxdart.dart';

class WorkGroupDetailFilesWidget extends StatefulWidget {
  final SharedSpaceNodeNested sharedSpaceNode;
  final OnBackClickedCallback onBackClickedCallback;
  final NodeSurfingType nodeSurfingType;
  final GlobalKey<WorkGroupNodesSurfingNavigatorState> _workgroupNavigatorKey = GlobalKey();
  final BehaviorSubject<WorkGroupNodesSurfingArguments> currentNodeObservable;

  WorkGroupDetailFilesWidget(
      Key key,
      this.sharedSpaceNode,
      this.onBackClickedCallback,
      {this.nodeSurfingType = NodeSurfingType.normal,
      this.currentNodeObservable}) : super(key: key);

  @override
  WorkGroupDetailFilesWidgetState createState() => WorkGroupDetailFilesWidgetState();

  void nodeSurfingNavigateBack() => _workgroupNavigatorKey.currentState.widget.nodeSurfingNavigateBack();
}

class WorkGroupDetailFilesWidgetState extends State<WorkGroupDetailFilesWidget> {
  final AppImagePaths imagePath = getIt<AppImagePaths>();
  final workGroupDetailFilesViewModel = getIt<WorkGroupDetailFilesViewModel>();
  final appNavigation = getIt<AppNavigation>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: WorkGroupNodesSurfingNavigator(
            widget._workgroupNavigatorKey,
            widget.sharedSpaceNode,
            widget.onBackClickedCallback,
            nodeSurfingType: widget.nodeSurfingType,
            currentNodeObservable: widget.currentNodeObservable,
          )
        ),
        StoreConnector<AppState, bool>(
          converter: (store) => store.state.sharedSpaceState.showUploadButton,
          distinct: true,
          builder: (context, showUploadButton) {
            return showUploadButton ? Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: 76,
                child: _buildBottomLayout(context),
              ),
            ) : SizedBox.shrink();
          }
        ),
      ],
    );
  }

  Widget _buildBottomLayout(BuildContext context) {
    switch (widget.nodeSurfingType) {
      case NodeSurfingType.normal:
        return _buildBottomLayoutNormal(context);
      case NodeSurfingType.destinationPicker:
        return _buildBottomLayoutDestinationPicker(context);
      default:
        return _buildBottomLayoutNormal(context);
    }
  }

  Widget _buildBottomLayoutNormal(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 56,
            color: AppColor.workgroupDetailFilesBottomBarColor,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox.shrink(),
                GestureDetector(
                  onTap: () => workGroupDetailFilesViewModel.openSearchState(),
                  child: SvgPicture.asset(
                    imagePath.icSearchBlue,
                    width: 32,
                    height: 32,
                  ),
                )
              ],
            )),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: GestureDetector(
            onTap: () => widget.sharedSpaceNode.sharedSpaceRole.name ==
                    SharedSpaceRoleName.READER
                ? {}
                : workGroupDetailFilesViewModel.openAddNewFileOrFolderMenu(
                    context,
                    addNewFileOrFolderMenuActionTiles(context)
                ),
            child: _buildUploadWidget(),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomLayoutDestinationPicker(BuildContext context) {
    return SizedBox.shrink();
  }

  Widget _buildUploadWidget() {
    final readerRole = widget.sharedSpaceNode.sharedSpaceRole.name == SharedSpaceRoleName.READER;
    final buttonColor = readerRole
        ? AppColor.workgroupDetailFilesUploadDisableColor
        : AppColor.workgroupDetailFilesUploadActiveColor;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(28.0)),
          color: buttonColor,
          boxShadow: [
            BoxShadow(
              color: buttonColor.withOpacity(0.3),
              blurRadius: 20.0,
              offset: Offset(0, 10),
            )
          ]
      ),
      child: Center(
        child: SvgPicture.asset(
          imagePath.icPlus,
          width: 24,
          height: 24,
        ),
      ),
    );
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
            SvgPicture.asset(imagePath.icCreateFolder,
                width: 24, height: 24, fit: BoxFit.fill),
            AppLocalizations.of(context).create_folder)
        .onActionClick((_) =>
            workGroupDetailFilesViewModel.openCreateFolderModal(context, widget._workgroupNavigatorKey.currentState.widget.currentPageData))
        .build();
  }

  Widget uploadFileAction() {
    return SimpleHorizontalContextMenuActionBuilder(
            Key('upload_file_context_menu_action'),
            SvgPicture.asset(imagePath.icPublish,
                width: 24, height: 24, fit: BoxFit.fill),
            AppLocalizations.of(context).upload_file_title)
        .onActionClick((_) =>
            workGroupDetailFilesViewModel.openUploadFileMenu(context, uploadFileMenuActionTiles(context)))
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
            SvgPicture.asset(imagePath.icPhotoLibrary,
                width: 24, height: 24, fit: BoxFit.fill),
            AppLocalizations.of(context).photos_and_videos)
        .onActionClick((_) =>
            workGroupDetailFilesViewModel.openFilePickerByType(
                widget._workgroupNavigatorKey.currentState.widget.currentPageData,
                FileType.media))
        .build();
  }

  Widget browseFileAction() {
    return SimpleContextMenuActionBuilder(
            Key('browse_file_context_menu_action'),
            SvgPicture.asset(imagePath.icMore,
                width: 24, height: 24, fit: BoxFit.fill),
            AppLocalizations.of(context).browse)
        .onActionClick((_) =>
            workGroupDetailFilesViewModel.openFilePickerByType(
                widget._workgroupNavigatorKey.currentState.widget.currentPageData,
                FileType.any))
        .build();
  }
}
