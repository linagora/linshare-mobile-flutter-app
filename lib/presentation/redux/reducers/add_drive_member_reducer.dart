// LinShare is an open source filesharing software, part of the LinPKI software
// suite, developed by Linagora.
//
// Copyright (C) 2021 LINAGORA
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
//

import 'package:domain/domain.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/add_drive_member_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/add_drive_member_state.dart';
import 'package:redux/redux.dart';

final addDriveMemberReducer = combineReducers<AddDriveMemberState>([
  TypedReducer<AddDriveMemberState, StartAddDriveMemberLoadingAction>((AddDriveMemberState state, _) =>
      state.startLoadingState()),
  TypedReducer<AddDriveMemberState, AddDriveMemberAction>((AddDriveMemberState state, AddDriveMemberAction action) =>
      state.sendViewState(viewState: action.viewState)),
  TypedReducer<AddDriveMemberState, AddDriveMemberGetAllDriveMembersAction>((AddDriveMemberState state, AddDriveMemberGetAllDriveMembersAction action) =>
      state.setDriveMembers(
          newMembers: action.getMembersViewState.fold(
              (failure) => [],
              (success) => (success is SharedSpaceMembersViewState) ? success.members : []),
          viewState: action.getMembersViewState)),
  TypedReducer<AddDriveMemberState, AddDriveMemberGetDriveAction>((AddDriveMemberState state, AddDriveMemberGetDriveAction action) =>
      state.setDrive(
          newDrive: action.getDriveViewState.fold(
              (failure) => null,
              (success) => (success is SharedSpaceDetailViewState) ? success.sharedSpace : null),
          viewState: action.getDriveViewState)),
  TypedReducer<AddDriveMemberState, AddDriveMemberSetDriveRoleAction>((AddDriveMemberState state, AddDriveMemberSetDriveRoleAction action) =>
      state.setDriveRoleName(action.newDriveRole)),
  TypedReducer<AddDriveMemberState, AddDriveMemberSetWorkgroupRoleAction>((AddDriveMemberState state, AddDriveMemberSetWorkgroupRoleAction action) =>
      state.setWorkgroupRoleName(action.newWorkgroupRole)),
  TypedReducer<AddDriveMemberState, AddDriveMemberGetAllRolesAction>((AddDriveMemberState state, AddDriveMemberGetAllRolesAction action) =>
      state.setListRoles(newDriveRoles: action.driveRoles, newWorkgroupRoles: action.workgroupRoles)),
  TypedReducer<AddDriveMemberState, CleanAddDriveMemberStateAction>((AddDriveMemberState state, CleanAddDriveMemberStateAction action) =>
      state.clearViewState()),
]);