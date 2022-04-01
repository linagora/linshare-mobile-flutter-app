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
import 'package:linshare_flutter_app/presentation/model/upload_request_group_tab.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/ui_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/upload_request_inside_active_closed_state.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/media_type_extension.dart';
import 'package:linshare_flutter_app/presentation/util/helper/responsive_utils.dart';
import 'package:linshare_flutter_app/presentation/util/helper/responsive_widget.dart';
import 'package:linshare_flutter_app/presentation/view/background_widgets/background_widget_builder.dart';
import 'package:linshare_flutter_app/presentation/view/common/common_view.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/upload_request_context_menu_action_builder.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/upload_request_entry_context_menu_action_builder.dart';
import 'package:linshare_flutter_app/presentation/view/multiple_selection_bar/upload_request_multiple_selection_action_builder.dart';
import 'package:linshare_flutter_app/presentation/view/multiple_selection_bar/uploadrequest_entry_multiple_selection_action_builder.dart';
import 'package:linshare_flutter_app/presentation/view/order_by/order_by_button.dart';
import 'package:linshare_flutter_app/presentation/view/search/search_bottom_bar_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/active_close/active_closed_upload_request_inside_view_model.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/upload_request_document_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/upload_request_document_type.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/upload_request_inside_navigator_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/upload_request_inside_widget.dart';
import 'package:redux/redux.dart';

class ActiveClosedUploadRequestInsideWidget extends UploadRequestInsideWidget {

  ActiveClosedUploadRequestInsideWidget(
      OnBackUploadRequestClickedCallback onBackUploadRequestClickedCallback,
      OnUploadRequestClickedCallback onUploadRequestClickedCallback
  ) : super(onBackUploadRequestClickedCallback, onUploadRequestClickedCallback);

  @override
  UploadRequestInsideWidgetState createState() => _ActiveCloseUploadRequestInsideWidgetState();
}

class _ActiveCloseUploadRequestInsideWidgetState extends UploadRequestInsideWidgetState {

  final _responsiveUtils = getIt<ResponsiveUtils>();
  final _widgetCommon = getIt<CommonView>();
  final _viewModel = getIt<ActiveCloseUploadRequestInsideViewModel>();

