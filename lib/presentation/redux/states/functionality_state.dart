// LinShare is an open source filesharing software, part of the LinPKI software
// suite, developed by Linagora.
//
// Copyright (C) 2021 LINAGORA
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
import 'package:linshare_flutter_app/presentation/redux/states/linshare_state.dart';

@immutable
class FunctionalityState extends LinShareState {
  final List<Functionality?> functionalityList;

  FunctionalityState(Either<Failure, Success> viewState, this.functionalityList) : super(viewState);

  factory FunctionalityState.initial() {
    return FunctionalityState(Right(IdleState()), []);
  }

  FunctionalityState setFunctionalityList(List<Functionality> functionalityList) {
    return FunctionalityState(viewState, functionalityList);
  }

  @override
  FunctionalityState clearViewState() {
    return FunctionalityState(Right(IdleState()), functionalityList);
  }

  @override
  FunctionalityState sendViewState({required Either<Failure, Success> viewState}) {
    return FunctionalityState(viewState, functionalityList);
  }

  @override
  FunctionalityState startLoadingState() {
    return FunctionalityState(Right(LoadingState()), functionalityList);
  }
}

extension FunctionalityStateExtension on FunctionalityState {
  bool isSharedSpaceEnable() => _isFunctionalityEnable(FunctionalityIdentifier.WORK_GROUP);

  bool isCreateWorkgroupEnable() => _isFunctionalityEnable(FunctionalityIdentifier.WORK_GROUP__CREATION_RIGHT);

  bool isDriveEnable() => _isFunctionalityEnable(FunctionalityIdentifier.DRIVE);

  bool isDriveCreationEnable() => _isFunctionalityEnable(FunctionalityIdentifier.DRIVE__CREATION_RIGHT);

  bool isUploadRequestEnable() => _isFunctionalityEnable(FunctionalityIdentifier.UPLOAD_REQUEST);

  bool _isFunctionalityEnable(FunctionalityIdentifier functionalityIdentifier) {
    final functionality = functionalityList.firstWhere(
            (element) => (element != null && element.identifier == functionalityIdentifier),
        orElse: () => null);
    if (functionality != null) {
      return functionality.enable;
    }
    return true;
  }

  List<Functionality?> getAllEnabledUploadRequest() {
    return functionalityList
        .where((element) =>
            element != null &&
            element.enable &&
            element.identifier.name.contains(FunctionalityIdentifier.UPLOAD_REQUEST.name))
        .toList();
  }
}
