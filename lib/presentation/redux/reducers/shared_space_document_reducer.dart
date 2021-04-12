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

import 'package:domain/domain.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/shared_space_document_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/shared_space_document_state.dart';
import 'package:redux/redux.dart';

final sharedSpaceDocumentReducer = combineReducers<SharedSpaceDocumentState>([
  TypedReducer<SharedSpaceDocumentState, StartSharedSpaceDocumentLoadingAction>((SharedSpaceDocumentState state, _) => state.startLoadingState()),
  TypedReducer<SharedSpaceDocumentState, SharedSpaceDocumentAction>((SharedSpaceDocumentState state, SharedSpaceDocumentAction action) => state.sendViewState(viewState: action.viewState)),
  TypedReducer<SharedSpaceDocumentState, CleanSharedSpaceDocumentStateAction>((SharedSpaceDocumentState state, _) => state.clearViewState()),
  TypedReducer<SharedSpaceDocumentState, UpdateSharedSpaceDocumentArgumentsAction>((SharedSpaceDocumentState state, UpdateSharedSpaceDocumentArgumentsAction action) =>
    state.setSharedSpaceDocumentArgument(newArguments: action.documentArguments)),
  TypedReducer<SharedSpaceDocumentState, SharedSpaceDocumentGetSorterAndAllWorkGroupNodeAction>((SharedSpaceDocumentState state, SharedSpaceDocumentGetSorterAndAllWorkGroupNodeAction action) {
    return state.setSharedSpaceDocument(
      viewState: action.viewState,
      newWorkGroupNodeList: action.viewState.fold(
        (failure) => [],
        (success) => (success is GetChildNodesViewState) ? success.workGroupNodes : []),
      newSorter: action.sorter);
  }),
  TypedReducer<SharedSpaceDocumentState, SharedSpaceDocumentGetAllWorkGroupNodeAction>((SharedSpaceDocumentState state, SharedSpaceDocumentGetAllWorkGroupNodeAction action) {
    return state.setSharedSpaceDocument(
      viewState: action.viewState,
      newWorkGroupNodeList: action.viewState.fold(
        (failure) => [],
        (success) => (success is GetChildNodesViewState) ? success.workGroupNodes : []));
  }),
  TypedReducer<SharedSpaceDocumentState, SharedSpaceDocumentSortWorkGroupNodeAction>((SharedSpaceDocumentState state, SharedSpaceDocumentSortWorkGroupNodeAction action) {
    return state.setSharedSpaceDocument(
      newWorkGroupNodeList: action.workGroupNodes,
      newSorter: action.sorter);
  }),
  TypedReducer<SharedSpaceDocumentState, ClearWorkGroupListSharedSpaceDocumentAction>((SharedSpaceDocumentState state, ClearWorkGroupListSharedSpaceDocumentAction action) =>
      state.setSharedSpaceDocument(newWorkGroupNodeList: [])),
  TypedReducer<SharedSpaceDocumentState, SharedSpaceDocumentSetSearchResultAction>((SharedSpaceDocumentState state, SharedSpaceDocumentSetSearchResultAction action) =>
      state.setSharedSpaceDocument(newWorkGroupNodeList: action.workGroupNodes)),
  TypedReducer<SharedSpaceDocumentState, SharedSpaceDocumentSelectWorkGroupNodeAction>((SharedSpaceDocumentState state, SharedSpaceDocumentSelectWorkGroupNodeAction action) =>
      state.selectSharedSpaceDocument(action.selectedWorkGroupNode)),
  TypedReducer<SharedSpaceDocumentState, SharedSpaceClearSelectedWorkGroupNodeAction>((SharedSpaceDocumentState state, SharedSpaceClearSelectedWorkGroupNodeAction action) =>
      state.cancelSelectedSharedSpaceDocument()),
  TypedReducer<SharedSpaceDocumentState, SharedSpaceSelectAllWorkGroupNodeAction>((SharedSpaceDocumentState state, SharedSpaceSelectAllWorkGroupNodeAction action) =>
      state.selectAllSharedSpaceDocument()),
  TypedReducer<SharedSpaceDocumentState, SharedSpaceUnSelectAllWorkGroupNodeAction>((SharedSpaceDocumentState state, SharedSpaceUnSelectAllWorkGroupNodeAction action) =>
      state.unSelectAllSharedSpaceDocument())
]);