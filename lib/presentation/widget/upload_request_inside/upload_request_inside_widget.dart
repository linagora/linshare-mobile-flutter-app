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
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/model/file/selectable_element.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/ui_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/upload_request_inside_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/media_type_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/upload_request_status_extension.dart';
import 'package:linshare_flutter_app/presentation/util/helper/responsive_utils.dart';
import 'package:linshare_flutter_app/presentation/util/helper/responsive_widget.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/view/background_widgets/background_widget_builder.dart';
import 'package:linshare_flutter_app/presentation/view/common/common_view.dart';
import 'package:linshare_flutter_app/presentation/view/search/search_bottom_bar_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/file_context_menu_mixin.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/recipient_context_menu_mixin.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/upload_request_document_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/upload_request_document_type.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/upload_request_inside_navigator_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/upload_request_inside_viewmodel.dart';

abstract class UploadRequestInsideWidget extends StatefulWidget {
  final OnBackUploadRequestClickedCallback onBackUploadRequestClickedCallback;
  final OnUploadRequestClickedCallback onUploadRequestClickedCallback;

  UploadRequestInsideWidget(this.onBackUploadRequestClickedCallback, this.onUploadRequestClickedCallback);

  @override
  UploadRequestInsideWidgetState createState();
}

abstract class UploadRequestInsideWidgetState extends State<UploadRequestInsideWidget>
    with FileContextMenuMixin, RecipientContextMenuMixin {

  UploadRequestInsideViewModel get viewModel => getIt<UploadRequestInsideViewModel>();
  final appNavigation = getIt<AppNavigation>();
  final imagePath = getIt<AppImagePaths>();
  final _responsiveUtils = getIt<ResponsiveUtils>();
  UploadRequestArguments? _arguments;
  final _widgetCommon = getIt<CommonView>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _arguments = ModalRoute.of(context)?.settings.arguments as UploadRequestArguments;
      if (_arguments != null) {
        viewModel.initState(_arguments!);
      }
    });
  }

  @override
  void dispose() {
    viewModel.onDisposed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, bool>(
      converter: (store) => store.state.uiState.isInSearchState(),
      builder: (context, isInSearchState) =>
        isInSearchState ? _buildSearchViewWidget(context) : _buildDefaultViewWidget());
  }

  Widget _buildSearchViewWidget(BuildContext context) {
    return StoreConnector<AppState, UploadRequestInsideState>(
      converter: (store) => store.state.uploadRequestInsideState,
      builder: (_, state) {
        if (viewModel.searchQuery.value.isEmpty) {
          return SizedBox.shrink();
        }
        if (state.uploadRequestEntries.isEmpty) {
          return _widgetCommon.buildNoResultFound(context);
        }
        return Column(children: [
          _buildMultipleSelectionTopBar(),
          _widgetCommon.buildResultCountRow(context, state.uploadRequestEntries.length),
          Expanded(child: _buildUploadRequestEntriesListView(state.uploadRequestEntries, state.selectMode)),
          (state.selectMode == SelectMode.ACTIVE && state.getAllSelectedEntries().isNotEmpty)
              ? buildFileMultipleSelectionBottomBar(
                  context,
                  state.getAllSelectedEntries())
              : SizedBox.shrink()
        ]);
      });
  }

  Widget _buildDefaultViewWidget() {
    return Scaffold(
      body: Column(
        children: [
          _buildTopBar(),
          _buildMultipleSelectionTopBar(),
          _buildLoadingLayout(),
          Expanded(child: _buildUploadRequestList()),
          StoreConnector<AppState, UploadRequestInsideState>(
              converter: (store) => store.state.uploadRequestInsideState,
              builder: (context, state) => _buildMultipleSelectionBottomBar(state))
        ],
      ),
      bottomNavigationBar: StoreConnector<AppState, AppState>(
          converter: (store) => store.state,
          builder: (context, appState) {
            if (!appState.uiState.isInSearchState() &&
                appState.uploadRequestInsideState.selectMode != SelectMode.ACTIVE &&
                appState.uploadRequestInsideState.uploadRequestEntries.isNotEmpty) {
              return SearchBottomBarBuilder().key(Key('search_bottom_bar')).onSearchActionClick(() {
                viewModel.openSearchState(context);
              }).build();
            }
            return SizedBox.shrink();
          }),
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
                    GestureDetector(
                      onTap: widget.onBackUploadRequestClickedCallback,
                      child: Container(
                        width: 48,
                        height: 48,
                        child: Align(
                          alignment: Alignment.center,
                          heightFactor: 24,
                          widthFactor: 24,
                          child: SvgPicture.asset(imagePath.icBackBlue, width: 24, height: 24),
                        ),
                      ),
                    ),
                    _buildTitleTopBar()
                  ]
              )
        )
    );
  }

  Widget _buildTitleTopBar() {
    return StoreConnector<AppState, UploadRequestInsideState>(
        converter: (store) => store.state.uploadRequestInsideState,
        builder: (context, urState) =>
            ((urState.uploadRequestGroup?.collective == false
                && urState.uploadRequestDocumentType == UploadRequestDocumentType.recipients)
              || urState.uploadRequestGroup?.collective == true)
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
                            fontWeight: FontWeight.w400
                        )
                    ),
                  ),
                )
            )
            : Expanded(
            child: Padding(
                padding: const EdgeInsets.only(left: 5.0, right: 45.0),
                child: Text(
                    urState.selectedUploadRequest?.recipients.first.mail ?? '',
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
    return StoreConnector<AppState, UploadRequestInsideState>(
      converter: (store) => store.state.uploadRequestInsideState,
      builder: (context, state) => state.selectMode == SelectMode.ACTIVE
        ? ListTile(
          leading: SvgPicture.asset(imagePath.icSelectAll,
            width: 28,
            height: 28,
            fit: BoxFit.fill,
            color: _isSelectAll(state) ? AppColor.unselectedElementColor : AppColor.primaryColor),
          title: Transform(
            transform: Matrix4.translationValues(-16, 0.0, 0.0),
            child: _isSelectAll(state)
              ? Text(AppLocalizations.of(context).unselect_all,
                  maxLines: 1, style: TextStyle(fontSize: 14, color: AppColor.documentNameItemTextColor))
              : Text(AppLocalizations.of(context).select_all,
                  maxLines: 1, style: TextStyle(fontSize: 14, color: AppColor.documentNameItemTextColor))),
          tileColor: AppColor.topBarBackgroundColor,
          onTap: () => _toggleSelectAll(state),
          trailing: TextButton(
            onPressed: () => _cancelSelection(state),
            child: Text(AppLocalizations.of(context).cancel,
                maxLines: 1, style: TextStyle(fontSize: 14, color: AppColor.primaryColor))))
        : SizedBox.shrink());
  }
  
  bool _isSelectAll(UploadRequestInsideState uploadRequestInsideState) {
    switch (uploadRequestInsideState.uploadRequestDocumentType) {
      case UploadRequestDocumentType.recipients:
        return uploadRequestInsideState.isAllRecipientSelected();
      case UploadRequestDocumentType.files:
        return uploadRequestInsideState.isAllEntriesSelected();
    }
  }
  
  void _toggleSelectAll(UploadRequestInsideState uploadRequestInsideState) {
    switch (uploadRequestInsideState.uploadRequestDocumentType) {
      case UploadRequestDocumentType.recipients:
        viewModel.toggleSelectAllRecipients();
        break;
      case UploadRequestDocumentType.files:
        viewModel.toggleSelectAllEntries();
        break;
    }
  }
  
  void _cancelSelection(UploadRequestInsideState uploadRequestInsideState) {
    switch (uploadRequestInsideState.uploadRequestDocumentType) {
      case UploadRequestDocumentType.recipients:
        viewModel.cancelRecipientSelection();
        break;
      case UploadRequestDocumentType.files:
        viewModel.cancelSelection();
        break;
    }
  }

  Widget _buildLoadingLayout() {
    return StoreConnector<AppState, dartz.Either<Failure, Success>>(
        converter: (store) => store.state.uploadRequestInsideState.viewState,
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

  Widget _buildUploadRequestList() {
    return StoreConnector<AppState, UploadRequestInsideState>(
        converter: (store) => store.state.uploadRequestInsideState,
        builder: (context, uploadRequestInsideState) =>
            uploadRequestInsideState.viewState.fold(
                (failure) => RefreshIndicator(
                  onRefresh: () async => viewModel.requestToGetUploadRequestAndEntries(),
                  child: _buildEmptyListIndicator()),
                (success) => RefreshIndicator(
                  onRefresh: () async => viewModel.requestToGetUploadRequestAndEntries(),
                  child: _buildLayoutCorrespondingWithState(uploadRequestInsideState)))
    );
  }

  Widget _buildLayoutCorrespondingWithState(UploadRequestInsideState uploadRequestInsideState) {
    switch (uploadRequestInsideState.uploadRequestDocumentType) {
      case UploadRequestDocumentType.recipients:
        return _buildUploadRequestListView(uploadRequestInsideState.uploadRequests, uploadRequestInsideState.selectMode);
      case UploadRequestDocumentType.files:
        return _buildUploadRequestEntriesListView(
            uploadRequestInsideState.uploadRequestEntries, uploadRequestInsideState.selectMode);
    }
  }

  Widget _buildEmptyListIndicator() {
    return BackgroundWidgetBuilder()
      .image(SvgPicture.asset(
        imagePath.icUploadFile,
        width: 120,
        height: 120,
        fit: BoxFit.fill,
      ))
      .text(AppLocalizations.of(context).upload_requests_no_files_uploaded)
      .build();
  }

  Widget _buildUploadRequestEntriesListView(
      List<SelectableElement<UploadRequestEntry>> uploadRequestEntries,
      SelectMode selectMode) {
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
      SelectMode selectMode) {
    return ListTile(
      onTap: () {
        if (selectMode == SelectMode.ACTIVE) {
          viewModel.selectItem(entry);
        }
      },
      onLongPress: () => viewModel.selectItem(entry),
      leading: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SvgPicture.asset(entry.element.mediaType.getFileTypeImagePath(imagePath), width: 20, height: 24, fit: BoxFit.fill)
      ]),
      title: ResponsiveWidget(
        mediumScreen: Transform(
          transform: Matrix4.translationValues(-16, 0.0, 0.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _buildItemTitle(entry.element.name),
            Align(alignment: Alignment.centerRight, child: _buildRecipientText(entry.element.recipient.mail))
          ]),
        ),
        smallScreen:
            Transform(transform: Matrix4.translationValues(-16, 0.0, 0.0), child: _buildItemTitle(entry.element.name)),
        responsiveUtil: _responsiveUtils,
      ),
      subtitle: _responsiveUtils.isSmallScreen(context)
          ? Transform(
              transform: Matrix4.translationValues(-16, 0.0, 0.0),
              child: Row(
                children: [
                  _buildRecipientText(entry.element.recipient.mail),
                ],
              ),
            )
          : null,
      trailing: selectMode == SelectMode.ACTIVE
          ? Checkbox(
              value: entry.selectMode == SelectMode.ACTIVE,
              onChanged: (bool? value) => viewModel.selectItem(entry),
              activeColor: AppColor.primaryColor)
          : IconButton(
              icon: SvgPicture.asset(
                imagePath.icContextMenu,
                width: 24,
                height: 24,
                fit: BoxFit.fill,
              ),
              onPressed: () => openFileContextMenu(context, entry.element)
            ),
    );
  }

  Widget _buildItemTitle(String title) {
    return Text(
      title,
      maxLines: 1,
      style: TextStyle(fontSize: 14, color: AppColor.uploadRequestTitleTextColor),
    );
  }

  Widget _buildRecipientText(String recipient) {
    return Text(
      recipient,
      style: TextStyle(fontSize: 13, color: AppColor.uploadRequestHintTextColor),
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
          viewModel.selectRecipient(uploadRequest);
        } else {
          widget.onUploadRequestClickedCallback(uploadRequest);
        }
      },
      onLongPress: () => viewModel.selectRecipient(uploadRequest),
      leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [SvgPicture.asset(imagePath.icUploadRequestIndividual, width: 20, height: 24, fit: BoxFit.fill)]),
      title: ResponsiveWidget(
        mediumScreen: Transform(
          transform: Matrix4.translationValues(-16, 0.0, 0.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _buildItemTitle(uploadRequest.element.recipients.first.mail),
            Align(alignment: Alignment.centerRight, child: _buildRecipientStatus(uploadRequest.element.status))
          ]),
        ),
        smallScreen: Transform(
            transform: Matrix4.translationValues(-16, 0.0, 0.0),
            child: _buildItemTitle(uploadRequest.element.recipients.first.mail)),
        responsiveUtil: _responsiveUtils,
      ),
      subtitle: _responsiveUtils.isSmallScreen(context)
          ? Transform(
              transform: Matrix4.translationValues(-16, 0.0, 0.0),
              child: Row(
                children: [
                  _buildRecipientStatus(uploadRequest.element.status),
                ],
              ),
            )
          : null,
      trailing: selectMode == SelectMode.ACTIVE
          ? Checkbox(
              value: uploadRequest.selectMode == SelectMode.ACTIVE,
              onChanged: (bool? value) => viewModel.selectRecipient(uploadRequest),
              activeColor: AppColor.primaryColor)
          : IconButton(
              icon: SvgPicture.asset(
                imagePath.icContextMenu,
                width: 24,
                height: 24,
                fit: BoxFit.fill,
              ),
              onPressed: () => openRecipientContextMenu(context, uploadRequest.element)),
    );
  }

  Widget _buildRecipientStatus(UploadRequestStatus status) {
    return Row(children: [
      Container(
        margin: EdgeInsets.only(right: 4),
        width: 7.0,
        height: 7.0,
        decoration: BoxDecoration(
          color: status.displayColor,
          shape: BoxShape.circle,
        ),
      ),
      Text(status.displayValue(context),
          style: TextStyle(fontSize: 13, color: AppColor.uploadRequestHintTextColor))
    ]);
  }

  Widget _buildMultipleSelectionBottomBar(UploadRequestInsideState state) {
    if (state.selectMode == SelectMode.INACTIVE) {
      return SizedBox.shrink();
    }

    if (_arguments == null) {
      return SizedBox.shrink();
    }

    switch (_arguments!.documentType) {
      case UploadRequestDocumentType.files:
        return buildFileMultipleSelectionBottomBar(context, state.getAllSelectedEntries());
      case UploadRequestDocumentType.recipients:
        return buildRecipientMultipleSelectionBottomBar(context, state.getAllSelectedRecipient());
    }
  }
}
