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

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/ui_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/network_connectivity_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/ui_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/upload_file_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/router/route_paths.dart';
import 'package:linshare_flutter_app/presentation/util/toast_message_handler.dart';
import 'package:linshare_flutter_app/presentation/widget/account_details/account_details_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/home/home_app_bar/home_app_bar_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/myspace/my_space_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/received/received_share_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space/shared_space_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_document_navigator_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/side_menu/side_menu_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_group/upload_request_group_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/upload_request_inside_navigator_widget.dart';

import 'home_viewmodel.dart';

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final homeViewModel = getIt<HomeViewModel>();
  final imagePath = getIt<AppImagePaths>();
  final _toastMessageHandler = getIt<ToastMessageHandler>();

  @override
  void initState() {
    super.initState();
    _toastMessageHandler.setup(context);
  }

  @override
  void dispose() {
    homeViewModel.onDisposed();
    _toastMessageHandler.cancelSubscription();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: HomeAppBarWidget(
        key: Key('home_app_bar'),
        scaffoldKey: _scaffoldKey,
        onCancelSearchPressed: () => homeViewModel.cancelSearchState(),
        onNewSearchQuery: (String searchQuery) => homeViewModel.search(searchQuery)),
      drawer: SideMenuDrawerWidget(),
      body: Column(
        children: [
          StoreConnector<AppState, NetworkConnectivityState>(
              converter: (store) => store.state.networkConnectivityState,
              builder: (context, data) => _buildNetworkConnectionWidget(context, data)
          ),
          StoreConnector<AppState, UploadFileState>(
              converter: (store) => store.state.uploadFileState,
              builder: (context, data) => handleUploadWidget(context, data)
          ),
          Expanded(
            child: StoreConnector<AppState, UIState>(
                converter: (store) => store.state.uiState,
                distinct: true,
                builder: (context, uiState) => getHomeWidget(uiState)
            ),
          ),
        ],
      ),
    );
  }

  Widget getHomeWidget(UIState uiState) {
    switch (uiState.routePath) {
      case RoutePaths.mySpace:
        return getIt<MySpaceWidget>();
      case RoutePaths.sharedSpace:
        return getIt<SharedSpaceWidget>();
      case RoutePaths.sharedSpaceInside:
        return SharedSpaceDocumentNavigatorWidget(
          Key('shared_space_document_navigator_widget_key'),
          uiState.selectedSharedSpace!,
          onBackSharedSpaceClickedCallback: () => homeViewModel.store.dispatch(SetCurrentView(RoutePaths.sharedSpace))
        );
      case RoutePaths.account_details:
        return getIt<AccountDetailsWidget>();
      case RoutePaths.received_shares:
        return getIt<ReceivedShareWidget>();
      case RoutePaths.uploadRequestGroup:
        return getIt<UploadRequestGroupWidget>();
      case RoutePaths.uploadRequestInside:
        return UploadRequestNavigatorWidget(
            Key('upload_request_navigator_widget_key'),
            uiState.uploadRequestGroup!,
            onBackUploadRequestClickedCallback: () => homeViewModel.store.dispatch(SetCurrentView(RoutePaths.uploadRequestGroup))
        );
      default:
        return getIt<MySpaceWidget>();
    }
  }

  Widget handleUploadWidget(BuildContext context, UploadFileState uploadFileState) {
    if (uploadFileState.isUploadingFiles) {
      return Container(
        height: 58,
        color: AppColor.mySpaceUploadBackground,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Text(
                  AppLocalizations.of(context).uploading_files_status_title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: FlatButton(
                    onPressed: () => homeViewModel.clickViewCurrentUploads(),
                    padding: EdgeInsets.only(left: 16, right: 16),
                    child: Text(
                      AppLocalizations.of(context).uploading_files_view_button,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return SizedBox.shrink();
  }

  Widget _buildNetworkConnectionWidget(BuildContext context, NetworkConnectivityState networkConnectivityState) {
    if (networkConnectivityState.connectivityResult == ConnectivityResult.none) {
      return Container(
          color: AppColor.networkConnectionBackgroundColor,
          height: 54.0,
          child: Stack(
            children: [
              Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      AppLocalizations.of(context).can_not_connect_network,
                      style: TextStyle(fontSize: 14.0, color: Colors.white),
                    ),
                  )),
            ],
          ));
    }
    return SizedBox.shrink();
  }
}
