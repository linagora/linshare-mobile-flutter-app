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
import 'package:linshare_flutter_app/presentation/redux/actions/share_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_file_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/upload_file_arguments.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:rxdart/rxdart.dart';

class UploadFileViewModel extends BaseViewModel {
  final AppNavigation _appNavigation;
  final UploadFileInteractor _uploadFileInteractor;
  final ShareDocumentInteractor _shareDocumentInteractor;
  final GetAutoCompleteSharingInteractor _getAutoCompleteSharingInteractor;
  StreamSubscription _autoCompleteResultListSubscription;

  UploadFileViewModel(
    Store<AppState> store,
    this._appNavigation,
    this._uploadFileInteractor,
    this._shareDocumentInteractor,
    this._getAutoCompleteSharingInteractor,
  ) : super(store) {
    _autoCompleteResultListSubscription = _autoCompleteResultListObservable.listen((value) {
      if (_shareTypeArgument == ShareType.quickShare) {
        value.isEmpty ? _enableUploadAndShareButton.add(false) : _enableUploadAndShareButton.add(true);
      }
    });
  }

  FileInfo _fileInfoArgument;

  ShareType _shareTypeArgument = ShareType.uploadAndShare;
  ShareType get shareTypeArgument => _shareTypeArgument;

  Document _documentArgument;

  final BehaviorSubject<List<AutoCompleteResult>> _autoCompleteResultListObservable = BehaviorSubject.seeded([]);
  BehaviorSubject<List<AutoCompleteResult>> get autoCompleteResultListObservable => _autoCompleteResultListObservable;

  final BehaviorSubject<bool> _enableUploadAndShareButton = BehaviorSubject.seeded(true);
  BehaviorSubject<bool> get enableUploadAndShareButton => _enableUploadAndShareButton;

  void backToMySpace() {
    _appNavigation.popBack();
    store.dispatch(CleanUploadStateAction());
  }

  void setFileInfoArgument(FileInfo fileInfo) {
    _fileInfoArgument = fileInfo;
  }

  void setShareTypeArgument(ShareType shareType) {
    _shareTypeArgument = shareType;
  }

  void setDocumentArgument(Document document) {
    _documentArgument = document;
  }

  void addUserEmail(AutoCompleteResult autoCompleteResult) {
    final newAutoCompleteResultList = _autoCompleteResultListObservable.value;
    newAutoCompleteResultList.add(autoCompleteResult);
    _autoCompleteResultListObservable.add(newAutoCompleteResultList);
  }

  void removeUserEmail(int index) {
    final newAutoCompleteResultList = _autoCompleteResultListObservable.value;
    newAutoCompleteResultList.removeAt(index);
    _autoCompleteResultListObservable.add(newAutoCompleteResultList);
  }

  String get fileName => _shareTypeArgument == ShareType.quickShare ? _documentArgument.name : _fileInfoArgument.fileName;

  int get fileSize => _shareTypeArgument == ShareType.quickShare ? _documentArgument.size : _fileInfoArgument.fileSize;

  void handleOnUploadAndSharePressed() {
    if (_shareTypeArgument == ShareType.quickShare) {
      _handleQuickShare();
    } else {
      _handleUploadAndShare();
    }
    _appNavigation.popBack();
  }

  void _handleQuickShare() {
    if (_documentArgument != null) {
      store.dispatch(shareAction());
    }
  }

  void _handleUploadAndShare() {
    if (_fileInfoArgument != null) {
      store.dispatch(uploadFileAction(_fileInfoArgument));
    }
  }

  Future<List<AutoCompleteResult>> getAutoCompleteSharing(
      String pattern) async {
    return await _getAutoCompleteSharingInteractor
        .execute(AutoCompletePattern(pattern), AutoCompleteType.sharing)
        .then((viewState) => viewState.fold(
            (failure) => <AutoCompleteResult>[],
            (success) => (success as AutoCompleteViewState).results));
  }

  ThunkAction<AppState> shareAction() {
    return (Store<AppState> store) async {
      final genericUserList = _autoCompleteResultListObservable.value
          .where((element) => element is UserAutoCompleteResult || element is SimpleAutoCompleteResult)
          .map((data) => GenericUser(data.getSuggestionMail(), firstName: none(), lastName: none()))
          .toList();
      final mailingListIdList = _autoCompleteResultListObservable.value
          .whereType<MailingListAutoCompleteResult>()
          .map((data) => MailingListId(data.identifier))
          .toList();
      final documentIdList = [_documentArgument.documentId];
      await _shareDocumentInteractor
          .execute(documentIdList, mailingListIdList, genericUserList)
          .then((viewState) {
            viewState.fold(
              (failure) => store.dispatch(ShareAction(Left(failure))),
              (success) => store.dispatch(ShareAction(Right(success))));
      });
    };
  }

  ThunkAction<AppState> uploadFileAction(FileInfo fileInfo) {
    return (Store<AppState> store) async {
      await _uploadFileInteractor.execute(fileInfo).forEach((viewState) {
        viewState.fold(
          (failure) => store.dispatch(UploadFileAction(Left(failure))),
          (success) => handleUploadFileSuccess(store, success));
      });
    };
  }

  void handleUploadFileSuccess(Store<AppState> store, Success success) {
    if (success is PreparingUpload) {
      store.dispatch(StartUploadLoadingAction());
    } else {
      store.dispatch(UploadFileAction(Right(success)));
    }
  }

  @override
  void onDisposed() {
    _autoCompleteResultListSubscription.cancel();
    super.onDisposed();
  }
}
