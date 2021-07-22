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
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_request_group_action.dart';
import 'package:linshare_flutter_app/presentation/redux/online_thunk_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/util/router/route_paths.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/context_menu_builder.dart';
import 'package:linshare_flutter_app/presentation/view/header/simple_bottom_sheet_header_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_creation/upload_request_creation_arguments.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

class UploadRequestGroupViewModel extends BaseViewModel {
  final AppNavigation _appNavigation;
  final GetAllUploadRequestGroupsInteractor _getAllUploadRequestGroupsInteractor;

  UploadRequestGroupViewModel(
      Store<AppState> store, this._appNavigation, this._getAllUploadRequestGroupsInteractor)
      : super(store);

  void initState() {
    getUploadRequestCreatedStatus();
    getUploadRequestActiveClosedStatus();
    getUploadRequestArchivedStatus();
  }

  void getUploadRequestCreatedStatus() {
    store.dispatch(OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(StartUploadRequestGroupLoadingAction());
      store.dispatch(UploadRequestGroupGetAllCreatedAction(
          await _getAllUploadRequestGroupsInteractor.execute([UploadRequestStatus.CREATED])));
    }));
  }

  void getUploadRequestActiveClosedStatus() {
    store.dispatch(OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(StartUploadRequestGroupLoadingAction());
      store.dispatch(UploadRequestGroupGetAllActiveClosedAction(
          await _getAllUploadRequestGroupsInteractor
              .execute([UploadRequestStatus.ENABLED, UploadRequestStatus.CLOSED])));
    }));
  }

  void getUploadRequestArchivedStatus() {
    store.dispatch(OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(StartUploadRequestGroupLoadingAction());
      store.dispatch(UploadRequestGroupGetAllArchivedAction(
          await _getAllUploadRequestGroupsInteractor.execute([UploadRequestStatus.ARCHIVED])));
    }));
  }

  void openUploadRequestAddMenu(BuildContext context, List<Widget> actionTiles) {
    store.dispatch(_handleUploadRequestAddMenuAction(context, actionTiles));
  }

  ThunkAction<AppState> _handleUploadRequestAddMenuAction(BuildContext context, List<Widget> actionTiles) {
    return (Store<AppState> store) async {
      ContextMenuBuilder(context, areTilesHorizontal: true)
          .addHeader(SimpleBottomSheetHeaderBuilder(Key('add_upload_request_bottom_sheet_header_builder'))
          .addLabel(AppLocalizations.of(context).add_new_upload_request)
          .build())
          .addTiles(actionTiles)
          .build();
    };
  }

  void addNewUploadRequest(UploadRequestCreationType type) {
    _appNavigation.popBack();
    _appNavigation.push(
      RoutePaths.createUploadRequest,
      arguments: UploadRequestCreationArguments(type),
    );
  }

  @override
  void onDisposed() {
    super.onDisposed();
  }
}
