/*
 * LinShare is an open source filesharing software, part of the LinPKI software
 * suite, developed by Linagora.
 *
 * Copyright (C) 2021 LINAGORA
 *
 * This program is free software: you can redistribute it and/or modify it under the
 * terms of the GNU Affero General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version,
 * provided you comply with the Additional Terms applicable for LinShare software by
 * Linagora pursuant to Section 7 of the GNU Affero General Public License,
 * subsections (b), (c), and (e), pursuant to which you must notably (i) retain the
 * display in the interface of the “LinShare™” trademark/logo, the "Libre & Free" mention,
 * the words “You are using the Free and Open Source version of LinShare™, powered by
 * Linagora © 2009–2021. Contribute to Linshare R&D by subscribing to an Enterprise
 * offer!”. You must also retain the latter notice in all asynchronous messages such as
 * e-mails sent with the Program, (ii) retain all hypertext links between LinShare and
 * http://www.linshare.org, between linagora.com and Linagora, and (iii) refrain from
 * infringing Linagora intellectual property rights over its trademarks and commercial
 * brands. Other Additional Terms apply, see
 * <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf>
 * for more details.
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for
 * more details.
 * You should have received a copy of the GNU Affero General Public License and its
 * applicable Additional Terms for LinShare along with this program. If not, see
 * <http://www.gnu.org/licenses/> for the GNU Affero General Public License version
 *  3 and <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf> for
 *  the Additional Terms applicable to LinShare software.
 */

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:data/src/util/device_manager.dart';
import 'package:domain/domain.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/model/file/selectable_element.dart';
import 'package:linshare_flutter_app/presentation/model/upload_request_group_tab.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/ui_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_request_inside_active_closed_action.dart';
import 'package:linshare_flutter_app/presentation/redux/online_thunk_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/ui_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/upload_request_inside_active_closed_state.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/upload_request_document_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/upload_request_document_type.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/upload_request_inside_viewmodel.dart';
import 'package:redux/src/store.dart';

class ActiveCloseUploadRequestInsideViewModel extends UploadRequestInsideViewModel {

  final GetAllUploadRequestsInteractor  _getAllUploadRequestsInteractor;
  final GetAllUploadRequestEntriesInteractor  _getAllUploadRequestEntriesInteractor;

  late StreamSubscription _storeStreamSubscription;

  List<UploadRequestEntry> _uploadRequestEntries = [];
  List<UploadRequest> _uploadRequests = [];

  SearchQuery _searchQuery = SearchQuery('');
  SearchQuery get searchQuery => _searchQuery;

  UploadRequestArguments? _arguments;

  ActiveCloseUploadRequestInsideViewModel(
    Store<AppState> store,
    AppNavigation appNavigation,
    DeviceManager deviceManager,
    DownloadUploadRequestEntriesInteractor downloadUploadRequestEntriesInteractor,
    UpdateMultipleUploadRequestStateInteractor updateMultipleUploadRequestStateInteractor,
    RemoveMultipleUploadRequestEntryInteractor removeMultipleUploadRequestEntryInteractor,
    DownloadMultipleUploadRequestEntryIOSInteractor downloadMultipleUploadRequestEntryIOSInteractor,
    CopyMultipleFilesFromUploadRequestEntriesToMySpaceInteractor entriesToMySpaceInteractor,
    SearchUploadRequestEntriesInteractor searchUploadRequestEntriesInteractor,
    SearchRecipientsUploadRequestInteractor searchRecipientsUploadRequestInteractor,
    this._getAllUploadRequestsInteractor,
    this._getAllUploadRequestEntriesInteractor,
  ) : super(
      store,
      appNavigation,
      deviceManager,
      downloadUploadRequestEntriesInteractor,
      updateMultipleUploadRequestStateInteractor,
      removeMultipleUploadRequestEntryInteractor,
      downloadMultipleUploadRequestEntryIOSInteractor,
      entriesToMySpaceInteractor,
      searchUploadRequestEntriesInteractor,
      searchRecipientsUploadRequestInteractor,
  ) {
    _storeStreamSubscription = store.onChange.listen((event) {
      event.activeClosedUploadRequestInsideState.viewState.fold((failure) => null, (success) {
        if (success is SearchUploadRequestEntriesNewQuery && event.uiState.searchState.searchStatus == SearchStatus.ACTIVE) {
          _search(success.searchQuery, UploadRequestDocumentType.files);
        } else if (success is SearchUploadRequestRecipientsNewQuery && event.uiState.searchState.searchStatus == SearchStatus.ACTIVE) {
          _search(success.searchQuery, UploadRequestDocumentType.recipients);
        } else if (success is DisableSearchViewState) {
          if (event.activeClosedUploadRequestInsideState.isIndividualRecipients()) {
            store.dispatch((ActiveClosedUploadRequestSetSearchResultAction(_uploadRequests)));
          } else {
            store.dispatch((ActiveClosedUploadRequestEntrySetSearchResultAction(_uploadRequestEntries)));
          }
          _setSearchQuery(SearchQuery(''));
        } else if (success is EditUploadRequestRecipientViewState ||
          success is AddRecipientsToUploadRequestGroupViewState) {
          requestToGetUploadRequestAndEntries();
        }
      });
    });
  }

