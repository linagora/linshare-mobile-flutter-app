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
class ArchivedUploadRequestInsideState extends LinShareState with EquatableMixin {
  final List<SelectableElement<UploadRequest>> uploadRequests;
  final List<SelectableElement<UploadRequestEntry>> uploadRequestEntries;
  final SelectMode selectMode;
  final Sorter recipientSorter;
  final Sorter fileSorter;
  final UploadRequestDocumentType uploadRequestDocumentType;
  final UploadRequestGroup? uploadRequestGroup;
  final UploadRequest? selectedUploadRequest;

  ArchivedUploadRequestInsideState(
      Either<Failure, Success> viewState,
      this.uploadRequests,
      this.uploadRequestEntries,
      this.selectMode,
      this.recipientSorter,
      this.fileSorter,
      this.uploadRequestDocumentType,
      this.uploadRequestGroup,
      this.selectedUploadRequest
  ) : super(viewState);

  factory ArchivedUploadRequestInsideState.initial() {
    return ArchivedUploadRequestInsideState(
        Right(IdleState()),
        [],
        [],
        SelectMode.INACTIVE,
        Sorter.fromOrderScreen(OrderScreen.uploadRequestRecipientArchived),
        Sorter.fromOrderScreen(OrderScreen.uploadRequestFileArchived),
        UploadRequestDocumentType.recipients,
        null,
        null);
  }

  @override
  ArchivedUploadRequestInsideState clearViewState() {
    return ArchivedUploadRequestInsideState(
      Right(IdleState()),
      uploadRequests,
      uploadRequestEntries,
      selectMode,
      recipientSorter,
      fileSorter,
      uploadRequestDocumentType,
      uploadRequestGroup,
      selectedUploadRequest
    );
  }

  @override
  ArchivedUploadRequestInsideState sendViewState({required Either<Failure, Success> viewState}) {
    return ArchivedUploadRequestInsideState(
        viewState,
        uploadRequests,
        uploadRequestEntries,
        selectMode,
        recipientSorter,
        fileSorter,
        uploadRequestDocumentType,
        uploadRequestGroup,
        selectedUploadRequest
    );
  }

  ArchivedUploadRequestInsideState setUploadRequestArgument({required UploadRequestArguments newUploadRequestArguments}) {
    return ArchivedUploadRequestInsideState(
      viewState,
      uploadRequests,
      uploadRequestEntries,
      selectMode,
        recipientSorter, fileSorter,
      newUploadRequestArguments.documentType,
      newUploadRequestArguments.uploadRequestGroup,
      newUploadRequestArguments.selectedUploadRequest
    );
  }

  ArchivedUploadRequestInsideState setUploadRequests(
      {Either<Failure, Success>? viewState, required List<UploadRequest> newUploadRequests}) {
    final currentSelectedUploadRequests = uploadRequests
        .where((element) => element.selectMode == SelectMode.ACTIVE)
        .map((selectableElement) => selectableElement.element)
        .toList();

    return ArchivedUploadRequestInsideState(
        viewState ?? this.viewState,
        newUploadRequests
          .where((element) => element.status != UploadRequestStatus.DELETED)
          .map((uploadRequest) => currentSelectedUploadRequests.contains(uploadRequest)
            ? SelectableElement<UploadRequest>(uploadRequest, SelectMode.ACTIVE)
            : SelectableElement<UploadRequest>(uploadRequest, SelectMode.INACTIVE)).toList(),
        uploadRequestEntries,
        selectMode,
        recipientSorter, fileSorter,
        UploadRequestDocumentType.recipients,
        uploadRequestGroup,
        selectedUploadRequest);
  }

  ArchivedUploadRequestInsideState setUploadRequestEntries(
      {Either<Failure, Success>? viewState, required List<UploadRequestEntry> newUploadRequestEntries}) {
    final selectedElements = uploadRequestEntries.where((element) => element.selectMode == SelectMode.ACTIVE).map((element) => element.element).toList();

    return ArchivedUploadRequestInsideState(
        viewState ?? this.viewState,
        uploadRequests,
        newUploadRequestEntries.map((entry) => selectedElements.contains(entry)
          ? SelectableElement<UploadRequestEntry>(entry, SelectMode.ACTIVE)
          : SelectableElement<UploadRequestEntry>(entry, SelectMode.INACTIVE))
          .toList(),
        selectMode,
        recipientSorter, fileSorter,
        UploadRequestDocumentType.files, uploadRequestGroup, selectedUploadRequest);
  }

  ArchivedUploadRequestInsideState setSelectedUploadRequest(
      {required UploadRequest selectedUploadRequest}) {
    return ArchivedUploadRequestInsideState(viewState, uploadRequests, uploadRequestEntries, selectMode, recipientSorter, fileSorter,
        UploadRequestDocumentType.files, uploadRequestGroup, selectedUploadRequest);
  }

