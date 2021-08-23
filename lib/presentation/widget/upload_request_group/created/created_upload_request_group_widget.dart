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
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/upload_request_group_created_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/view/common/common_view.dart';
import 'package:linshare_flutter_app/presentation/view/common/upload_request_group_common_view.dart';
import 'package:linshare_flutter_app/presentation/view/common/upload_request_group_tile_builder.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/simple_context_menu_action_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_group/created/created_upload_request_group_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/datetime_extension.dart';
import 'package:redux/redux.dart';
import 'package:linshare_flutter_app/presentation/redux/states/ui_state.dart';
import 'package:linshare_flutter_app/presentation/view/order_by/order_by_button.dart';

class CreatedUploadRequestGroupWidget extends StatefulWidget {
  CreatedUploadRequestGroupWidget({Key? key}) : super(key: key);

  @override
  _CreatedUploadRequestGroupWidgetState createState() => _CreatedUploadRequestGroupWidgetState();
}

class _CreatedUploadRequestGroupWidgetState extends State<CreatedUploadRequestGroupWidget>
    with AutomaticKeepAliveClientMixin {
  final _model = getIt<CreatedUploadRequestGroupViewModel>();
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
    return StoreConnector<AppState, CreatedUploadRequestGroupState>(
      converter: (store) => store.state.createdUploadRequestGroupState,
      builder: (_, state) => Column(children: [
        _buildMenuSorterPending(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _model.getUploadRequestCreatedStatus(),
            child: _buildListData(state.uploadRequestsCreatedList)))
      ]));
  }

  Widget _buildMenuSorterPending() {
    return StoreConnector<AppState, AppState>(
      converter: (Store<AppState> store) => store.state,
      builder: (context, appState) {
        return !appState.uiState.isInSearchState()
          ? OrderByButtonBuilder(context, appState.createdUploadRequestGroupState.pendingSorter)
            .onOpenOrderMenuAction((currentSorter) => _model.openPopupMenuSorterPending(context, currentSorter))
            .build()
          : SizedBox.shrink();
      },
    );
  }

  Widget _buildListData(List<SelectableElement<UploadRequestGroup>> uploadRequestList) {
    if (uploadRequestList.isEmpty) {
      return _uploadRequestWidgetCommon.buildCreateUploadRequestsHere(context, imagePath.icCreateUploadRequest);
    } else {
      return ListView.builder(
        itemCount: uploadRequestList.length,
        itemBuilder: (context, index) => _buildPendingUploadTile(uploadRequestList[index]));
    }
  }

  Widget _buildPendingUploadTile(SelectableElement<UploadRequestGroup> request) {
    return UploadRequestGroupTileBuilder(
      Key('pending_upload_request_tile'),
      context,
      uploadRequestGroup: request.element,
      subTitleWidget: Text(
        AppLocalizations.of(context).activated_date(request.element.activationDate.getMMMddyyyyFormatString()),
        style: TextStyle(fontSize: 14, color: AppColor.uploadFileFileSizeTextColor)),
      onTileTapCallback: () => _model.getListUploadRequests(request.element),
      onMenuOptionPressCallback: () => _model.openContextMenu(context, request.element, _contextMenuActionTiles(request.element)),
      onTileLongPressCallback: () {}
    ).build();
  }

  Widget _buildSearchViewWidget(BuildContext context) {
    return StoreConnector<AppState, CreatedUploadRequestGroupState>(
      converter: (store) => store.state.createdUploadRequestGroupState,
      builder: (_, state) {
        if (_model.searchQuery.value.isEmpty) {
          return SizedBox.shrink();
        }
        if (state.uploadRequestsCreatedList.isEmpty) {
          return _widgetCommon.buildNoResultFound(context);
        }
        return Column(children: [
          _widgetCommon.buildResultCountRow(context, state.uploadRequestsCreatedList.length),
          Expanded(child: _buildListData(state.uploadRequestsCreatedList))
        ]);
      });
  }

  List<Widget> _contextMenuActionTiles(UploadRequestGroup uploadRequestGroup) {
    return [
      _addRecipientsAction(uploadRequestGroup)
    ];
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