  void initState(UploadRequestArguments arguments) {
    _arguments = arguments;
    store.dispatch(SetActiveClosedUploadRequestsArgumentsAction(arguments));
    requestToGetUploadRequestAndEntries();
  }

  void requestToGetUploadRequestAndEntries() {
    if (_arguments != null) {
      store.dispatch(_getAllUploadRequests(
        _arguments!.uploadRequestGroup,
        _arguments!.documentType,
        _arguments!.selectedUploadRequest));
    }
  }

  OnlineThunkAction _getAllUploadRequests(
      UploadRequestGroup group,
      UploadRequestDocumentType documentType,
      UploadRequest? selectedUploadRequest
  ) {
    return OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(StartActiveClosedUploadRequestInsideLoadingAction());

      await _getAllUploadRequestsInteractor.execute(group.uploadRequestGroupId)
        .then((result) => result.fold(
          (failure) {
            if (failure is UploadRequestFailure) {
              if (documentType == UploadRequestDocumentType.recipients) {
                _uploadRequests = [];
              }
              handleOnFailureAction(UploadRequestGroupTab.ACTIVE_CLOSED, failure);
            }
          },
          (success) {
            if (success is UploadRequestViewState) {
              if (group.collective) {
                _loadListFilesCollectiveUploadRequest(success);
              } else {
                if (documentType == UploadRequestDocumentType.recipients) {
                  _loadListRecipientsIndividualUploadRequest(success, group);
                } else if (documentType == UploadRequestDocumentType.files && selectedUploadRequest != null) {
                  _loadUploadRequestEntriesByRecipient(selectedUploadRequest);
                }
              }
            }
          })
      );
    });
  }

  void _loadListFilesCollectiveUploadRequest(UploadRequestViewState uploadRequestViewState) {
    if(uploadRequestViewState.uploadRequests.isEmpty) {
      handleOnFailureAction(UploadRequestGroupTab.ACTIVE_CLOSED, UploadRequestFailure(UploadRequestNotFound()));
    } else {
      return store.dispatch(_getAllUploadRequestEntries(uploadRequestViewState.uploadRequests.first));
    }
  }

  void _loadListRecipientsIndividualUploadRequest(UploadRequestViewState uploadRequestViewState, UploadRequestGroup group) {
    final newUploadRequests = uploadRequestViewState.uploadRequests
        .where((uploadRequest) => uploadRequest.status == UploadRequestStatus.ENABLED || uploadRequest.status == UploadRequestStatus.CLOSED)
        .toList();
    _uploadRequests = newUploadRequests;
    store.dispatch(GetAllActiveClosedUploadRequestsAction(Right(UploadRequestViewState(newUploadRequests))));
  }

  void _loadUploadRequestEntriesByRecipient(UploadRequest uploadRequest) {
    store.dispatch(SetSelectedActiveClosedUploadRequestAction(uploadRequest));
    store.dispatch(_getAllUploadRequestEntries(uploadRequest));
  }

  OnlineThunkAction _getAllUploadRequestEntries(UploadRequest uploadRequest) {
    return OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(StartActiveClosedUploadRequestInsideLoadingAction());

      await _getAllUploadRequestEntriesInteractor.execute(uploadRequest.uploadRequestId)
        .then((result) => result.fold(
          (failure) {
            _uploadRequestEntries = [];
            handleOnFailureAction(UploadRequestGroupTab.ACTIVE_CLOSED, failure);
          },
          (success) {
            _uploadRequestEntries = success is UploadRequestEntryViewState ? success.uploadRequestEntries : [];
            if (success is UploadRequestEntryViewState) {
              store.dispatch(GetAllActiveClosedUploadRequestEntriesAction(Right(success)));
            }
          })
      );
    });
  }

  void _search(SearchQuery searchQuery, UploadRequestDocumentType documentType) {
    _setSearchQuery(searchQuery);
    if (searchQuery.value.isNotEmpty) {
      if (documentType == UploadRequestDocumentType.recipients) {
        store.dispatch(searchRecipientsUploadRequestAction(
            UploadRequestGroupTab.ACTIVE_CLOSED,
            _uploadRequests,
            searchQuery));
      } else {
        store.dispatch(searchUploadRequestEntriesAction(
            UploadRequestGroupTab.ACTIVE_CLOSED,
            _uploadRequestEntries,
            searchQuery));
      }
    } else {
      if (documentType == UploadRequestDocumentType.recipients) {
        handleOnFailureSearchRecipientsAction(UploadRequestGroupTab.ACTIVE_CLOSED);
      } else {
        handleOnFailureSearchEntriesAction(UploadRequestGroupTab.ACTIVE_CLOSED);
      }
    }
  }

  void openSearchState(BuildContext context) {
    var destinationName = AppLocalizations.of(context).upload_requests;

    if ((getActiveClosedUploadRequestState().isIndividualRecipients()) ||
        getActiveClosedUploadRequestState().isCollective()) {
      destinationName = store.state.uiState.uploadRequestGroup?.label ?? AppLocalizations.of(context).upload_requests;
    } else {
      destinationName = getActiveClosedUploadRequestState().selectedUploadRequest?.recipients.first.mail ?? AppLocalizations.of(context).upload_requests;
    }

    if (getActiveClosedUploadRequestState().isIndividualRecipients()) {
      store.dispatch(EnableSearchStateAction(
          SearchDestination.activeClosedUploadRequestRecipient,
          AppLocalizations.of(context).search_in(destinationName)));
      store.dispatch((ActiveClosedUploadRequestSetSearchResultAction([])));
    } else {
      store.dispatch(EnableSearchStateAction(
          SearchDestination.activeClosedUploadRequestInside,
          AppLocalizations.of(context).search_in(destinationName)));
      store.dispatch((ActiveClosedUploadRequestEntrySetSearchResultAction([])));
    }
  }

  void selectEntry(SelectableElement<UploadRequestEntry> selectedEntry) {
    store.dispatch(ActiveClosedUploadRequestSelectEntryAction(selectedEntry));
  }

  void selectRecipient(SelectableElement<UploadRequest> selectedRecipient) {
    store.dispatch(SelectActiveClosedUploadRequestAction(selectedRecipient));
  }

  void toggleSelectAllEntries() {
    if (getActiveClosedUploadRequestState().isAllEntriesSelected()) {
      store.dispatch(ActiveClosedUploadRequestUnSelectAllEntryAction());
    } else {
      store.dispatch(ActiveClosedUploadRequestSelectAllEntryAction());
    }
  }

  void toggleSelectAllRecipients() {
    if (getActiveClosedUploadRequestState().isAllRecipientSelected()) {
      store.dispatch(ActiveClosedUploadRequestUnSelectAllRecipientAction());
    } else {
      store.dispatch(ActiveClosedUploadRequestSelectAllRecipientAction());
    }
  }

  void _setSearchQuery(SearchQuery newSearchQuery) => _searchQuery = newSearchQuery;

  bool isEmptySearchQuery() => _searchQuery.value.isEmpty;

  ActiveClosedUploadRequestInsideState getActiveClosedUploadRequestState() {
    return store.state.activeClosedUploadRequestInsideState;
  }

  @override
  void onDisposed() {
    cancelAllSelectionRecipients(UploadRequestGroupTab.ACTIVE_CLOSED);
    cancelAllSelectionEntries(UploadRequestGroupTab.ACTIVE_CLOSED);
    clearUploadRequestListAction(UploadRequestGroupTab.ACTIVE_CLOSED);
    _storeStreamSubscription.cancel();
    _setSearchQuery(SearchQuery(''));
    super.onDisposed();
  }
}