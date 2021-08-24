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
import 'package:linshare_flutter_app/presentation/model/file/selectable_element.dart';
import 'package:linshare_flutter_app/presentation/model/upload_request_group_tab.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/upload_request_group_active_closed_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/view/common/common_view.dart';
import 'package:linshare_flutter_app/presentation/view/common/upload_request_group_common_view.dart';
import 'package:linshare_flutter_app/presentation/view/common/upload_request_group_tile_builder.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/simple_context_menu_action_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_group/active_closed/active_closed_upload_request_group_viewmodel.dart';
import 'package:redux/redux.dart';
import 'package:linshare_flutter_app/presentation/redux/states/ui_state.dart';
import 'package:linshare_flutter_app/presentation/view/order_by/order_by_button.dart';

class ActiveClosedUploadRequestGroupWidget extends StatefulWidget {
  ActiveClosedUploadRequestGroupWidget({Key? key}) : super(key: key);

  @override
  _ActiveClosedUploadRequestGroupWidgetState createState() => _ActiveClosedUploadRequestGroupWidgetState();
}

class _ActiveClosedUploadRequestGroupWidgetState extends State<ActiveClosedUploadRequestGroupWidget>
    with AutomaticKeepAliveClientMixin {
  final _model = getIt<ActiveClosedUploadRequestGroupViewModel>();
  final imagePath = getIt<AppImagePaths>();
  final _uploadRequestWidgetCommon = getIt<UploadRequestGroupCommonView>();
  final _widgetCommon = getIt<CommonView>();

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
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StoreConnector<AppState, bool>(
      converter: (store) => store.state.uiState.isInSearchState(),
      builder: (context, isInSearchState) =>
        isInSearchState ? _buildSearchViewWidget(context) : _buildDefaultViewWidget());
  }

  Widget _buildDefaultViewWidget() {
    return StoreConnector<AppState, ActiveClosedUploadRequestGroupState>(
      converter: (store) => store.state.activeClosedUploadRequestGroupState,
      builder: (_, state) => Column(children: [
        _buildMultipleSelectionTopBar(),
        _buildMenuSorterActiveClosed(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _model.getUploadRequestActiveClosedStatus(),
            child: _buildListData(state.uploadRequestsActiveClosedList, state.selectMode))),
        (state.selectMode == SelectMode.ACTIVE && state.getAllSelectedActiveClosedGroups().isNotEmpty)
            ? _uploadRequestWidgetCommon.buildMultipleSelectionBottomBar(
            context,
            allSelectedGroups: state.getAllSelectedActiveClosedGroups(),
            actionWidgets: _multipleSelectionActions(state.getAllSelectedActiveClosedGroups()))
            : SizedBox.shrink()
      ]));
  }

  Widget _buildMultipleSelectionTopBar() {
    return StoreConnector<AppState, ActiveClosedUploadRequestGroupState>(
        converter: (store) => store.state.activeClosedUploadRequestGroupState,
        builder: (context, state) {
          final isAllItemSelected = state.isAllActiveClosedGroupsSelected();
          return state.selectMode == SelectMode.ACTIVE
              ? ListTile(
              leading: SvgPicture.asset(imagePath.icSelectAll,
                  width: 28, height: 28, fit: BoxFit.fill, color: isAllItemSelected ? AppColor.unselectedElementColor : AppColor.primaryColor),
              title: Transform(
                  transform: Matrix4.translationValues(-16, 0.0, 0.0),
                  child: isAllItemSelected
                      ? Text(AppLocalizations.of(context).unselect_all,
                      maxLines: 1, style: TextStyle(fontSize: 14, color: AppColor.documentNameItemTextColor))
                      : Text(AppLocalizations.of(context).select_all,
                      maxLines: 1, style: TextStyle(fontSize: 14, color: AppColor.documentNameItemTextColor))),
              tileColor: AppColor.topBarBackgroundColor,
              onTap: () {
                return _model.toggleSelectAllGroups(UploadRequestGroupTab.ACTIVE_CLOSED);
              },
              trailing: TextButton(
                  onPressed: () => _model.cancelSelection(UploadRequestGroupTab.ACTIVE_CLOSED),
                  child: Text(AppLocalizations.of(context).cancel, maxLines: 1, style: TextStyle(fontSize: 14, color: AppColor.primaryColor))))
              : SizedBox.shrink();
        });
  }

  Widget _buildMenuSorterActiveClosed() {
    return StoreConnector<AppState, AppState>(
      converter: (Store<AppState> store) => store.state,
      builder: (context, appState) {
        return !appState.uiState.isInSearchState()
          ? OrderByButtonBuilder(context, appState.activeClosedUploadRequestGroupState.activeClosedSorter)
            .onOpenOrderMenuAction((currentSorter) => _model.openPopupMenuSorterActiveClosed(context, currentSorter))
            .build()
          : SizedBox.shrink();
      },
    );
  }

  Widget _buildListData(List<SelectableElement<UploadRequestGroup>> uploadRequestList, SelectMode selectMode) {
    if (uploadRequestList.isEmpty) {
      return _uploadRequestWidgetCommon.buildCreateUploadRequestsHere(context, imagePath.icCreateUploadRequest);
    } else {
      return ListView.builder(
        itemCount: uploadRequestList.length,
        itemBuilder: (context, index) => _buildActiveClosedUploadTile(uploadRequestList[index], selectMode));
    }
  }

  Widget _buildActiveClosedUploadTile(SelectableElement<UploadRequestGroup> request, SelectMode selectMode) {
    return UploadRequestGroupTileBuilder(
      Key('active_closed_upload_request_tile'),
      context,
      uploadRequestGroup: request,
      selectMode: selectMode,
      subTitleWidget: _buildActiveClosedSubtitleWidget(request.element.status),
      onSelectModeChangeCallback: () => _model.selectItem(request, UploadRequestGroupTab.ACTIVE_CLOSED),
      onTileLongPressCallback: () => _model.selectItem(request, UploadRequestGroupTab.ACTIVE_CLOSED),
      onTileTapCallback: () {
        if (selectMode == SelectMode.ACTIVE) {
          _model.selectItem(request, UploadRequestGroupTab.ACTIVE_CLOSED);
        } else {
          _model.getListUploadRequests(request.element);
        }
      },
      onMenuOptionPressCallback: () => _model.openContextMenu(
          context,
          request.element,
          _contextMenuActionTiles(request.element),
          footerAction: SizedBox.shrink())
    ).build();
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

  Widget _buildSearchViewWidget(BuildContext context) {
    return StoreConnector<AppState, ActiveClosedUploadRequestGroupState>(
      converter: (store) => store.state.activeClosedUploadRequestGroupState,
      builder: (_, state) {
        if (_model.searchQuery.value.isEmpty) {
          return SizedBox.shrink();
        }
        if (state.uploadRequestsActiveClosedList.isEmpty) {
          return _widgetCommon.buildNoResultFound(context);
        }
        return Column(children: [
          _buildMultipleSelectionTopBar(),
          _widgetCommon.buildResultCountRow(context, state.uploadRequestsActiveClosedList.length),
          Expanded(child: _buildListData(state.uploadRequestsActiveClosedList, state.selectMode)),
          (state.selectMode == SelectMode.ACTIVE && state.getAllSelectedActiveClosedGroups().isNotEmpty)
              ? _uploadRequestWidgetCommon.buildMultipleSelectionBottomBar(
              context,
              allSelectedGroups: state.getAllSelectedActiveClosedGroups(),
              actionWidgets: _multipleSelectionActions(state.getAllSelectedActiveClosedGroups()))
              : SizedBox.shrink()
        ]);
      });
  }

  List<Widget> _contextMenuActionTiles(UploadRequestGroup uploadRequestGroup) {
    return [
      if(uploadRequestGroup.status == UploadRequestStatus.ENABLED) _addRecipientsAction(uploadRequestGroup)
    ];
  }

  List<Widget> _multipleSelectionActions(List<UploadRequestGroup> allSelectedGroups) {
    return [
      _uploadRequestWidgetCommon.moreActionMultipleSelection(allSelectedGroups, () {
        _model.openMoreActionBottomMenu(context,
            allSelectedGroups: allSelectedGroups,
            actionTiles: _moreActionList(allSelectedGroups),
            footerAction: SizedBox.shrink());
      }),
    ];
  }

  List<Widget> _moreActionList(List<UploadRequestGroup> groups) {
    return [];
  }

  Widget _addRecipientsAction(UploadRequestGroup uploadRequestGroup) {
    return SimpleContextMenuActionBuilder(
        Key('add_recipients_context_menu_action'),
        SvgPicture.asset(imagePath.icAddMember,
            width: 24, height: 24, fit: BoxFit.fill),
        AppLocalizations.of(context).add_recipients)
        .onActionClick((_) => _model.goToAddRecipients(uploadRequestGroup))
        .build();
  }

}
