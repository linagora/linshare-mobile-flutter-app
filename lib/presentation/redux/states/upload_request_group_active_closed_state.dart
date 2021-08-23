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
class ActiveClosedUploadRequestGroupState extends LinShareState with EquatableMixin {
  final List<SelectableElement<UploadRequestGroup>> uploadRequestsActiveClosedList;
  final SelectMode selectMode;

  final Sorter activeClosedSorter;

  ActiveClosedUploadRequestGroupState(
      Either<Failure, Success> viewState,
      this.uploadRequestsActiveClosedList,
      this.activeClosedSorter,
      this.selectMode
      ) : super(viewState);

  factory ActiveClosedUploadRequestGroupState.initial() {
    return ActiveClosedUploadRequestGroupState(
        Right(IdleState()),
        [],
        Sorter.fromOrderScreen(OrderScreen.uploadRequestGroupsActiveClosed),
        SelectMode.INACTIVE
    );
  }

  @override
  ActiveClosedUploadRequestGroupState clearViewState() {
    return ActiveClosedUploadRequestGroupState(
        Right(IdleState()),
        uploadRequestsActiveClosedList,
        Sorter.fromOrderScreen(OrderScreen.uploadRequestGroupsActiveClosed),
        selectMode
    );
  }

  @override
  ActiveClosedUploadRequestGroupState sendViewState({required Either<Failure, Success> viewState}) {
    return ActiveClosedUploadRequestGroupState(
        viewState,
        uploadRequestsActiveClosedList,
        activeClosedSorter,
        selectMode
    );
  }

  ActiveClosedUploadRequestGroupState setUploadRequestsActiveClosedList(
      {
        required Either<Failure, Success> viewState,
        required List<UploadRequestGroup> newUploadRequestsList
      }) {
    final selectedElements = uploadRequestsActiveClosedList
        .where((element) => element.selectMode == SelectMode.ACTIVE)
        .map((element) => element.element)
        .toList();
    return ActiveClosedUploadRequestGroupState(
        viewState,
        newUploadRequestsList.map((group) => selectedElements.contains(group)
            ? SelectableElement<UploadRequestGroup>(group, SelectMode.ACTIVE)
            : SelectableElement<UploadRequestGroup>(group, SelectMode.INACTIVE))
            .toList(),
        activeClosedSorter,
        selectMode
    );
  }

  ActiveClosedUploadRequestGroupState setUploadRequestsActiveClosedListWithSort(
      Sorter newSorter,
      {
        Either<Failure, Success>? viewState,
        required List<UploadRequestGroup> newUploadRequestsList
      }) {
    final selectedElements = uploadRequestsActiveClosedList
        .where((element) => element.selectMode == SelectMode.ACTIVE)
        .map((element) => element.element)
        .toList();
    return ActiveClosedUploadRequestGroupState(
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
  ActiveClosedUploadRequestGroupState startLoadingState() {
    return ActiveClosedUploadRequestGroupState(
        Right(LoadingState()),
        uploadRequestsActiveClosedList,
        activeClosedSorter,
        selectMode
    );
  }

  ActiveClosedUploadRequestGroupState setSorterActiveClosed({Either<Failure, Success>? viewState, required Sorter newSorter}) {
    return ActiveClosedUploadRequestGroupState(
        viewState ?? this.viewState,
        uploadRequestsActiveClosedList,
        newSorter,
        selectMode
    );
  }

  ActiveClosedUploadRequestGroupState setSearchResult({required List<UploadRequestGroup> newSearchResult}) {
    final selectedElements = uploadRequestsActiveClosedList
        .where((element) => element.selectMode == SelectMode.ACTIVE)
        .map((element) => element.element)
        .toList();
    return ActiveClosedUploadRequestGroupState(
      viewState,
      newSearchResult.map((group) => selectedElements.contains(group)
        ? SelectableElement<UploadRequestGroup>(group, SelectMode.ACTIVE)
        : SelectableElement<UploadRequestGroup>(group, SelectMode.INACTIVE))
        .toList(),
      activeClosedSorter,
      selectMode
    );
  }

  ActiveClosedUploadRequestGroupState selectActiveClosedUploadRequestGroup(
      SelectableElement<UploadRequestGroup> selectedUploadRequestGroup) {
    uploadRequestsActiveClosedList.firstWhere((group) => group == selectedUploadRequestGroup).toggleSelect();
    return ActiveClosedUploadRequestGroupState(
        viewState,
        uploadRequestsActiveClosedList,
        activeClosedSorter,
        SelectMode.ACTIVE
    );
  }

  ActiveClosedUploadRequestGroupState cancelSelectedActiveClosedUploadRequestGroup() {
    return ActiveClosedUploadRequestGroupState(
        viewState,
        uploadRequestsActiveClosedList
            .map((group) => SelectableElement<UploadRequestGroup>(group.element, SelectMode.INACTIVE))
            .toList(),
        activeClosedSorter,
        SelectMode.INACTIVE
    );
  }

  ActiveClosedUploadRequestGroupState selectAllActiveClosedUploadRequestGroup() {
    return ActiveClosedUploadRequestGroupState(
        viewState,
        uploadRequestsActiveClosedList
            .map((group) => SelectableElement<UploadRequestGroup>(group.element, SelectMode.ACTIVE))
            .toList(),
        activeClosedSorter,
        SelectMode.ACTIVE
    );
  }

  ActiveClosedUploadRequestGroupState unSelectAllActiveClosedUploadRequestGroup() {
    return ActiveClosedUploadRequestGroupState(
        viewState,
        uploadRequestsActiveClosedList
            .map((group) => SelectableElement<UploadRequestGroup>(group.element, SelectMode.INACTIVE))
            .toList(),
        activeClosedSorter,
        SelectMode.ACTIVE
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    uploadRequestsActiveClosedList,
    activeClosedSorter,
    selectMode
  ];
}

extension MultipleSelections on ActiveClosedUploadRequestGroupState {
  bool isAllActiveClosedGroupsSelected() {
    return uploadRequestsActiveClosedList.every((group) => group.selectMode == SelectMode.ACTIVE);
  }
  List<UploadRequestGroup> getAllSelectedActiveClosedGroups() {
    return uploadRequestsActiveClosedList
        .where((group) => group.selectMode == SelectMode.ACTIVE)
        .map((group) => group.element)
        .toList();
  }
}