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
class CreatedUploadRequestGroupState extends LinShareState with EquatableMixin {
  final List<SelectableElement<UploadRequestGroup>> uploadRequestsCreatedList;
  final SelectMode selectMode;

  final Sorter pendingSorter;

  CreatedUploadRequestGroupState(
    Either<Failure, Success> viewState,
    this.uploadRequestsCreatedList,
    this.pendingSorter,
    this.selectMode
  ) : super(viewState);

  factory CreatedUploadRequestGroupState.initial() {
    return CreatedUploadRequestGroupState(
      Right(IdleState()),
      [],
      Sorter.fromOrderScreen(OrderScreen.uploadRequestGroupsCreated),
      SelectMode.INACTIVE
    );
  }

  @override
  CreatedUploadRequestGroupState clearViewState() {
    return CreatedUploadRequestGroupState(
      Right(IdleState()),
      uploadRequestsCreatedList,
      Sorter.fromOrderScreen(OrderScreen.uploadRequestGroupsCreated),
      selectMode
    );
  }

  @override
  CreatedUploadRequestGroupState sendViewState({required Either<Failure, Success> viewState}) {
    return CreatedUploadRequestGroupState(
      viewState,
      uploadRequestsCreatedList,
      pendingSorter,
      selectMode
    );
  }

  CreatedUploadRequestGroupState setUploadRequestsCreatedList(
    {
      required Either<Failure, Success> viewState,
      required List<UploadRequestGroup> newUploadRequestsList
    }) {
    final selectedElements = uploadRequestsCreatedList
        .where((element) => element.selectMode == SelectMode.ACTIVE)
        .map((element) => element.element)
        .toList();
    return CreatedUploadRequestGroupState(
      viewState,
      newUploadRequestsList.map((group) => selectedElements.contains(group)
        ? SelectableElement<UploadRequestGroup>(group, SelectMode.ACTIVE)
        : SelectableElement<UploadRequestGroup>(group, SelectMode.INACTIVE))
        .toList(),
      pendingSorter,
      selectMode
    );
  }

  CreatedUploadRequestGroupState setUploadRequestsCreatedListWithSort(
    Sorter newSorter,
    {
      Either<Failure, Success>? viewState,
      required List<UploadRequestGroup> newUploadRequestsList
    }) {
    final selectedElements = uploadRequestsCreatedList
        .where((element) => element.selectMode == SelectMode.ACTIVE)
        .map((element) => element.element)
        .toList();
    return CreatedUploadRequestGroupState(
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
  CreatedUploadRequestGroupState startLoadingState() {
    return CreatedUploadRequestGroupState(
      Right(LoadingState()),
      uploadRequestsCreatedList,
      pendingSorter,
      selectMode
    );
  }

  CreatedUploadRequestGroupState setSorterCreated({Either<Failure, Success>? viewState, required Sorter newSorter}) {
    return CreatedUploadRequestGroupState(
      viewState ?? this.viewState,
      uploadRequestsCreatedList,
      newSorter,
      selectMode
    );
  }

  CreatedUploadRequestGroupState setSearchResult({required List<UploadRequestGroup> newSearchResult}) {
    final selectedElements = uploadRequestsCreatedList
        .where((element) => element.selectMode == SelectMode.ACTIVE)
        .map((element) => element.element)
        .toList();
    return CreatedUploadRequestGroupState(
      viewState,
      newSearchResult.map((group) => selectedElements.contains(group)
        ? SelectableElement<UploadRequestGroup>(group, SelectMode.ACTIVE)
        : SelectableElement<UploadRequestGroup>(group, SelectMode.INACTIVE))
        .toList(),
      pendingSorter,
      selectMode
    );
  }

  CreatedUploadRequestGroupState selectCreatedUploadRequestGroup(
      SelectableElement<UploadRequestGroup> selectedUploadRequestGroup) {
    uploadRequestsCreatedList.firstWhere((group) => group == selectedUploadRequestGroup).toggleSelect();
    return CreatedUploadRequestGroupState(
        viewState,
        uploadRequestsCreatedList,
        pendingSorter,
        SelectMode.ACTIVE
    );
  }

  CreatedUploadRequestGroupState cancelSelectedCreatedUploadRequestGroup() {
    return CreatedUploadRequestGroupState(
        viewState,
        uploadRequestsCreatedList
            .map((group) => SelectableElement<UploadRequestGroup>(group.element, SelectMode.INACTIVE))
            .toList(),
        pendingSorter,
        SelectMode.INACTIVE
    );
  }

  CreatedUploadRequestGroupState selectAllCreatedUploadRequestGroup() {
    return CreatedUploadRequestGroupState(
        viewState,
        uploadRequestsCreatedList
            .map((group) => SelectableElement<UploadRequestGroup>(group.element, SelectMode.ACTIVE))
            .toList(),
        pendingSorter,
        SelectMode.ACTIVE
    );
  }

  CreatedUploadRequestGroupState unSelectAllCreatedUploadRequestGroup() {
    return CreatedUploadRequestGroupState(
        viewState,
        uploadRequestsCreatedList
            .map((group) => SelectableElement<UploadRequestGroup>(group.element, SelectMode.INACTIVE))
            .toList(),
        pendingSorter,
        SelectMode.ACTIVE
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    uploadRequestsCreatedList,
    pendingSorter,
    selectMode
  ];
}

extension MultipleSelections on CreatedUploadRequestGroupState {
  bool isAllCreatedGroupsSelected() {
    return uploadRequestsCreatedList.every((group) => group.selectMode == SelectMode.ACTIVE);
  }
  List<UploadRequestGroup> getAllSelectedCreatedGroups() {
    return uploadRequestsCreatedList
      .where((group) => group.selectMode == SelectMode.ACTIVE)
      .map((group) => group.element)
      .toList();
  }
}