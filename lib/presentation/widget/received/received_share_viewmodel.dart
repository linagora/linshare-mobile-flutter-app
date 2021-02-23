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

import 'package:dartz/dartz.dart';
import 'package:domain/domain.dart';
import 'package:flutter/widgets.dart';
import 'package:linshare_flutter_app/presentation/model/file/share_presentation_file.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/received_share_action.dart';
import 'package:linshare_flutter_app/presentation/redux/online_thunk_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/context_menu_builder.dart';
import 'package:linshare_flutter_app/presentation/view/header/context_menu_header_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:redux/src/store.dart';
import 'package:redux_thunk/redux_thunk.dart';

class ReceivedShareViewModel extends BaseViewModel {
  final GetAllReceivedSharesInteractor _getAllReceivedInteractor;
  final AppNavigation _appNavigation;
  final CopyMultipleFilesFromReceivedSharesToMySpaceInteractor _copyMultipleFilesFromReceivedSharesToMySpaceInteractor;

  ReceivedShareViewModel(
      Store<AppState> store,
      this._getAllReceivedInteractor,
      this._appNavigation,
      this._copyMultipleFilesFromReceivedSharesToMySpaceInteractor
  ) : super(store);

  void getAllReceivedShare() {
    store.dispatch(_getAllReceivedShareAction());
  }

  OnlineThunkAction _getAllReceivedShareAction() {
    return OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(StartReceivedShareLoadingAction());
      await _getAllReceivedInteractor.execute().then((result) => result.fold(
              (failure) => store.dispatch(ReceivedShareGetAllReceivedSharesAction(Left(failure))),
              (success) => store.dispatch(ReceivedShareGetAllReceivedSharesAction(Right(success))))
      );
    });
  }

  void openContextMenu(BuildContext context, ReceivedShare share, List<Widget> actionTiles, {Widget footerAction}) {
    store.dispatch(_handleContextMenuAction(context, share, actionTiles, footerAction: footerAction));
  }

  ThunkAction<AppState> _handleContextMenuAction(
      BuildContext context,
      ReceivedShare share,
      List<Widget> actionTiles,
      {Widget footerAction}) {
    return (Store<AppState> store) async {
      ContextMenuBuilder(context)
          .addHeader(ContextMenuHeaderBuilder(
            Key('context_menu_header'),
            SharePresentationFile.fromShare(share)).build())
          .addTiles(actionTiles)
          .addFooter(footerAction)
          .build();
      store.dispatch(ReceivedShareAction(Right(ReceivedShareContextMenuItemViewState(share))));
    };
  }

  void copyToMySpace(List<ReceivedShare> shares) {
    _appNavigation.popBack();
    store.dispatch(_copyToMySpaceAction(shares));
  }

  OnlineThunkAction _copyToMySpaceAction(List<ReceivedShare> shares) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _copyMultipleFilesFromReceivedSharesToMySpaceInteractor.execute(shares: shares)
        .then((result) => result.fold(
          (failure) => store.dispatch(ReceivedShareAction(Left(failure))),
          (success) => store.dispatch(ReceivedShareAction(Right(success)))));
    });
  }
}