  @override
  ArchivedUploadRequestInsideState startLoadingState() {
    return ArchivedUploadRequestInsideState(Right(LoadingState()), uploadRequests, uploadRequestEntries, selectMode, recipientSorter, fileSorter,
        uploadRequestDocumentType, uploadRequestGroup, selectedUploadRequest);
  }

  ArchivedUploadRequestInsideState selectUploadRequestEntry(SelectableElement<UploadRequestEntry> selectedUploadRequestEntry) {
    uploadRequestEntries.firstWhere((entry) => entry == selectedUploadRequestEntry).toggleSelect();
    return ArchivedUploadRequestInsideState(
        viewState,
        uploadRequests,
        uploadRequestEntries,
        SelectMode.ACTIVE,
        recipientSorter,
        fileSorter,
        uploadRequestDocumentType,
        uploadRequestGroup,
        selectedUploadRequest);
  }

  ArchivedUploadRequestInsideState cancelSelectedUploadRequestEntry() {
    return ArchivedUploadRequestInsideState(
        viewState,
        uploadRequests,
        uploadRequestEntries
          .map((entry) => SelectableElement<UploadRequestEntry>(entry.element, SelectMode.INACTIVE))
          .toList(),
        SelectMode.INACTIVE,
        recipientSorter,
        fileSorter,
        uploadRequestDocumentType,
        uploadRequestGroup, 
        selectedUploadRequest
    );
  }

  ArchivedUploadRequestInsideState selectAllUploadRequestEntry() {
    return ArchivedUploadRequestInsideState(
        viewState,
        uploadRequests,
        uploadRequestEntries
          .map((entry) => SelectableElement<UploadRequestEntry>(entry.element, SelectMode.ACTIVE))
          .toList(),
        SelectMode.ACTIVE,
        recipientSorter,
        fileSorter,
        uploadRequestDocumentType,
        uploadRequestGroup,
        selectedUploadRequest
    );
  }

  ArchivedUploadRequestInsideState unSelectAllUploadRequestEntry() {
    return ArchivedUploadRequestInsideState(
        viewState,
        uploadRequests,
        uploadRequestEntries
          .map((entry) => SelectableElement<UploadRequestEntry>(entry.element, SelectMode.INACTIVE))
          .toList(),
        SelectMode.ACTIVE,
        recipientSorter,
        fileSorter,
        uploadRequestDocumentType,
        uploadRequestGroup,
        selectedUploadRequest
    );
  }

  ArchivedUploadRequestInsideState selectUploadRequests(SelectableElement<UploadRequest> newSelectedUploadRequest) {
    uploadRequests.firstWhere((entry) => entry == newSelectedUploadRequest).toggleSelect();
    return ArchivedUploadRequestInsideState(
        viewState,
        uploadRequests,
        uploadRequestEntries,
        SelectMode.ACTIVE,
        recipientSorter,
        fileSorter,
        uploadRequestDocumentType,
        uploadRequestGroup,
        selectedUploadRequest);
  }

  ArchivedUploadRequestInsideState cancelSelectedUploadRequest() {
    return ArchivedUploadRequestInsideState(
        viewState,
        uploadRequests.map((entry) => SelectableElement<UploadRequest>(entry.element, SelectMode.INACTIVE))
            .toList(),
        uploadRequestEntries,
        SelectMode.INACTIVE,
        recipientSorter,
        fileSorter,
        uploadRequestDocumentType,
        uploadRequestGroup,
        selectedUploadRequest
    );
  }

  ArchivedUploadRequestInsideState selectAllUploadRequest() {
    return ArchivedUploadRequestInsideState(
        viewState,
        uploadRequests.map((entry) => SelectableElement<UploadRequest>(entry.element, SelectMode.ACTIVE))
            .toList(),
        uploadRequestEntries,
        SelectMode.ACTIVE,
        recipientSorter,
        fileSorter,
        uploadRequestDocumentType,
        uploadRequestGroup,
        selectedUploadRequest
    );
  }

  ArchivedUploadRequestInsideState unSelectAllUploadRequest() {
    return ArchivedUploadRequestInsideState(
        viewState,
        uploadRequests.map((entry) => SelectableElement<UploadRequest>(entry.element, SelectMode.INACTIVE))
            .toList(),
        uploadRequestEntries,
        SelectMode.ACTIVE,
        recipientSorter,
        fileSorter,
        uploadRequestDocumentType,
        uploadRequestGroup,
        selectedUploadRequest
    );
  }

