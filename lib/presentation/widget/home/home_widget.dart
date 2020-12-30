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

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/ui_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/ui_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/router/route_paths.dart';
import 'package:linshare_flutter_app/presentation/widget/myspace/my_space_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space/file_surfing/workgroup_detail_files_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space/shared_space_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/side_menu/side_menu_widget.dart';

import 'home_viewmodel.dart';

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final homeViewModel = getIt<HomeViewModel>();
  final imagePath = getIt<AppImagePaths>();

  @override
  void dispose() {
    homeViewModel.onDisposed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: StoreConnector<AppState, UIState>(
          converter: (store) => store.state.uiState,
          distinct: true,
          builder: (context, uiState) => Text(
            getAppBarTitle(uiState),
            style: TextStyle(fontSize: 24, color: Colors.white))
        ),
        centerTitle: true,
        backgroundColor: AppColor.primaryColor,
        leading: IconButton(
            icon: SvgPicture.asset(imagePath.icLinShareMenu),
            onPressed: () => _scaffoldKey.currentState.openDrawer()),
      ),
      drawer: SideMenuDrawerWidget(),
      body: StoreConnector<AppState, UIState>(
        converter: (store) => store.state.uiState,
        distinct: true,
        builder: (context, uiState) => getHomeWidget(uiState)
      ),
    );
  }

  String getAppBarTitle(UIState uiState) {
    switch (uiState.routePath) {
      case RoutePaths.mySpace:
        return AppLocalizations.of(context).my_space_title;
      case RoutePaths.sharedSpace:
        return AppLocalizations.of(context).shared_space;
      case RoutePaths.sharedSpaceInside:
        return uiState.sharedSpace.name;
      default:
        return AppLocalizations.of(context).my_space_title;
    }
  }

  Widget getHomeWidget(UIState uiState) {
    switch (uiState.routePath) {
      case RoutePaths.mySpace:
        return getIt<MySpaceWidget>();
      case RoutePaths.sharedSpace:
        return getIt<SharedSpaceWidget>();
      case RoutePaths.sharedSpaceInside:
        return WorkGroupDetailFilesWidget(
          uiState.sharedSpace,
          () { // Back to shared spaces screen
            homeViewModel.store.dispatch(SetCurrentView(RoutePaths.sharedSpace));
          },
        );
      default:
        return getIt<MySpaceWidget>();
    }
  }
}
