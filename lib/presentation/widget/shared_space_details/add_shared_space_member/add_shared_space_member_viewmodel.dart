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
import 'package:linshare_flutter_app/presentation/redux/actions/add_shared_space_members_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/delete_shared_space_members_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/shared_space_details_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/update_shared_space_members_action.dart';
import 'package:linshare_flutter_app/presentation/redux/online_thunk_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:redux/redux.dart';

class AddSharedSpaceMemberViewModel extends BaseViewModel {
  final AppNavigation _appNavigation;
  final GetSharedSpaceInteractor _getSharedSpaceInteractor;
  final GetAutoCompleteSharingInteractor _getAutoCompleteSharingInteractor;
  final AddSharedSpaceMemberInteractor _addSharedSpaceMemberInteractor;
  final UpdateSharedSpaceMemberInteractor _updateSharedSpaceMemberInteractor;
  final GetAllSharedSpaceMembersInteractor _getAllSharedSpaceMembersInteractor;
  final SharedSpaceActivitiesInteractor _sharedSpaceActivitiesInteractor;
  final DeleteSharedSpaceMemberInteractor _deleteSharedSpaceMemberInteractor;

  AddSharedSpaceMemberViewModel(
      Store<AppState> store,
      this._appNavigation,
      this._getSharedSpaceInteractor,
      this._getAutoCompleteSharingInteractor,
      this._addSharedSpaceMemberInteractor,
      this._updateSharedSpaceMemberInteractor,
      this._getAllSharedSpaceMembersInteractor,
      this._sharedSpaceActivitiesInteractor,
      this._deleteSharedSpaceMemberInteractor
  ) : super(store);

  void initState() {
  }

  void backToSharedSpacesDetails() {
    _appNavigation.popBack();
  }

  void selectRole(SharedSpaceRoleName role) {
    store.dispatch(AddSharedSpaceMembersSetRoleAction(role));
    _appNavigation.popBack();
  }

  void addSharedSpaceMember(SharedSpaceNodeNested sharedSpace,
      SharedSpaceMemberAutoCompleteResult autoCompleteResult) {
    store.dispatch(
        _addSharedSpaceAction(
            sharedSpace,
            AccountId(autoCompleteResult.userUuid.uuid)));
  }

  void changeMemberRole(SharedSpaceNodeNested sharedSpace,
      SharedSpaceMember fromMember, SharedSpaceRoleName changeToRole) {
    store.dispatch(
        _updateSharedSpaceMemberRoleAction(
            sharedSpace,
            AccountId(fromMember.account?.accountId.uuid ?? ''),
            changeToRole));
    _appNavigation.popBack();
  }

  void deleteMember(SharedSpaceNodeNested sharedSpace, SharedSpaceMemberId sharedSpaceMemberId) {
    store.dispatch(_deleteSharedSpaceMemberAction(sharedSpace, sharedSpaceMemberId));
    _appNavigation.popBack();
  }

  Future<List<AutoCompleteResult>> getAutoCompleteSharing(
      String pattern, SharedSpaceNodeNested sharedSpace, List<SharedSpaceMember> members) async {
    return await _getAutoCompleteSharingInteractor
        .execute(AutoCompletePattern(pattern), AutoCompleteType.THREAD_MEMBERS,
            threadId: ThreadId(sharedSpace.sharedSpaceId.uuid))
        .then(
          (viewState) => viewState.fold(
            (failure) => <AutoCompleteResult>[],
            (success) => (success as AutoCompleteViewState)
                .results
                .where((user) => !members
                    .map((member) => member.account?.mail)
                    .contains(user.getSuggestionMail()))
                .toList(),
          ),
        );
  }

  OnlineThunkAction _addSharedSpaceAction(SharedSpaceNodeNested sharedSpace, AccountId accountId) {
    return OnlineThunkAction((Store<AppState> store) async {
      final rolesList = store.state.sharedSpaceState.rolesList;
      if (rolesList.isEmpty) {
        store.dispatch(AddSharedSpaceMembersAction(
            Left<Failure, Success>(AddSharedSpaceMemberFailure(RolesListNotFound()))));
        return;
      }

      final selectedRole = store.state.addSharedSpaceMembersState.selectedRole;
      final role = rolesList.firstWhere((element) => element.name == selectedRole, orElse: () => SharedSpaceRole.initial());
      if (role.sharedSpaceRoleId.uuid.isEmpty) {
        store.dispatch(AddSharedSpaceMembersAction(
            Left<Failure, Success>(AddSharedSpaceMemberFailure(SelectedRoleNotFound()))));
        return;
      }

      await _addSharedSpaceMemberInteractor
          .execute(sharedSpace.sharedSpaceId, AddSharedSpaceMemberRequest(accountId, sharedSpace.sharedSpaceId, role.sharedSpaceRoleId))
          .then((result) => result.fold(
              (failure) => store.dispatch(AddSharedSpaceMembersAction(Left<Failure, Success>(AddSharedSpaceMemberFailure(AddMemberFailed())))),
              (success) {
                _getAllMember(sharedSpace);
                store.dispatch(_getSharedSpaceActivitiesAction(sharedSpace.sharedSpaceId));
              }));
    });
  }

