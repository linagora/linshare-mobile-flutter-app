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
import 'package:linshare_flutter_app/presentation/redux/actions/upload_request_inside_created_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/upload_request_inside_created_state.dart';
import 'package:redux/redux.dart';

final createdUploadRequestInsideReducer = combineReducers<CreatedUploadRequestInsideState>([
  TypedReducer<CreatedUploadRequestInsideState, StartCreatedUploadRequestInsideLoadingAction>((CreatedUploadRequestInsideState state, _) => state.startLoadingState()),
  TypedReducer<CreatedUploadRequestInsideState, CreatedUploadRequestInsideAction>((CreatedUploadRequestInsideState state, CreatedUploadRequestInsideAction action) => state.sendViewState(viewState: action.viewState)),
  TypedReducer<CreatedUploadRequestInsideState, SetCreatedUploadRequestsArgumentsAction>((CreatedUploadRequestInsideState state, SetCreatedUploadRequestsArgumentsAction action) =>
      state.setUploadRequestArgument(newUploadRequestArguments: action.arguments)),
  TypedReducer<CreatedUploadRequestInsideState, GetAllCreatedUploadRequestsAction>((CreatedUploadRequestInsideState state, GetAllCreatedUploadRequestsAction action) =>
      state.setUploadRequests(
          newUploadRequests: action.viewState.fold(
                  (failure) => [],
                  (success) => (success is UploadRequestViewState) ? success.uploadRequests : []),
          viewState: action.viewState)),
  TypedReducer<CreatedUploadRequestInsideState, GetAllCreatedUploadRequestEntriesAction>((CreatedUploadRequestInsideState state, GetAllCreatedUploadRequestEntriesAction action) =>
      state.setUploadRequestEntries(
          newUploadRequestEntries: action.viewState.fold(
                  (failure) => [],
                  (success) => (success is UploadRequestEntryViewState) ? success.uploadRequestEntries : []),
          viewState: action.viewState)),
  TypedReducer<CreatedUploadRequestInsideState, SetSelectedCreatedUploadRequestAction>((CreatedUploadRequestInsideState state, SetSelectedCreatedUploadRequestAction action) =>
      state.setSelectedUploadRequest(selectedUploadRequest: action.selectedUploadRequest)),
  TypedReducer<CreatedUploadRequestInsideState, ClearCreatedUploadRequestEntriesListAction>((CreatedUploadRequestInsideState state, ClearCreatedUploadRequestEntriesListAction action) =>
      state.setUploadRequestEntries(
          newUploadRequestEntries: [])),
  TypedReducer<CreatedUploadRequestInsideState, ClearCreatedUploadRequestsListAction>((CreatedUploadRequestInsideState state, ClearCreatedUploadRequestsListAction action) =>
      state.setUploadRequests(
          newUploadRequests: [])),
  TypedReducer<CreatedUploadRequestInsideState, CreatedUploadRequestSelectEntryAction>((CreatedUploadRequestInsideState state, CreatedUploadRequestSelectEntryAction action) =>
      state.selectUploadRequestEntry(action.selectedEntry)),
  TypedReducer<CreatedUploadRequestInsideState, CreatedUploadRequestClearSelectedEntryAction>((CreatedUploadRequestInsideState state, CreatedUploadRequestClearSelectedEntryAction action) =>
      state.cancelSelectedUploadRequestEntry()),
  TypedReducer<CreatedUploadRequestInsideState, CreatedUploadRequestSelectAllEntryAction>((CreatedUploadRequestInsideState state, CreatedUploadRequestSelectAllEntryAction action) =>
      state.selectAllUploadRequestEntry()),
  TypedReducer<CreatedUploadRequestInsideState, CreatedUploadRequestUnSelectAllEntryAction>((CreatedUploadRequestInsideState state, CreatedUploadRequestUnSelectAllEntryAction action) =>
      state.unSelectAllUploadRequestEntry()),
  TypedReducer<CreatedUploadRequestInsideState, SelectCreatedUploadRequestAction>((CreatedUploadRequestInsideState state, SelectCreatedUploadRequestAction action) =>
      state.selectUploadRequests(action.selectedUploadRequest)),
  TypedReducer<CreatedUploadRequestInsideState, ClearCreatedUploadRequestSelectionAction>((CreatedUploadRequestInsideState state, ClearCreatedUploadRequestSelectionAction action) =>
      state.cancelSelectedUploadRequest()),
  TypedReducer<CreatedUploadRequestInsideState, CreatedUploadRequestSelectAllRecipientAction>((CreatedUploadRequestInsideState state, CreatedUploadRequestSelectAllRecipientAction action) =>
      state.selectAllUploadRequest()),
  TypedReducer<CreatedUploadRequestInsideState, CreatedUploadRequestUnSelectAllRecipientAction>((CreatedUploadRequestInsideState state, CreatedUploadRequestUnSelectAllRecipientAction action) =>
      state.unSelectAllUploadRequest()),
  TypedReducer<CreatedUploadRequestInsideState, CreatedUploadRequestEntrySetSearchResultAction>((CreatedUploadRequestInsideState state, CreatedUploadRequestEntrySetSearchResultAction action) =>
      state.setSearchResult(newSearchResult: action.uploadRequestEntries)),
  TypedReducer<CreatedUploadRequestInsideState, CleanCreatedUploadRequestInsideAction>((CreatedUploadRequestInsideState state, _) =>
      state.clearViewState()),
  TypedReducer<CreatedUploadRequestInsideState, CreatedUploadRequestSetSearchResultAction>((CreatedUploadRequestInsideState state, CreatedUploadRequestSetSearchResultAction action) =>
      state.setSearchResultRecipients(newSearchResult: action.uploadRequests)),
  TypedReducer<CreatedUploadRequestInsideState, CreatedUploadRequestInsideSortAction>((CreatedUploadRequestInsideState state, CreatedUploadRequestInsideSortAction action) =>
      state.setUploadRequestsRecipientsCreatedWithSort(
          newUploadRequestsList: action.uploadRequests,
          newSorter: action.sorter)),
  TypedReducer<CreatedUploadRequestInsideState, CreatedUploadRequestInsideGetSorterAction>((CreatedUploadRequestInsideState state, CreatedUploadRequestInsideGetSorterAction action) =>
      state.setSorterUploadRequestRecipient(newSorter: action.sorter)),
  TypedReducer<CreatedUploadRequestInsideState, CreatedUploadRequestEntryInsideSortAction>((CreatedUploadRequestInsideState state, CreatedUploadRequestEntryInsideSortAction action) =>
      state.setUploadRequestsFilesCreatedWithSort(
          newUploadRequestsEntries: action.uploadRequestEntries,
          newSorter: action.sorter)),
  TypedReducer<CreatedUploadRequestInsideState, CreatedUploadRequestInsideGetSorterAction>((CreatedUploadRequestInsideState state, CreatedUploadRequestInsideGetSorterAction action) =>
      state.setSorterUploadRequestFiles(newSorter: action.sorter)),
]);