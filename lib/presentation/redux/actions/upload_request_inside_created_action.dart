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
class StartCreatedUploadRequestInsideLoadingAction extends ActionOnline {}

@immutable
class CreatedUploadRequestInsideAction extends ActionOffline {
  final Either<Failure, Success> viewState;

  CreatedUploadRequestInsideAction(this.viewState);
}

@immutable
class GetAllCreatedUploadRequestsAction extends ActionOnline {
  final Either<Failure, Success> viewState;

  GetAllCreatedUploadRequestsAction(this.viewState);
}

@immutable
class SetCreatedUploadRequestsArgumentsAction extends ActionOnline {
  final UploadRequestArguments arguments;

  SetCreatedUploadRequestsArgumentsAction(this.arguments);
}

@immutable
class GetAllCreatedUploadRequestEntriesAction extends ActionOnline {
  final Either<Failure, Success> viewState;

  GetAllCreatedUploadRequestEntriesAction(this.viewState);
}

@immutable
class SetSelectedCreatedUploadRequestAction extends ActionOnline {
  final UploadRequest selectedUploadRequest;

  SetSelectedCreatedUploadRequestAction(this.selectedUploadRequest);
}

@immutable
class ClearCreatedUploadRequestEntriesListAction extends ActionOffline {
  ClearCreatedUploadRequestEntriesListAction();
}

@immutable
class ClearCreatedUploadRequestsListAction extends ActionOffline {
  ClearCreatedUploadRequestsListAction();
}

class CreatedUploadRequestSelectEntryAction extends ActionOffline {
  final SelectableElement<UploadRequestEntry> selectedEntry;

  CreatedUploadRequestSelectEntryAction(this.selectedEntry);
}

@immutable
class CreatedUploadRequestClearSelectedEntryAction extends ActionOffline {
  CreatedUploadRequestClearSelectedEntryAction();
}

@immutable
class CreatedUploadRequestSelectAllEntryAction extends ActionOffline {
  CreatedUploadRequestSelectAllEntryAction();
}

@immutable
class CreatedUploadRequestUnSelectAllEntryAction extends ActionOffline {
  CreatedUploadRequestUnSelectAllEntryAction();
}

@immutable
class CreatedUploadRequestEntrySetSearchResultAction extends ActionOffline {
  final List<UploadRequestEntry> uploadRequestEntries;

  CreatedUploadRequestEntrySetSearchResultAction(this.uploadRequestEntries);
}

@immutable
class CleanCreatedUploadRequestInsideAction extends ActionOffline {
  CleanCreatedUploadRequestInsideAction();
}

class SelectCreatedUploadRequestAction extends ActionOffline {
  final SelectableElement<UploadRequest> selectedUploadRequest;

  SelectCreatedUploadRequestAction(this.selectedUploadRequest);
}

@immutable
class ClearCreatedUploadRequestSelectionAction extends ActionOffline {
  ClearCreatedUploadRequestSelectionAction();
}

@immutable
class CreatedUploadRequestSelectAllRecipientAction extends ActionOffline {
  CreatedUploadRequestSelectAllRecipientAction();
}

@immutable
class CreatedUploadRequestUnSelectAllRecipientAction extends ActionOffline {
  CreatedUploadRequestUnSelectAllRecipientAction();
}

@immutable
class CreatedUploadRequestSetSearchResultAction extends ActionOffline {
  final List<UploadRequest> uploadRequests;

  CreatedUploadRequestSetSearchResultAction(this.uploadRequests);
}

@immutable
class CreatedUploadRequestInsideGetSorterAction extends ActionOffline {
  final Sorter sorter;

  CreatedUploadRequestInsideGetSorterAction(this.sorter);
}

@immutable
class CreatedUploadRequestInsideSortAction extends ActionOffline {
  final List<UploadRequest> uploadRequests;
  final Sorter sorter;

  CreatedUploadRequestInsideSortAction(this.uploadRequests, this.sorter);
}