  OnlineThunkAction _updateSharedSpaceMemberRoleAction(
      SharedSpaceNodeNested sharedSpace, AccountId accountId, SharedSpaceRoleName newRole) {
    return OnlineThunkAction((Store<AppState> store) async {
      final rolesList = store.state.sharedSpaceState.rolesList;
      if (rolesList.isEmpty) {
        store.dispatch(UpdateSharedSpaceMembersAction(
            Left<Failure, Success>(UpdateSharedSpaceMemberFailure(RolesListNotFound()))));
        return;
      }

      final role = rolesList.firstWhere((_role) => _role.name == newRole, orElse: () => SharedSpaceRole.initial());
      if (role.sharedSpaceRoleId.uuid.isEmpty) {
        store.dispatch(UpdateSharedSpaceMembersAction(
            Left<Failure, Success>(UpdateSharedSpaceMemberFailure(SelectedRoleNotFound()))));
        return;
      }

      await _updateSharedSpaceMemberInteractor
          .execute(sharedSpace.sharedSpaceId, UpdateSharedSpaceMemberRequest(accountId, sharedSpace.sharedSpaceId, role.sharedSpaceRoleId))
          .then((result) => result.fold(
              (failure) => store.dispatch(UpdateSharedSpaceMembersAction(
                  Left<Failure, Success>(UpdateSharedSpaceMemberFailure(UpdateRoleFailed())))),
              (success) {
                store.dispatch(_refreshSharedSpaceAction(sharedSpace));
                _getAllMember(sharedSpace);
                store.dispatch(_getSharedSpaceActivitiesAction(sharedSpace.sharedSpaceId));
              }));
    });
  }

  void _getAllMember(SharedSpaceNodeNested sharedSpaceNodeNested) {
    if (sharedSpaceNodeNested.parentId != null) {
      store.dispatch(_getDriveMembersAction(sharedSpaceNodeNested.parentId!));
    }
    store.dispatch(_getSharedSpaceMembersAction(sharedSpaceNodeNested.sharedSpaceId));
  }

  OnlineThunkAction _refreshSharedSpaceAction(SharedSpaceNodeNested sharedSpace) {
    return OnlineThunkAction((Store<AppState> store) async {
      final sharedSpaceViewState = await _getSharedSpaceInteractor.execute(sharedSpace.sharedSpaceId);
      store.dispatch(SharedSpaceDetailsGetSharedSpaceDetailsAction(sharedSpaceViewState));
    });
  }

  OnlineThunkAction _getSharedSpaceMembersAction(SharedSpaceId sharedSpaceId) {
    return OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(SharedSpaceDetailsGetAllSharedSpaceMembersAction(
          await _getAllSharedSpaceMembersInteractor.execute(sharedSpaceId)));
    });
  }

  OnlineThunkAction _getDriveMembersAction(SharedSpaceId parentId) {
    return OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(StartSharedSpaceDetailsLoadingAction());

      await _getAllSharedSpaceMembersInteractor.execute(parentId)
        .then((result) => result.fold(
          (failure) => store.dispatch(GetAllDriveMembersInsideWorkgroupDetailAction([])),
          (success) => store.dispatch(GetAllDriveMembersInsideWorkgroupDetailAction(
            success is SharedSpaceMembersViewState ? success.members : []))));
    });
  }

  OnlineThunkAction _getSharedSpaceActivitiesAction(SharedSpaceId sharedSpaceId) {
    return OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(SharedSpaceDetailsGetAllSharedSpaceActivitesAction(await _sharedSpaceActivitiesInteractor.execute(sharedSpaceId)));
    });
  }

  OnlineThunkAction _deleteSharedSpaceMemberAction(
      SharedSpaceNodeNested sharedSpace,
      SharedSpaceMemberId sharedSpaceMemberId) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _deleteSharedSpaceMemberInteractor
        .execute(sharedSpace.sharedSpaceId, sharedSpaceMemberId)
        .then((result) => result.fold(
          (failure) => store.dispatch(DeleteSharedSpaceMembersAction(Left<Failure, Success>(DeleteSharedSpaceMemberFailure(DeleteMemberFailed())))),
          (success) {
            store.dispatch(DeleteSharedSpaceMembersAction(Right(success)));
            _getAllMember(sharedSpace);
            store.dispatch(_getSharedSpaceActivitiesAction(sharedSpace.sharedSpaceId));
          }));
    });
  }

  @override
  void onDisposed() {
    store.dispatch(CleanAddSharedSpaceMembersStateAction());
    store.dispatch(CleanUpdateSharedSpaceMembersStateAction());
    store.dispatch(CleanDeleteSharedSpaceMembersStateAction());
    super.onDisposed();
  }

}
