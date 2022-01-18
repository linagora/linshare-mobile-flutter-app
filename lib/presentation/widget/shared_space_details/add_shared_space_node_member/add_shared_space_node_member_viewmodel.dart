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
import 'package:linshare_flutter_app/presentation/redux/actions/add_drive_member_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/delete_shared_space_members_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/shared_space_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/shared_space_details_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/update_shared_space_members_action.dart';
import 'package:linshare_flutter_app/presentation/redux/online_thunk_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_details/add_shared_space_node_member/add_member_destination.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_details/add_shared_space_node_member/add_shared_space_node_member_arguments.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/linshare_node_type_extension.dart';
import 'package:redux/redux.dart';

class AddSharedSpaceNodeMemberViewModel extends BaseViewModel {
  final AppNavigation _appNavigation;
  final GetSharedSpaceInteractor _getSharedSpaceInteractor;
  final GetAllSharedSpaceMembersInteractor _getAllSharedSpaceMembersInteractor;
  final GetAutoCompleteSharingInteractor _getAutoCompleteSharingInteractor;
  final AddSharedSpaceMemberInteractor _addSharedSpaceMemberInteractor;
  final GetAllSharedSpaceRolesInteractor _getAllSharedSpaceRolesInteractor;
  final DeleteSharedSpaceMemberInteractor _deleteSharedSpaceMemberInteractor;
  final UpdateDriveMemberInteractor _updateDriveMemberInteractor;
  final UpdateWorkspaceMemberInteractor _updateWorkspaceMemberInteractor;

  AddSharedSpaceNodeMemberArguments? _arguments;

  AddSharedSpaceNodeMemberViewModel(
      Store<AppState> store,
      this._appNavigation,
      this._getSharedSpaceInteractor,
      this._getAllSharedSpaceMembersInteractor,
      this._getAutoCompleteSharingInteractor,
      this._addSharedSpaceMemberInteractor,
      this._getAllSharedSpaceRolesInteractor,
      this._deleteSharedSpaceMemberInteractor,
      this._updateDriveMemberInteractor,
      this._updateWorkspaceMemberInteractor,
  ) : super(store);

  void initState(AddSharedSpaceNodeMemberArguments? arguments) {
    _arguments = arguments;
    if (_arguments != null) {
      if (_arguments!.destination == AddMemberDestination.sharedSpaceDetail) {
        store.dispatch(AddSharedSpaceNodeMemberGetNodeNestedAction(Right(SharedSpaceDetailViewState(_arguments!.nodeNested))));
        store.dispatch(AddSharedSpaceNodeMemberGetAllSharedSpaceNodeMembersAction(Right(SharedSpaceMembersViewState(_arguments!.members ?? []))));
        store.dispatch(_getAllRolesAction(
            _arguments!.nodeNested.nodeType!, _arguments!.nodeNested.sharedSpaceId));
      } else {
        store.dispatch(_getSharedSpaceNodeAndAllMemberAction(
            _arguments!.nodeNested.nodeType!, _arguments!.nodeNested.sharedSpaceId));
      }
    }
  }

  OnlineThunkAction _getAllRolesAction(LinShareNodeType nodeType, SharedSpaceId sharedSpaceId) {
    return OnlineThunkAction((Store<AppState> store) async {
      await Future.wait([
        _getAllSharedSpaceRolesInteractor.execute(type: nodeType),
        _getAllSharedSpaceRolesInteractor.execute(type: LinShareNodeType.WORK_GROUP),
      ]).then((responses) {

        final nodeNestedRoles = responses.first
            .map((success) => success is SharedSpaceRolesViewState ? success.roles : List<SharedSpaceRole>.empty())
            .getOrElse(() => List<SharedSpaceRole>.empty());
        final workgroupRoles = responses.last
            .map((success) => success is SharedSpaceRolesViewState ? success.roles : List<SharedSpaceRole>.empty())
            .getOrElse(() => List<SharedSpaceRole>.empty());

        store.dispatch(AddSharedSpaceNodeMemberGetAllRolesAction(nodeNestedRoles, workgroupRoles));
        store.dispatch(AddSharedSpaceNodeMemberSetNodeNestedRoleAction(nodeType.getDefaultSharedSpaceRole().name));
      });
    });
  }

