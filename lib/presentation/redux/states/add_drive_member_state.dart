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
//

import 'package:dartz/dartz.dart';
import 'package:domain/domain.dart';
import 'package:domain/src/state/failure.dart';
import 'package:domain/src/state/success.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:linshare_flutter_app/presentation/redux/states/linshare_state.dart';

@immutable
class AddDriveMemberState extends LinShareState with EquatableMixin {
  final SharedSpaceNodeNested? drive;
  final List<SharedSpaceMember> membersList;
  final List<SharedSpaceRole> driveRoleList;
  final List<SharedSpaceRole> workgroupRoleList;
  final SharedSpaceRoleName selectedDriveRole;
  final SharedSpaceRoleName selectedWorkgroupRole;

  AddDriveMemberState(
      Either<Failure, Success> viewState, this.drive,
      this.membersList,
      this.driveRoleList,
      this.workgroupRoleList,
      this.selectedDriveRole,
      this.selectedWorkgroupRole,
  ) : super(viewState);

  factory AddDriveMemberState.initial() {
    return AddDriveMemberState(Right(IdleState()), null, [], [], [], SharedSpaceRoleName.DRIVE_READER, SharedSpaceRoleName.READER);
  }

  @override
  AddDriveMemberState clearViewState() {
    return AddDriveMemberState(Right(IdleState()), null, [], [], [], SharedSpaceRoleName.DRIVE_READER, SharedSpaceRoleName.READER);
  }

  @override
  AddDriveMemberState sendViewState(
      {required Either<Failure, Success> viewState}) {
    return AddDriveMemberState(viewState, drive, membersList, driveRoleList, workgroupRoleList, selectedDriveRole, selectedWorkgroupRole);
  }

  @override
  AddDriveMemberState startLoadingState() {
    return AddDriveMemberState(Right(LoadingState()), drive, membersList, driveRoleList, workgroupRoleList, selectedDriveRole, selectedWorkgroupRole);
  }

  AddDriveMemberState setDriveMembers(
      {required Either<Failure, Success> viewState, required List<SharedSpaceMember> newMembers}) {
    return AddDriveMemberState(viewState, drive, newMembers, driveRoleList, workgroupRoleList, selectedDriveRole, selectedWorkgroupRole);
  }

  AddDriveMemberState setDrive({required Either<Failure,
      Success> viewState, SharedSpaceNodeNested? newDrive}) {
    return AddDriveMemberState(viewState, newDrive, membersList, driveRoleList, workgroupRoleList, selectedDriveRole, selectedWorkgroupRole);
  }

  AddDriveMemberState setDriveRoleName(SharedSpaceRoleName newDriveRole) {
    return AddDriveMemberState(viewState, drive, membersList, driveRoleList, workgroupRoleList, newDriveRole, selectedWorkgroupRole);
  }

  AddDriveMemberState setWorkgroupRoleName(SharedSpaceRoleName newWorkgroupRole) {
    return AddDriveMemberState(viewState, drive, membersList, driveRoleList, workgroupRoleList, selectedDriveRole, newWorkgroupRole);
  }

  AddDriveMemberState setListRoles({required List<SharedSpaceRole> newDriveRoles, required List<SharedSpaceRole> newWorkgroupRoles}) {
    return AddDriveMemberState(viewState, drive, membersList, newDriveRoles, newWorkgroupRoles, selectedDriveRole, selectedWorkgroupRole);
  }
}