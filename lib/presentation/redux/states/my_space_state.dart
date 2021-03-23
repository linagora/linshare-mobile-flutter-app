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
class MySpaceState extends LinShareState with EquatableMixin {
  final List<SelectableElement<Document>> documentList;
  final SelectMode selectMode;
  final Sorter sorter;

  MySpaceState(
    Either<Failure, Success> viewState,
    this.documentList,
    this.selectMode,
    this.sorter
  ) : super(viewState);

  factory MySpaceState.initial() {
    return MySpaceState(Right(IdleState()), [], SelectMode.INACTIVE, Sorter(OrderScreen.mySpace, OrderBy.modificationDate, OrderType.descending));
  }

  @override
  LinShareState clearViewState() {
    return MySpaceState(Right(IdleState()), documentList, selectMode, sorter);
  }

  @override
  LinShareState sendViewState({Either<Failure, Success> viewState}) {
    return MySpaceState(viewState, documentList, selectMode, sorter);
  }

  LinShareState setDocuments({Either<Failure, Success> viewState, List<Document> newDocumentList}) {
    final selectedElements = documentList.where((element) => element.selectMode == SelectMode.ACTIVE).map((element) => element.element).toList();

    return MySpaceState(viewState ?? this.viewState,
      {for (var document in newDocumentList)
          if (selectedElements.contains(document))
            SelectableElement<Document>(document, SelectMode.ACTIVE)
          else SelectableElement<Document>(document, SelectMode.INACTIVE)}.toList(),
      selectMode, sorter);
  }

  LinShareState setDocumentsWithSorter({Either<Failure, Success> viewState, List<Document> newDocumentList, Sorter newSorter}) {
    final selectedElements = documentList.where((element) => element.selectMode == SelectMode.ACTIVE).map((element) => element.element).toList();

    return MySpaceState(viewState ?? this.viewState,
        {for (var document in newDocumentList)
          if (selectedElements.contains(document))
            SelectableElement<Document>(document, SelectMode.ACTIVE)
          else SelectableElement<Document>(document, SelectMode.INACTIVE)}.toList(),
        selectMode, newSorter);
  }

  LinShareState setSorter({Either<Failure, Success> viewState, Sorter newSorter}) {
    return MySpaceState(viewState ?? this.viewState, documentList, selectMode, newSorter);
  }

  LinShareState selectDocument(SelectableElement<Document> selectedDocument) {
    documentList.firstWhere((document) => document == selectedDocument).toggleSelect();
    return MySpaceState(viewState, documentList, SelectMode.ACTIVE, sorter);
  }

  LinShareState cancelSelectedDocuments() {
    return MySpaceState(viewState, documentList.map((document) => SelectableElement<Document>(document.element, SelectMode.INACTIVE)).toList(), SelectMode.INACTIVE, sorter);
  }

  LinShareState selectAllDocuments() {
    return MySpaceState(viewState, documentList.map((document) => SelectableElement<Document>(document.element, SelectMode.ACTIVE)).toList(), SelectMode.ACTIVE, sorter);
  }

  LinShareState unSelectAllDocuments() {
    return MySpaceState(viewState, documentList.map((document) => SelectableElement<Document>(document.element, SelectMode.INACTIVE)).toList(), SelectMode.ACTIVE, sorter);
  }

  @override
  MySpaceState startLoadingState() {
    return MySpaceState(Right(LoadingState()), documentList, selectMode, sorter);
  }

  @override
  List<Object> get props => [
    ...super.props,
    documentList,
    selectMode,
    sorter
  ];
}

extension MultipleSelections on MySpaceState {
  bool isAllDocumentsSelected() {
    return documentList.every((value) => value.selectMode == SelectMode.ACTIVE);
  }

  List<Document> getAllSelectedDocuments() {
    return documentList.where((element) => element.selectMode == SelectMode.ACTIVE).map((document) => document.element).toList();
  }
}