  ArchivedUploadRequestInsideState setSearchResult({required List<UploadRequestEntry> newSearchResult}) {
    final selectedElements = uploadRequestEntries
        .where((element) => element.selectMode == SelectMode.ACTIVE)
        .map((element) => element.element)
        .toList();
    return ArchivedUploadRequestInsideState(
        viewState,
        uploadRequests,
        newSearchResult.map((entry) => selectedElements.contains(entry)
            ? SelectableElement<UploadRequestEntry>(entry, SelectMode.ACTIVE)
            : SelectableElement<UploadRequestEntry>(entry, SelectMode.INACTIVE)).toList(),
        selectMode,
        recipientSorter,
        fileSorter,
        uploadRequestDocumentType,
        uploadRequestGroup,
        selectedUploadRequest
    );
  }

  ArchivedUploadRequestInsideState setSearchResultRecipients({required List<UploadRequest> newSearchResult}) {
    final selectedElements = uploadRequests
        .where((element) => element.selectMode == SelectMode.ACTIVE)
        .map((element) => element.element)
        .toList();
    return ArchivedUploadRequestInsideState(
        viewState,
        newSearchResult.map((uploadRequest) => selectedElements.contains(uploadRequest)
          ? SelectableElement<UploadRequest>(uploadRequest, SelectMode.ACTIVE)
          : SelectableElement<UploadRequest>(uploadRequest, SelectMode.INACTIVE)).toList(),
        uploadRequestEntries,
        selectMode,
        recipientSorter,
        fileSorter,
        uploadRequestDocumentType,
        uploadRequestGroup,
        selectedUploadRequest
    );
  }

  ArchivedUploadRequestInsideState setUploadRequestsRecipientsWithSort({required List<UploadRequest> newUploadRequestsList, required Sorter newSorter}) {
    final selectedElements = uploadRequests
        .where((element) => element.selectMode == SelectMode.ACTIVE)
        .map((element) => element.element)
        .toList();

    return ArchivedUploadRequestInsideState(
        viewState,
        newUploadRequestsList.map((uploadRequest) => selectedElements.contains(uploadRequest)
            ? SelectableElement<UploadRequest>(uploadRequest, SelectMode.ACTIVE)
            : SelectableElement<UploadRequest>(uploadRequest, SelectMode.INACTIVE)).toList(),
        uploadRequestEntries,
        selectMode,
        newSorter,
        fileSorter,
        uploadRequestDocumentType,
        uploadRequestGroup,
        selectedUploadRequest
    );
  }

  ArchivedUploadRequestInsideState setSorterUploadRequestRecipient({required Sorter newSorter}) {
    return ArchivedUploadRequestInsideState(
        viewState,
        uploadRequests,
        uploadRequestEntries,
        selectMode,
        newSorter,
        fileSorter,
        uploadRequestDocumentType,
        uploadRequestGroup,
        selectedUploadRequest
    );
  }

  ArchivedUploadRequestInsideState setUploadRequestsFilesWithSort({required List<UploadRequestEntry> newUploadRequestsEntries, required Sorter newSorter}) {
    final selectedElements = uploadRequests
        .where((element) => element.selectMode == SelectMode.ACTIVE)
        .map((element) => element.element)
        .toList();

    return ArchivedUploadRequestInsideState(
        viewState,
        uploadRequests,
        newUploadRequestsEntries.map((uploadRequestEntry) => selectedElements.contains(uploadRequestEntry)
            ? SelectableElement<UploadRequestEntry>(uploadRequestEntry, SelectMode.ACTIVE)
            : SelectableElement<UploadRequestEntry>(uploadRequestEntry, SelectMode.INACTIVE)).toList(),
        selectMode,
        recipientSorter,
        newSorter,
        uploadRequestDocumentType,
        uploadRequestGroup,
        selectedUploadRequest
    );
  }

  ArchivedUploadRequestInsideState setSorterUploadRequestFiles({required Sorter newSorter}) {
    return ArchivedUploadRequestInsideState(
        viewState,
        uploadRequests,
        uploadRequestEntries,
        selectMode,
        recipientSorter,
        newSorter,
        uploadRequestDocumentType,
        uploadRequestGroup,
        selectedUploadRequest
    );
  }

  bool isIndividualRecipients() {
    return uploadRequestGroup != null &&
        uploadRequestGroup?.collective == false &&
        uploadRequestDocumentType == UploadRequestDocumentType.recipients;
  }

  bool isCollective() => uploadRequestGroup != null && uploadRequestGroup?.collective == true;

  @override
  List<Object?> get props =>
    [...super.props,
      uploadRequests,
      uploadRequestEntries,
      selectMode,
      recipientSorter,
      fileSorter,
      uploadRequestDocumentType,
      uploadRequestGroup,
      selectedUploadRequest
    ];
}

extension MultipleSelections on ArchivedUploadRequestInsideState {
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
