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
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/upload_request_group_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/helper/responsive_utils.dart';
import 'package:linshare_flutter_app/presentation/view/background_widgets/background_widget_builder.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/simple_horizontal_context_menu_action_builder.dart';
import 'package:linshare_flutter_app/presentation/view/search/search_bottom_bar_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_group/upload_request_group_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/datetime_extension.dart';
import 'package:redux/redux.dart';
import 'package:linshare_flutter_app/presentation/redux/states/ui_state.dart';
import 'package:linshare_flutter_app/presentation/view/order_by/order_by_button.dart';

class UploadRequestGroupWidget extends StatefulWidget {
  UploadRequestGroupWidget({Key? key}) : super(key: key);

  @override
  _UploadRequestGroupWidgetState createState() => _UploadRequestGroupWidgetState();
}

class _UploadRequestGroupWidgetState extends State<UploadRequestGroupWidget> {
  final _model = getIt<UploadRequestGroupViewModel>();
  final imagePath = getIt<AppImagePaths>();
  final _responsiveUtils = getIt<ResponsiveUtils>();

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      _model.initState();
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
    return StoreConnector<AppState, bool>(
        converter: (store) => store.state.uiState.isInSearchState(),
        builder: (context, isInSearchState) =>
            isInSearchState ? _buildSearchViewWidget(context) : _buildDefaultViewWidget());
  }

  Widget _buildDefaultViewWidget() {
    return DefaultTabController(
        initialIndex: _model.store.state.uiState.uploadRequestGroupTabIndex,
        length: 3,
        child: Scaffold(
          appBar: TabBar(
              unselectedLabelColor: AppColor.uploadRequestLabelsColor,
              unselectedLabelStyle: TextStyle(fontSize: 16),
              labelStyle: TextStyle(fontSize: 16),
              labelColor: AppColor.primaryColor,
              indicatorColor: AppColor.primaryColor,
              onTap: (index) => _model.setTabIndex(index),
              tabs: [
                FittedBox(
                  fit: BoxFit.contain,
                  child: Tab(
                    text: AppLocalizations.of(context).pending,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.none,
                  child: Tab(
                    text: AppLocalizations.of(context).active_closed,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.contain,
                  child: Tab(
                    text: AppLocalizations.of(context).archived,
                  ),
                ),
              ]),
          body: StoreConnector<AppState, UploadRequestGroupState>(
            converter: (store) => store.state.uploadRequestGroupState,
            builder: (_, state) => TabBarView(
              children: [
                _buildPendingUploadRequestListWidget(context, state.uploadRequestsCreatedList),
                _buildActiveClosedListWidget(context, state.uploadRequestsActiveClosedList),
                _buildArchivedUploadRequestListWidget(context, state.uploadRequestsArchivedList)
              ],
            ),
          ),
          bottomNavigationBar:
              SearchBottomBarBuilder().key(Key('search_bottom_bar')).onSearchActionClick(() {
            _model.openSearchState();
          }).build(),
          floatingActionButton: FloatingActionButton(
            key: Key('upload_request_add_button'),
            onPressed: () => _model.openUploadRequestAddMenu(
                context, _addNewUploadRequestMenuActionTiles(context)),
            backgroundColor: AppColor.primaryColor,
            child: SvgPicture.asset(
              imagePath.icPlus,
              width: 24,
              height: 24,
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        ));
  }

  Widget _buildArchivedUploadRequestListWidget(
      BuildContext context, List<UploadRequestGroup> uploadRequestList) {
    return Column(children: [
      _buildMenuSorterArchived(),
      Expanded(
          child: RefreshIndicator(
              onRefresh: () async => _model.getUploadRequestArchivedStatus(),
              child: uploadRequestList.isEmpty
                  ? _buildCreateUploadRequestsHere(context)
                  : ListView.builder(
                      itemCount: uploadRequestList.length,
                      itemBuilder: (context, index) =>
                          _buildArchivedUploadTile(uploadRequestList[index]))))
    ]);
  }

  Widget _buildPendingUploadRequestListWidget(
      BuildContext context, List<UploadRequestGroup> uploadRequestList) {
    return Column(children: [
      _buildMenuSorterPending(),
      Expanded(
          child: RefreshIndicator(
              onRefresh: () async => _model.getUploadRequestCreatedStatus(),
              child: uploadRequestList.isEmpty
                  ? _buildCreateUploadRequestsHere(context)
                  : ListView.builder(
                      itemCount: uploadRequestList.length,
                      itemBuilder: (context, index) =>
                          _buildPendingUploadTile(uploadRequestList[index]))))
    ]);
  }

  Widget _buildActiveClosedListWidget(
      BuildContext context, List<UploadRequestGroup> uploadRequestList) {
    return Column(children: [
      _buildMenuSorterActiveClosed(),
      Expanded(
          child: RefreshIndicator(
              onRefresh: () async => _model.getUploadRequestActiveClosedStatus(),
              child: uploadRequestList.isEmpty
                  ? _buildCreateUploadRequestsHere(context)
                  : ListView.builder(
                      itemCount: uploadRequestList.length,
                      itemBuilder: (context, index) =>
                          _buildActiveClosedUploadTile(uploadRequestList[index]))))
    ]);
  }

  ListTile _buildPendingUploadTile(UploadRequestGroup request) {
    return ListTile(
      onTap: () => _model.getListUploadRequests(request),
      dense: true,
      leading: _getTileIcon(request.collective),
      title: Text(request.label,
          style: TextStyle(fontSize: 14, color: AppColor.uploadRequestLabelsColor)),
      subtitle: Text(
          AppLocalizations.of(context)
              .activated_date(request.activationDate.getMMMddyyyyFormatString()),
          style: TextStyle(fontSize: 14, color: AppColor.uploadFileFileSizeTextColor)),
      trailing: IconButton(
          icon: SvgPicture.asset(
            imagePath.icContextMenu,
            width: 24,
            height: 24,
            fit: BoxFit.fill,
          ),
          onPressed: () => null),
    );
  }

  ListTile _buildArchivedUploadTile(UploadRequestGroup request) {
    return ListTile(
      onTap: () => _model.getListUploadRequests(request),
      dense: true,
      leading: _getTileIcon(request.collective),
      title: Text(request.label,
          style: TextStyle(fontSize: 14, color: AppColor.uploadRequestLabelsColor)),
      subtitle: Text(
          AppLocalizations.of(context)
              .archived_date(request.activationDate.getMMMddyyyyFormatString()),
          style: TextStyle(fontSize: 14, color: AppColor.uploadFileFileSizeTextColor)),
      trailing: IconButton(
          icon: SvgPicture.asset(
            imagePath.icContextMenu,
            width: 24,
            height: 24,
            fit: BoxFit.fill,
          ),
          onPressed: () => null),
    );
  }

  ListTile _buildActiveClosedUploadTile(UploadRequestGroup request) {
    return ListTile(
      onTap: () => _model.getListUploadRequests(request),
      dense: true,
      leading: _getTileIcon(request.collective),
      title: Text(request.label,
          style: TextStyle(fontSize: 14, color: AppColor.uploadRequestLabelsColor)),
      subtitle: _buildActiveClosedSubtitleWidget(request.status),
      trailing: IconButton(
          icon: SvgPicture.asset(
            imagePath.icContextMenu,
            width: 24,
            height: 24,
            fit: BoxFit.fill,
          ),
          onPressed: () => null),
    );
  }

  Widget _buildActiveClosedSubtitleWidget(UploadRequestStatus status) {
    if (status == UploadRequestStatus.ENABLED) {
      return Row(children: [
        Container(
          margin: EdgeInsets.only(right: 4),
          width: 7.0,
          height: 7.0,
          decoration: BoxDecoration(
            color: AppColor.primaryColor,
            shape: BoxShape.circle,
          ),
        ),
        Text(AppLocalizations.of(context).active,
            style: TextStyle(fontSize: 14, color: AppColor.uploadFileFileSizeTextColor))
      ]);
    }

    if (status == UploadRequestStatus.CLOSED) {
      return Row(children: [
        Container(
          margin: EdgeInsets.only(right: 4),
          width: 7.0,
          height: 7.0,
          decoration: BoxDecoration(
            color: AppColor.uploadRequestLabelsColor,
            shape: BoxShape.circle,
          ),
        ),
        Text(AppLocalizations.of(context).expired_closed,
            style: TextStyle(fontSize: 14, color: AppColor.uploadFileFileSizeTextColor))
      ]);
    }

    return SizedBox.shrink();
  }

  Widget _buildCreateUploadRequestsHere(BuildContext context) {
    return BackgroundWidgetBuilder()
        .key(Key('create_upload_request_here'))
        .image(SvgPicture.asset(imagePath.icCreateUploadRequest,
            width: 120, height: 120, fit: BoxFit.fill))
        .text(AppLocalizations.of(context).create_upload_requests_here)
        .build();
  }

  Widget _getTileIcon(bool collective) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      SvgPicture.asset(
          collective ? imagePath.icUploadRequestCollective : imagePath.icUploadRequestIndividual,
          width: 20,
          height: 24,
          fit: BoxFit.fill)
    ]);
  }

  List<Widget> _addNewUploadRequestMenuActionTiles(BuildContext context) {
    return [_addCollectiveAction(context), _addIndividualAction(context)];
  }

  Widget _addCollectiveAction(BuildContext context) => SimpleHorizontalContextMenuActionBuilder(
          Key('add_collective_ur_context_menu_action'),
          SvgPicture.asset(imagePath.icUploadRequestCollective,
              width: 24,
              height: 24,
              fit: BoxFit.fill,
              color: AppColor.uploadRequestAddNewIconColor),
          AppLocalizations.of(context).collective_upload)
      .onActionClick((_) => _model.addNewUploadRequest(UploadRequestCreationType.COLLECTIVE))
      .build();

  Widget _addIndividualAction(BuildContext context) => SimpleHorizontalContextMenuActionBuilder(
          Key('add_individual_ur_context_menu_action'),
          SvgPicture.asset(imagePath.icUploadRequestIndividual,
              width: 24,
              height: 24,
              fit: BoxFit.fill,
              color: AppColor.uploadRequestAddNewIconColor),
          AppLocalizations.of(context).individual_upload)
      .onActionClick((_) => _model.addNewUploadRequest(UploadRequestCreationType.INDIVIDUAL))
      .build();

  Widget _buildMenuSorterPending() {
    return StoreConnector<AppState, AppState>(
      converter: (Store<AppState> store) => store.state,
      builder: (context, appState) {
        return !appState.uiState.isInSearchState()
            ? OrderByButtonBuilder(context, appState.uploadRequestGroupState.pendingSorter)
                .onOpenOrderMenuAction(
                    (currentSorter) => _model.openPopupMenuSorterPending(context, currentSorter))
                .build()
            : SizedBox.shrink();
      },
    );
  }

  Widget _buildMenuSorterArchived() {
    return StoreConnector<AppState, AppState>(
        converter: (Store<AppState> store) => store.state,
        builder: (context, appState) =>
            OrderByButtonBuilder(context, appState.uploadRequestGroupState.archivedSorter)
                .onOpenOrderMenuAction(
                    (currentSorter) => _model.openPopupMenuSorterArchived(context, currentSorter))
                .build());
  }

  Widget _buildMenuSorterActiveClosed() {
    return StoreConnector<AppState, AppState>(
      converter: (Store<AppState> store) => store.state,
      builder: (context, appState) {
        return !appState.uiState.isInSearchState()
            ? OrderByButtonBuilder(context, appState.uploadRequestGroupState.activeClosedSorter)
                .onOpenOrderMenuAction((currentSorter) =>
                    _model.openPopupMenuSorterActiveClosed(context, currentSorter))
                .build()
            : SizedBox.shrink();
      },
    );
  }

  // Search Widgets
  Widget _buildSearchViewWidget(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: TabBar(
              unselectedLabelColor: AppColor.uploadRequestLabelsColor,
              unselectedLabelStyle: TextStyle(fontSize: 16),
              labelStyle: TextStyle(fontSize: 16),
              labelColor: AppColor.primaryColor,
              indicatorColor: AppColor.primaryColor,
              tabs: [
                FittedBox(
                  fit: BoxFit.contain,
                  child: Tab(
                    text: AppLocalizations.of(context).pending,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.none,
                  child: Tab(
                    text: AppLocalizations.of(context).active_closed,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.contain,
                  child: Tab(
                    text: AppLocalizations.of(context).archived,
                  ),
                ),
              ]),
          body: StoreConnector<AppState, UploadRequestGroupState>(
            converter: (store) => store.state.uploadRequestGroupState,
            builder: (_, state) => TabBarView(
              children: [
                _buildPendingUploadRequestSearchListWidget(
                    context,
                    state.searchResult
                        .where((element) => element.status == UploadRequestStatus.CREATED)
                        .toList()),
                _buildActiveClosedSearchListWidget(
                    context,
                    state.searchResult
                        .where((element) =>
                            element.status == UploadRequestStatus.ENABLED ||
                            element.status == UploadRequestStatus.CLOSED)
                        .toList()),
                _buildArchivedUploadRequestSearchListWidget(
                    context,
                    state.searchResult
                        .where((element) => element.status == UploadRequestStatus.ARCHIVED)
                        .toList())
              ],
            ),
          ),
        ));
  }

  Widget _buildNoResultFound() {
    return BackgroundWidgetBuilder()
        .key(Key('search_no_result_found'))
        .text(AppLocalizations.of(context).no_results_found)
        .build();
  }

  Widget _buildResultCount(int count) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, appState) {
          if (_model.searchQuery.value.isNotEmpty) {
            return _buildResultCountRow(count);
          }
          return SizedBox.shrink();
        });
  }

  Widget _buildResultCountRow(int count) {
    return Container(
      color: AppColor.topBarBackgroundColor,
      height: 40.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            AppLocalizations.of(context).results_count(count),
            style: TextStyle(fontSize: 16.0, color: AppColor.searchResultsCountTextColor),
          ),
        ),
      ),
    );
  }

  Widget _buildArchivedUploadRequestSearchListWidget(
      BuildContext context, List<UploadRequestGroup> uploadRequestList) {
    return Column(children: [
      _buildResultCount(uploadRequestList.length),
      Expanded(
          child: RefreshIndicator(
              onRefresh: () async => _model.getUploadRequestArchivedStatus(),
              child: uploadRequestList.isEmpty
                  ? _buildNoResultFound()
                  : ListView.builder(
                      itemCount: uploadRequestList.length,
                      itemBuilder: (context, index) =>
                          _buildArchivedUploadTile(uploadRequestList[index]))))
    ]);
  }

  Widget _buildPendingUploadRequestSearchListWidget(
      BuildContext context, List<UploadRequestGroup> uploadRequestList) {
    return Column(children: [
      _buildResultCount(uploadRequestList.length),
      Expanded(
          child: RefreshIndicator(
              onRefresh: () async => _model.getUploadRequestCreatedStatus(),
              child: uploadRequestList.isEmpty
                  ? _buildNoResultFound()
                  : ListView.builder(
                      itemCount: uploadRequestList.length,
                      itemBuilder: (context, index) =>
                          _buildPendingUploadTile(uploadRequestList[index]))))
    ]);
  }

  Widget _buildActiveClosedSearchListWidget(
      BuildContext context, List<UploadRequestGroup> uploadRequestList) {
    return Column(children: [
      _buildResultCount(uploadRequestList.length),
      Expanded(
          child: RefreshIndicator(
              onRefresh: () async => _model.getUploadRequestActiveClosedStatus(),
              child: uploadRequestList.isEmpty
                  ? _buildNoResultFound()
                  : ListView.builder(
                      itemCount: uploadRequestList.length,
                      itemBuilder: (context, index) =>
                          _buildActiveClosedUploadTile(uploadRequestList[index]))))
    ]);
  }
}
