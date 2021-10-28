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

class SharedSpacesViewState extends ViewState {
  final List<SharedSpaceNodeNested> sharedSpacesList;

  SharedSpacesViewState(this.sharedSpacesList);

  @override
  List<Object> get props => [sharedSpacesList];
}

class SharedSpacesFailure extends FeatureFailure {
  final exception;

  SharedSpacesFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

class SharedSpacesRootNodeInfoViewState extends ViewState {
  final WorkGroupNode workgroupNode;

  SharedSpacesRootNodeInfoViewState(this.workgroupNode);

  @override
  List<Object> get props => [workgroupNode];
}

class SharedSpacesRootNodeInfoFailure extends FeatureFailure {
  final exception;

  SharedSpacesRootNodeInfoFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

class CopyToSharedSpaceViewState extends ViewState {
  final List<WorkGroupNode> workGroupNode;

  CopyToSharedSpaceViewState(this.workGroupNode);

  @override
  List<Object> get props => [workGroupNode];
}

class CopyToSharedSpaceFailure extends FeatureFailure {
  final exception;

  CopyToSharedSpaceFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

class CopyMultipleFilesToSharedSpaceAllSuccessViewState extends ViewState {
  final List<Either<Failure, Success>> resultList;

  CopyMultipleFilesToSharedSpaceAllSuccessViewState(this.resultList);

  @override
  List<Object> get props => [resultList];
}

class CopyMultipleFilesToSharedSpaceHasSomeFilesFailedViewState extends ViewState {
  final List<Either<Failure, Success>> resultList;

  CopyMultipleFilesToSharedSpaceHasSomeFilesFailedViewState(this.resultList);

  @override
  List<Object> get props => [resultList];
}

class CopyMultipleFilesToSharedSpaceAllFailureViewState extends FeatureFailure {
  final List<Either<Failure, Success>> resultList;

  CopyMultipleFilesToSharedSpaceAllFailureViewState(this.resultList);

  @override
  List<Object> get props => [resultList];
}

class RemoveSharedSpaceNodeViewState extends ViewState {
  final WorkGroupNode workGroupNode;

  RemoveSharedSpaceNodeViewState(this.workGroupNode);

  @override
  List<Object> get props => [workGroupNode];
}

class RemoveSharedSpaceNodeFailure extends FeatureFailure {
  final exception;

  RemoveSharedSpaceNodeFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

class RemoveAllSharedSpaceNodesSuccessViewState extends ViewState {
  final List<Either<Failure, Success>> resultList;

  RemoveAllSharedSpaceNodesSuccessViewState(this.resultList);

  @override
  List<Object> get props => [resultList];
}

class RemoveSomeSharedSpaceNodesSuccessViewState extends ViewState {
  final List<Either<Failure, Success>> resultList;

  RemoveSomeSharedSpaceNodesSuccessViewState(this.resultList);

  @override
  List<Object> get props => [resultList];
}

class RemoveAllSharedSpaceNodesFailureViewState extends FeatureFailure {
  final List<Either<Failure, Success>> resultList;

  RemoveAllSharedSpaceNodesFailureViewState(this.resultList);

  @override
  List<Object> get props => [resultList];
}

class ContextMenuWorkGroupNodeViewState extends ViewState {
  final WorkGroupNode workGroupNode;

  ContextMenuWorkGroupNodeViewState(this.workGroupNode);

  @override
  List<Object> get props => [workGroupNode];
}

class DownloadNodesSuccessViewState extends ViewState {
  final List<DownloadTaskId> taskIds;

  DownloadNodesSuccessViewState(this.taskIds);

  @override
  List<Object> get props => [taskIds];
}

class DownloadNodesFailure extends FeatureFailure {
  final Object exception;

  DownloadNodesFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

class DownloadNodeIOSViewState extends ViewState {
  final String filePath;
  DownloadNodeIOSViewState(this.filePath);

  @override
  List<Object> get props => [filePath];
}

class DownloadNodeIOSFailure extends FeatureFailure {
  final downloadFileException;

  DownloadNodeIOSFailure(this.downloadFileException);

