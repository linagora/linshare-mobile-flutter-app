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

import 'package:dartz/dartz.dart' as dartz;
import 'package:domain/domain.dart';
import 'package:domain/src/model/upload_request_entry/upload_request_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/model/file/selectable_element.dart';
import 'package:linshare_flutter_app/presentation/model/item_selection_type.dart';
import 'package:linshare_flutter_app/presentation/model/upload_request_group_tab.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/ui_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/upload_request_inside_created_state.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/media_type_extension.dart';
import 'package:linshare_flutter_app/presentation/util/helper/responsive_utils.dart';
import 'package:linshare_flutter_app/presentation/util/helper/responsive_widget.dart';
import 'package:linshare_flutter_app/presentation/view/background_widgets/background_widget_builder.dart';
import 'package:linshare_flutter_app/presentation/view/common/common_view.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/upload_request_context_menu_action_builder.dart';
import 'package:linshare_flutter_app/presentation/view/order_by/order_by_button.dart';
import 'package:linshare_flutter_app/presentation/view/search/search_bottom_bar_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/pending/pending_upload_request_inside_view_model.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/upload_request_document_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/upload_request_document_type.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/upload_request_inside_navigator_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/upload_request_inside_widget.dart';
import 'package:redux/redux.dart';

class PendingUploadRequestInsideWidget extends UploadRequestInsideWidget {

  PendingUploadRequestInsideWidget(
    OnBackUploadRequestClickedCallback onBackUploadRequestClickedCallback,
    OnUploadRequestClickedCallback onUploadRequestClickedCallback
  ) : super(onBackUploadRequestClickedCallback, onUploadRequestClickedCallback);

  @override
  UploadRequestInsideWidgetState createState() => _PendingUploadRequestInsideWidgetState();
}

class _PendingUploadRequestInsideWidgetState extends UploadRequestInsideWidgetState {

