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

import 'package:dartz/dartz.dart';
import 'package:domain/domain.dart';
import 'package:flutter/widgets.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/ui_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_request_group_action.dart';
import 'package:linshare_flutter_app/presentation/redux/online_thunk_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/ui_state.dart';
import 'package:linshare_flutter_app/presentation/util/router/route_paths.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/context_menu_builder.dart';
import 'package:linshare_flutter_app/presentation/view/header/simple_bottom_sheet_header_builder.dart';
import 'package:linshare_flutter_app/presentation/view/order_by/order_by_dialog_bottom_sheet.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:redux/src/store.dart';

typedef OnSelectedSorter = void Function(Sorter sorter);

abstract class UploadRequestGroupTabViewModel extends BaseViewModel {
  UploadRequestGroupTabViewModel(Store<AppState> store) : super(store);

  void openPopupMenuSorter(BuildContext context, Sorter currentSorter, OnSelectedSorter selectSorterAction) {
    ContextMenuBuilder(context)
      .addHeader(SimpleBottomSheetHeaderBuilder(Key('order_by_menu_header')).addLabel(AppLocalizations.of(context).order_by).build())
      .addTiles(OrderByDialogBottomSheetBuilder(context, currentSorter).onSelectSorterAction((sorterSelected) =>
        selectSorterAction.call(sorterSelected)).build())
      .build();
  }

  void getListUploadRequests(UploadRequestGroup requestGroup) {
    store.dispatch(OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(DisableSearchStateAction());
      store.dispatch(UploadRequestGroupAction(Right(DisableSearchViewState())));
      store.dispatch(UploadRequestInsideView(RoutePaths.uploadRequestInside, requestGroup));
    }));
  }

  bool isInSearchState() {
    return store.state.uiState.isInSearchState();
  }

}