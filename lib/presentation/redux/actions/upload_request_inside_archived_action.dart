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
import 'package:flutter/foundation.dart';
import 'package:linshare_flutter_app/presentation/model/file/selectable_element.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/app_action.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/upload_request_document_arguments.dart';

@immutable
class StartArchivedUploadRequestInsideLoadingAction extends ActionOnline {}

@immutable
class ArchivedUploadRequestInsideAction extends ActionOffline {
  final Either<Failure, Success> viewState;

  ArchivedUploadRequestInsideAction(this.viewState);
}

@immutable
class GetAllArchivedUploadRequestsAction extends ActionOnline {
  final Either<Failure, Success> viewState;

  GetAllArchivedUploadRequestsAction(this.viewState);
}

@immutable
class SetArchivedUploadRequestsArgumentsAction extends ActionOnline {
  final UploadRequestArguments arguments;

  SetArchivedUploadRequestsArgumentsAction(this.arguments);
}

@immutable
class GetAllArchivedUploadRequestEntriesAction extends ActionOnline {
  final Either<Failure, Success> viewState;

  GetAllArchivedUploadRequestEntriesAction(this.viewState);
}

@immutable
class SetSelectedArchivedUploadRequestAction extends ActionOnline {
  final UploadRequest selectedUploadRequest;

  SetSelectedArchivedUploadRequestAction(this.selectedUploadRequest);
}

@immutable
class ClearArchivedUploadRequestEntriesListAction extends ActionOffline {
  ClearArchivedUploadRequestEntriesListAction();
}

@immutable
class ClearArchivedUploadRequestsListAction extends ActionOffline {
  ClearArchivedUploadRequestsListAction();
}

class ArchivedUploadRequestSelectEntryAction extends ActionOffline {
  final SelectableElement<UploadRequestEntry> selectedEntry;

  ArchivedUploadRequestSelectEntryAction(this.selectedEntry);
}

@immutable
class ArchivedUploadRequestClearSelectedEntryAction extends ActionOffline {
  ArchivedUploadRequestClearSelectedEntryAction();
}

@immutable
class ArchivedUploadRequestSelectAllEntryAction extends ActionOffline {
  ArchivedUploadRequestSelectAllEntryAction();
}

@immutable
class ArchivedUploadRequestUnSelectAllEntryAction extends ActionOffline {
  ArchivedUploadRequestUnSelectAllEntryAction();
}

@immutable
class ArchivedUploadRequestEntrySetSearchResultAction extends ActionOffline {
  final List<UploadRequestEntry> uploadRequestEntries;

  ArchivedUploadRequestEntrySetSearchResultAction(this.uploadRequestEntries);
}

@immutable
class CleanArchivedUploadRequestInsideAction extends ActionOffline {
  CleanArchivedUploadRequestInsideAction();
}

class SelectArchivedUploadRequestAction extends ActionOffline {
  final SelectableElement<UploadRequest> selectedUploadRequest;

  SelectArchivedUploadRequestAction(this.selectedUploadRequest);
}

@immutable
class ClearArchivedUploadRequestSelectionAction extends ActionOffline {
  ClearArchivedUploadRequestSelectionAction();
}

@immutable
class ArchivedUploadRequestSelectAllRecipientAction extends ActionOffline {
  ArchivedUploadRequestSelectAllRecipientAction();
}

@immutable
class ArchivedUploadRequestUnSelectAllRecipientAction extends ActionOffline {
  ArchivedUploadRequestUnSelectAllRecipientAction();
}

@immutable
class ArchivedUploadRequestSetSearchResultAction extends ActionOffline {
  final List<UploadRequest> uploadRequests;

  ArchivedUploadRequestSetSearchResultAction(this.uploadRequests);
}