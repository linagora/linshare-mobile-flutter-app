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
import 'package:linshare_flutter_app/presentation/model/versioning_state.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/delete_shared_space_members_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/shared_space_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/shared_space_details_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/update_shared_space_members_action.dart';
import 'package:linshare_flutter_app/presentation/redux/online_thunk_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/util/router/route_paths.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_details/add_drive_member/add_drive_member_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_details/add_drive_member/add_member_destination.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_details/shared_space_details_arguments.dart';
import 'package:redux/redux.dart';

import 'add_shared_space_member/add_shared_space_member_arguments.dart';

class SharedSpaceDetailsViewModel extends BaseViewModel {
  final AppNavigation _appNavigation;
  final GetSharedSpaceInteractor _getSharedSpaceInteractor;
  final GetQuotaInteractor _getQuotaInteractor;
  final GetAllSharedSpaceMembersInteractor _getAllSharedSpaceMembersInteractor;
  final SharedSpaceActivitiesInteractor _sharedSpaceActivitiesInteractor;
  final GetAllSharedSpaceRolesInteractor _getAllSharedSpaceRolesInteractor;
  final UpdateSharedSpaceMemberInteractor _updateSharedSpaceMemberInteractor;
  final DeleteSharedSpaceMemberInteractor _deleteSharedSpaceMemberInteractor;
  final EnableVersioningWorkgroupInteractor _enableVersioningWorkgroupInteractor;

  SharedSpaceDetailsViewModel(
    Store<AppState> store,
    this._appNavigation,
    this._getSharedSpaceInteractor,
    this._getQuotaInteractor,
    this._getAllSharedSpaceMembersInteractor,
    this._sharedSpaceActivitiesInteractor,
    this._getAllSharedSpaceRolesInteractor,
    this._updateSharedSpaceMemberInteractor,
    this._deleteSharedSpaceMemberInteractor,
    this._enableVersioningWorkgroupInteractor,
  ) : super(store);

  void initState(SharedSpaceDetailsArguments arguments) {
    refreshSharedSpaceMembers(arguments.sharedSpace.sharedSpaceId);
    store.dispatch(_getSharedSpaceAction(arguments.sharedSpace));
    if (arguments.sharedSpace.nodeType == LinShareNodeType.WORK_GROUP) {
      store.dispatch(_getSharedSpaceActivitiesAction(arguments.sharedSpace.sharedSpaceId));
      store.dispatch(_getSharedSpaceRolesAction());
    }
  }

  void backToSharedSpacesList() {
    _appNavigation.popBack();
  }

  void refreshSharedSpaceMembers(SharedSpaceId? sharedSpaceId) {
    if(sharedSpaceId == null) {
      return;
    }
    store.dispatch(_getSharedSpaceMembersAction(sharedSpaceId));
  }

  void goToAddSharedSpaceMember(SharedSpaceNodeNested sharedSpace, List<SharedSpaceMember> members) {
    _appNavigation.push(
      RoutePaths.addSharedSpaceMember,
      arguments: AddSharedSpaceMemberArgument(sharedSpace, members),
    );
  }

  void goToAddDriveMember(SharedSpaceNodeNested drive, List<SharedSpaceMember> members) {
    _appNavigation.push(
      RoutePaths.addDriveMember,
      arguments: AddDriveMemberArguments(drive, AddMemberDestination.sharedSpaceDetail, members: members),
    );
  }

  void changeMemberRole(SharedSpaceId sharedSpaceId, SharedSpaceMember fromMember, SharedSpaceRoleName changeToRole) {
    store.dispatch(_updateSharedSpaceMemberRoleAction(sharedSpaceId, AccountId(fromMember.account?.accountId.uuid ?? ''), changeToRole));
    _appNavigation.popBack();
  }

  void deleteMember(SharedSpaceId sharedSpaceId, SharedSpaceMemberId sharedSpaceMemberId) {
    store.dispatch(_deleteSharedSpaceMemberAction(sharedSpaceId, sharedSpaceMemberId));
    _appNavigation.popBack();
  }