  final _responsiveUtils = getIt<ResponsiveUtils>();
  final _widgetCommon = getIt<CommonView>();
  final _viewModel = getIt<PendingUploadRequestInsideViewModel>();

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
    return StoreConnector<AppState, CreatedUploadRequestInsideState>(
        converter: (store) => store.state.createdUploadRequestInsideState,
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
            Expanded(child: state.isIndividualRecipients()
                ? _buildUploadRequestListView(state.uploadRequests, state.selectMode)
                : _buildUploadRequestEntriesListView(state.uploadRequestEntries, state.selectMode)),
            _buildMultipleSelectionBottomBar(state)
          ]);
        });
  }

  Widget _buildDefaultViewWidget() {
    return Scaffold(
      body: Column(
        children: [
          buildTopBar(titleTopBar: _buildTitleTopBar()),
          _buildMultipleSelectionTopBar(),
          _buildMenuSorterPending(),
          _buildLoadingLayout(),
          Expanded(child: _buildUploadRequestList()),
          StoreConnector<AppState, CreatedUploadRequestInsideState>(
              converter: (store) => store.state.createdUploadRequestInsideState,
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
                  final group = appState.createdUploadRequestInsideState.uploadRequestGroup;
                  if (group != null) {
                    _viewModel.goToAddRecipients(group, UploadRequestGroupTab.PENDING);
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

  Widget _buildMenuSorterPending() {
    return StoreConnector<AppState, AppState>(
      converter: (Store<AppState> store) => store.state,
      builder: (context, appState) => !appState.uiState.isInSearchState()
        ? _buildSorterPendingWidget(context, appState)
        : SizedBox.shrink()
    );
  }

  Widget _buildSorterPendingWidget(BuildContext context, AppState appState) {
    if (appState.createdUploadRequestInsideState.uploadRequestDocumentType == UploadRequestDocumentType.files) {
      return OrderByButtonBuilder(context, appState.createdUploadRequestInsideState.fileSorter)
        .onOpenOrderMenuAction((currentSorter) => _viewModel)
        .build();
    }
    return OrderByButtonBuilder(context, appState.createdUploadRequestInsideState.recipientSorter)
      .onOpenOrderMenuAction((currentSorter) => _viewModel.openPopupMenuSorterRecipientsPending(context, currentSorter))
      .build();
  }

  Widget _buildTitleTopBar() {
    return StoreConnector<AppState, CreatedUploadRequestInsideState>(
        converter: (store) => store.state.createdUploadRequestInsideState,
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

  Widget _buildLoadingLayout() {
    return StoreConnector<AppState, dartz.Either<Failure, Success>>(
        converter: (store) => store.state.createdUploadRequestInsideState.viewState,
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

  Widget _buildUploadRequestList() {
    return StoreConnector<AppState, CreatedUploadRequestInsideState>(
        converter: (store) => store.state.createdUploadRequestInsideState,
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

  Widget _buildLayoutCorrespondingWithState(CreatedUploadRequestInsideState state) {
    switch (state.uploadRequestDocumentType) {
      case UploadRequestDocumentType.recipients:
        return _buildUploadRequestListView(state.uploadRequests, state.selectMode);
      case UploadRequestDocumentType.files:
        return _buildUploadRequestEntriesListView(state.uploadRequestEntries, state.selectMode);
    }
  }

  bool _validateAddRecipientButton(AppState appState) {
    final isInMultipleSelectMode = appState.createdUploadRequestInsideState.selectMode == SelectMode.ACTIVE;
    final uploadRequestGroup = appState.createdUploadRequestInsideState.uploadRequestGroup;

    if (!appState.uiState.isInSearchState() && !isInMultipleSelectMode) {
      if (appState.createdUploadRequestInsideState.isIndividualRecipients()) {
        return uploadRequestGroup?.status == UploadRequestStatus.CREATED;
      }
    }
    return false;
  }

  bool _validateSearchButton(AppState appState) {
    final isInMultipleSelectMode = appState.createdUploadRequestInsideState.selectMode == SelectMode.ACTIVE;

    if (!appState.uiState.isInSearchState() && !isInMultipleSelectMode) {
      if (appState.createdUploadRequestInsideState.isIndividualRecipients()) {
        return appState.createdUploadRequestInsideState.uploadRequests.isNotEmpty;
      } else {
        return appState.createdUploadRequestInsideState.uploadRequestEntries.isNotEmpty;
      }
    }
    return false;
  }

  Widget _buildMultipleSelectionBottomBar(CreatedUploadRequestInsideState state) {
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
              child: Row(children: [buildRecipientStatus(uploadRequest.element.status)]))
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
                  fit: BoxFit.fill),
              onPressed: () => openRecipientContextMenu(context, uploadRequest.element)),
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

  Widget _buildEntryListItem(BuildContext context, SelectableElement<UploadRequestEntry> entry, SelectMode selectMode) {
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
            Align(alignment: Alignment.centerRight, child: buildRecipientText(entry.element.recipient.mail))
          ]),
        ),
        smallScreen:
        Transform(transform: Matrix4.translationValues(-16, 0.0, 0.0), child: buildItemTitle(entry.element.name)),
        responsiveUtil: _responsiveUtils,
      ),
      subtitle: _responsiveUtils.isSmallScreen(context)
          ? Transform(
              transform: Matrix4.translationValues(-16, 0.0, 0.0),
              child: Row(
                children: [
                  buildRecipientText(entry.element.recipient.mail),
                ],
              ),
            )
          : null,
      trailing: selectMode == SelectMode.ACTIVE
          ? Checkbox(
              value: entry.selectMode == SelectMode.ACTIVE,
              onChanged: (bool? value) => _viewModel.selectEntry(entry),
              activeColor: AppColor.primaryColor)
          : IconButton(
              icon: SvgPicture.asset(imagePath.icContextMenu, width: 24, height: 24, fit: BoxFit.fill),
              onPressed: () => openFileContextMenu(context, entry.element)
      ),
    );
  }

  Widget _buildMultipleSelectionTopBar() {
    return StoreConnector<AppState, CreatedUploadRequestInsideState>(
        converter: (store) => store.state.createdUploadRequestInsideState,
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

  bool _isSelectAll(CreatedUploadRequestInsideState state) {
    switch (state.uploadRequestDocumentType) {
      case UploadRequestDocumentType.recipients:
        return state.isAllRecipientSelected();
      case UploadRequestDocumentType.files:
        return state.isAllEntriesSelected();
    }
  }

  void _toggleSelectAll(CreatedUploadRequestInsideState state) {
    switch (state.uploadRequestDocumentType) {
      case UploadRequestDocumentType.recipients:
        _viewModel.toggleSelectAllRecipients();
        break;
      case UploadRequestDocumentType.files:
        _viewModel.toggleSelectAllEntries();
        break;
    }
  }

  void _cancelSelection(CreatedUploadRequestInsideState state) {
    switch (state.uploadRequestDocumentType) {
      case UploadRequestDocumentType.recipients:
        _viewModel.cancelAllSelectionRecipients(UploadRequestGroupTab.PENDING);
        break;
      case UploadRequestDocumentType.files:
        _viewModel.cancelAllSelectionEntries(UploadRequestGroupTab.PENDING);
        break;
    }
  }

  Widget _buildEmptyListIndicator() {
    return StoreConnector<AppState, dartz.Either<Failure, Success>>(
        converter: (store) => store.state.createdUploadRequestInsideState.viewState,
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

  @override
  void openFileContextMenu(BuildContext context, UploadRequestEntry entry) {
  }

  @override
  void openRecipientContextMenu(BuildContext context, UploadRequest entry) {
    super.openRecipientContextMenu(context, entry);
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
  List<Widget> fileContextMenuActionTiles(BuildContext context, UploadRequestEntry entry) {
    throw [];
  }

  @override
  Widget? fileFooterActionTile() {
    return null;
  }

  @override
  List<Widget> fileMultipleSelectionActions(BuildContext context, List<UploadRequestEntry> allSelectedEntries) {
    throw [];
  }

  @override
  List<Widget> recipientContextMenuActionTiles(BuildContext context, UploadRequest uploadRequest) {
    return [
      if (uploadRequest.status == UploadRequestStatus.CREATED) editUploadRequestRecipientAction(
          context,
          uploadRequest,
          () => _viewModel.goToEditUploadRequestRecipient(uploadRequest, UploadRequestGroupTab.PENDING))
    ];
  }

  @override
  Widget? recipientFooterActionTile(UploadRequest entry) {
    return Column(children: [
      if (entry.status == UploadRequestStatus.CREATED) _cancelUploadRequestAction([entry])
    ]);
  }

  @override
  List<Widget> recipientMultipleSelectionActions(BuildContext context, List<UploadRequest> allSelected) {
    return [
      moreActionMultipleSelection(allSelected, () => openRecipientMoreActionBottomMenu(context, allSelected)),
    ];
  }

  Widget _cancelUploadRequestAction(List<UploadRequest> uploadRequests,
      {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    return UploadRequestContextMenuActionBuilder(
          Key('cancel_upload_request_recipient_context_menu_action'),
          SvgPicture.asset(imagePath.icUploadRequestCancel, width: 24, height: 24, fit: BoxFit.fill),
          AppLocalizations.of(context).cancel, uploadRequests.first)
      .onActionClick((_) => _viewModel.updateUploadRequestStatus(
          context,
          uploadRequests: uploadRequests,
          status: UploadRequestStatus.CANCELED,
          title: AppLocalizations.of(context).confirm_cancel_multiple_upload_request(uploadRequests.length, uploadRequests.first.recipients.first.mail),
          titleButtonConfirm: AppLocalizations.of(context).upload_request_proceed_button,
          currentTab: UploadRequestGroupTab.PENDING,
          itemSelectionType: itemSelectionType,
          onUpdateSuccess: () => _viewModel.requestToGetUploadRequestAndEntries()))
      .build();
  }

  @override
  Widget? recipientFooterMultipleSelectionMoreActionBottomMenuTile(List<UploadRequest> allSelected) {
    final isAllSelectedPending = allSelected.where((element) => element.status != UploadRequestStatus.CREATED).isEmpty;

    return Column(children: [
      if (isAllSelectedPending) _cancelUploadRequestAction(allSelected, itemSelectionType: ItemSelectionType.multiple),
    ]);
  }

  @override
  List<Widget> recipientMultipleSelectionMoreActionBottomMenuTiles(BuildContext context, List<UploadRequest> allSelected) {
    return [];
  }
}