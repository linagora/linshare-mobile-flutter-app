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
class StartActiveClosedUploadRequestInsideLoadingAction extends ActionOnline {}

@immutable
class ActiveClosedUploadRequestInsideAction extends ActionOffline {
  final Either<Failure, Success> viewState;

  ActiveClosedUploadRequestInsideAction(this.viewState);
}

@immutable
class GetAllActiveClosedUploadRequestsAction extends ActionOnline {
  final Either<Failure, Success> viewState;

  GetAllActiveClosedUploadRequestsAction(this.viewState);
}

@immutable
class SetActiveClosedUploadRequestsArgumentsAction extends ActionOnline {
  final UploadRequestArguments arguments;

  SetActiveClosedUploadRequestsArgumentsAction(this.arguments);
}

@immutable
class GetAllActiveClosedUploadRequestEntriesAction extends ActionOnline {
  final Either<Failure, Success> viewState;

  GetAllActiveClosedUploadRequestEntriesAction(this.viewState);
}

@immutable
class SetSelectedActiveClosedUploadRequestAction extends ActionOnline {
  final UploadRequest selectedUploadRequest;

  SetSelectedActiveClosedUploadRequestAction(this.selectedUploadRequest);
}

@immutable
class ClearActiveClosedUploadRequestEntriesListAction extends ActionOffline {
  ClearActiveClosedUploadRequestEntriesListAction();
}

@immutable
class ClearActiveClosedUploadRequestsListAction extends ActionOffline {
  ClearActiveClosedUploadRequestsListAction();
}

class ActiveClosedUploadRequestSelectEntryAction extends ActionOffline {
  final SelectableElement<UploadRequestEntry> selectedEntry;

  ActiveClosedUploadRequestSelectEntryAction(this.selectedEntry);
}

@immutable
class ActiveClosedUploadRequestClearSelectedEntryAction extends ActionOffline {
  ActiveClosedUploadRequestClearSelectedEntryAction();
}

@immutable
class ActiveClosedUploadRequestSelectAllEntryAction extends ActionOffline {
  ActiveClosedUploadRequestSelectAllEntryAction();
}

@immutable
class ActiveClosedUploadRequestUnSelectAllEntryAction extends ActionOffline {
  ActiveClosedUploadRequestUnSelectAllEntryAction();
}

@immutable
class ActiveClosedUploadRequestEntrySetSearchResultAction extends ActionOffline {
  final List<UploadRequestEntry> uploadRequestEntries;

  ActiveClosedUploadRequestEntrySetSearchResultAction(this.uploadRequestEntries);
}

class SelectActiveClosedUploadRequestAction extends ActionOffline {
  final SelectableElement<UploadRequest> selectedUploadRequest;

  SelectActiveClosedUploadRequestAction(this.selectedUploadRequest);
}

@immutable
class ClearActiveClosedUploadRequestSelectionAction extends ActionOffline {
  ClearActiveClosedUploadRequestSelectionAction();
}

@immutable
class ActiveClosedUploadRequestSelectAllRecipientAction extends ActionOffline {
  ActiveClosedUploadRequestSelectAllRecipientAction();
}

@immutable
class ActiveClosedUploadRequestUnSelectAllRecipientAction extends ActionOffline {
  ActiveClosedUploadRequestUnSelectAllRecipientAction();
}

@immutable
class ActiveClosedUploadRequestSetSearchResultAction extends ActionOffline {
  final List<UploadRequest> uploadRequests;

  ActiveClosedUploadRequestSetSearchResultAction(this.uploadRequests);
}

@immutable
class CleanActiveClosedUploadRequestInsideAction extends ActionOffline {
  CleanActiveClosedUploadRequestInsideAction();
}

@immutable
class ActiveClosedUploadRequestInsideGetSorterAction extends ActionOffline {
  final Sorter sorter;

  ActiveClosedUploadRequestInsideGetSorterAction(this.sorter);
}

@immutable
class ActiveClosedUploadRequestInsideSortAction extends ActionOffline {
  final List<UploadRequest> uploadRequests;
  final Sorter sorter;

  ActiveClosedUploadRequestInsideSortAction(this.uploadRequests, this.sorter);
}

@immutable
class ActiveClosedUploadRequestEntryInsideGetSorterAction extends ActionOffline {
  final Sorter sorter;

  ActiveClosedUploadRequestEntryInsideGetSorterAction(this.sorter);
}

@immutable
class ActiveClosedUploadRequestEntryInsideSortAction extends ActionOffline {
  final List<UploadRequestEntry> uploadRequestEntries;
  final Sorter sorter;

  ActiveClosedUploadRequestEntryInsideSortAction(this.uploadRequestEntries, this.sorter);
}