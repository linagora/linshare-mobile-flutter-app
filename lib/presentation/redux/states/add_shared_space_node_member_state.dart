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
class AddSharedSpaceNodeMemberState extends LinShareState with EquatableMixin {
  final SharedSpaceNodeNested? nodeNested;
  final List<SharedSpaceMember> membersList;
  final List<SharedSpaceRole> nodeNestedRoleList;
  final List<SharedSpaceRole> workgroupRoleList;
  final SharedSpaceRoleName selectedNodeNestedRole;
  final SharedSpaceRoleName selectedWorkgroupRole;

  AddSharedSpaceNodeMemberState(
      Either<Failure, Success> viewState, this.nodeNested,
      this.membersList,
      this.nodeNestedRoleList,
      this.workgroupRoleList,
      this.selectedNodeNestedRole,
      this.selectedWorkgroupRole,
  ) : super(viewState);

  factory AddSharedSpaceNodeMemberState.initial() {
    return AddSharedSpaceNodeMemberState(Right(IdleState()), null, [], [], [], SharedSpaceRoleName.DRIVE_READER, SharedSpaceRoleName.READER);
  }

  @override
  AddSharedSpaceNodeMemberState clearViewState() {
    return AddSharedSpaceNodeMemberState(Right(IdleState()), null, [], [], [], SharedSpaceRoleName.DRIVE_READER, SharedSpaceRoleName.READER);
  }

  @override
  AddSharedSpaceNodeMemberState sendViewState(
      {required Either<Failure, Success> viewState}) {
    return AddSharedSpaceNodeMemberState(viewState, nodeNested, membersList, nodeNestedRoleList, workgroupRoleList, selectedNodeNestedRole, selectedWorkgroupRole);
  }

  @override
  AddSharedSpaceNodeMemberState startLoadingState() {
    return AddSharedSpaceNodeMemberState(Right(LoadingState()), nodeNested, membersList, nodeNestedRoleList, workgroupRoleList, selectedNodeNestedRole, selectedWorkgroupRole);
  }

  AddSharedSpaceNodeMemberState setNodeNestedMembers(
      {required Either<Failure, Success> viewState, required List<SharedSpaceMember> newMembers}) {
    return AddSharedSpaceNodeMemberState(viewState, nodeNested, newMembers, nodeNestedRoleList, workgroupRoleList, selectedNodeNestedRole, selectedWorkgroupRole);
  }

  AddSharedSpaceNodeMemberState setNodeNested({required Either<Failure,
      Success> viewState, SharedSpaceNodeNested? newNodeNested}) {
    return AddSharedSpaceNodeMemberState(viewState, newNodeNested, membersList, nodeNestedRoleList, workgroupRoleList, selectedNodeNestedRole, selectedWorkgroupRole);
  }

  AddSharedSpaceNodeMemberState setNodeNestedRoleName(SharedSpaceRoleName newNodeNestedRoleName) {
    return AddSharedSpaceNodeMemberState(viewState, nodeNested, membersList, nodeNestedRoleList, workgroupRoleList, newNodeNestedRoleName, selectedWorkgroupRole);
  }

  AddSharedSpaceNodeMemberState setWorkgroupRoleName(SharedSpaceRoleName newWorkgroupRole) {
    return AddSharedSpaceNodeMemberState(viewState, nodeNested, membersList, nodeNestedRoleList, workgroupRoleList, selectedNodeNestedRole, newWorkgroupRole);
  }

  AddSharedSpaceNodeMemberState setListRoles({required List<SharedSpaceRole> newNodeNestedRoles, required List<SharedSpaceRole> newWorkgroupRoles}) {
    return AddSharedSpaceNodeMemberState(viewState, nodeNested, membersList, newNodeNestedRoles, newWorkgroupRoles, selectedNodeNestedRole, selectedWorkgroupRole);
  }
}