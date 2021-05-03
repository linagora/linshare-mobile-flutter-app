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
import 'package:linshare_flutter_app/presentation/model/file/work_group_document_presentation_file.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/shared_space_node_versions_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/context_menu_builder.dart';
import 'package:linshare_flutter_app/presentation/view/header/context_menu_header_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_node_versions/shared_space_node_versions_arguments.dart';
import 'package:redux/redux.dart';
import 'package:linshare_flutter_app/presentation/redux/online_thunk_action.dart';

class SharedSpaceNodeVersionsViewModel extends BaseViewModel {
  final AppNavigation _appNavigation;
  final GetAllChildNodesInteractor _getAllChildNodesInteractor;
  final RestoreWorkGroupDocumentVersionInteractor _restoreWorkGroupDocumentVersionInteractor;

  SharedSpaceNodeVersionsViewModel(
    Store<AppState> store,
    this._appNavigation,
    this._getAllChildNodesInteractor,
    this._restoreWorkGroupDocumentVersionInteractor
  ) : super(store);

  void initState(SharedSpaceNodeVersionsArguments arguments) {
    getAllVersions(arguments.workGroupNode);
  }

  void backToMyWorkGroupNodesList() {
    _appNavigation.popBack();
  }

  void getAllVersions(WorkGroupNode workGroupNode) {
    store.dispatch(_getSharedSpaceNodeVersionsAction(workGroupNode));
  }

  OnlineThunkAction _getSharedSpaceNodeVersionsAction(WorkGroupNode workGroupNode) {
    return OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(SharedSpaceNodeVersionsSetWorkGroupNodeVersionsAction(
          await _getAllChildNodesInteractor.execute(
            workGroupNode.sharedSpaceId,
            parentId: workGroupNode.workGroupNodeId)));
    });
  }

  void openContextMenu(
    BuildContext context,
    WorkGroupDocument document,
    List<Widget> actionTiles,
    {Widget footerAction}
  ) {
    ContextMenuBuilder(context)
        .addHeader(ContextMenuHeaderBuilder(Key('context_menu_header'),
                WorkGroupDocumentPresentationFile.fromWorkGroupDocument(document))
            .build())
        .addTiles(actionTiles)
        .addFooter(footerAction)
        .build();
  }

  void restoreAction(WorkGroupDocument document, WorkGroupNode parentNode) {
    store.dispatch(_restoreDocumentAction(document, parentNode));
    _appNavigation.popBack();
  }

  OnlineThunkAction _restoreDocumentAction(WorkGroupDocument document, WorkGroupNode parentNode) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _restoreWorkGroupDocumentVersionInteractor
          .execute(document.toCopyRequest(), document.sharedSpaceId, parentId: document.parentWorkGroupNodeId)
          .then((result) => result.fold((failure) {
                store.dispatch(SharedSpaceNodeVersionsAction(Left(failure)));
              }, (success) {
                store.dispatch(SharedSpaceNodeVersionsAction(Right(success)));
              }));
      store.dispatch(_getSharedSpaceNodeVersionsAction(parentNode));
    });
  }

  @override
  void onDisposed() {
    store.dispatch(CleanSharedSpaceNodeVersionsStateAction());
    super.onDisposed();
  }
}