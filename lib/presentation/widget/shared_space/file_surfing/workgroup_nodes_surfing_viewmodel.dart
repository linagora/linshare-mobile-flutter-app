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

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:domain/domain.dart';
import 'package:flutter/widgets.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/model/file/selectable_element.dart';
import 'package:linshare_flutter_app/presentation/model/file/work_group_document_presentation_file.dart';
import 'package:linshare_flutter_app/presentation/model/file/work_group_folder_presentation_file.dart';
import 'package:linshare_flutter_app/presentation/model/item_selection_type.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/shared_space_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/context_menu_builder.dart';
import 'package:linshare_flutter_app/presentation/view/header/context_menu_header_builder.dart';
import 'package:linshare_flutter_app/presentation/view/modal_sheets/confirm_modal_sheet_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space/file_surfing/workgroup_nodes_surfing_state.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space/file_surfing/workgroup_nodes_surfling_arguments.dart';
import 'package:redux/src/store.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:rxdart/rxdart.dart';

class WorkGroupNodesSurfingViewModel extends BaseViewModel {
  WorkGroupNodesSurfingViewModel(
    Store<AppState> store,
    this._appNavigation,
    this._getAllChildNodesInteractor,
    this._removeMultipleSharedSpaceNodesInteractor
  ) : super(store);

  final GetAllChildNodesInteractor _getAllChildNodesInteractor;
  final RemoveMultipleSharedSpaceNodesInteractor _removeMultipleSharedSpaceNodesInteractor;
  final AppNavigation _appNavigation;

  final BehaviorSubject<WorkGroupNodesSurfingState> _stateSubscription =
      BehaviorSubject.seeded(WorkGroupNodesSurfingState(null, [], FolderNodeType.normal));
  StreamView<WorkGroupNodesSurfingState> get stateSubscription => _stateSubscription;

  WorkGroupNodesSurfingState get currentState => _stateSubscription.value;

  void initial(WorkGroupNodesSurfingArguments input) {
    _stateSubscription.add(currentState.copyWith(
      node: input.folder,
      folderNodeType: input.folderType,
      sharedSpaceId: input.sharedSpaceNodeNested.sharedSpaceId,
    ));
  }

  void loadAllChildNodes() async {
    _stateSubscription.add(currentState.copyWith(showLoading: true));

    final isRootFolder = currentState.folderNodeType == FolderNodeType.root;
    final result = await _getAllChildNodesInteractor.execute(
      isRootFolder
          ? currentState.sharedSpaceId
          : currentState.node.sharedSpaceId,
      parentId: isRootFolder ? null : currentState.node.workGroupNodeId,
    );

    result.fold(
      (failure) {
        _stateSubscription.add(currentState.copyWith(children: [], showLoading: false));
      },
      (success) {
        _stateSubscription.add(currentState.setWorkGroupNodesList(
          (success as GetChildNodesViewState).workGroupNodes,
          showLoading: false
        ));
      },
    );
  }

  void openFolderContextMenu(BuildContext context, WorkGroupFolder workGroupFolder, List<Widget> actionTiles) {
    store.dispatch(_handleContextMenuFolderAction(context, workGroupFolder, actionTiles));
  }

  void openDocumentContextMenu(BuildContext context, WorkGroupDocument workGroupDocument, List<Widget> actionTiles, Widget footerAction) {
    store.dispatch(_handleContextMenuDocumentAction(context, workGroupDocument, actionTiles, footerAction));
  }

  ThunkAction<AppState> _handleContextMenuDocumentAction(
      BuildContext context, WorkGroupDocument workGroupDocument, List<Widget> actionTiles, Widget footerAction) {
    return (Store<AppState> store) async {
      ContextMenuBuilder(context)
        .addHeader(ContextMenuHeaderBuilder(
          Key('context_menu_header'),
          WorkGroupDocumentPresentationFile.fromWorkGroupDocument(workGroupDocument)).build())
        .addTiles(actionTiles)
        .addFooter(footerAction)
        .build();
      store.dispatch(SharedSpaceAction(Right(ContextMenuWorkGroupNodeViewState(workGroupDocument))));
    };
  }

  ThunkAction<AppState> _handleContextMenuFolderAction(
      BuildContext context, WorkGroupFolder workGroupFolder, List<Widget> actionTiles) {
    return (Store<AppState> store) async {
      ContextMenuBuilder(context)
        .addHeader(ContextMenuHeaderBuilder(
          Key('context_menu_header'),
          WorkGroupFolderPresentationFile.fromWorkGroupFolder(workGroupFolder)).build())
        .addTiles(actionTiles)
        .build();
      store.dispatch(SharedSpaceAction(Right(ContextMenuWorkGroupNodeViewState(workGroupFolder))));
    };
  }

  void removeWorkGroupNode(BuildContext context, List<WorkGroupNode> workGroupNodes,
      {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {

    if (itemSelectionType == ItemSelectionType.single) {
      _appNavigation.popBack();
    }
    final deleteTitle = workGroupNodes.length == 1
      ? AppLocalizations.of(context).are_you_sure_you_want_to_delete_file(workGroupNodes.first.name)
      : AppLocalizations.of(context).are_you_sure_you_want_to_delete_files(workGroupNodes.length);

    ConfirmModalSheetBuilder(_appNavigation)
      .key(Key('delete_work_group_node_confirm_modal'))
      .title(deleteTitle)
      .cancelText(AppLocalizations.of(context).cancel)
      .onConfirmAction(AppLocalizations.of(context).delete, () {
        _appNavigation.popBack();
      if (itemSelectionType == ItemSelectionType.multiple) {
        cancelSelection();
      }
      store.dispatch(_removeWorkGroupNodeAction(workGroupNodes));
    }).show(context);
  }

  ThunkAction<AppState> _removeWorkGroupNodeAction(List<WorkGroupNode> workGroupNodes) {
    return (Store<AppState> store) async {
      await _removeMultipleSharedSpaceNodesInteractor.execute(workGroupNodes)
        .then((result) => result.fold(
          (failure) => store.dispatch(SharedSpaceAction(Left(failure))),
          (success) => store.dispatch(SharedSpaceAction(Right(success)))));
      loadAllChildNodes();
    };
  }

  void toggleSelectAllWorkGroupNodes() {
    if (_stateSubscription.value.isAllDocumentsSelected()) {
      _stateSubscription.add(currentState.unselectAllWorkGroupNodes());
    } else {
      _stateSubscription.add(currentState.selectAllWorkGroupNodes());
    }
  }

  void cancelSelection() {
    _stateSubscription.add(currentState.cancelSelectedWorkGroupNodes());
    store.dispatch(EnableUploadButtonAction());
  }

  void selectItem(SelectableElement<WorkGroupNode> selectedWorkGroupNode) {
    _stateSubscription.add(currentState.selectWorkGroupNode(selectedWorkGroupNode));
    store.dispatch(DisableUploadButtonAction());
  }
}
