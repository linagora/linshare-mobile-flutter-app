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
import 'package:linshare_flutter_app/presentation/redux/actions/upload_request_inside_active_closed_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/upload_request_inside_active_closed_state.dart';
import 'package:redux/redux.dart';

final activeClosedUploadRequestInsideReducer = combineReducers<ActiveClosedUploadRequestInsideState>([
  TypedReducer<ActiveClosedUploadRequestInsideState, StartActiveClosedUploadRequestInsideLoadingAction>((ActiveClosedUploadRequestInsideState state, _) => state.startLoadingState()),
  TypedReducer<ActiveClosedUploadRequestInsideState, ActiveClosedUploadRequestInsideAction>((ActiveClosedUploadRequestInsideState state, ActiveClosedUploadRequestInsideAction action) => state.sendViewState(viewState: action.viewState)),
  TypedReducer<ActiveClosedUploadRequestInsideState, SetActiveClosedUploadRequestsArgumentsAction>((ActiveClosedUploadRequestInsideState state, SetActiveClosedUploadRequestsArgumentsAction action) =>
      state.setUploadRequestArgument(newUploadRequestArguments: action.arguments)),
  TypedReducer<ActiveClosedUploadRequestInsideState, GetAllActiveClosedUploadRequestsAction>((ActiveClosedUploadRequestInsideState state, GetAllActiveClosedUploadRequestsAction action) =>
      state.setUploadRequests(
          newUploadRequests: action.viewState.fold(
              (failure) => [],
              (success) => (success is UploadRequestViewState) ? success.uploadRequests : []),
          viewState: action.viewState)),
  TypedReducer<ActiveClosedUploadRequestInsideState, GetAllActiveClosedUploadRequestEntriesAction>((ActiveClosedUploadRequestInsideState state, GetAllActiveClosedUploadRequestEntriesAction action) =>
      state.setUploadRequestEntries(
          newUploadRequestEntries: action.viewState.fold(
              (failure) => [],
              (success) => (success is UploadRequestEntryViewState) ? success.uploadRequestEntries : []),
          viewState: action.viewState)),
  TypedReducer<ActiveClosedUploadRequestInsideState, SetSelectedActiveClosedUploadRequestAction>((ActiveClosedUploadRequestInsideState state, SetSelectedActiveClosedUploadRequestAction action) =>
      state.setSelectedUploadRequest(selectedUploadRequest: action.selectedUploadRequest)),
  TypedReducer<ActiveClosedUploadRequestInsideState, ClearActiveClosedUploadRequestEntriesListAction>((ActiveClosedUploadRequestInsideState state, ClearActiveClosedUploadRequestEntriesListAction action) =>
      state.setUploadRequestEntries(
          newUploadRequestEntries: [])),
  TypedReducer<ActiveClosedUploadRequestInsideState, ClearActiveClosedUploadRequestsListAction>((ActiveClosedUploadRequestInsideState state, ClearActiveClosedUploadRequestsListAction action) =>
      state.setUploadRequests(
          newUploadRequests: [])),
  TypedReducer<ActiveClosedUploadRequestInsideState, ActiveClosedUploadRequestSelectEntryAction>((ActiveClosedUploadRequestInsideState state, ActiveClosedUploadRequestSelectEntryAction action) =>
      state.selectUploadRequestEntry(action.selectedEntry)),
  TypedReducer<ActiveClosedUploadRequestInsideState, ActiveClosedUploadRequestClearSelectedEntryAction>((ActiveClosedUploadRequestInsideState state, ActiveClosedUploadRequestClearSelectedEntryAction action) =>
      state.cancelSelectedUploadRequestEntry()),
  TypedReducer<ActiveClosedUploadRequestInsideState, ActiveClosedUploadRequestSelectAllEntryAction>((ActiveClosedUploadRequestInsideState state, ActiveClosedUploadRequestSelectAllEntryAction action) =>
      state.selectAllUploadRequestEntry()),
  TypedReducer<ActiveClosedUploadRequestInsideState, ActiveClosedUploadRequestUnSelectAllEntryAction>((ActiveClosedUploadRequestInsideState state, ActiveClosedUploadRequestUnSelectAllEntryAction action) =>
      state.unSelectAllUploadRequestEntry()),
  TypedReducer<ActiveClosedUploadRequestInsideState, SelectActiveClosedUploadRequestAction>((ActiveClosedUploadRequestInsideState state, SelectActiveClosedUploadRequestAction action) =>
      state.selectUploadRequests(action.selectedUploadRequest)),
  TypedReducer<ActiveClosedUploadRequestInsideState, ClearActiveClosedUploadRequestSelectionAction>((ActiveClosedUploadRequestInsideState state, ClearActiveClosedUploadRequestSelectionAction action) =>
      state.cancelSelectedUploadRequest()),
  TypedReducer<ActiveClosedUploadRequestInsideState, ActiveClosedUploadRequestSelectAllRecipientAction>((ActiveClosedUploadRequestInsideState state, ActiveClosedUploadRequestSelectAllRecipientAction action) =>
      state.selectAllUploadRequest()),
  TypedReducer<ActiveClosedUploadRequestInsideState, ActiveClosedUploadRequestUnSelectAllRecipientAction>((ActiveClosedUploadRequestInsideState state, ActiveClosedUploadRequestUnSelectAllRecipientAction action) =>
      state.unSelectAllUploadRequest()),
  TypedReducer<ActiveClosedUploadRequestInsideState, ActiveClosedUploadRequestEntrySetSearchResultAction>((ActiveClosedUploadRequestInsideState state, ActiveClosedUploadRequestEntrySetSearchResultAction action) =>
      state.setSearchResult(newSearchResult: action.uploadRequestEntries)),
  TypedReducer<ActiveClosedUploadRequestInsideState, CleanActiveClosedUploadRequestInsideAction>((ActiveClosedUploadRequestInsideState state, _) =>
      state.clearViewState()),
  TypedReducer<ActiveClosedUploadRequestInsideState, ActiveClosedUploadRequestSetSearchResultAction>((ActiveClosedUploadRequestInsideState state, ActiveClosedUploadRequestSetSearchResultAction action) =>
      state.setSearchResultRecipients(newSearchResult: action.uploadRequests)),
]);
