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
import 'package:flutter/widgets.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/document_details_action.dart';
import 'package:linshare_flutter_app/presentation/redux/online_thunk_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:redux/redux.dart';

import 'document_details_arguments.dart';

class DocumentDetailsViewModel extends BaseViewModel {
  final AppNavigation _appNavigation;
  final GetDocumentInteractor _getDocumentInteractor;
  final EditDescriptionDocumentInteractor _editDescriptionDocumentInteractor;

  DocumentDetailsViewModel(
      Store<AppState> store,
      this._appNavigation,
      this._getDocumentInteractor,
      this._editDescriptionDocumentInteractor
  ) : super(store);

  void initState(DocumentDetailsArguments arguments) {
    store.dispatch(_getDocumentAction(arguments.document.documentId));
  }

  void backToMySpace() {
    _appNavigation.popBack();
  }

  void editDescription(BuildContext context, Document document, String newDescription) {
    FocusScope.of(context).unfocus();
    toggleDescriptionEditing();

    if (document.description == newDescription) {
      return;
    }

    store.dispatch(_editDescriptionAction(document, newDescription));
  }

  OnlineThunkAction _editDescriptionAction(Document document, String newDescription) {
    return OnlineThunkAction((Store<AppState> store) async {
      (await _editDescriptionDocumentInteractor.execute(
              document.documentId, EditDescriptionDocumentRequest(document.name, newDescription)))
          .fold((failure) => store.dispatch(DocumentDetailsAction(Left(failure))),
              (success) => store.dispatch(Right(success)));
      store.dispatch(_getDocumentAction(document.documentId));
    });
  }

  OnlineThunkAction _getDocumentAction(DocumentId documentId) {
    return OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(DocumentDetailsGetDocumentAction(await _getDocumentInteractor.execute(documentId)));
    });
  }

  void toggleDescriptionEditing() {
    store.dispatch(DocumentDetailsToggleDescriptionEditing());
  }

  @override
  void onDisposed() {
    store.dispatch(CleanDocumentDetailsStateAction());
    super.onDisposed();
  }
}
