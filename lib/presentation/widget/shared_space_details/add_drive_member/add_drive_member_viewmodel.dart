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
import 'package:linshare_flutter_app/presentation/redux/actions/shared_space_details_action.dart';
import 'package:linshare_flutter_app/presentation/redux/online_thunk_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_details/add_drive_member/add_drive_member_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_details/add_drive_member/add_member_destination.dart';
import 'package:redux/redux.dart';

class AddDriveMemberViewModel extends BaseViewModel {
  final AppNavigation _appNavigation;
  final GetSharedSpaceInteractor _getSharedSpaceInteractor;
  final GetAllSharedSpaceMembersInteractor _getAllDriveMembersInteractor;
  final GetAutoCompleteSharingInteractor _getAutoCompleteSharingInteractor;
  final AddSharedSpaceMemberInteractor _addSharedSpaceMemberInteractor;
  final GetAllSharedSpaceRolesInteractor _getAllSharedSpaceRolesInteractor;

  AddDriveMemberArguments? _arguments;

  AddDriveMemberViewModel(
      Store<AppState> store,
      this._appNavigation,
      this._getSharedSpaceInteractor,
      this._getAllDriveMembersInteractor,
      this._getAutoCompleteSharingInteractor,
      this._addSharedSpaceMemberInteractor,
      this._getAllSharedSpaceRolesInteractor,
  ) : super(store);

  void initState(AddDriveMemberArguments? arguments) {
    _arguments = arguments;
    if (_arguments != null) {
      if (_arguments!.destination == AddMemberDestination.sharedSpaceDetail) {
        store.dispatch(AddDriveMemberGetDriveAction(Right(SharedSpaceDetailViewState(_arguments!.drive))));
        store.dispatch(AddDriveMemberGetAllDriveMembersAction(Right(SharedSpaceMembersViewState(_arguments!.members ?? []))));
        store.dispatch(_getAllDriveRolesAction(_arguments!.drive.sharedSpaceId));
      } else {
        store.dispatch(_getDriveAndAllMemberAction(_arguments!.drive.sharedSpaceId));
      }
    }
  }

  OnlineThunkAction _getAllDriveRolesAction(SharedSpaceId sharedSpaceId) {
    return OnlineThunkAction((Store<AppState> store) async {
      await Future.wait([
        _getAllSharedSpaceRolesInteractor.execute(type: LinShareNodeType.DRIVE),
        _getAllSharedSpaceRolesInteractor.execute(type: LinShareNodeType.WORK_GROUP),
      ]).then((responses) {

        final driveRoles = responses.first
            .map((success) => success is SharedSpaceRolesViewState ? success.roles : List<SharedSpaceRole>.empty())
            .getOrElse(() => List<SharedSpaceRole>.empty());
        final workgroupRoles = responses.last
            .map((success) => success is SharedSpaceRolesViewState ? success.roles : List<SharedSpaceRole>.empty())
            .getOrElse(() => List<SharedSpaceRole>.empty());

        store.dispatch(AddDriveMemberGetAllRolesAction(driveRoles, workgroupRoles));
      });
    });
  }

  OnlineThunkAction _getDriveAndAllMemberAction(SharedSpaceId sharedSpaceId) {
    return OnlineThunkAction((Store<AppState> store) async {

      store.dispatch(StartAddDriveMemberLoadingAction());

      await Future.wait([
        _getSharedSpaceInteractor.execute(sharedSpaceId),
        _getAllDriveMembersInteractor.execute(sharedSpaceId),
        _getAllSharedSpaceRolesInteractor.execute(type: LinShareNodeType.DRIVE),
        _getAllSharedSpaceRolesInteractor.execute(type: LinShareNodeType.WORK_GROUP),
      ]).then((responses) {
        store.dispatch(AddDriveMemberGetDriveAction(responses[0]));
        store.dispatch(AddDriveMemberGetAllDriveMembersAction(responses[1]));

        final driveRoles = responses[2]
          .map((success) => success is SharedSpaceRolesViewState ? success.roles : List<SharedSpaceRole>.empty())
          .getOrElse(() => List<SharedSpaceRole>.empty());
        final workgroupRoles = responses[3]
          .map((success) => success is SharedSpaceRolesViewState ? success.roles : List<SharedSpaceRole>.empty())
          .getOrElse(() => List<SharedSpaceRole>.empty());

        store.dispatch(AddDriveMemberGetAllRolesAction(driveRoles, workgroupRoles));
      });
    });
  }

