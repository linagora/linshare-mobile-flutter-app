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
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/shared_space_node_versions_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/media_type_extension.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/work_group_node_context_menu_action_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_node_versions/shared_space_node_versions_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_node_versions/shared_space_node_versions_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/destination_type.dart';

class SharedSpaceNodeVersionsWidget extends StatefulWidget {
  SharedSpaceNodeVersionsWidget({Key? key}) : super(key: key);

  @override
  _SharedSpaceNodeVersionsWidgetState createState() => _SharedSpaceNodeVersionsWidgetState();
}

class _SharedSpaceNodeVersionsWidgetState extends State<SharedSpaceNodeVersionsWidget> {
  final _model = getIt<SharedSpaceNodeVersionsViewModel>();
  final imagePath = getIt<AppImagePaths>();

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      var arguments = ModalRoute.of(context)?.settings.arguments as SharedSpaceNodeVersionsArguments;
        _model.initState(arguments);
    });

    super.initState();
  }

  @override
  void dispose() {
    _model.onDisposed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var arguments = ModalRoute.of(context)?.settings.arguments as SharedSpaceNodeVersionsArguments;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: Key('shared_space_node_versions_arrow_back_button'),
          icon: Image.asset(imagePath.icArrowBack),
          onPressed: () => _model.backToMyWorkGroupNodesList(),
        ),
        centerTitle: true,
        title: Text(arguments.workGroupNode.name,
            key: Key('shared_space_node_versions_title'),
            style: TextStyle(fontSize: 24, color: Colors.white)),
        backgroundColor: AppColor.primaryColor,
        actions: [
          Padding(
              padding: EdgeInsets.only(right: 16),
              child: SvgPicture.asset(imagePath.icInfo, width: 28, height: 28, color: Colors.white))
        ],
      ),
      body: Column(
        children: [
          _buildLoadingLayout(),
          Expanded(child: StoreConnector<AppState, SharedSpaceNodeVersionsState>(
            converter: (store) => store.state.sharedSpaceNodeVersionsState,
            builder: (_, state) => RefreshIndicator(
              onRefresh: () async => _model.getAllVersions(arguments.workGroupNode),
              child: _versionsListWidget(state.workgroupNodeVersions, arguments.workGroupNode)),
          ))
        ]
      )
    );
  }

  Widget _buildLoadingLayout() {
    return StoreConnector<AppState, dartz.Either<Failure, Success>>(
      converter: (store) => store.state.sharedSpaceNodeVersionsState.viewState,
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
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor)))))
          : SizedBox.shrink())
    );
  }

  ListView _versionsListWidget(List<WorkGroupDocument> versionsList, WorkGroupNode parentNode) {
    return ListView.builder(
        itemCount: versionsList.length,
        itemBuilder: (context, index) => ListTile(
              leading: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                SvgPicture.asset(versionsList[index].mediaType.getFileTypeImagePath(imagePath),
                    width: 20, height: 24, fit: BoxFit.fill)
              ]),
              title: Transform(
                  transform: Matrix4.translationValues(-16, 0.0, 0.0),
                  child: Text(
                      AppLocalizations.of(context)
                          .version(versionsList.reversed.toList().indexOf(versionsList[index]) + 1),
                      maxLines: 1,
                      style: TextStyle(fontSize: 14, color: AppColor.documentNameItemTextColor))),
              subtitle: Transform(
                  transform: Matrix4.translationValues(-16, 0.0, 0.0),
                  child: Text(versionsList[index].lastAuthor.name,
                      maxLines: 1,
                      style: TextStyle(fontSize: 14, color: AppColor.unselectedElementColor))),
              trailing: IconButton(
                  icon: SvgPicture.asset(imagePath.icContextMenu,
                      width: 24, height: 24, fit: BoxFit.fill, color: AppColor.primaryColor),
                  onPressed: () => _model.openContextMenu(
                      context,
                      versionsList[index],
                      _contextMenuActionTiles(context, versionsList[index], parentNode, index == 0),
                      footerAction: _removeAction(
                        versionsList[index],
                        versionsList.length == 1 ? true : false))),
              onTap: () => SharedSpaceOperationRole.previewVersionDocumentSharedSpaceRoles.contains(_model.sharedSpaceRole.name)
                ? _model.previewAction(context, versionsList[index])
                : {}
        ));
  }

  List<Widget> _contextMenuActionTiles(BuildContext context, WorkGroupDocument document, WorkGroupNode parentNode, bool isLatestVersion) {
    return [
      _exportFileAction(document),
      if (Platform.isAndroid) _downloadFileAction(document),
      if (SharedSpaceOperationRole.previewVersionDocumentSharedSpaceRoles.contains(_model.sharedSpaceRole.name))
        _previewAction(context, document),
      _copyToAction(context, document),
      if (!isLatestVersion) _restoreAction(context, document, parentNode)
    ];
  }

  Widget _restoreAction(BuildContext context, WorkGroupDocument document, WorkGroupNode parentNode) {
    return WorkGroupNodeContextMenuTileBuilder(
            Key('restore_context_menu_action'),
            SvgPicture.asset(imagePath.icHistory, width: 24, height: 24, fit: BoxFit.fill),
            AppLocalizations.of(context).restore,
            document)
        .onActionClick((data) => _model.restoreAction(document, parentNode))
        .build();
  }

  Widget _previewAction(BuildContext context, WorkGroupDocument document) {
    return WorkGroupNodeContextMenuTileBuilder(
        Key('preview_context_menu_action'),
        SvgPicture.asset(imagePath.icPreview, width: 24, height: 24, fit: BoxFit.fill),
        AppLocalizations.of(context).preview,
        document)
      .onActionClick((data) {
        _model.closeDialogMenuContext();
        _model.previewAction(context, document);
      })
      .build();
  }

  Widget _removeAction(WorkGroupDocument document, bool finalVersion) {
    return WorkGroupNodeContextMenuTileBuilder(
          Key('remove_context_menu_action'),
          SvgPicture.asset(imagePath.icDelete, width: 24, height: 24, fit: BoxFit.fill),
          AppLocalizations.of(context).delete,
          document)
      .onActionClick((data) => _model.removeNodeVersion(context, document, finalVersion))
      .build();
  }

  Widget _exportFileAction(WorkGroupDocument document) {
    return WorkGroupNodeContextMenuTileBuilder(
          Key('export_file_context_menu_action'),
          SvgPicture.asset(imagePath.icExportFile, width: 24, height: 24, fit: BoxFit.fill),
          AppLocalizations.of(context).export_file,
          document)
      .onActionClick((data) => _model.exportFile(context, document))
      .build();
  }

  Widget _downloadFileAction(WorkGroupDocument document) {
    return WorkGroupNodeContextMenuTileBuilder(
          Key('download_file_context_menu_action'),
          SvgPicture.asset(imagePath.icFileDownload, width: 24, height: 24, fit: BoxFit.fill),
          AppLocalizations.of(context).download_to_device,
          document)
      .onActionClick((data) => _model.downloadFile(document))
      .build();
  }

  Widget _copyToAction(BuildContext context, WorkGroupDocument document) {
    return WorkGroupNodeContextMenuTileBuilder(
          Key('copy_to_context_menu_action'),
          SvgPicture.asset(imagePath.icSharedSpace, width: 24, height: 24, fit: BoxFit.fill),
          AppLocalizations.of(context).copy_to,
          document)
      .trailing(SvgPicture.asset(imagePath.icArrowRight, width: 24, height: 24, fit: BoxFit.fill))
      .onActionClick((data) => _model.copyTo(
          context,
          document,
          [DestinationType.mySpace, DestinationType.workGroup]))
      .build();
  }
}
