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
import 'package:flutter/widgets.dart';
import 'package:linshare_flutter_app/presentation/util/router/route_paths.dart';
import 'package:equatable/equatable.dart';

@immutable
class UIState with EquatableMixin {
  final String routePath;
  final SharedSpaceNodeNested? selectedSharedSpace;
  final SharedSpaceNodeNested? selectedDrive;
  final UploadRequestGroup? uploadRequestGroup;
  final SearchState searchState;
  final ActionOutsideAppState actionOutsideAppState;
  final ActionInsideAppState actionInsideAppState;
  final int uploadRequestGroupTabIndex;

  UIState(
    this.routePath,
    this.searchState,
    this.actionOutsideAppState,
    this.actionInsideAppState,
    {
      this.uploadRequestGroupTabIndex = 0,
      this.selectedSharedSpace,
      this.selectedDrive,
      this.uploadRequestGroup
    }
  );

  factory UIState.initial() {
    return UIState(RoutePaths.initializeRoute, SearchState.initial(), ActionOutsideAppState.initial(), ActionInsideAppState.initial());
  }

  UIState setCurrentView(
      String routePath,
      {
        SharedSpaceNodeNested? sharedSpace,
        SharedSpaceNodeNested? drive,
        UploadRequestGroup? uploadRequestGroup
  }) {
    return UIState(routePath,
        searchState,
        actionOutsideAppState,
        actionInsideAppState,
        uploadRequestGroupTabIndex: uploadRequestGroupTabIndex,
        selectedSharedSpace: sharedSpace,
        selectedDrive: drive,
        uploadRequestGroup: uploadRequestGroup);
  }

  UIState clearCurrentView() {
    return UIState.initial();
  }

  UIState setSearchState(SearchState searchState) {
    return UIState(routePath,
        searchState,
        actionOutsideAppState,
        actionInsideAppState,
        uploadRequestGroupTabIndex: uploadRequestGroupTabIndex,
        selectedSharedSpace: selectedSharedSpace,
        selectedDrive: selectedDrive,
        uploadRequestGroup: uploadRequestGroup);
  }

  UIState setUploadRequestGroupIndexTab(int newIndex) {
    return UIState(routePath,
        searchState,
        actionOutsideAppState,
        actionInsideAppState,
        uploadRequestGroupTabIndex: newIndex,
        selectedSharedSpace: selectedSharedSpace,
        selectedDrive: selectedDrive,
        uploadRequestGroup: uploadRequestGroup);
  }

  UIState setActionOutsideAppState(ActionOutsideAppState actionOutsideAppState) {
    return UIState(routePath,
        searchState,
        actionOutsideAppState,
        actionInsideAppState,
        uploadRequestGroupTabIndex: uploadRequestGroupTabIndex,
        selectedSharedSpace: selectedSharedSpace,
        selectedDrive: selectedDrive,
        uploadRequestGroup: uploadRequestGroup);
  }

  UIState setActionInsideAppState(ActionInsideAppState actionInsideAppState) {
    return UIState(routePath,
        searchState,
        actionOutsideAppState,
        actionInsideAppState,
        uploadRequestGroupTabIndex: uploadRequestGroupTabIndex,
        selectedSharedSpace: selectedSharedSpace,
        selectedDrive: selectedDrive,
        uploadRequestGroup: uploadRequestGroup);
  }

  @override
  List<Object?> get props => [
    routePath,
    searchState,
    actionOutsideAppState,
    actionInsideAppState,
    selectedSharedSpace,
    selectedDrive,
    uploadRequestGroup,
    uploadRequestGroupTabIndex
  ];
}

extension UIStateExtension on UIState {
  bool isInSearchState() => searchState.searchStatus == SearchStatus.ACTIVE;
  bool isInOutsideAppState() => actionOutsideAppState.actionOutsideAppType != ActionOutsideAppType.NONE;
  bool isInInsideAppState() => actionInsideAppState.actionInsideAppType != ActionInsideAppType.NONE;
}

class SearchState with EquatableMixin {
  final SearchStatus searchStatus;
  final SearchDestination searchDestination;
  final String destinationName;

  SearchState(this.searchStatus, this.searchDestination, this.destinationName);

  factory SearchState.initial() {
    return SearchState(SearchStatus.INACTIVE, SearchDestination.mySpace, '');
  }

  SearchState newSearchQuery(SearchQuery searchQuery) {
    return SearchState(searchStatus, searchDestination, destinationName);
  }

  SearchState disableSearchState() {
    return SearchState(SearchStatus.INACTIVE, searchDestination, destinationName);
  }

  SearchState enableSearchState(SearchDestination searchDestination, String destinationName) {
    return SearchState(SearchStatus.ACTIVE, searchDestination, destinationName);
  }

  @override
  List<Object?> get props => [searchStatus, searchDestination, destinationName];
}

class ActionOutsideAppState with EquatableMixin {
  final ActionOutsideAppType actionOutsideAppType;

  ActionOutsideAppState(this.actionOutsideAppType);

  factory ActionOutsideAppState.initial() {
    return ActionOutsideAppState(ActionOutsideAppType.NONE);
  }

  ActionOutsideAppState disableActionOutsideAppState() {
    return ActionOutsideAppState(ActionOutsideAppType.NONE);
  }

  ActionOutsideAppState enableActionOutsideAppState(ActionOutsideAppType outsideAppType) {
    return ActionOutsideAppState(outsideAppType);
  }

  @override
  List<Object?> get props => [actionOutsideAppType];
}

class ActionInsideAppState with EquatableMixin {
  final ActionInsideAppType actionInsideAppType;

  ActionInsideAppState(this.actionInsideAppType);

  factory ActionInsideAppState.initial() {
    return ActionInsideAppState(ActionInsideAppType.NONE);
  }

  ActionInsideAppState disableInsideAppState() {
    return ActionInsideAppState(ActionInsideAppType.NONE);
  }

  ActionInsideAppState enableInsideAppState(ActionInsideAppType insideAppActionType) {
    return ActionInsideAppState(insideAppActionType);
  }

  @override
  List<Object?> get props => [actionInsideAppType];
}

enum SearchStatus {
  ACTIVE, INACTIVE
}

enum ActionOutsideAppType {
  NONE, PICKING_FILE
}

enum ActionInsideAppType {
  NONE, AUTHENTICATING_BIOMETRIC
}

enum SearchDestination {
  mySpace,
  sharedSpace,
  insideDrive,
  allSharedSpaces,
  receivedShares,
  uploadRequestGroups,
  activeClosedUploadRequestInside,
  archivedUploadRequestInside,
  createdUploadRequestInside,
  activeClosedUploadRequestRecipient,
  archivedUploadRequestRecipient,
  createdUploadRequestRecipient,
}