  OnlineThunkAction _getSharedSpaceNodeAndAllMemberAction(LinShareNodeType nodeType, SharedSpaceId sharedSpaceId) {
    return OnlineThunkAction((Store<AppState> store) async {

      store.dispatch(StartAddSharedSpaceNodeMemberLoadingAction());

      await Future.wait([
        _getSharedSpaceInteractor.execute(sharedSpaceId),
        _getAllSharedSpaceMembersInteractor.execute(sharedSpaceId),
        _getAllSharedSpaceRolesInteractor.execute(type: nodeType),
        _getAllSharedSpaceRolesInteractor.execute(type: LinShareNodeType.WORK_GROUP),
      ]).then((responses) {
        store.dispatch(AddSharedSpaceNodeMemberGetNodeNestedAction(responses[0]));
        store.dispatch(AddSharedSpaceNodeMemberGetAllSharedSpaceNodeMembersAction(responses[1]));

        final nodeNestedRoles = responses[2]
          .map((success) => success is SharedSpaceRolesViewState ? success.roles : List<SharedSpaceRole>.empty())
          .getOrElse(() => List<SharedSpaceRole>.empty());
        final workgroupRoles = responses[3]
          .map((success) => success is SharedSpaceRolesViewState ? success.roles : List<SharedSpaceRole>.empty())
          .getOrElse(() => List<SharedSpaceRole>.empty());

        store.dispatch(AddSharedSpaceNodeMemberGetAllRolesAction(nodeNestedRoles, workgroupRoles));
        store.dispatch(AddSharedSpaceNodeMemberSetNodeNestedRoleAction(nodeType.getDefaultSharedSpaceRole().name));
      });
    });
  }

  void selectNodeNestedRole(SharedSpaceRoleName role) {
    store.dispatch(AddSharedSpaceNodeMemberSetNodeNestedRoleAction(role));
    _appNavigation.popBack();
  }

  void selectWorkgroupRole(SharedSpaceRoleName role) {
    store.dispatch(AddSharedSpaceNodeMemberSetWorkgroupRoleAction(role));
    _appNavigation.popBack();
  }

  void addSharedSpaceNodeMember(SharedSpaceId sharedSpaceId,
      LinShareNodeType nodeType, SharedSpaceMemberAutoCompleteResult autoCompleteResult) {
    store.dispatch(_addSharedSpaceNodeMemberAction(sharedSpaceId, AccountId(autoCompleteResult.userUuid.uuid), nodeType));
  }

  Future<List<AutoCompleteResult>> getAutoCompleteSharing(
      String pattern, SharedSpaceNodeNested drive, List<SharedSpaceMember> members) async {
    return await _getAutoCompleteSharingInteractor
      .execute(AutoCompletePattern(pattern), AutoCompleteType.THREAD_MEMBERS, threadId: ThreadId(drive.sharedSpaceId.uuid))
      .then((viewState) => viewState.fold(
        (failure) => <AutoCompleteResult>[],
        (success) => (success as AutoCompleteViewState).results
          .where((user) => !members
              .map((member) => member.account?.mail)
              .contains(user.getSuggestionMail()))
          .toList()));
  }

  OnlineThunkAction _addSharedSpaceNodeMemberAction(SharedSpaceId sharedSpaceId,
      AccountId accountId, LinShareNodeType nodeType) {
    return OnlineThunkAction((Store<AppState> store) async {
      final nodeNestedRoleList = store.state.addSharedSpaceNodeMemberState.nodeNestedRoleList;
      final workgroupRolesList = store.state.addSharedSpaceNodeMemberState.workgroupRoleList;
      if (nodeNestedRoleList.isEmpty || workgroupRolesList.isEmpty) {
        store.dispatch(AddSharedSpaceNodeMemberAction(Left(AddSharedSpaceMemberFailure(RolesListNotFound()))));
        return;
      }

      final selectedNodeNestedRole = store.state.addSharedSpaceNodeMemberState.selectedNodeNestedRole;
      final selectedWorkgroupRole = store.state.addSharedSpaceNodeMemberState.selectedWorkgroupRole;

      final roleNodeNested = nodeNestedRoleList.firstWhere((element) => element.name == selectedNodeNestedRole, orElse: () => nodeType.getDefaultSharedSpaceRole());
      final roleWorkgroup = workgroupRolesList.firstWhere((element) => element.name == selectedWorkgroupRole, orElse: () => SharedSpaceRole.initial());
      if (roleNodeNested.sharedSpaceRoleId.uuid.isEmpty || roleWorkgroup.sharedSpaceRoleId.uuid.isEmpty) {
        store.dispatch(AddSharedSpaceNodeMemberAction(Left(AddSharedSpaceMemberFailure(SelectedRoleNotFound()))));
        return;
      }

      await _addSharedSpaceMemberInteractor
        .execute(sharedSpaceId, AddSharedSpaceMemberRequest(
            accountId,
            sharedSpaceId,
            roleNodeNested.sharedSpaceRoleId,
            type: nodeType,
            nestedRole: roleWorkgroup.sharedSpaceRoleId))
        .then((result) => result.fold(
          (failure) => store.dispatch(AddSharedSpaceNodeMemberAction(Left(AddSharedSpaceMemberFailure(AddMemberFailed())))),
          (success) => _refreshListMember(sharedSpaceId)));
    });
  }

