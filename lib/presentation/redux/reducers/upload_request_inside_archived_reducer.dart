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

import 'package:domain/domain.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_request_inside_archived_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/upload_request_inside_archived_state.dart';
import 'package:redux/redux.dart';

final archivedUploadRequestInsideReducer = combineReducers<ArchivedUploadRequestInsideState>([
  TypedReducer<ArchivedUploadRequestInsideState, StartArchivedUploadRequestInsideLoadingAction>((ArchivedUploadRequestInsideState state, _) => state.startLoadingState()),
  TypedReducer<ArchivedUploadRequestInsideState, ArchivedUploadRequestInsideAction>((ArchivedUploadRequestInsideState state, ArchivedUploadRequestInsideAction action) => state.sendViewState(viewState: action.viewState)),
  TypedReducer<ArchivedUploadRequestInsideState, SetArchivedUploadRequestsArgumentsAction>((ArchivedUploadRequestInsideState state, SetArchivedUploadRequestsArgumentsAction action) =>
      state.setUploadRequestArgument(newUploadRequestArguments: action.arguments)),
  TypedReducer<ArchivedUploadRequestInsideState, GetAllArchivedUploadRequestsAction>((ArchivedUploadRequestInsideState state, GetAllArchivedUploadRequestsAction action) =>
      state.setUploadRequests(
          newUploadRequests: action.viewState.fold(
                  (failure) => [],
                  (success) => (success is UploadRequestViewState) ? success.uploadRequests : []),
          viewState: action.viewState)),
  TypedReducer<ArchivedUploadRequestInsideState, GetAllArchivedUploadRequestEntriesAction>((ArchivedUploadRequestInsideState state, GetAllArchivedUploadRequestEntriesAction action) =>
      state.setUploadRequestEntries(
          newUploadRequestEntries: action.viewState.fold(
                  (failure) => [],
                  (success) => (success is UploadRequestEntryViewState) ? success.uploadRequestEntries : []),
          viewState: action.viewState)),
  TypedReducer<ArchivedUploadRequestInsideState, SetSelectedArchivedUploadRequestAction>((ArchivedUploadRequestInsideState state, SetSelectedArchivedUploadRequestAction action) =>
      state.setSelectedUploadRequest(selectedUploadRequest: action.selectedUploadRequest)),
  TypedReducer<ArchivedUploadRequestInsideState, ClearArchivedUploadRequestEntriesListAction>((ArchivedUploadRequestInsideState state, ClearArchivedUploadRequestEntriesListAction action) =>
      state.setUploadRequestEntries(
          newUploadRequestEntries: [])),
  TypedReducer<ArchivedUploadRequestInsideState, ClearArchivedUploadRequestsListAction>((ArchivedUploadRequestInsideState state, ClearArchivedUploadRequestsListAction action) =>
      state.setUploadRequests(
          newUploadRequests: [])),
  TypedReducer<ArchivedUploadRequestInsideState, ArchivedUploadRequestSelectEntryAction>((ArchivedUploadRequestInsideState state, ArchivedUploadRequestSelectEntryAction action) =>
      state.selectUploadRequestEntry(action.selectedEntry)),
  TypedReducer<ArchivedUploadRequestInsideState, ArchivedUploadRequestClearSelectedEntryAction>((ArchivedUploadRequestInsideState state, ArchivedUploadRequestClearSelectedEntryAction action) =>
      state.cancelSelectedUploadRequestEntry()),
  TypedReducer<ArchivedUploadRequestInsideState, ArchivedUploadRequestSelectAllEntryAction>((ArchivedUploadRequestInsideState state, ArchivedUploadRequestSelectAllEntryAction action) =>
      state.selectAllUploadRequestEntry()),
  TypedReducer<ArchivedUploadRequestInsideState, ArchivedUploadRequestUnSelectAllEntryAction>((ArchivedUploadRequestInsideState state, ArchivedUploadRequestUnSelectAllEntryAction action) =>
      state.unSelectAllUploadRequestEntry()),
  TypedReducer<ArchivedUploadRequestInsideState, SelectArchivedUploadRequestAction>((ArchivedUploadRequestInsideState state, SelectArchivedUploadRequestAction action) =>
      state.selectUploadRequests(action.selectedUploadRequest)),
  TypedReducer<ArchivedUploadRequestInsideState, ClearArchivedUploadRequestSelectionAction>((ArchivedUploadRequestInsideState state, ClearArchivedUploadRequestSelectionAction action) =>
      state.cancelSelectedUploadRequest()),
  TypedReducer<ArchivedUploadRequestInsideState, ArchivedUploadRequestSelectAllRecipientAction>((ArchivedUploadRequestInsideState state, ArchivedUploadRequestSelectAllRecipientAction action) =>
      state.selectAllUploadRequest()),
  TypedReducer<ArchivedUploadRequestInsideState, ArchivedUploadRequestUnSelectAllRecipientAction>((ArchivedUploadRequestInsideState state, ArchivedUploadRequestUnSelectAllRecipientAction action) =>
      state.unSelectAllUploadRequest()),
  TypedReducer<ArchivedUploadRequestInsideState, ArchivedUploadRequestEntrySetSearchResultAction>((ArchivedUploadRequestInsideState state, ArchivedUploadRequestEntrySetSearchResultAction action) =>
      state.setSearchResult(newSearchResult: action.uploadRequestEntries)),
  TypedReducer<ArchivedUploadRequestInsideState, CleanArchivedUploadRequestInsideAction>((ArchivedUploadRequestInsideState state, _) =>
      state.clearViewState()),
  TypedReducer<ArchivedUploadRequestInsideState, ArchivedUploadRequestSetSearchResultAction>((ArchivedUploadRequestInsideState state, ArchivedUploadRequestSetSearchResultAction action) =>
      state.setSearchResultRecipients(newSearchResult: action.uploadRequests)),
]);