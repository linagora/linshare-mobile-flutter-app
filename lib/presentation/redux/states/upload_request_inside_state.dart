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
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/upload_request_document_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/upload_request_document_type.dart';

@immutable
class UploadRequestInsideState extends LinShareState with EquatableMixin {
  final List<SelectableElement<UploadRequest>> uploadRequests;

  final List<SelectableElement<UploadRequestEntry>> uploadRequestEntries;
  final SelectMode selectMode;

  final UploadRequestDocumentType uploadRequestDocumentType;
  final UploadRequestGroup? uploadRequestGroup;
  final UploadRequest? selectedUploadRequest;

  UploadRequestInsideState(
      Either<Failure, Success> viewState,
      this.uploadRequests,
      this.uploadRequestEntries,
      this.selectMode,
      this.uploadRequestDocumentType,
      this.uploadRequestGroup,
      this.selectedUploadRequest)
      : super(viewState);

  factory UploadRequestInsideState.initial() {
    return UploadRequestInsideState(Right(IdleState()), [], [], SelectMode.INACTIVE, UploadRequestDocumentType.recipients, null, null);
  }

  @override
  UploadRequestInsideState clearViewState() {
    return UploadRequestInsideState(
      Right(IdleState()),
      uploadRequests,
      uploadRequestEntries,
      selectMode,
      uploadRequestDocumentType,
      uploadRequestGroup,
      selectedUploadRequest
    );
  }

  @override
  UploadRequestInsideState sendViewState({required Either<Failure, Success> viewState}) {
    return UploadRequestInsideState(
        viewState,
        uploadRequests,
        uploadRequestEntries,
        selectMode,
        uploadRequestDocumentType,
        uploadRequestGroup,
        selectedUploadRequest
    );
  }

  UploadRequestInsideState setUploadRequestArgument({required UploadRequestArguments newUploadRequestArguments}) {
    return UploadRequestInsideState(
      viewState,
      uploadRequests,
      uploadRequestEntries,
      selectMode,
      newUploadRequestArguments.documentType,
      newUploadRequestArguments.uploadRequestGroup,
      null
    );
  }

  UploadRequestInsideState setUploadRequests(
      {Either<Failure, Success>? viewState, required List<UploadRequest> newUploadRequests}) {
    final currentSelectedUploadRequests = uploadRequests
        .where((element) => element.selectMode == SelectMode.ACTIVE)
        .map((selectableElement) => selectableElement.element)
        .toList();

    return UploadRequestInsideState(
        viewState ?? this.viewState,
        newUploadRequests
          .where((element) => element.status != UploadRequestStatus.DELETED)
          .map((uploadRequest) => currentSelectedUploadRequests.contains(uploadRequest)
            ? SelectableElement<UploadRequest>(uploadRequest, SelectMode.ACTIVE)
            : SelectableElement<UploadRequest>(uploadRequest, SelectMode.INACTIVE)).toList(),
        uploadRequestEntries,
        selectMode,
        UploadRequestDocumentType.recipients,
        uploadRequestGroup,
        selectedUploadRequest);
  }

  UploadRequestInsideState setUploadRequestEntries(
      {Either<Failure, Success>? viewState, required List<UploadRequestEntry> newUploadRequestEntries}) {
    final selectedElements = uploadRequestEntries.where((element) => element.selectMode == SelectMode.ACTIVE).map((element) => element.element).toList();

    return UploadRequestInsideState(
        viewState ?? this.viewState,
        uploadRequests,
        newUploadRequestEntries.map((entry) => selectedElements.contains(entry)
          ? SelectableElement<UploadRequestEntry>(entry, SelectMode.ACTIVE)
          : SelectableElement<UploadRequestEntry>(entry, SelectMode.INACTIVE))
          .toList(),
        selectMode,
        UploadRequestDocumentType.files, uploadRequestGroup, selectedUploadRequest);
  }

  UploadRequestInsideState setSelectedUploadRequest(
      {required UploadRequest selectedUploadRequest}) {
    return UploadRequestInsideState(viewState, uploadRequests, uploadRequestEntries, selectMode,
        UploadRequestDocumentType.files, uploadRequestGroup, selectedUploadRequest);
  }

  @override
  UploadRequestInsideState startLoadingState() {
    return UploadRequestInsideState(Right(LoadingState()), uploadRequests, uploadRequestEntries, selectMode,
        uploadRequestDocumentType, uploadRequestGroup, selectedUploadRequest);
  }

  UploadRequestInsideState selectUploadRequestEntry(SelectableElement<UploadRequestEntry> selectedUploadRequestEntry) {
    uploadRequestEntries.firstWhere((entry) => entry == selectedUploadRequestEntry).toggleSelect();
    return UploadRequestInsideState(
        viewState,
        uploadRequests,
        uploadRequestEntries,
        SelectMode.ACTIVE,
        uploadRequestDocumentType,
        uploadRequestGroup,
        selectedUploadRequest);
  }