  void _refreshListMember(SharedSpaceId sharedSpaceId) {
    store.dispatch(_getListMembersAction(sharedSpaceId));
  }

  OnlineThunkAction _getListMembersAction(SharedSpaceId sharedSpaceId) {
    return OnlineThunkAction((Store<AppState> store) async {
      final memberViewState = await _getAllSharedSpaceMembersInteractor.execute(sharedSpaceId);
      store.dispatch(AddSharedSpaceNodeMemberGetAllSharedSpaceNodeMembersAction(memberViewState));
      if (_arguments?.destination == AddMemberDestination.sharedSpaceDetail) {
        store.dispatch(SharedSpaceDetailsGetAllSharedSpaceNodeMembersAction(memberViewState));
      }
    });
  }

  void deleteMember(SharedSpaceId sharedSpaceId, SharedSpaceMemberId sharedSpaceMemberId) {
    store.dispatch(_deleteDriveMemberAction(sharedSpaceId, sharedSpaceMemberId));
    _appNavigation.popBack();
  }

  OnlineThunkAction _deleteDriveMemberAction(
      SharedSpaceId sharedSpaceId,
      SharedSpaceMemberId sharedSpaceMemberId
  ) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _deleteSharedSpaceMemberInteractor.execute(sharedSpaceId, sharedSpaceMemberId)
        .then((result) => result.fold(
          (failure) => store.dispatch(DeleteSharedSpaceMembersAction(Left(DeleteSharedSpaceMemberFailure(DeleteMemberFailed())))),
          (success) {
            store.dispatch(DeleteSharedSpaceMembersAction(Right(success)));
            store.dispatch(SharedSpaceAction(Right(success)));
            _refreshListMember(sharedSpaceId);
          }));
    });
  }

  void changeSharedSpaceNodeMemberRole(SharedSpaceNodeNested nodeNested,
      SharedSpaceMember fromMember, SharedSpaceRoleName changeToRole, LinShareNodeType nodeType) {
    store.dispatch(_updateSharedSpaceNodeMemberRoleAction(
        nodeNested,
        AccountId(fromMember.account?.accountId.uuid ?? ''),
        changeToRole,
        fromMember.nestedRole?.name ?? SharedSpaceRoleName.READER,
        nodeType));
    _appNavigation.popBack();
  }

  OnlineThunkAction _updateSharedSpaceNodeMemberRoleAction(
      SharedSpaceNodeNested nodeNested, AccountId accountId,
      SharedSpaceRoleName newRole, SharedSpaceRoleName nestedRoleName,
      LinShareNodeType nodeType, {bool? isOverrideRoleForAll}) {
    return OnlineThunkAction((Store<AppState> store) async {
      final nodeNestedRoleList = store.state.addSharedSpaceNodeMemberState.nodeNestedRoleList;
      final rolesList = store.state.addSharedSpaceNodeMemberState.workgroupRoleList;
      if (rolesList.isEmpty || nodeNestedRoleList.isEmpty) {
        switch(nodeType) {
          case LinShareNodeType.DRIVE:
            store.dispatch(UpdateDriveMembersAction(Left(UpdateDriveMemberFailure(RolesListNotFound()))));
            break;
          case LinShareNodeType.WORK_GROUP:
            store.dispatch(UpdateSharedSpaceMembersAction(Left(UpdateSharedSpaceMemberFailure(RolesListNotFound()))));
            break;
          case LinShareNodeType.WORK_SPACE:
            store.dispatch(UpdateWorkspaceMembersAction(Left(UpdateWorkspaceMemberFailure(RolesListNotFound()))));
            break;
        }
        return;
      }

      final workgroupRole = rolesList.firstWhere((_role) => _role.name == nestedRoleName, orElse: () => SharedSpaceRole.initial());
      final roleNodeNested = nodeNestedRoleList.firstWhere((_role) => _role.name == newRole, orElse: () => nodeType.getDefaultSharedSpaceRole());
      if (roleNodeNested.sharedSpaceRoleId.uuid.isEmpty || workgroupRole.sharedSpaceRoleId.uuid.isEmpty) {
        switch(nodeType) {
          case LinShareNodeType.DRIVE:
            store.dispatch(UpdateDriveMembersAction(Left(UpdateDriveMemberFailure(SelectedRoleNotFound()))));
            break;
          case LinShareNodeType.WORK_GROUP:
            store.dispatch(UpdateSharedSpaceMembersAction(Left(UpdateSharedSpaceMemberFailure(SelectedRoleNotFound()))));
            break;
          case LinShareNodeType.WORK_SPACE:
            store.dispatch(UpdateWorkspaceMembersAction(Left(UpdateWorkspaceMemberFailure(SelectedRoleNotFound()))));
            break;
        }
        return;
      }

        if (nodeType == LinShareNodeType.DRIVE) {
          await _updateDriveMemberInteractor
              .execute(
                  nodeNested.sharedSpaceId,
                  UpdateDriveMemberRequest(
                      accountId,
                      nodeNested.sharedSpaceId,
                      roleNodeNested.sharedSpaceRoleId,
                      workgroupRole.sharedSpaceRoleId,
                      nodeType),
                  isOverrideRoleForAll: isOverrideRoleForAll)
              .then((result) => result.fold(
                  (failure) => store.dispatch(UpdateDriveMembersAction(Left(UpdateDriveMemberFailure(UpdateRoleFailed())))),
                  (success) {
                    store.dispatch(SharedSpaceAction(Right(success)));
                    _refreshListMember(nodeNested.sharedSpaceId);
                  }));
        } else if (nodeType == LinShareNodeType.WORK_SPACE) {
          await _updateWorkspaceMemberInteractor
              .execute(
                  nodeNested.sharedSpaceId,
                  UpdateWorkspaceMemberRequest(
                      accountId,
                      nodeNested.sharedSpaceId,
                      roleNodeNested.sharedSpaceRoleId,
                      workgroupRole.sharedSpaceRoleId,
                      nodeType),
                  isOverrideRoleForAll: isOverrideRoleForAll)
              .then((result) => result.fold(
                  (failure) => store.dispatch(UpdateWorkspaceMembersAction(Left(UpdateWorkspaceMemberFailure(UpdateRoleFailed())))),
                  (success) {
                    store.dispatch(SharedSpaceAction(Right(success)));
                    _refreshListMember(nodeNested.sharedSpaceId);
                  }));
        }
    });
  }

  void changeWorkgroupInsideDriveMemberRole(SharedSpaceNodeNested nodeNested,
      SharedSpaceMember fromMember, SharedSpaceRoleName changeToRole,
      LinShareNodeType nodeType, {bool? isOverrideRoleForAll}) {
    store.dispatch(_updateSharedSpaceNodeMemberRoleAction(
        nodeNested,
        AccountId(fromMember.account?.accountId.uuid ?? ''),
        fromMember.role?.name ?? nodeType.getDefaultSharedSpaceRole().name,
        changeToRole,
        nodeType,
        isOverrideRoleForAll: isOverrideRoleForAll));
    _appNavigation.popBack();
  }

  void backToSharedSpacesDetails() {
    store.dispatch(CleanAddSharedSpaceNodeMemberStateAction());
    _appNavigation.popBack();
  }

  @override
  void onDisposed() {
    store.dispatch(CleanAddSharedSpaceNodeMemberStateAction());
    super.onDisposed();
  }
}