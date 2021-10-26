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

import 'package:dartz/dartz.dart';
import 'package:domain/domain.dart';
import 'package:domain/src/state/failure.dart';
import 'package:domain/src/state/success.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:linshare_flutter_app/presentation/model/advance_search_date_state.dart';
import 'package:linshare_flutter_app/presentation/model/advance_search_kind_state.dart';
import 'package:linshare_flutter_app/presentation/model/advance_search_setting.dart';
import 'package:linshare_flutter_app/presentation/redux/states/linshare_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/ui_state.dart';

@immutable
class AdvanceSearchSettingsWorkgroupNodeState extends LinShareState with EquatableMixin {
  final AdvanceSearchSetting advanceSearchSetting;

  AdvanceSearchSettingsWorkgroupNodeState(Either<Failure, Success> viewState, this.advanceSearchSetting)
      : super(viewState);

  factory AdvanceSearchSettingsWorkgroupNodeState.initial() {
    return AdvanceSearchSettingsWorkgroupNodeState(
        Right(IdleState()), AdvanceSearchSetting.fromSearchDestination(SearchDestination.sharedSpace));
  }

  @override
  AdvanceSearchSettingsWorkgroupNodeState clearViewState() {
    return AdvanceSearchSettingsWorkgroupNodeState(Right(IdleState()), advanceSearchSetting);
  }

  @override
  AdvanceSearchSettingsWorkgroupNodeState sendViewState({required Either<Failure, Success> viewState}) {
    return AdvanceSearchSettingsWorkgroupNodeState(viewState, advanceSearchSetting);
  }

  @override
  AdvanceSearchSettingsWorkgroupNodeState startLoadingState() {
    return AdvanceSearchSettingsWorkgroupNodeState(Right(LoadingState()), advanceSearchSetting);
  }

  AdvanceSearchSettingsWorkgroupNodeState setNewKindState({Either<Failure, Success>? viewState, required AdvanceSearchKindState? newAdvanceSearchKindState}) {
    final updatedKindList = advanceSearchSetting.listKindState?.map((e) {
      if (e.kind == newAdvanceSearchKindState?.kind) {
        return e.copyWith(kind: e.kind, selected: newAdvanceSearchKindState?.selected);
      }
      return e;
    }).toList();
    final updatedAdvanceSearchSetting = advanceSearchSetting.copyWith(newListKindState: updatedKindList);
    return AdvanceSearchSettingsWorkgroupNodeState(viewState ?? this.viewState, updatedAdvanceSearchSetting);
  }

  AdvanceSearchSettingsWorkgroupNodeState setNewDateState({Either<Failure, Success>? viewState, required AdvanceSearchDateState? newAdvanceSearchDateState}) {
    final updatedDateList = advanceSearchSetting.listModificationDate?.map((e) {
      if (e.date == newAdvanceSearchDateState?.date) {
        return e.copyWith(date: e.date, selected: newAdvanceSearchDateState?.selected);
      }
      return e.copyWith(date: e.date, selected: false);
    }).toList();
    final updatedAdvanceSearchSetting = advanceSearchSetting.copyWith(newListModificationDate: updatedDateList);
    return AdvanceSearchSettingsWorkgroupNodeState(viewState ?? this.viewState, updatedAdvanceSearchSetting);
  }

  AdvanceSearchSettingsWorkgroupNodeState resetAllSettings() {
    return AdvanceSearchSettingsWorkgroupNodeState(viewState, AdvanceSearchSetting.fromSearchDestination(SearchDestination.sharedSpace));
  }

  AdvanceSearchSettingsWorkgroupNodeState applySearch() {
    return AdvanceSearchSettingsWorkgroupNodeState(viewState, AdvanceSearchSetting.fromSearchDestination(SearchDestination.sharedSpace));
  }
}
