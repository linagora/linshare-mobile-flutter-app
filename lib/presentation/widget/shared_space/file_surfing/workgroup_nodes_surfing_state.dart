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

import 'package:domain/domain.dart';
import 'package:linshare_flutter_app/presentation/model/file/selectable_element.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space/file_surfing/workgroup_nodes_surfling_arguments.dart';

class WorkGroupNodesSurfingState {
  final WorkGroupNode node;
  final List<SelectableElement<WorkGroupNode>> children;
  final FolderNodeType folderNodeType;
  final SharedSpaceId sharedSpaceId;
  final bool showLoading;
  final SelectMode selectMode;

  WorkGroupNodesSurfingState(
    this.node,
    this.children,
    this.folderNodeType, {
    this.sharedSpaceId,
    this.showLoading = false,
    this.selectMode = SelectMode.INACTIVE
  });

  WorkGroupNodesSurfingState selectWorkGroupNode(SelectableElement<WorkGroupNode> selectedWorkGroupNode) {
    children.firstWhere((workGroupNode) => workGroupNode == selectedWorkGroupNode).toggleSelect();
    return WorkGroupNodesSurfingState(
      node,
      children,
      folderNodeType,
      sharedSpaceId: sharedSpaceId,
      showLoading: showLoading,
      selectMode: SelectMode.ACTIVE
    );
  }

  WorkGroupNodesSurfingState cancelSelectedWorkGroupNodes() {
    return WorkGroupNodesSurfingState(
      node,
      children.map((workGroupNode) => SelectableElement<WorkGroupNode>(workGroupNode.element, SelectMode.INACTIVE)).toList(),
      folderNodeType,
      sharedSpaceId: sharedSpaceId,
      showLoading: showLoading,
      selectMode: SelectMode.INACTIVE
    );
  }

  WorkGroupNodesSurfingState selectAllWorkGroupNodes() {
    return WorkGroupNodesSurfingState(
      node,
      children.map((workGroupNode) => SelectableElement<WorkGroupNode>(workGroupNode.element, SelectMode.ACTIVE)).toList(),
      folderNodeType,
      sharedSpaceId: sharedSpaceId,
      showLoading: showLoading,
      selectMode: SelectMode.ACTIVE
    );
  }

  WorkGroupNodesSurfingState unselectAllWorkGroupNodes() {
    return WorkGroupNodesSurfingState(
      node,
      children.map((workGroupNode) => SelectableElement<WorkGroupNode>(workGroupNode.element, SelectMode.INACTIVE)).toList(),
      folderNodeType,
      sharedSpaceId: sharedSpaceId,
      showLoading: showLoading,
      selectMode: SelectMode.ACTIVE
    );
  }
  
  WorkGroupNodesSurfingState copyWith({
    WorkGroupNode node,
    List<SelectableElement<WorkGroupNode>> children,
    FolderNodeType folderNodeType,
    SharedSpaceId sharedSpaceId,
    bool showLoading,
  }) {
    return WorkGroupNodesSurfingState(
      node ?? this.node,
      children ?? this.children,
      folderNodeType ?? this.folderNodeType,
      sharedSpaceId: sharedSpaceId ?? this.sharedSpaceId,
      showLoading: showLoading ?? this.showLoading,
      selectMode: selectMode
    );
  }

  WorkGroupNodesSurfingState setWorkGroupNodesList(List<WorkGroupNode> workGroupNodes, {bool showLoading}) {
    final selectedElements = children.where((element) => element.selectMode == SelectMode.ACTIVE).map((element) => element.element).toList();

    return WorkGroupNodesSurfingState(
      node,
      {for (var workGroupNode in workGroupNodes)
          if (selectedElements.contains(workGroupNode))
            SelectableElement<WorkGroupNode>(workGroupNode, SelectMode.ACTIVE)
          else SelectableElement<WorkGroupNode>(workGroupNode, SelectMode.INACTIVE)}.toList(),
      folderNodeType,
      sharedSpaceId: sharedSpaceId,
      showLoading: showLoading ?? this.showLoading,
      selectMode: selectMode
    );
  }
}

extension MultipleSelections on WorkGroupNodesSurfingState {
  bool isAllDocumentsSelected() {
    return children.every((value) => value.selectMode == SelectMode.ACTIVE);
  }

  List<WorkGroupNode> getAllSelectedDocuments() {
    return children.where((element) => element.selectMode == SelectMode.ACTIVE).map((workGroupNode) => workGroupNode.element).toList();
  }
}