  OnlineThunkAction _getSharedSpaceMembersAction(SharedSpaceId sharedSpaceId) {
    return OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(StartSharedSpaceDetailsLoadingAction());
      store.dispatch(SharedSpaceDetailsGetAllSharedSpaceMembersAction(await _getAllSharedSpaceMembersInteractor.execute(sharedSpaceId)));
    });
  }

  OnlineThunkAction _getSharedSpaceActivitiesAction(SharedSpaceId sharedSpaceId) {
    return OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(SharedSpaceDetailsGetAllSharedSpaceActivitesAction(await _sharedSpaceActivitiesInteractor.execute(sharedSpaceId)));
    });
  }

  OnlineThunkAction _getSharedSpaceAction(SharedSpaceNodeNested sharedSpace) {
    return OnlineThunkAction((Store<AppState> store) async {
      final sharedSpaceViewState = await _getSharedSpaceInteractor.execute(sharedSpace.sharedSpaceId);
      store.dispatch(SharedSpaceDetailsGetSharedSpaceDetailsAction(sharedSpaceViewState));

      if (sharedSpace.nodeType == LinShareNodeType.WORK_GROUP) {
        await sharedSpaceViewState.fold((_) => null, (success) async {
          if (success is SharedSpaceDetailViewState) {
            store.dispatch(SharedSpaceDetailsGetAccountQuotaAction(await _getQuotaInteractor.execute(success.sharedSpace.quotaId)));
          }
        });
      }
    });
  }

  OnlineThunkAction _getSharedSpaceRolesAction() {
    return OnlineThunkAction((Store<AppState> store) async {
      final roles = (await _getAllSharedSpaceRolesInteractor.execute())
          .map((result) => result is SharedSpaceRolesViewState ? result.roles : <SharedSpaceRole>[])
          .getOrElse(() => <SharedSpaceRole>[]);

      store.dispatch(SharedSpaceGetSharedSpaceRolesListAction(roles));
    });
  }

  OnlineThunkAction _updateSharedSpaceMemberRoleAction(
      SharedSpaceId sharedSpaceId, AccountId accountId, SharedSpaceRoleName newRole) {
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
          .execute(sharedSpaceId,
              UpdateSharedSpaceMemberRequest(accountId, sharedSpaceId, role.sharedSpaceRoleId))
          .then((result) => result.fold(
              (failure) => store.dispatch(UpdateSharedSpaceMembersAction(
                  Left<Failure, Success>(UpdateSharedSpaceMemberFailure(UpdateRoleFailed())))),
              (success) {
                store.dispatch(_getSharedSpaceMembersAction(sharedSpaceId));
              }));
    });
  }

  OnlineThunkAction _deleteSharedSpaceMemberAction(
      SharedSpaceId sharedSpaceId,
      SharedSpaceMemberId sharedSpaceMemberId) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _deleteSharedSpaceMemberInteractor
          .execute(sharedSpaceId, sharedSpaceMemberId)
          .then((result) => result.fold(
              (failure) => store.dispatch(DeleteSharedSpaceMembersAction(
                  Left<Failure, Success>(DeleteSharedSpaceMemberFailure(DeleteMemberFailed())))),
              (success) {
                store.dispatch(DeleteSharedSpaceMembersAction(Right(success)));
                store.dispatch(_getSharedSpaceMembersAction(sharedSpaceId));
              }));
    });
  }

  void enableVersioningForWorkgroup(SharedSpaceNodeNested sharedSpaceNodeNested, VersioningState versioningState) {
    final newVersioningParameter = VersioningParameter(versioningState == VersioningState.ENABLE);
    store.dispatch(_enableVersioningForWorkgroupAction(
        sharedSpaceNodeNested.sharedSpaceId,
        sharedSpaceNodeNested.sharedSpaceRole,
        EnableVersioningWorkGroupRequest(
          sharedSpaceNodeNested.name,
          newVersioningParameter,
          sharedSpaceNodeNested.nodeType)
    ));
  }

  OnlineThunkAction _enableVersioningForWorkgroupAction(
      SharedSpaceId sharedSpaceId,
      SharedSpaceRole sharedSpaceRole,
      EnableVersioningWorkGroupRequest enableVersioningRequest
  ) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _enableVersioningWorkgroupInteractor
        .execute(sharedSpaceId, sharedSpaceRole, enableVersioningRequest)
        .then((result) => result.fold(
          (failure) => null,
          (success) => success is EnableVersioningWorkGroupViewState
            ? store.dispatch(SharedSpaceDetailsEnableVersioningAction(success.sharedSpaceNodeNested))
            : null));
    });
  }

  @override
  void onDisposed() {
    store.dispatch(CleanSharedSpaceDetailsStateAction());
    store.dispatch(CleanUpdateSharedSpaceMembersStateAction());
    store.dispatch(CleanDeleteSharedSpaceMembersStateAction());
    super.onDisposed();
  }

}