  @override
  List<Object> get props => [downloadFileException];
}

class DownloadNodeIOSAllSuccessViewState extends ViewState {
  final List<Either<Failure, Success>> resultList;

  DownloadNodeIOSAllSuccessViewState(this.resultList);

  @override
  List<Object> get props => [resultList];
}

class DownloadNodeIOSHasSomeFilesFailureViewState extends ViewState {
  final List<Either<Failure, Success>> resultList;

  DownloadNodeIOSHasSomeFilesFailureViewState(this.resultList);

  @override
  List<Object> get props => [resultList];
}

class DownloadNodeIOSAllFailureViewState extends FeatureFailure {
  final List<Either<Failure, Success>> resultList;

  DownloadNodeIOSAllFailureViewState(this.resultList);

  @override
  List<Object> get props => [resultList];
}

class ClearWorkGroupNodesListViewState extends ViewState {
  ClearWorkGroupNodesListViewState();

  @override
  List<Object> get props => [];
}

class RemoveSharedSpaceViewState extends ViewState {
  final SharedSpaceNodeNested sharedSpaceNodeNested;

  RemoveSharedSpaceViewState(this.sharedSpaceNodeNested);

  @override
  List<Object> get props => [sharedSpaceNodeNested];
}

class RemoveSharedSpaceFailure extends FeatureFailure {
  final Object exception;

  RemoveSharedSpaceFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

class RemoveSharedSpaceNotFoundFailure extends FeatureFailure {
  RemoveSharedSpaceNotFoundFailure();

  @override
  List<Object> get props => [];
}

class SharedSpaceContextMenuItemViewState extends ViewState {
  final SharedSpaceNodeNested sharedSpace;

  SharedSpaceContextMenuItemViewState(this.sharedSpace);

  @override
  List<Object> get props => [sharedSpace];
}

class RemoveAllSharedSpacesSuccessViewState extends ViewState {
  final List<Either<Failure, Success>> resultList;

  RemoveAllSharedSpacesSuccessViewState(this.resultList);

  @override
  List<Object> get props => [resultList];
}

class RemoveSomeSharedSpacesSuccessViewState extends ViewState {
  final List<Either<Failure, Success>> resultList;

  RemoveSomeSharedSpacesSuccessViewState(this.resultList);

  @override
  List<Object> get props => [resultList];
}

class RemoveAllSharedSpacesFailureViewState extends FeatureFailure {
  final List<Either<Failure, Success>> resultList;

  RemoveAllSharedSpacesFailureViewState(this.resultList);

  @override
  List<Object> get props => [resultList];
}

class CreateSharedSpaceFolderViewState extends ViewState {
  final WorkGroupFolder workGroupFolder;

  CreateSharedSpaceFolderViewState(this.workGroupFolder);

  @override
  List<Object> get props => [workGroupFolder];
}

class CreateSharedSpaceFolderFailure extends FeatureFailure {
  final exception;

  CreateSharedSpaceFolderFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

class SharedSpaceDetailViewState extends ViewState {
  final SharedSpaceNodeNested sharedSpace;

  SharedSpaceDetailViewState(this.sharedSpace);

  @override
  List<Object> get props => [sharedSpace];
}

class SharedSpaceDetailFailure extends FeatureFailure {
  final exception;

  SharedSpaceDetailFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

class SharedSpaceMembersViewState extends ViewState {
  final List<SharedSpaceMember> members;

  SharedSpaceMembersViewState(this.members);

  @override
  List<Object> get props => [members];
}

class SharedSpaceMembersFailure extends FeatureFailure {
  final exception;

  SharedSpaceMembersFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

class CreateWorkGroupViewState extends ViewState {
  final SharedSpaceNodeNested sharedSpaceNodeNested;

  CreateWorkGroupViewState(this.sharedSpaceNodeNested);

  @override
  List<Object> get props => [sharedSpaceNodeNested];
}

class CreateWorkGroupFailure extends FeatureFailure {
  final exception;

  CreateWorkGroupFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

class RenameSharedSpaceNodeViewState extends ViewState {
  final WorkGroupNode workGroupNode;

  RenameSharedSpaceNodeViewState(this.workGroupNode);

