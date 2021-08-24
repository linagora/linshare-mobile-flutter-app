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
import 'package:linshare_flutter_app/presentation/model/file/presentation_file.dart';
import 'package:linshare_flutter_app/presentation/model/file/selectable_element.dart';
import 'package:linshare_flutter_app/presentation/model/file/upload_request_presentation_file.dart';
import 'package:linshare_flutter_app/presentation/model/item_selection_type.dart';
import 'package:linshare_flutter_app/presentation/model/upload_request_group_tab.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/ui_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_request_group_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_request_group_active_closed_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_request_group_archived_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_request_group_created_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/upload_request_group_created_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/upload_request_group_active_closed_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/upload_request_group_archived_state.dart';
import 'package:linshare_flutter_app/presentation/redux/online_thunk_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/ui_state.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/util/router/route_paths.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/context_menu_builder.dart';
import 'package:linshare_flutter_app/presentation/view/header/context_menu_header_builder.dart';
import 'package:linshare_flutter_app/presentation/view/header/more_action_bottom_sheet_header_builder.dart';
import 'package:linshare_flutter_app/presentation/view/header/simple_bottom_sheet_header_builder.dart';
import 'package:linshare_flutter_app/presentation/view/modal_sheets/confirm_modal_sheet_builder.dart';
import 'package:linshare_flutter_app/presentation/view/order_by/order_by_dialog_bottom_sheet.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_group_add_recipient/add_recipients_upload_request_group_arguments.dart';
import 'package:redux/src/store.dart';
import 'package:redux_thunk/redux_thunk.dart';

typedef OnSelectedSorter = void Function(Sorter sorter);

abstract class UploadRequestGroupTabViewModel extends BaseViewModel {
  final AppNavigation _appNavigation;
  final UpdateMultipleUploadRequestGroupStateInteractor _multipleUploadRequestGroupStateInteractor;

  UploadRequestGroupTabViewModel(
    Store<AppState> store,
    this._appNavigation,
    this._multipleUploadRequestGroupStateInteractor) : super(store);

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

  void openContextMenu(BuildContext context, UploadRequestGroup uploadRequestGroup, List<Widget> actionTiles, {Widget? footerAction}) {
    store.dispatch(_handleContextMenuAction(context, uploadRequestGroup, actionTiles, footerAction: footerAction));
  }

  ThunkAction<AppState> _handleContextMenuAction(
      BuildContext context,
      UploadRequestGroup uploadRequestGroup,
      List<Widget> actionTiles,
      {Widget? footerAction}) {
    return (Store<AppState> store) async {
      ContextMenuBuilder(context)
          .addHeader(ContextMenuHeaderBuilder(
          Key('upload_request_group_context_menu_header'),
          UploadRequestGroupPresentationFile.fromUploadRequestGroup(uploadRequestGroup)).build())
          .addTiles(actionTiles)
          .addFooter(footerAction ?? SizedBox.shrink())
          .build();
      store.dispatch(UploadRequestGroupAction(Right(UploadRequestGroupContextMenuItemViewState(uploadRequestGroup))));
    };
  }

  void goToAddRecipients(UploadRequestGroup request) {
    _appNavigation.popBack();
    _appNavigation.push(
      RoutePaths.addRecipientsUploadRequestGroup,
      arguments: AddRecipientsUploadRequestGroupArgument(request),
    );
  }

  void openMoreActionBottomMenu(BuildContext context,
    {required List<UploadRequestGroup> allSelectedGroups,
    required List<Widget> actionTiles,
    required Widget footerAction}) => ContextMenuBuilder(context)
      .addHeader(MoreActionBottomSheetHeaderBuilder(
          context,
          Key('more_action_menu_header'),
          allSelectedGroups
            .map<PresentationFile>(
              (element) => UploadRequestGroupPresentationFile.fromUploadRequestGroup(element))
            .toList())
        .build())
      .addTiles(actionTiles)
      .addFooter(footerAction)
      .build();