  void selectDriveRole(SharedSpaceRoleName role) {
    store.dispatch(AddDriveMemberSetDriveRoleAction(role));
    _appNavigation.popBack();
  }

  void selectWorkgroupRole(SharedSpaceRoleName role) {
    store.dispatch(AddDriveMemberSetWorkgroupRoleAction(role));
    _appNavigation.popBack();
  }

  void addDriveMember(SharedSpaceId sharedSpaceId, SharedSpaceMemberAutoCompleteResult autoCompleteResult) {
    store.dispatch(_addDriveMemberAction(sharedSpaceId, AccountId(autoCompleteResult.userUuid.uuid)));
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

  OnlineThunkAction _addDriveMemberAction(SharedSpaceId sharedSpaceId, AccountId accountId) {
    return OnlineThunkAction((Store<AppState> store) async {
      final driveRolesList = store.state.addDriveMemberState.driveRoleList;
      final workgroupRolesList = store.state.addDriveMemberState.workgroupRoleList;
      if (driveRolesList.isEmpty || workgroupRolesList.isEmpty) {
        store.dispatch(AddDriveMemberAction(Left(AddSharedSpaceMemberFailure(RolesListNotFound()))));
        return;
      }

      final selectedDriveRole = store.state.addDriveMemberState.selectedDriveRole;
      final selectedWorkgroupRole = store.state.addDriveMemberState.selectedWorkgroupRole;

      final roleDrive = driveRolesList.firstWhere((element) => element.name == selectedDriveRole, orElse: () => SharedSpaceRole.initialDrive());
      final roleWorkgroup = workgroupRolesList.firstWhere((element) => element.name == selectedWorkgroupRole, orElse: () => SharedSpaceRole.initial());
      if (roleDrive.sharedSpaceRoleId.uuid.isEmpty || roleWorkgroup.sharedSpaceRoleId.uuid.isEmpty) {
        store.dispatch(AddDriveMemberAction(Left(AddSharedSpaceMemberFailure(SelectedRoleNotFound()))));
        return;
      }

      await _addSharedSpaceMemberInteractor
        .execute(sharedSpaceId, AddSharedSpaceMemberRequest(
            accountId,
            sharedSpaceId,
            roleDrive.sharedSpaceRoleId,
            type: LinShareNodeType.DRIVE,
            nestedRole: roleWorkgroup.sharedSpaceRoleId))
        .then((result) => result.fold(
          (failure) => store.dispatch(AddDriveMemberAction(Left(AddSharedSpaceMemberFailure(AddMemberFailed())))),
          (success) => _refreshListDriveMember(sharedSpaceId)));
    });
  }

  void _refreshListDriveMember(SharedSpaceId sharedSpaceId) {
    store.dispatch(_getDriveMembersAction(sharedSpaceId));
  }

  OnlineThunkAction _getDriveMembersAction(SharedSpaceId sharedSpaceId) {
    return OnlineThunkAction((Store<AppState> store) async {
      final memberViewState = await _getAllDriveMembersInteractor.execute(sharedSpaceId);
      store.dispatch(AddDriveMemberGetAllDriveMembersAction(memberViewState));
      if (_arguments?.destination == AddMemberDestination.sharedSpaceDetail) {
        store.dispatch(SharedSpaceDetailsGetAllDriveMembersAction(memberViewState));
      }
    });
  }

  void backToSharedSpacesDetails() {
    store.dispatch(CleanAddDriveMemberStateAction());
    _appNavigation.popBack();
  }

  @override
  void onDisposed() {
    store.dispatch(CleanAddDriveMemberStateAction());
    super.onDisposed();
  }
}