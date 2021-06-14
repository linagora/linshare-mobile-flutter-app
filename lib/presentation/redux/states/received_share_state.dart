/*
 * LinShare is an open source filesharing software, part of the LinPKI software
 * suite, developed by Linagora.
 *
 * Copyright (C) 2021 LINAGORA
 *
 * This program is free software: you can redistribute it and/or modify it under the
 * terms of the GNU Affero General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version,
 * provided you comply with the Additional Terms applicable for LinShare software by
 * Linagora pursuant to Section 7 of the GNU Affero General Public License,
 * subsections (b), (c), and (e), pursuant to which you must notably (i) retain the
 * display in the interface of the “LinShare™” trademark/logo, the "Libre & Free" mention,
 * the words “You are using the Free and Open Source version of LinShare™, powered by
 * Linagora © 2009–2021. Contribute to Linshare R&D by subscribing to an Enterprise
 * offer!”. You must also retain the latter notice in all asynchronous messages such as
 * e-mails sent with the Program, (ii) retain all hypertext links between LinShare and
 * http://www.linshare.org, between linagora.com and Linagora, and (iii) refrain from
 * infringing Linagora intellectual property rights over its trademarks and commercial
 * brands. Other Additional Terms apply, see
 * <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf>
 * for more details.
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for
 * more details.
 * You should have received a copy of the GNU Affero General Public License and its
 * applicable Additional Terms for LinShare along with this program. If not, see
 * <http://www.gnu.org/licenses/> for the GNU Affero General Public License version
 *  3 and <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf> for
 *  the Additional Terms applicable to LinShare software.
 */

import 'package:dartz/dartz.dart';
import 'package:domain/domain.dart';
import 'package:domain/src/state/failure.dart';
import 'package:domain/src/state/success.dart';
import 'package:equatable/equatable.dart';
import 'package:linshare_flutter_app/presentation/model/file/selectable_element.dart';
import 'package:linshare_flutter_app/presentation/redux/states/linshare_state.dart';

class ReceivedShareState extends LinShareState with EquatableMixin {
  final List<SelectableElement<ReceivedShare>> receivedSharesList;
  final SelectMode selectMode;
  final Sorter sorter;

  ReceivedShareState(
      Either<Failure, Success> viewState,
      this.receivedSharesList,
      this.selectMode,
      this.sorter
  ) : super(viewState);

  factory ReceivedShareState.initial() {
    return ReceivedShareState(Right(IdleState()), [], SelectMode.INACTIVE, Sorter.fromOrderScreen(OrderScreen.receivedShares));
  }

  ReceivedShareState setReceivedShareList(List<ReceivedShare> newReceivedShareList, {Either<Failure, Success>? viewState}) {
    final selectedElements = receivedSharesList.where((element) => element.selectMode == SelectMode.ACTIVE).map((element) => element.element).toList();

    return ReceivedShareState(
      viewState ?? this.viewState,
      {for (var receivedShare in newReceivedShareList)
          if (selectedElements.contains(receivedShare))
            SelectableElement<ReceivedShare>(receivedShare, SelectMode.ACTIVE)
          else SelectableElement<ReceivedShare>(receivedShare, SelectMode.INACTIVE)}.toList(),
      selectMode,
      sorter
    );
  }

  ReceivedShareState setReceivedSharesWithSorter(
      {Either<Failure, Success>? viewState,
      required List<ReceivedShare> newReceivedShareList,
        required Sorter newSorter}) {
    final selectedElements = receivedSharesList
        .where((element) => element.selectMode == SelectMode.ACTIVE)
        .map((element) => element.element)
        .toList();

    return ReceivedShareState(
        viewState ?? this.viewState,
        {
          for (var receivedShare in newReceivedShareList)
            if (selectedElements.contains(receivedShare))
              SelectableElement<ReceivedShare>(receivedShare, SelectMode.ACTIVE)
            else
              SelectableElement<ReceivedShare>(receivedShare, SelectMode.INACTIVE)
        }.toList(),
        selectMode,
        newSorter);
  }

  ReceivedShareState setSorter({Either<Failure, Success>? viewState, required Sorter newSorter}) {
    return ReceivedShareState(viewState ?? this.viewState, receivedSharesList, selectMode, newSorter);
  }

  @override
  ReceivedShareState clearViewState() {
    return ReceivedShareState(Right(IdleState()), receivedSharesList, selectMode, sorter);
  }

  @override
  ReceivedShareState sendViewState({required Either<Failure, Success> viewState}) {
    return ReceivedShareState(viewState, receivedSharesList, selectMode, sorter);
  }

  @override
  ReceivedShareState startLoadingState() {
    return ReceivedShareState(Right(LoadingState()), receivedSharesList, selectMode, sorter);
  }

  ReceivedShareState selectReceivedShare(SelectableElement<ReceivedShare> selectedReceivedShare) {
    receivedSharesList.firstWhere((receivedShare) => receivedShare == selectedReceivedShare).toggleSelect();
    return ReceivedShareState(viewState, receivedSharesList, SelectMode.ACTIVE, sorter);
  }

  ReceivedShareState cancelSelectedReceivedShares() {
    return ReceivedShareState(viewState, receivedSharesList.map((receivedShare) => SelectableElement<ReceivedShare>(receivedShare.element, SelectMode.INACTIVE)).toList(), SelectMode.INACTIVE, sorter);
  }

  ReceivedShareState selectAllReceivedShares() {
    return ReceivedShareState(viewState, receivedSharesList.map((receivedShare) => SelectableElement<ReceivedShare>(receivedShare.element, SelectMode.ACTIVE)).toList(), SelectMode.ACTIVE, sorter);
  }

  ReceivedShareState unselectAllReceivedShares() {
    return ReceivedShareState(viewState, receivedSharesList.map((receivedShare) => SelectableElement<ReceivedShare>(receivedShare.element, SelectMode.INACTIVE)).toList(), SelectMode.ACTIVE, sorter);
  }
}

extension MultipleSelections on ReceivedShareState {
  bool isAllReceivedSharesSelected() {
    return receivedSharesList.every((value) => value.selectMode == SelectMode.ACTIVE);
  }

  List<ReceivedShare> getAllSelectedReceivedShares() {
    return receivedSharesList.where((element) => element.selectMode == SelectMode.ACTIVE).map((receivedShare) => receivedShare.element).toList();
  }
}