  void updateUploadRequestGroupStatus(
      BuildContext context,
      {required List<UploadRequestGroup> listUploadRequest,
      required UploadRequestStatus status,
      required String title,
      required UploadRequestGroupTab currentTab,
      ItemSelectionType itemSelectionType = ItemSelectionType.single,
      Function? onUpdateSuccess,
      Function? onUpdateFailed}) {
    _appNavigation.popBack();
    if (listUploadRequest.isNotEmpty) {
      ConfirmModalSheetBuilder(_appNavigation)
          .key(Key('cancel_upload_request_group_confirm_modal'))
          .title(title)
          .cancelText(AppLocalizations.of(context).cancel)
          .onConfirmAction(AppLocalizations.of(context).upload_request_cancel_proceed_button, () {
        _appNavigation.popBack();
        if (itemSelectionType == ItemSelectionType.multiple) {
          cancelSelection(currentTab);
        }
        store.dispatch(_updateUploadRequestGroupStatusAction(listUploadRequest, status,
            onUpdateSuccess: onUpdateSuccess, onUpdateFailed: onUpdateFailed));
      }).show(context);
    }
  }

  OnlineThunkAction _updateUploadRequestGroupStatusAction(
    List<UploadRequestGroup> groups,
    UploadRequestStatus status,
    {Function? onUpdateSuccess,
    Function? onUpdateFailed}) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _multipleUploadRequestGroupStateInteractor
          .execute(groups, status)
          .then((result) => result.fold(
              (failure) {
                store.dispatch(UploadRequestGroupAction(Left(failure)));
                onUpdateFailed?.call();
              },
              (success) {
                store.dispatch(UploadRequestGroupAction(Right(success)));
                //getUploadRequestCreatedStatus();
                onUpdateSuccess?.call();
          }));
    });
  }

  void cancelSelection(UploadRequestGroupTab currentTab) {
    switch(currentTab) {
      case UploadRequestGroupTab.PENDING:
        store.dispatch(UploadRequestGroupCreatedClearSelectedAction());
      break;
      case UploadRequestGroupTab.ACTIVE_CLOSED:
        store.dispatch(UploadRequestGroupActiveClosedClearSelectedAction());
      break;
      case UploadRequestGroupTab.ARCHIVED:
        store.dispatch(UploadRequestGroupArchivedClearSelectedAction());
      break;
    }
  }

  void selectItem(SelectableElement<UploadRequestGroup> selectedGroup, UploadRequestGroupTab currentTab) {
    switch(currentTab) {
      case UploadRequestGroupTab.PENDING:
        store.dispatch(UploadRequestGroupCreatedSelectAction(selectedGroup));
        break;
      case UploadRequestGroupTab.ACTIVE_CLOSED:
        store.dispatch(UploadRequestGroupActiveClosedSelectAction(selectedGroup));
        break;
      case UploadRequestGroupTab.ARCHIVED:
        store.dispatch(UploadRequestGroupArchivedSelectAction(selectedGroup));
        break;
    }
  }

  void toggleSelectAllGroups(UploadRequestGroupTab currentTab) {
    switch(currentTab) {
      case UploadRequestGroupTab.PENDING:
        if (store.state.createdUploadRequestGroupState.isAllCreatedGroupsSelected()) {
          store.dispatch(UploadRequestGroupCreatedUnSelectAllAction());
        } else {
          store.dispatch(UploadRequestGroupCreatedSelectAllAction());
        }
        break;
      case UploadRequestGroupTab.ACTIVE_CLOSED:
        if (store.state.activeClosedUploadRequestGroupState.isAllActiveClosedGroupsSelected()) {
          store.dispatch(UploadRequestGroupActiveClosedUnSelectAllAction());
        } else {
          store.dispatch(UploadRequestGroupActiveClosedSelectAllAction());
        }
        break;
      case UploadRequestGroupTab.ARCHIVED:
        if (store.state.archivedUploadRequestGroupState.isAllArchivedGroupsSelected()) {
          store.dispatch(UploadRequestGroupArchivedUnSelectAllAction());
        } else {
          store.dispatch(UploadRequestGroupArchivedSelectAllAction());
        }
        break;
    }
  }

}