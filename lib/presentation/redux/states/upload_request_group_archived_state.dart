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
import 'package:flutter/foundation.dart';
import 'package:linshare_flutter_app/presentation/model/file/selectable_element.dart';
import 'package:linshare_flutter_app/presentation/redux/states/linshare_state.dart';
import 'package:equatable/equatable.dart';

@immutable
class ArchivedUploadRequestGroupState extends LinShareState with EquatableMixin {
  final List<SelectableElement<UploadRequestGroup>> uploadRequestsArchivedList;
  final SelectMode selectMode;

  final Sorter archivedSorter;

  ArchivedUploadRequestGroupState(
    Either<Failure, Success> viewState,
    this.uploadRequestsArchivedList,
    this.archivedSorter,
    this.selectMode
  ) : super(viewState);

  factory ArchivedUploadRequestGroupState.initial() {
    return ArchivedUploadRequestGroupState(
      Right(IdleState()),
      [],
      Sorter.fromOrderScreen(OrderScreen.uploadRequestGroupsArchived),
      SelectMode.INACTIVE
    );
  }

  @override
  ArchivedUploadRequestGroupState clearViewState() {
    return ArchivedUploadRequestGroupState(
      Right(IdleState()),
      uploadRequestsArchivedList,
      Sorter.fromOrderScreen(OrderScreen.uploadRequestGroupsArchived),
      selectMode
    );
  }

  @override
  ArchivedUploadRequestGroupState sendViewState({required Either<Failure, Success> viewState}) {
    return ArchivedUploadRequestGroupState(
      viewState,
      uploadRequestsArchivedList,
      archivedSorter,
      selectMode
    );
  }

  ArchivedUploadRequestGroupState setUploadRequestsArchivedList(
    {
      required Either<Failure, Success> viewState,
      required List<UploadRequestGroup> newUploadRequestsList
    }) {
    final selectedElements = uploadRequestsArchivedList
        .where((element) => element.selectMode == SelectMode.ACTIVE)
        .map((element) => element.element)
        .toList();
    return ArchivedUploadRequestGroupState(
      viewState,
      newUploadRequestsList.map((group) => selectedElements.contains(group)
        ? SelectableElement<UploadRequestGroup>(group, SelectMode.ACTIVE)
        : SelectableElement<UploadRequestGroup>(group, SelectMode.INACTIVE))
        .toList(),
      archivedSorter,
      selectMode
    );
  }

  ArchivedUploadRequestGroupState setUploadRequestsArchivedListWithSort(
    Sorter newSorter,
    {
      Either<Failure, Success>? viewState,
      required List<UploadRequestGroup> newUploadRequestsList
    }) {
    final selectedElements = uploadRequestsArchivedList
        .where((element) => element.selectMode == SelectMode.ACTIVE)
        .map((element) => element.element)
        .toList();
    return ArchivedUploadRequestGroupState(
      viewState ?? this.viewState,
      newUploadRequestsList.map((group) => selectedElements.contains(group)
          ? SelectableElement<UploadRequestGroup>(group, SelectMode.ACTIVE)
          : SelectableElement<UploadRequestGroup>(group, SelectMode.INACTIVE))
          .toList(),
      newSorter,
      selectMode
    );
  }

  @override
  ArchivedUploadRequestGroupState startLoadingState() {
    return ArchivedUploadRequestGroupState(
      Right(LoadingState()),
      uploadRequestsArchivedList,
      archivedSorter,
      selectMode
    );
  }

  ArchivedUploadRequestGroupState setSorterArchived({Either<Failure, Success>? viewState, required Sorter newSorter}) {
    return ArchivedUploadRequestGroupState(
      viewState ?? this.viewState,
      uploadRequestsArchivedList,
      newSorter,
      selectMode
    );
  }

  ArchivedUploadRequestGroupState setSearchResult({required List<UploadRequestGroup> newSearchResult}) {
    final selectedElements = uploadRequestsArchivedList
        .where((element) => element.selectMode == SelectMode.ACTIVE)
        .map((element) => element.element)
        .toList();
    return ArchivedUploadRequestGroupState(
      viewState,
      newSearchResult.map((group) => selectedElements.contains(group)
        ? SelectableElement<UploadRequestGroup>(group, SelectMode.ACTIVE)
        : SelectableElement<UploadRequestGroup>(group, SelectMode.INACTIVE))
        .toList(),
      archivedSorter,
      selectMode
    );
  }

  ArchivedUploadRequestGroupState selectArchivedUploadRequestGroup(
      SelectableElement<UploadRequestGroup> selectedUploadRequestGroup) {
    uploadRequestsArchivedList.firstWhere((group) => group == selectedUploadRequestGroup).toggleSelect();
    return ArchivedUploadRequestGroupState(
        viewState,
        uploadRequestsArchivedList,
        archivedSorter,
        SelectMode.ACTIVE
    );
  }

  ArchivedUploadRequestGroupState cancelSelectedArchivedUploadRequestGroup() {
    return ArchivedUploadRequestGroupState(
        viewState,
        uploadRequestsArchivedList
            .map((group) => SelectableElement<UploadRequestGroup>(group.element, SelectMode.INACTIVE))
            .toList(),
        archivedSorter,
        SelectMode.INACTIVE
    );
  }

  ArchivedUploadRequestGroupState selectAllArchivedUploadRequestGroup() {
    return ArchivedUploadRequestGroupState(
        viewState,
        uploadRequestsArchivedList
            .map((group) => SelectableElement<UploadRequestGroup>(group.element, SelectMode.ACTIVE))
            .toList(),
        archivedSorter,
        SelectMode.ACTIVE
    );
  }

  ArchivedUploadRequestGroupState unSelectAllArchivedUploadRequestGroup() {
    return ArchivedUploadRequestGroupState(
        viewState,
        uploadRequestsArchivedList
            .map((group) => SelectableElement<UploadRequestGroup>(group.element, SelectMode.INACTIVE))
            .toList(),
        archivedSorter,
        SelectMode.ACTIVE
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    uploadRequestsArchivedList,
    archivedSorter,
    selectMode
  ];
}

extension MultipleSelections on ArchivedUploadRequestGroupState {
  bool isAllArchivedGroupsSelected() {
    return uploadRequestsArchivedList.every((group) => group.selectMode == SelectMode.ACTIVE);
  }
  List<UploadRequestGroup> getAllSelectedArchivedGroups() {
    return uploadRequestsArchivedList
      .where((group) => group.selectMode == SelectMode.ACTIVE)
      .map((group) => group.element)
      .toList();
  }
}