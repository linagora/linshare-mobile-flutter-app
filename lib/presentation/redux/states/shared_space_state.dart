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
import 'package:linshare_flutter_app/presentation/model/file/selectable_element.dart';
import 'package:linshare_flutter_app/presentation/redux/states/linshare_state.dart';

@immutable
class SharedSpaceState extends LinShareState  with EquatableMixin {
  final List<SelectableElement<SharedSpaceNodeNested>> sharedSpacesList;
  final bool showUploadButton;
  final SelectMode selectMode;
  final List<SharedSpaceRole> rolesList;


  SharedSpaceState(
    Either<Failure, Success> viewState,
    this.sharedSpacesList,
    this.rolesList,
    this.selectMode,
    {this.showUploadButton = true}
  ) : super(viewState);

  factory SharedSpaceState.initial() {
    return SharedSpaceState(Right(IdleState()), [], [], SelectMode.INACTIVE);
  }

  @override
  SharedSpaceState clearViewState() {
    return SharedSpaceState(Right(IdleState()), sharedSpacesList, rolesList, selectMode, showUploadButton: showUploadButton);
  }

  @override
  SharedSpaceState sendViewState({Either<Failure, Success> viewState}) {
    return SharedSpaceState(viewState, sharedSpacesList, rolesList, selectMode, showUploadButton: showUploadButton);
  }

  SharedSpaceState setSharedSpaces({Either<Failure, Success> viewState, List<SharedSpaceNodeNested> newSharedSpacesList}) {
    final selectedElements = sharedSpacesList.where((element) => element.selectMode == SelectMode.ACTIVE).map((element) => element.element).toList();

    return SharedSpaceState(viewState ?? this.viewState,
      {for (var sharedSpace in newSharedSpacesList)
          if (selectedElements.contains(sharedSpace))
            SelectableElement<SharedSpaceNodeNested>(sharedSpace, SelectMode.ACTIVE)
          else SelectableElement<SharedSpaceNodeNested>(sharedSpace, SelectMode.INACTIVE)}.toList(),
      rolesList,
      selectMode);
  }

  SharedSpaceState disableUploadButton() {
    return SharedSpaceState(viewState, sharedSpacesList, rolesList, selectMode, showUploadButton: false);
  }

  SharedSpaceState enableUploadButton() {
    return SharedSpaceState(viewState, sharedSpacesList, rolesList, selectMode, showUploadButton: true);
  }

  @override
  SharedSpaceState startLoadingState() {
    return SharedSpaceState(Right(LoadingState()), sharedSpacesList, rolesList, selectMode);
  }

  LinShareState selectSharedSpace(SelectableElement<SharedSpaceNodeNested> selectedSharedSpace) {
    sharedSpacesList.firstWhere((sharedSpace) => sharedSpace == selectedSharedSpace).toggleSelect();
    return SharedSpaceState(viewState, sharedSpacesList, rolesList, SelectMode.ACTIVE);
  }

  LinShareState cancelSelectedSharedSpaces() {
    return SharedSpaceState(
      viewState,
      sharedSpacesList.map((document) => SelectableElement<SharedSpaceNodeNested>(document.element, SelectMode.INACTIVE)).toList(),
      rolesList,
      SelectMode.INACTIVE
    );
  }

  LinShareState selectAllSharedSpaces() {
    return SharedSpaceState(
      viewState,
      sharedSpacesList.map((document) => SelectableElement<SharedSpaceNodeNested>(document.element, SelectMode.ACTIVE)).toList(),
      rolesList,
      SelectMode.ACTIVE
    );
  }

  LinShareState unSelectAllSharedSpaces() {
    return SharedSpaceState(
      viewState, 
      sharedSpacesList.map((document) => SelectableElement<SharedSpaceNodeNested>(document.element, SelectMode.INACTIVE)).toList(),
      rolesList,
      SelectMode.ACTIVE
    );
  }

  LinShareState setSharedSpaceRolesList(List<SharedSpaceRole> roles) {
    return SharedSpaceState(
      viewState,
      sharedSpacesList,
      roles,
      selectMode
    );
  }

  @override
  List<Object> get props => [
    ...super.props,
    sharedSpacesList,
    rolesList,
    showUploadButton
  ];
}

extension MultipleSelections on SharedSpaceState {
  bool isAllSharedSpacesSelected() {
    return sharedSpacesList.every((value) => value.selectMode == SelectMode.ACTIVE);
  }

  List<SharedSpaceNodeNested> getAllSelectedSharedSpaces() {
    return sharedSpacesList.where((element) => element.selectMode == SelectMode.ACTIVE).map((sharedSpace) => sharedSpace.element).toList();
  }
}
