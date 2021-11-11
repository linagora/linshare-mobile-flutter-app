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
//

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/app_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/ui_state.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/util/router/route_paths.dart';
import 'package:linshare_flutter_app/presentation/widget/home/home_arguments.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:redux/src/store.dart';

@immutable
class SetCurrentView extends ActionOffline {
  final String routePath;

  SetCurrentView(this.routePath);
}

class SharedSpaceInsideView extends SetCurrentView {
  final SharedSpaceNodeNested? drive;
  final SharedSpaceNodeNested sharedSpace;

  SharedSpaceInsideView(String routePath, this.sharedSpace, {this.drive}) : super(routePath);
}

class WorkgroupView extends SetCurrentView {
  final SharedSpaceNodeNested drive;

  WorkgroupView(String routePath, this.drive) : super(routePath);
}

@immutable
class ClearCurrentView extends ActionOffline {
  ClearCurrentView();
}

ThunkAction<AppState> initializeHomeView(AppNavigation appNavigation, Uri baseUrl) {
  return (Store<AppState> store) async {
    store.dispatch(SetCurrentView(RoutePaths.mySpace));
    await appNavigation.pushAndRemoveAll(RoutePaths.homeRoute, arguments: HomeArguments(baseUrl));
  };
}

@immutable
class EnableSearchStateAction extends ActionOffline {
  final SearchDestination searchDestination;
  final String destinationName;

  EnableSearchStateAction(this.searchDestination, this.destinationName);
}

@immutable
class DisableSearchStateAction extends ActionOffline {}

class UploadRequestInsideView extends SetCurrentView {
  final UploadRequestGroup uploadRequestGroup;

  UploadRequestInsideView(String routePath, this.uploadRequestGroup) : super(routePath);
}

@immutable
class UIStateSetUploadRequestGroupIndexAction extends ActionOffline {
  final int newIndex;

  UIStateSetUploadRequestGroupIndexAction(this.newIndex);
}

@immutable
class OutsideAppAction extends ActionOffline {
  final ActionOutsideAppType outsideAppType;

  OutsideAppAction({required this.outsideAppType});
}

@immutable
class InsideAppAction extends ActionOffline {
  final ActionInsideAppType actionInsideAppType;

  InsideAppAction({required this.actionInsideAppType});
}