  UploadRequestArguments? _arguments;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _arguments = ModalRoute.of(context)?.settings.arguments as UploadRequestArguments;
      if (_arguments != null) {
        _viewModel.initState(_arguments!);
      }
    });
  }

  @override
  void dispose() {
    _viewModel.onDisposed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, bool>(
      converter: (store) => store.state.uiState.isInSearchState(),
      builder: (context, isInSearchState) => isInSearchState
        ? _buildSearchViewWidget(context)
        : _buildDefaultViewWidget());
  }

  Widget _buildSearchViewWidget(BuildContext context) {
    return StoreConnector<AppState, ActiveClosedUploadRequestInsideState>(
        converter: (store) => store.state.activeClosedUploadRequestInsideState,
        builder: (_, state) {
          if (_viewModel.isEmptySearchQuery()) {
            return SizedBox.shrink();
          }

          if ((state.isIndividualRecipients() && state.uploadRequests.isEmpty) ||
              (!state.isIndividualRecipients() && state.uploadRequestEntries.isEmpty)) {
            return _widgetCommon.buildNoResultFound(context);
          }

          return Column(children: [
            _buildMultipleSelectionTopBar(),
            _widgetCommon.buildResultCountRow(
              context,
              state.isIndividualRecipients() ? state.uploadRequests.length : state.uploadRequestEntries.length),
            Expanded(
              child: state.isIndividualRecipients()
                ? _buildUploadRequestListView(state.uploadRequests, state.selectMode)
                : _buildUploadRequestEntriesListView(state.uploadRequestEntries, state.selectMode)
            ),
            _buildMultipleSelectionBottomBar(state)
          ]);
        });
  }

  Widget _buildMultipleSelectionTopBar() {
    return StoreConnector<AppState, ActiveClosedUploadRequestInsideState>(
        converter: (store) => store.state.activeClosedUploadRequestInsideState,
        builder: (context, state) => state.selectMode == SelectMode.ACTIVE
            ? ListTile(
                leading: SvgPicture.asset(imagePath.icSelectAll,
                  width: 28,
                  height: 28,
                  fit: BoxFit.fill,
                  color: _isSelectAll(state) ? AppColor.unselectedElementColor : AppColor.primaryColor),
                title: Transform(
                  transform: Matrix4.translationValues(-16, 0.0, 0.0),
                  child: Text(
                      _isSelectAll(state) ? AppLocalizations.of(context).unselect_all : AppLocalizations.of(context).select_all,
                      maxLines: 1,
                      style: TextStyle(fontSize: 14, color: AppColor.documentNameItemTextColor))),
                tileColor: AppColor.topBarBackgroundColor,
                onTap: () => _toggleSelectAll(state),
                trailing: TextButton(
                    onPressed: () => _cancelSelection(state),
                    child: Text(
                        AppLocalizations.of(context).cancel,
                        maxLines: 1,
                        style: TextStyle(fontSize: 14, color: AppColor.primaryColor))))
            : SizedBox.shrink());
  }

  Widget _buildDefaultViewWidget() {
    return Scaffold(
      body: Column(
        children: [
          buildTopBar(titleTopBar: _buildTitleTopBar()),
          _buildMultipleSelectionTopBar(),
          _buildMenuSorter(),
          _buildLoadingLayout(),
          Expanded(child: _buildUploadRequestList()),
          StoreConnector<AppState, ActiveClosedUploadRequestInsideState>(
              converter: (store) => store.state.activeClosedUploadRequestInsideState,
              builder: (context, state) => _buildMultipleSelectionBottomBar(state))
        ],
      ),
      bottomNavigationBar: StoreConnector<AppState, AppState>(
          converter: (store) => store.state,
          builder: (context, appState) {
            if (_validateSearchButton(appState)) {
              return SearchBottomBarBuilder().key(Key('search_bottom_bar')).onSearchActionClick(() {
                _viewModel.openSearchState(context);
              }).build();
            }
            return SizedBox.shrink();
          }),
      floatingActionButton: StoreConnector<AppState, AppState>(
          converter: (store) => store.state,
          builder: (context, appState) {
            if (_validateAddRecipientButton(appState)) {
              return FloatingActionButton(
                key: Key('upload_request_add_recipient_button'),
                onPressed: () {
                  final group = appState.activeClosedUploadRequestInsideState.uploadRequestGroup;
                  if (group != null) {
                    _viewModel.goToAddRecipients(group, UploadRequestGroupTab.ACTIVE_CLOSED);
                  }
                },
                backgroundColor: AppColor.primaryColor,
                child: SvgPicture.asset(
                  imagePath.icUploadRequestAddRecipient,
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

  bool _validateAddRecipientButton(AppState appState) {
    final isInMultipleSelectMode = appState.activeClosedUploadRequestInsideState.selectMode == SelectMode.ACTIVE;
    final uploadRequestGroup = appState.activeClosedUploadRequestInsideState.uploadRequestGroup;

    if (!appState.uiState.isInSearchState() && !isInMultipleSelectMode) {
      if (appState.activeClosedUploadRequestInsideState.isIndividualRecipients()) {
        return uploadRequestGroup?.status == UploadRequestStatus.ENABLED;
      }
    }
    return false;
  }

  bool _validateSearchButton(AppState appState) {
    final isInMultipleSelectMode = appState.activeClosedUploadRequestInsideState.selectMode == SelectMode.ACTIVE;

    if (!appState.uiState.isInSearchState() && !isInMultipleSelectMode) {
      if (appState.activeClosedUploadRequestInsideState.isIndividualRecipients()) {
        return appState.activeClosedUploadRequestInsideState.uploadRequests.isNotEmpty;
      } else {
        return appState.activeClosedUploadRequestInsideState.uploadRequestEntries.isNotEmpty;
      }
    }
    return false;
  }

  Widget _buildMenuSorter() {
    return StoreConnector<AppState, AppState>(
      converter: (Store<AppState> store) => store.state,
      builder: (context, appState) => !appState.uiState.isInSearchState()
        ? _buildSorterWidget(context, appState)
        : SizedBox.shrink()
    );
  }

  Widget _buildSorterWidget(BuildContext context, AppState appState) {
    if (appState.activeClosedUploadRequestInsideState.uploadRequestDocumentType == UploadRequestDocumentType.files) {
      return OrderByButtonBuilder(context, appState.activeClosedUploadRequestInsideState.fileSorter)
      .onOpenOrderMenuAction((currentSorter) => _viewModel.openPopupMenuSorterFile(context, currentSorter))
      .build();
    }
    return OrderByButtonBuilder(context, appState.activeClosedUploadRequestInsideState.recipientSorter)
      .onOpenOrderMenuAction((currentSorter) => _viewModel.openPopupMenuSorterRecipients(context, currentSorter))
      .build();
  }

  Widget _buildTitleTopBar() {
    return StoreConnector<AppState, ActiveClosedUploadRequestInsideState>(
        converter: (store) => store.state.activeClosedUploadRequestInsideState,
        builder: (context, urState) => (urState.isIndividualRecipients() || urState.isCollective())
            ? GestureDetector(
                onTap: widget.onBackUploadRequestClickedCallback,
                child: Container(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      AppLocalizations.of(context).upload_requests_root_back_title,
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColor.uploadRequestSurfingBackTitleColor,
                        fontWeight: FontWeight.w400))),
                ))
            : Expanded(child: Padding(
                padding: const EdgeInsets.only(left: 5.0, right: 45.0),
                child: Text(
                  urState.selectedUploadRequest?.recipients.first.mail ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColor.workgroupNodesSurfingFolderNameColor)
                ))
        )
    );
  }

  Widget _buildLayoutCorrespondingWithState(ActiveClosedUploadRequestInsideState state) {
    switch (state.uploadRequestDocumentType) {
      case UploadRequestDocumentType.recipients:
        return _buildUploadRequestListView(state.uploadRequests, state.selectMode);
      case UploadRequestDocumentType.files:
        return _buildUploadRequestEntriesListView(state.uploadRequestEntries, state.selectMode);
    }
  }

  Widget _buildEmptyListIndicator() {
    return StoreConnector<AppState, dartz.Either<Failure, Success>>(
      converter: (store) => store.state.activeClosedUploadRequestInsideState.viewState,
      builder: (context, viewState) => viewState.fold(
        (failure) => BackgroundWidgetBuilder(context)
          .image(SvgPicture.asset(imagePath.icUploadFile, width: 120, height: 120, fit: BoxFit.fill))
          .text(AppLocalizations.of(context).upload_requests_no_files_uploaded)
          .build(),
        (success) => (success is LoadingState)
          ? SizedBox.shrink()
          : BackgroundWidgetBuilder(context)
              .image(SvgPicture.asset(imagePath.icUploadFile, width: 120, height: 120, fit: BoxFit.fill))
              .text(AppLocalizations.of(context).upload_requests_no_files_uploaded)
              .build()
      )
    );
  }

  Widget _buildUploadRequestEntriesListView(
      List<SelectableElement<UploadRequestEntry>> uploadRequestEntries,
      SelectMode selectMode
  ) {
    if (uploadRequestEntries.isEmpty) {
      return _buildEmptyListIndicator();
    }

    return ListView.builder(
      itemCount: uploadRequestEntries.length,
      itemBuilder: (BuildContext context, int index) {
        return _buildEntryListItem(context, uploadRequestEntries[index], selectMode);
      },
    );
  }

  Widget _buildEntryListItem(
      BuildContext context,
      SelectableElement<UploadRequestEntry> entry,
      SelectMode selectMode
  ) {
    return ListTile(
      onTap: () {
        if (selectMode == SelectMode.ACTIVE) {
          _viewModel.selectEntry(entry);
        }
      },
      onLongPress: () => _viewModel.selectEntry(entry),
      leading: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SvgPicture.asset(entry.element.mediaType.getFileTypeImagePath(imagePath), width: 20, height: 24, fit: BoxFit.fill)
      ]),
      title: ResponsiveWidget(
        mediumScreen: Transform(
          transform: Matrix4.translationValues(-16, 0.0, 0.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            buildItemTitle(entry.element.name),
            Align(alignment: Alignment.centerRight, child: buildRecipientText(entry.element.recipient?.mail ?? ''))
          ]),
        ),
        smallScreen:
        Transform(transform: Matrix4.translationValues(-16, 0.0, 0.0), child: buildItemTitle(entry.element.name)),
        responsiveUtil: _responsiveUtils,
      ),
      subtitle: _responsiveUtils.isSmallScreen(context)
          ? Transform(
              transform: Matrix4.translationValues(-16, 0.0, 0.0),
              child: Row(children: [buildRecipientText(entry.element.recipient?.mail ?? '')]))
          : null,
      trailing: selectMode == SelectMode.ACTIVE
          ? Checkbox(
              value: entry.selectMode == SelectMode.ACTIVE,
              onChanged: (bool? value) => _viewModel.selectEntry(entry),
              activeColor: AppColor.primaryColor)
          : IconButton(
              icon: SvgPicture.asset(imagePath.icContextMenu, width: 24, height: 24, fit: BoxFit.fill, color: AppColor.primaryColor),
              onPressed: () => openFileContextMenu(context, entry.element)
      ),
    );
  }

  Widget _buildUploadRequestListView(List<SelectableElement<UploadRequest>> uploadRequests, SelectMode selectMode) {
    if (uploadRequests.isEmpty) {
      return _buildEmptyListIndicator();
    }
    return ListView.builder(
      itemCount: uploadRequests.length,
      itemBuilder: (BuildContext context, int index) {
        return _buildRecipientListItem(context, uploadRequests[index], selectMode);
      },
    );
  }

  Widget _buildRecipientListItem(BuildContext context, SelectableElement<UploadRequest> uploadRequest, SelectMode selectMode) {
    return ListTile(
      onTap: () {
        if (selectMode == SelectMode.ACTIVE) {
          _viewModel.selectRecipient(uploadRequest);
        } else {
          widget.onUploadRequestClickedCallback(uploadRequest);
        }
      },
      onLongPress: () => _viewModel.selectRecipient(uploadRequest),
      leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [SvgPicture.asset(imagePath.icUploadRequestIndividual, width: 20, height: 24, fit: BoxFit.fill)]),
      title: ResponsiveWidget(
        mediumScreen: Transform(
          transform: Matrix4.translationValues(-16, 0.0, 0.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            buildItemTitle(uploadRequest.element.recipients.first.mail),
            Align(alignment: Alignment.centerRight, child: buildRecipientStatus(uploadRequest.element.status))
          ]),
        ),
        smallScreen: Transform(
            transform: Matrix4.translationValues(-16, 0.0, 0.0),
            child: buildItemTitle(uploadRequest.element.recipients.first.mail)),
        responsiveUtil: _responsiveUtils,
      ),
      subtitle: _responsiveUtils.isSmallScreen(context)
          ? Transform(
              transform: Matrix4.translationValues(-16, 0.0, 0.0),
              child: Row(
                children: [
                  buildRecipientStatus(uploadRequest.element.status),
                ],
              ),
            )
          : null,
      trailing: selectMode == SelectMode.ACTIVE
          ? Checkbox(
              value: uploadRequest.selectMode == SelectMode.ACTIVE,
              onChanged: (bool? value) => _viewModel.selectRecipient(uploadRequest),
              activeColor: AppColor.primaryColor)
          : IconButton(
              icon: SvgPicture.asset(
                imagePath.icContextMenu,
                width: 24,
                height: 24,
                fit: BoxFit.fill,
                color: AppColor.primaryColor,
              ),
              onPressed: () => openRecipientContextMenu(context, uploadRequest.element)),
    );
  }

  Widget _buildMultipleSelectionBottomBar(ActiveClosedUploadRequestInsideState state) {
    if (state.selectMode == SelectMode.INACTIVE) {
      return SizedBox.shrink();
    }
    switch (state.uploadRequestDocumentType) {
      case UploadRequestDocumentType.files:
        return buildFileMultipleSelectionBottomBar(context, state.getAllSelectedEntries());
      case UploadRequestDocumentType.recipients:
        return buildRecipientMultipleSelectionBottomBar(context, state.getAllSelectedRecipient());
    }
  }

  Widget _buildUploadRequestList() {
    return StoreConnector<AppState, ActiveClosedUploadRequestInsideState>(
      converter: (store) => store.state.activeClosedUploadRequestInsideState,
      builder: (context, state) =>
        state.viewState.fold(
          (failure) => RefreshIndicator(
            onRefresh: () async => _viewModel.requestToGetUploadRequestAndEntries(),
            child: _buildEmptyListIndicator()),
          (success) => RefreshIndicator(
            onRefresh: () async => _viewModel.requestToGetUploadRequestAndEntries(),
            child: _buildLayoutCorrespondingWithState(state)))
    );
  }

  bool _isSelectAll(ActiveClosedUploadRequestInsideState state) {
    switch (state.uploadRequestDocumentType) {
      case UploadRequestDocumentType.recipients:
        return state.isAllRecipientSelected();
      case UploadRequestDocumentType.files:
        return state.isAllEntriesSelected();
    }
  }

  void _toggleSelectAll(ActiveClosedUploadRequestInsideState state) {
    switch (state.uploadRequestDocumentType) {
      case UploadRequestDocumentType.recipients:
        _viewModel.toggleSelectAllRecipients();
        break;
      case UploadRequestDocumentType.files:
        _viewModel.toggleSelectAllEntries();
        break;
    }
  }

  void _cancelSelection(ActiveClosedUploadRequestInsideState state) {
    switch (state.uploadRequestDocumentType) {
      case UploadRequestDocumentType.recipients:
        _viewModel.cancelAllSelectionRecipients(UploadRequestGroupTab.ACTIVE_CLOSED);
        break;
      case UploadRequestDocumentType.files:
        _viewModel.cancelAllSelectionEntries(UploadRequestGroupTab.ACTIVE_CLOSED);
        break;
    }
  }

  Widget _buildLoadingLayout() {
    return StoreConnector<AppState, dartz.Either<Failure, Success>>(
        converter: (store) => store.state.activeClosedUploadRequestInsideState.viewState,
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
                        )))
                : SizedBox.shrink())
    );
  }

  Widget _downloadFileMultipleSelection(List<UploadRequestEntry> uploadRequestEntries) {
    return UploadRequestEntryMultipleSelectionActionBuilder(
        Key('multiple_selection_download_action'),
        SvgPicture.asset(
          Platform.isAndroid ? imagePath.icFileDownload : imagePath.icExportFile,
          width: 24,
          height: 24,
          fit: BoxFit.fill),
        uploadRequestEntries)
      .onActionClick((entries) => Platform.isAndroid
        ? _viewModel.downloadEntries(
            entries,
            currentTab: UploadRequestGroupTab.ACTIVE_CLOSED,
            itemSelectionType: ItemSelectionType.multiple)
        : _viewModel.exportFiles(
            context,
            entries,
            currentTab: UploadRequestGroupTab.ACTIVE_CLOSED,
            itemSelectionType: ItemSelectionType.multiple))
      .build();
  }

  Widget _removeFileMultipleSelection(List<UploadRequestEntry> uploadRequestEntries) {
    return UploadRequestEntryMultipleSelectionActionBuilder(
        Key('multiple_selection_remove_action'),
        SvgPicture.asset(imagePath.icDelete, width: 24, height: 24, fit: BoxFit.fill),
        uploadRequestEntries)
      .onActionClick((entries) => _viewModel.removeFiles(
        context,
        entries,
        itemSelectionType: ItemSelectionType.multiple,
        currentTab: UploadRequestGroupTab.ACTIVE_CLOSED,
        onActionSuccess: () => _viewModel.requestToGetUploadRequestAndEntries()))
      .build();
  }

  Widget _moreActionMultipleSelection(BuildContext context, List<UploadRequestEntry> entries) {
    return UploadRequestEntryMultipleSelectionActionBuilder(
        Key('multiple_selection_more_action'),
        SvgPicture.asset(
          imagePath.icMoreVertical,
          width: 24,
          height: 24,
          fit: BoxFit.fill,
          color: AppColor.primaryColor,
        ),
        entries)
      .onActionClick((entries) => _viewModel.openMoreActionEntryBottomMenu(
        context,
        entries,
        _moreActionList(context, entries),
        SizedBox.shrink()))
      .build();
  }

  List<Widget> _moreActionList(BuildContext context, List<UploadRequestEntry> entries) {
    return [
      _exportFileAction(entries, itemSelectionType: ItemSelectionType.multiple),
      _removeFileAction(entries, itemSelectionType: ItemSelectionType.multiple),
      _shareAction(entries, itemSelectionType: ItemSelectionType.multiple),
      _copyToMySpaceAction(entries, itemSelectionType: ItemSelectionType.multiple),
      if (Platform.isAndroid) _downloadFilesAction(entries, itemSelectionType: ItemSelectionType.multiple),
    ];
  }

  Widget _exportFileAction(
    List<UploadRequestEntry> entries,
    {ItemSelectionType itemSelectionType = ItemSelectionType.single}
  ) {
    return UploadRequestEntryContextMenuTileBuilder(
          Key('export_file_context_menu_action'),
          SvgPicture.asset(imagePath.icExportFile, width: 24, height: 24, fit: BoxFit.fill),
          AppLocalizations.of(context).export_file,
          entries.first)
      .onActionClick((data) => _viewModel.exportFiles(
          context,
          entries,
          currentTab: UploadRequestGroupTab.ACTIVE_CLOSED,
          itemSelectionType: itemSelectionType))
      .build();
  }

  Widget _downloadFilesAction(List<UploadRequestEntry> entries, {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    return UploadRequestEntryContextMenuTileBuilder(
          Key('download_file_context_menu_action'),
          SvgPicture.asset(imagePath.icFileDownload, width: 24, height: 24, fit: BoxFit.fill),
          AppLocalizations.of(context).download_to_device,
          entries.first)
      .onActionClick((data) => _viewModel.downloadEntries(
          entries,
          currentTab: UploadRequestGroupTab.ACTIVE_CLOSED,
          itemSelectionType: itemSelectionType))
      .build();
  }

  Widget _copyToMySpaceAction(List<UploadRequestEntry> entries,
      {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    return UploadRequestEntryContextMenuTileBuilder(
          Key('copy_to_my_space_context_menu_action'),
          SvgPicture.asset(imagePath.icCopy, width: 24, height: 24, fit: BoxFit.fill),
          AppLocalizations.of(context).copy_to_my_space,
          entries.first)
      .onActionClick((data) => _viewModel.copyToMySpace(
          entries,
          currentTab: UploadRequestGroupTab.ACTIVE_CLOSED,
          itemSelectionType: itemSelectionType))
      .build();
  }

  Widget _removeFileAction(List<UploadRequestEntry> entries,
      {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    return UploadRequestEntryContextMenuTileBuilder(
          Key('remove_upload_request_entry_context_menu_action'),
          SvgPicture.asset(imagePath.icDelete, width: 24, height: 24, fit: BoxFit.fill),
          AppLocalizations.of(context).delete,
          entries.first)
      .onActionClick((data) => _viewModel.removeFiles(
          context,
          entries,
          itemSelectionType: itemSelectionType,
          currentTab: UploadRequestGroupTab.ACTIVE_CLOSED,
          onActionSuccess: () => _viewModel.requestToGetUploadRequestAndEntries()))
      .build();
  }

  @override
  List<Widget> fileContextMenuActionTiles(BuildContext context, UploadRequestEntry entry) {
    return [
      viewDetailsFileAction(context,  entry, (entry) => _viewModel.goToUploadRequestFileDetails(entry)),
      _exportFileAction([entry]),
      _removeFileAction([entry]),
      _shareAction([entry]),
      _copyToMySpaceAction([entry]),
      if (Platform.isAndroid) _downloadFilesAction([entry])
    ];
  }

  @override
  Widget? fileFooterActionTile() {
    return null;
  }

  @override
  List<Widget> fileMultipleSelectionActions(BuildContext context, List<UploadRequestEntry> allSelectedEntries) {
    return [
      _downloadFileMultipleSelection(allSelectedEntries),
      _removeFileMultipleSelection(allSelectedEntries),
      _moreActionMultipleSelection(context, allSelectedEntries)
    ];
  }

  @override
  void openRecipientContextMenu(BuildContext context, UploadRequest uploadRequest) {
    super.openRecipientContextMenu(context, uploadRequest);
  }

  @override
  void openRecipientMoreActionBottomMenu(BuildContext context, List<UploadRequest> allSelected) {
    super.openRecipientMoreActionBottomMenu(context, allSelected);
  }

  @override
  Widget buildRecipientMultipleSelectionBottomBar(BuildContext context, List<UploadRequest> allSelected) {
    return super.buildRecipientMultipleSelectionBottomBar(context, allSelected);
  }

  @override
  List<Widget> recipientContextMenuActionTiles(BuildContext context, UploadRequest uploadRequest) {
    return [
      viewDetailsUploadRequestRecipientAction(context, uploadRequest, (uploadRequest) => _viewModel.goToUploadRequestRecipientDetails(uploadRequest)),
      if (uploadRequest.status == UploadRequestStatus.ENABLED)
        editUploadRequestRecipientAction(
          context,
          uploadRequest,
          () => _viewModel.goToEditUploadRequestRecipient(uploadRequest, UploadRequestGroupTab.ACTIVE_CLOSED))
    ];
  }

  @override
  Widget? recipientFooterActionTile(UploadRequest uploadRequest) {
    return Column(children: [
      if (uploadRequest.status == UploadRequestStatus.ENABLED) _closeUploadRequestAction([uploadRequest]),
      if (uploadRequest.status == UploadRequestStatus.CLOSED) _archiveUploadRequestAction([uploadRequest])
    ]);
  }

  @override
  List<Widget> recipientMultipleSelectionActions(BuildContext context, List<UploadRequest> allSelected) {
    final isAllSelectedClosed = allSelected.where((element) => element.status != UploadRequestStatus.CLOSED).isEmpty;
    final isAllSelectedActive = allSelected.where((element) => element.status != UploadRequestStatus.ENABLED).isEmpty;

    return [
      if (isAllSelectedClosed)_archiveUploadRequestMultipleSelectionAction(allSelected),
      if (isAllSelectedActive)moreActionMultipleSelection(allSelected, () => openRecipientMoreActionBottomMenu(context, allSelected)),
    ];
  }

  @override
  Widget? recipientFooterMultipleSelectionMoreActionBottomMenuTile(List<UploadRequest> allSelected) {
    final isAllSelectedActive = allSelected.where((element) => element.status != UploadRequestStatus.ENABLED).isEmpty;

    return Column(children: [
      if (isAllSelectedActive) _closeUploadRequestAction(allSelected, itemSelectionType: ItemSelectionType.multiple),
    ]);
  }

  @override
  List<Widget> recipientMultipleSelectionMoreActionBottomMenuTiles(BuildContext context, List<UploadRequest> allSelected) {
    return [];
  }

  Widget _closeUploadRequestAction(List<UploadRequest> uploadRequests,
      {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    return UploadRequestContextMenuActionBuilder(
          Key('close_upload_request_recipient_context_menu_action'),
          Icon(Icons.cancel, size: 24.0, color: AppColor.unselectedElementColor),
          AppLocalizations.of(context).close, uploadRequests.first)
      .onActionClick((_) => _viewModel.updateUploadRequestStatus(
          context,
          uploadRequests: uploadRequests,
          status: UploadRequestStatus.CLOSED,
          title: AppLocalizations.of(context).confirm_close_multiple_upload_request(uploadRequests.length, uploadRequests.first.recipients.first.mail),
          titleButtonConfirm: AppLocalizations.of(context).upload_request_proceed_button,
          currentTab: UploadRequestGroupTab.ACTIVE_CLOSED,
          itemSelectionType: itemSelectionType,
          onUpdateSuccess: () => _viewModel.requestToGetUploadRequestAndEntries()))
      .build();
  }

  Widget _archiveUploadRequestAction(List<UploadRequest> uploadRequests,
      {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    return UploadRequestContextMenuActionBuilder(
          Key('archive_upload_request_recipient_context_menu_action'),
          Icon(Icons.archive, size: 24.0, color: AppColor.unselectedElementColor),
          AppLocalizations.of(context).archive, uploadRequests.first)
      .onActionClick((_) => _viewModel.updateUploadRequestStatus(
          context,
          uploadRequests: uploadRequests,
          status: UploadRequestStatus.ARCHIVED,
          title: AppLocalizations.of(context).confirm_archive_multiple_upload_request(uploadRequests.length, uploadRequests.first.recipients.first.mail),
          titleButtonConfirm: AppLocalizations.of(context).archive,
          currentTab: UploadRequestGroupTab.ACTIVE_CLOSED,
          optionalCheckbox: true,
          optionalTitle: AppLocalizations.of(context).copy_before_archiving,
          itemSelectionType: itemSelectionType,
          onUpdateSuccess: () => _viewModel.requestToGetUploadRequestAndEntries()))
      .build();
  }

  Widget _archiveUploadRequestMultipleSelectionAction(List<UploadRequest> uploadRequests) {
    return UploadRequestMultipleSelectionActionBuilder(
        Key('multiple_selection_archive_action'),
        Icon(Icons.archive, size: 24.0, color: AppColor.unselectedElementColor),
        uploadRequests)
      .onActionClick((entries) => _viewModel.updateUploadRequestStatus(
          context,
          uploadRequests: uploadRequests,
          status: UploadRequestStatus.ARCHIVED,
          title: AppLocalizations.of(context).confirm_archive_multiple_upload_request(uploadRequests.length, uploadRequests.first.recipients.first.mail),
          titleButtonConfirm: AppLocalizations.of(context).archive,
          currentTab: UploadRequestGroupTab.ACTIVE_CLOSED,
          optionalCheckbox: true,
          optionalTitle: AppLocalizations.of(context).copy_before_archiving,
          itemSelectionType: ItemSelectionType.multiple,
          onUpdateSuccess: () => _viewModel.requestToGetUploadRequestAndEntries()))
      .build();
  }

  Widget _shareAction(List<UploadRequestEntry> entries,
      {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    return UploadRequestEntryContextMenuTileBuilder(
        Key('share_context_menu_action'),
        SvgPicture.asset(imagePath.icContextItemShare, width: 24, height: 24, fit: BoxFit.fill),
        AppLocalizations.of(context).share,
        entries.first)
      .onActionClick((data) =>
        _viewModel.copyToAndShareFiles(entries, itemSelectionType: itemSelectionType, currentTab: UploadRequestGroupTab.ACTIVE_CLOSED))
      .build();
  }
}