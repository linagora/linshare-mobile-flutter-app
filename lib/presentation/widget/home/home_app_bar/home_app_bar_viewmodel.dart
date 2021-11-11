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

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:domain/domain.dart';
import 'package:flutter/widgets.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/my_space_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/received_share_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/shared_space_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/workgroup_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_request_group_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_request_group_active_closed_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_request_group_archived_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_request_group_created_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_request_inside_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:redux/redux.dart';

class HomeAppBarViewModel extends BaseViewModel {
  late StreamSubscription _streamSubscription;

  HomeAppBarViewModel(Store<AppState> store) : super(store);

  void registerViewStateHandler(TextEditingController _typeAheadController) {
    _streamSubscription = store.onChange.listen((event) {
      _handleMySpaceViewState(_typeAheadController, event.mySpaceState.viewState);
      _handleReceivedShareViewState(_typeAheadController, event.receivedShareState.viewState);
      _handleSharedSpaceViewState(_typeAheadController, event.sharedSpaceState.viewState);
      _handleWorkgroupViewState(_typeAheadController, event.workgroupState.viewState);
      _handleUploadRequestGroupsViewState(_typeAheadController, event.uploadRequestGroupState.viewState);
      _handleUploadRequestInsideViewState(_typeAheadController, event.uploadRequestInsideState.viewState);
    });
  }

  void _handleMySpaceViewState(
      TextEditingController _typeAheadController, Either<Failure, Success> viewState) {
    viewState.fold((failure) => null, (success) {
      if (success is DisableSearchViewState) {
        _typeAheadController.clear();
        store.dispatch(CleanMySpaceStateAction());
      }
    });
  }

  void _handleReceivedShareViewState(
      TextEditingController _typeAheadController, Either<Failure, Success> viewState) {
    viewState.fold((failure) => null, (success) {
      if (success is DisableSearchViewState) {
        _typeAheadController.clear();
        store.dispatch(CleanReceivedShareStateAction());
      }
    });
  }

  void _handleSharedSpaceViewState(
      TextEditingController _typeAheadController, Either<Failure, Success> viewState) {
    viewState.fold((failure) => null, (success) {
      if (success is DisableSearchViewState) {
        _typeAheadController.clear();
        store.dispatch(CleanSharedSpaceStateAction());
      }
    });
  }

  void _handleWorkgroupViewState(
      TextEditingController _typeAheadController, Either<Failure, Success> viewState) {
    viewState.fold((failure) => null, (success) {
      if (success is DisableSearchViewState) {
        _typeAheadController.clear();
        store.dispatch(CleanWorkgroupStateAction());
      }
    });
  }

  void _handleUploadRequestGroupsViewState(
      TextEditingController _typeAheadController, Either<Failure, Success> viewState) {
    viewState.fold((failure) => null, (success) {
      if (success is DisableSearchViewState) {
        _typeAheadController.clear();
				store.dispatch(CleanUploadRequestGroupAction());
				store.dispatch(CleanCreatedUploadRequestGroupAction());
				store.dispatch(CleanArchivedUploadRequestGroupAction());
				store.dispatch(CleanActiveClosedUploadRequestGroupAction());
      }
    });
  }

  void _handleUploadRequestInsideViewState(
      TextEditingController _typeAheadController, Either<Failure, Success> viewState) {
    viewState.fold((failure) => null, (success) {
      if (success is DisableSearchViewState) {
        _typeAheadController.clear();
        store.dispatch(CleanUploadRequestInsideAction());
      }
    });
  }

  @override
  void onDisposed() {
    _streamSubscription.cancel();
    super.onDisposed();
  }
}