  UploadRequestInsideState cancelSelectedUploadRequestEntry() {
    return UploadRequestInsideState(
        viewState,
        uploadRequests,
        uploadRequestEntries
          .map((entry) => SelectableElement<UploadRequestEntry>(entry.element, SelectMode.INACTIVE))
          .toList(),
        SelectMode.INACTIVE,
        uploadRequestDocumentType, 
        uploadRequestGroup, 
        selectedUploadRequest
    );
  }

  UploadRequestInsideState selectAllUploadRequestEntry() {
    return UploadRequestInsideState(
        viewState,
        uploadRequests,
        uploadRequestEntries
          .map((entry) => SelectableElement<UploadRequestEntry>(entry.element, SelectMode.ACTIVE))
          .toList(),
        SelectMode.ACTIVE,
        uploadRequestDocumentType,
        uploadRequestGroup,
        selectedUploadRequest
    );
  }

  UploadRequestInsideState unSelectAllUploadRequestEntry() {
    return UploadRequestInsideState(
        viewState,
        uploadRequests,
        uploadRequestEntries
          .map((entry) => SelectableElement<UploadRequestEntry>(entry.element, SelectMode.INACTIVE))
          .toList(),
        SelectMode.ACTIVE,
        uploadRequestDocumentType,
        uploadRequestGroup,
        selectedUploadRequest
    );
  }

  UploadRequestInsideState selectUploadRequests(SelectableElement<UploadRequest> newSelectedUploadRequest) {
    uploadRequests.firstWhere((entry) => entry == newSelectedUploadRequest).toggleSelect();
    return UploadRequestInsideState(
        viewState,
        uploadRequests,
        uploadRequestEntries,
        SelectMode.ACTIVE,
        uploadRequestDocumentType,
        uploadRequestGroup,
        selectedUploadRequest);
  }

  UploadRequestInsideState cancelSelectedUploadRequest() {
    return UploadRequestInsideState(
        viewState,
        uploadRequests.map((entry) => SelectableElement<UploadRequest>(entry.element, SelectMode.INACTIVE))
            .toList(),
        uploadRequestEntries,
        SelectMode.INACTIVE,
        uploadRequestDocumentType,
        uploadRequestGroup,
        selectedUploadRequest
    );
  }

  UploadRequestInsideState selectAllUploadRequest() {
    return UploadRequestInsideState(
        viewState,
        uploadRequests.map((entry) => SelectableElement<UploadRequest>(entry.element, SelectMode.ACTIVE))
            .toList(),
        uploadRequestEntries,
        SelectMode.ACTIVE,
        uploadRequestDocumentType,
        uploadRequestGroup,
        selectedUploadRequest
    );
  }

  UploadRequestInsideState unSelectAllUploadRequest() {
    return UploadRequestInsideState(
        viewState,
        uploadRequests.map((entry) => SelectableElement<UploadRequest>(entry.element, SelectMode.INACTIVE))
            .toList(),
        uploadRequestEntries,
        SelectMode.ACTIVE,
        uploadRequestDocumentType,
        uploadRequestGroup,
        selectedUploadRequest
    );
  }

  UploadRequestInsideState setSearchResult({required List<UploadRequestEntry> newSearchResult}) {
    final selectedElements = uploadRequestEntries
        .where((element) => element.selectMode == SelectMode.ACTIVE)
        .map((element) => element.element)
        .toList();
    return UploadRequestInsideState(
        viewState,
        uploadRequests,
        newSearchResult.map((entry) => selectedElements.contains(entry)
          ? SelectableElement<UploadRequestEntry>(entry, SelectMode.ACTIVE)
          : SelectableElement<UploadRequestEntry>(entry, SelectMode.INACTIVE)).toList(),
        selectMode,
        uploadRequestDocumentType,
        uploadRequestGroup,
        selectedUploadRequest
    );
  }

  @override
  List<Object?> get props =>
    [...super.props,
      uploadRequests,
      uploadRequestEntries,
      selectMode,
      uploadRequestDocumentType,
      uploadRequestGroup,
      selectedUploadRequest
    ];
}

extension MultipleSelections on UploadRequestInsideState {
  bool isAllEntriesSelected() {
    return uploadRequestEntries.every((entry) => entry.selectMode == SelectMode.ACTIVE);
  }

  List<UploadRequestEntry> getAllSelectedEntries() {
    return uploadRequestEntries
        .where((entry) => entry.selectMode == SelectMode.ACTIVE)
        .map((entry) => entry.element)
        .toList();
  }

  bool isAllRecipientSelected() {
    return uploadRequests.every((uploadRequest) => uploadRequest.selectMode == SelectMode.ACTIVE);
  }

  List<UploadRequest> getAllSelectedRecipient() {
    return uploadRequests
      .where((entry) => entry.selectMode == SelectMode.ACTIVE)
      .map((entry) => entry.element)
      .toList();
  }
}
