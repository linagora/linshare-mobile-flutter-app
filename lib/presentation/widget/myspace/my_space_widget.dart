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
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/model/file/selectable_element.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/my_space_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/app_toast.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/datetime_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/media_type_extension.dart';
import 'package:linshare_flutter_app/presentation/util/helper/responsive_widget.dart';
import 'package:linshare_flutter_app/presentation/view/background_widgets/background_widget_builder.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/document_context_menu_action_builder.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/simple_context_menu_action_builder.dart';
import 'package:linshare_flutter_app/presentation/view/multiple_selection_bar/document_multiple_selection_action_builder.dart';
import 'package:linshare_flutter_app/presentation/view/multiple_selection_bar/multiple_selection_bar_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/myspace/my_space_viewmodel.dart';
import 'package:redux/redux.dart';

class MySpaceWidget extends StatefulWidget {
  @override
  _MySpaceWidgetState createState() => _MySpaceWidgetState();
}

class _MySpaceWidgetState extends State<MySpaceWidget> {
  final mySpaceViewModel = getIt<MySpaceViewModel>();
  final imagePath = getIt<AppImagePaths>();
  final appToast = getIt<AppToast>();

  @override
  void initState() {
    super.initState();
    mySpaceViewModel.getAllDocument();
  }

  @override
  void dispose() {
    mySpaceViewModel.onDisposed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector(
        builder: (BuildContext context, MySpaceViewModel viewModel) => Scaffold(
              body: Column(
                children: [
                  StoreConnector<AppState, MySpaceState>(
                    converter: (Store<AppState> store) => store.state.mySpaceState,
                    builder: (context, state) {
                      return state.selectMode == SelectMode.ACTIVE ? ListTile(
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
                        onTap: () => mySpaceViewModel.toggleSelectAllDocuments(),
                        trailing: TextButton(
                          onPressed: () => mySpaceViewModel.cancelSelection(),
                          child: Text(AppLocalizations.of(context).cancel,
                          maxLines: 1,
                          style: TextStyle(fontSize: 14, color: AppColor.primaryColor),
                        )),
                      ) : SizedBox.shrink();
                    },
                  ),
                  StoreConnector<AppState, dartz.Either<Failure, Success>>(
                    converter: (store) => store.state.mySpaceState.viewState,
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
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              AppColor.primaryColor),
                                    ),
                                  ),
                                )
                              : SizedBox.shrink());
                    },
                  ),
                  Expanded(
                    child: _buildMySpaceList(context),
                  ),
                  StoreConnector<AppState, MySpaceState>(
                    converter: (store) => store.state.mySpaceState,
                    builder: (context, state) {
                      return state.selectMode == SelectMode.ACTIVE && state.getAllSelectedDocuments().isNotEmpty ?
                        MultipleSelectionBarBuilder()
                          .key(Key('multiple_document_selection_bar'))
                          .text(
                            AppLocalizations
                              .of(context)
                              .items(state.getAllSelectedDocuments().length))
                          .actions(multipleSelectionActions(state.getAllSelectedDocuments()))
                          .build()
                        : SizedBox.shrink();
                    })
                ],
              ),
              floatingActionButton: StoreConnector<AppState, SelectMode>(
                converter: (store) => store.state.mySpaceState.selectMode,
                builder: (context, selectMode) {
                  return selectMode == SelectMode.INACTIVE ? FloatingActionButton(
                    key: Key('my_space_upload_button'),
                    onPressed: () => mySpaceViewModel
                        .openUploadFileMenu(context, uploadFileMenuActionTiles(context)),
                    backgroundColor: AppColor.primaryColor,
                    child: Image(image: AssetImage(imagePath.icAdd)),
                  ) : SizedBox.shrink();
                }),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
            ),
        converter: (Store<AppState> store) => mySpaceViewModel);
  }

  Widget _buildMySpaceList(BuildContext context) {
    return StoreConnector<AppState, MySpaceState>(
        converter: (store) => store.state.mySpaceState,
        builder: (context, mySpaceState) {
          return mySpaceState.viewState.fold(
            (failure) =>
              RefreshIndicator(
                onRefresh: () async => mySpaceViewModel.getAllDocument(),
                child: failure is MySpaceFailure ?
                  BackgroundWidgetBuilder()
                    .key(Key('my_space_error_background'))
                    .image(SvgPicture.asset(
                      imagePath.icUnexpectedError,
                      width: 120,
                      height: 120,
                      fit: BoxFit.fill))
                    .text(AppLocalizations.of(context).common_error_occured_message)
                    .build() : _buildMySpaceListView(context, mySpaceState.documentList)),
            (success) => success is LoadingState ?
              _buildMySpaceListView(context, mySpaceState.documentList) :
              RefreshIndicator(
                onRefresh: () async => mySpaceViewModel.getAllDocument(),
                child: _buildMySpaceListView(context, mySpaceState.documentList)));
        });
  }

  Widget _buildMySpaceListView(BuildContext context, List<SelectableElement<Document>> documentList) {
    if (documentList.isEmpty) {
      return _buildUploadFileHere(context);
    } else {
      return ListView.builder(
        padding: ResponsiveWidget.isLargeScreen(context) ?
          EdgeInsets.symmetric(horizontal: 132.0)
          : EdgeInsets.zero,
        key: Key('my_space_documents_list'),
        itemCount: documentList.length,
        itemBuilder: (context, index) {
          return _buildMySpaceListItem(context, documentList[index]);
        });
    }
  }

  Widget _buildMySpaceListItem(BuildContext context, SelectableElement<Document> document) {
    return ListTile(
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
          document.element.mediaType.getFileTypeImagePath(imagePath),
          width: 20,
          height: 24,
          fit: BoxFit.fill)
        ]
      ),
      title: ResponsiveWidget(
        mediumScreen: Transform(
          transform: Matrix4.translationValues(-16, 0.0, 0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildDocumentName(document.element.name),
                  _buildSharedIcon(document.element.isShared())
                ]
              ),
              Align(
                alignment: Alignment.centerRight,
                child: _buildModifiedDocumentText(AppLocalizations.of(context).item_last_modified(
                  document.element.modificationDate.getMMMddyyyyFormatString())))
            ]
          ),
        ),
        smallScreen: Transform(
          transform: Matrix4.translationValues(-16, 0.0, 0.0),
          child: _buildDocumentName(document.element.name),
        ),
      ),
      subtitle: ResponsiveWidget.isSmallScreen(context) ? Transform(
        transform: Matrix4.translationValues(-16, 0.0, 0.0),
        child: Row(
          children: [
            _buildModifiedDocumentText(AppLocalizations.of(context).item_last_modified(
                  document.element.modificationDate.getMMMddyyyyFormatString())),
            _buildSharedIcon(document.element.isShared())
          ],
        ),
      ) : null,
      trailing: StoreConnector<AppState, SelectMode>(
        converter: (store) => store.state.mySpaceState.selectMode,
        builder: (context, selectMode) {
          return selectMode == SelectMode.ACTIVE ?
            Checkbox(
              value: document.selectMode == SelectMode.ACTIVE,
              onChanged: (bool value) => mySpaceViewModel.selectItem(document),
              activeColor: AppColor.primaryColor,
            ) :
            IconButton(
              icon: SvgPicture.asset(
                imagePath.icContextMenu,
                width: 24,
                height: 24,
                fit: BoxFit.fill,
              ),
              onPressed: () => mySpaceViewModel
                .openContextMenu(context, document.element, contextMenuActionTiles(context, document.element))
            );
        }),
        onLongPress: () => mySpaceViewModel.selectItem(document)
    );
  }

  Widget _buildDocumentName(String documentName) {
    return Text(
      documentName,
      maxLines: 1,
      style: TextStyle(fontSize: 14, color: AppColor.documentNameItemTextColor),
    );
  }

  Widget _buildModifiedDocumentText(String modificationDate) {
    return Text(
      modificationDate,
      style: TextStyle(fontSize: 13, color: AppColor.documentModifiedDateItemTextColor),
    );
  }

  Widget _buildSharedIcon(bool isShared) {
    return isShared
        ? Padding(
            padding: EdgeInsets.only(left: 16),
            child: SvgPicture.asset(
              imagePath.icSharedPeople,
              width: 16,
              height: 16,
              fit: BoxFit.fill,
            ),
          )
        : SizedBox.shrink();
  }

  Widget _buildUploadFileHere(BuildContext context) {
    return BackgroundWidgetBuilder()
      .key(Key('my_space_upload_file_here'))
      .image(SvgPicture.asset(
        imagePath.icUploadFile,
        width: 120,
        height: 120,
        fit: BoxFit.fill))
      .text(AppLocalizations.of(context).my_space_text_upload_your_files_here).build();
  }

  List<Widget> contextMenuActionTiles(BuildContext context, Document document) {
    return [
      if (Platform.isIOS) exportFileAction(context, document),
      if (Platform.isAndroid) downloadAction(document),
      shareAction(document),
    ];
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
        .onActionClick((_) => mySpaceViewModel.openFilePickerByType(FileType.media))
        .build();
  }

  Widget browseFileAction() {
    return SimpleContextMenuActionBuilder(
        Key('browse_file_context_menu_action'),
        SvgPicture.asset(imagePath.icMore,
            width: 24, height: 24, fit: BoxFit.fill),
        AppLocalizations.of(context).browse)
        .onActionClick((_) => mySpaceViewModel.openFilePickerByType(FileType.any))
        .build();
  }

  Widget downloadAction(Document document) {
    return DocumentContextMenuTileBuilder(
            Key('download_context_menu_action'),
            SvgPicture.asset(imagePath.icFileDownload,
                width: 24, height: 24, fit: BoxFit.fill),
            AppLocalizations.of(context).download_to_device,
            document)
        .onActionClick((data) => mySpaceViewModel.downloadFileClick(data.documentId))
        .build();
  }

  Widget exportFileAction(BuildContext context, Document document) {
    return DocumentContextMenuTileBuilder(
            Key('export_context_menu_action'),
            SvgPicture.asset(imagePath.icExportFile,
                width: 24, height: 24, fit: BoxFit.fill),
            AppLocalizations.of(context).export_file,
            document)
        .onActionClick((data) {
      mySpaceViewModel.exportFile(context, data);
    }).build();
  }

  Widget shareAction(Document document) {
    return DocumentContextMenuTileBuilder(
            Key('share_context_menu_action'),
            SvgPicture.asset(imagePath.icContextItemShare,
                width: 24, height: 24, fit: BoxFit.fill),
            AppLocalizations.of(context).share,
            document)
        .onActionClick(
            (data) => mySpaceViewModel.shareDocument(document))
        .build();
  }

  List<Widget> multipleSelectionActions(List<Document> documents) {
    return [shareMultipleSelection(documents)];
  }

  Widget shareMultipleSelection(List<Document> documents) {
    return DocumentMultipleSelectionActionBuilder(
      Key('multiple_selection_share_action'),
      SvgPicture.asset(
        imagePath.icContextItemShare,
        width: 24,
        height: 24,
        fit: BoxFit.fill,
      ),
      documents)
      .onActionClick((documents) => null)
      .build();
  }
}