  @override
  List<Object> get props => [workGroupNode];
}

class RenameSharedSpaceNodeFailure extends FeatureFailure {
  final exception;

  RenameSharedSpaceNodeFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

class AddSharedSpaceMemberViewState extends ViewState {
  final SharedSpaceMember member;

  AddSharedSpaceMemberViewState(this.member);

  @override
  List<Object> get props => [member];
}

class AddSharedSpaceMemberFailure extends FeatureFailure {
  final exception;

  AddSharedSpaceMemberFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

class UpdateSharedSpaceMemberViewState extends ViewState {

  UpdateSharedSpaceMemberViewState();

  @override
  List<Object> get props => [];
}

class UpdateSharedSpaceMemberFailure extends FeatureFailure {
  final exception;

  UpdateSharedSpaceMemberFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

class DeleteSharedSpaceMemberViewState extends ViewState {

  DeleteSharedSpaceMemberViewState();

  @override
  List<Object> get props => [];
}

class DeleteSharedSpaceMemberFailure extends FeatureFailure {
  final exception;

  DeleteSharedSpaceMemberFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

class SharedSpaceRolesViewState extends ViewState {
  final List<SharedSpaceRole> roles;

  SharedSpaceRolesViewState(this.roles);

  @override
  List<Object> get props => [roles];
}

class SharedSpaceRolesFailure extends FeatureFailure {
  final exception;

  SharedSpaceRolesFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

class SharedSpaceNodeViewState extends ViewState {
  final WorkGroupNode? workGroupNode;

  SharedSpaceNodeViewState(this.workGroupNode);

  @override
  List<Object> get props => [if(workGroupNode != null) workGroupNode!];
}

class SharedSpaceNodeFailure extends FeatureFailure {
  final exception;

  SharedSpaceNodeFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

class RestoreWorkGroupDocumentViewState extends ViewState {
  final List<WorkGroupNode> workGroupNodes;

  RestoreWorkGroupDocumentViewState(this.workGroupNodes);

  @override
  List<Object> get props => [workGroupNodes];
}

class RestoreWorkGroupDocumentFailure extends FeatureFailure {
  final exception;

  RestoreWorkGroupDocumentFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

class RenameWorkGroupViewState extends ViewState {
  final SharedSpaceNodeNested sharedSpaceNodeNested;

  RenameWorkGroupViewState(this.sharedSpaceNodeNested);

  @override
  List<Object> get props => [sharedSpaceNodeNested];
}

class RenameWorkGroupFailure extends FeatureFailure {
  final exception;

  RenameWorkGroupFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

class MoveWorkgroupNodeViewState extends ViewState {
  final WorkGroupNode workGroupNode;

  MoveWorkgroupNodeViewState(this.workGroupNode);

  @override
  List<Object> get props => [workGroupNode];
}

class MoveWorkgroupNodeFailure extends FeatureFailure {
  final exception;

  MoveWorkgroupNodeFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

class MoveAllWorkgroupNodesSuccessViewState extends ViewState {
  final List<Either<Failure, Success>> resultList;

  MoveAllWorkgroupNodesSuccessViewState(this.resultList);

  @override
  List<Object> get props => [resultList];
}

class MoveSomeWorkgroupNodesSuccessViewState extends ViewState {
  final List<Either<Failure, Success>> resultList;

  MoveSomeWorkgroupNodesSuccessViewState(this.resultList);

  @override
  List<Object> get props => [resultList];
}

class MoveAllWorkgroupNodesFailureViewState extends FeatureFailure {
  final List<Either<Failure, Success>> resultList;

  MoveAllWorkgroupNodesFailureViewState(this.resultList);

  @override
  List<Object> get props => [resultList];
}

class EnableVersioningWorkGroupViewState extends ViewState {
  final SharedSpaceNodeNested sharedSpaceNodeNested;

  EnableVersioningWorkGroupViewState(this.sharedSpaceNodeNested);

  @override
  List<Object> get props => [sharedSpaceNodeNested];
}

class EnableVersioningWorkGroupFailure extends FeatureFailure {
  final exception;

  EnableVersioningWorkGroupFailure(this.exception);

  @override
  List<Object> get props => [exception];
}