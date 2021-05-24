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
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:domain/domain.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/model/file/selectable_element.dart';
import 'package:linshare_flutter_app/presentation/model/file/share_presentation_file.dart';
import 'package:linshare_flutter_app/presentation/model/item_selection_type.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/received_share_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/ui_action.dart';
import 'package:linshare_flutter_app/presentation/redux/online_thunk_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/received_share_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/ui_state.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/context_menu_builder.dart';
import 'package:linshare_flutter_app/presentation/view/downloading_file/downloading_file_builder.dart';
import 'package:linshare_flutter_app/presentation/view/header/context_menu_header_builder.dart';
import 'package:linshare_flutter_app/presentation/view/header/simple_bottom_sheet_header_builder.dart';
import 'package:linshare_flutter_app/presentation/view/order_by/order_by_dialog_bottom_sheet.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:open_file/open_file.dart' as open_file;
import 'package:permission_handler/permission_handler.dart';
import 'package:redux/src/store.dart';
import 'package:redux_thunk/redux_thunk.dart';

class ReceivedShareViewModel extends BaseViewModel {
  final GetAllReceivedSharesInteractor _getAllReceivedInteractor;
  final AppNavigation _appNavigation;
  final CopyMultipleFilesFromReceivedSharesToMySpaceInteractor _copyMultipleFilesFromReceivedSharesToMySpaceInteractor;
  final DownloadReceivedSharesInteractor _downloadReceivedSharesInteractor;
  final DownloadPreviewReceivedShareInteractor _downloadPreviewReceivedShareInteractor;
  final GetSorterInteractor _getSorterInteractor;
  final SaveSorterInteractor _saveSorterInteractor;
  final SortInteractor _sortInteractor;

  List<ReceivedShare> _receivedSharesList = [];
  final SearchReceivedSharesInteractor _searchReceivedSharesInteractor;

  StreamSubscription _storeStreamSubscription;

  SearchQuery _searchQuery = SearchQuery('');
  SearchQuery get searchQuery  => _searchQuery;

  ReceivedShareViewModel(
      Store<AppState> store,
      this._getAllReceivedInteractor,
      this._appNavigation,
      this._copyMultipleFilesFromReceivedSharesToMySpaceInteractor,
      this._downloadReceivedSharesInteractor,
      this._downloadPreviewReceivedShareInteractor,
      this._getSorterInteractor,
      this._saveSorterInteractor,
      this._sortInteractor,
      this._searchReceivedSharesInteractor
  ) : super(store) {
    _storeStreamSubscription = store.onChange.listen((event) {
      event.receivedShareState.viewState.fold(
         (failure) => null,
         (success) {
            if (success is SearchReceivedSharesNewQuery && event.uiState.searchState.searchStatus == SearchStatus.ACTIVE) {
              _search(success.searchQuery);
            } else if (success is DisableSearchViewState) {
              store.dispatch((ReceivedShareSetSearchResultAction(_receivedSharesList)));
              _searchQuery = SearchQuery('');
            }
      });
    });
  }

  void _search(SearchQuery searchQuery) {
    _searchQuery = searchQuery;
    if (searchQuery.value.isNotEmpty) {
      store.dispatch(_searchReceivedSharesAction(_receivedSharesList, searchQuery));
    } else {
      store.dispatch(ReceivedShareSetSearchResultAction([]));
    }
  }

  ThunkAction<AppState> _searchReceivedSharesAction(List<ReceivedShare> receivedSharesList, SearchQuery searchQuery) {
    return (Store<AppState> store) async {
      await _searchReceivedSharesInteractor.execute(receivedSharesList, searchQuery).then((result) => result.fold(
              (failure) {
                if (_isInSearchState()) {
                  store.dispatch(ReceivedShareSetSearchResultAction([]));
                }
              },
              (success) {
                if (_isInSearchState()) {
                  store.dispatch(ReceivedShareSetSearchResultAction(success is SearchReceivedSharesSuccess ? success.receivedSharesList : []));
                }
              })
      );
    };
  }

  bool _isInSearchState() {
    return store.state.uiState.isInSearchState();
  }

  void getAllReceivedShare() {
    store.dispatch(_getAllReceivedShareAction());
  }

  OnlineThunkAction _getAllReceivedShareAction() {
    return OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(StartReceivedShareLoadingAction());
      await _getAllReceivedInteractor.execute().then((result) => result.fold(
              (failure) {
                store.dispatch(ReceivedShareGetAllReceivedSharesAction(Left(failure)));
                _receivedSharesList = [];
              },
              (success) {
                store.dispatch(ReceivedShareGetAllReceivedSharesAction(Right(success)));
                _receivedSharesList = success is GetAllReceivedShareSuccess ? success.receivedShares : [];
              })
      );
    });
  }

  void openContextMenu(BuildContext context, ReceivedShare share, List<Widget> actionTiles, {Widget footerAction}) {
    store.dispatch(_handleContextMenuAction(context, share, actionTiles, footerAction: footerAction));
  }

  ThunkAction<AppState> _handleContextMenuAction(
      BuildContext context,
      ReceivedShare share,
      List<Widget> actionTiles,
      {Widget footerAction}) {
    return (Store<AppState> store) async {
      ContextMenuBuilder(context)
          .addHeader(ContextMenuHeaderBuilder(
            Key('context_menu_header'),
            SharePresentationFile.fromShare(share)).build())
          .addTiles(actionTiles)
          .addFooter(footerAction)
          .build();
      store.dispatch(ReceivedShareAction(Right(ReceivedShareContextMenuItemViewState(share))));
    };
  }

  void copyToMySpace(List<ReceivedShare> shares, {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    if (itemSelectionType == ItemSelectionType.single) {
      _appNavigation.popBack();
    }

    store.dispatch(_copyToMySpaceAction(shares));
  }

  OnlineThunkAction _copyToMySpaceAction(List<ReceivedShare> shares) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _copyMultipleFilesFromReceivedSharesToMySpaceInteractor.execute(shares: shares)
        .then((result) => result.fold(
          (failure) => store.dispatch(ReceivedShareAction(Left(failure))),
          (success) => store.dispatch(ReceivedShareAction(Right(success)))));
    });
  }

  void selectItem(SelectableElement<ReceivedShare> selectedReceivedShare) {
    store.dispatch(ReceivedShareSelectAction(selectedReceivedShare));
  }

  void toggleSelectAllReceivedShares() {
    if (store.state.receivedShareState.isAllReceivedSharesSelected()) {
      store.dispatch(ReceivedShareUnselectAllAction());
    } else {
      store.dispatch(ReceivedShareSelectAllAction());
    }
  }

  void cancelSelection() {
    store.dispatch(ReceivedShareClearSelectedAction());
  }

  void downloadFileClick(List<ShareId> shareIds, {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    store.dispatch(_handleDownloadFile(shareIds, itemSelectionType: itemSelectionType));
  }

  OnlineThunkAction _handleDownloadFile(List<ShareId> shareIds, {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    return OnlineThunkAction((Store<AppState> store) async {
      final status = await Permission.storage.status;
      switch (status) {
        case PermissionStatus.granted: _download(shareIds, itemSelectionType: itemSelectionType);
        break;
        case PermissionStatus.permanentlyDenied:
          _appNavigation.popBack();
          break;
        default: {
          final requested = await Permission.storage.request();
          switch (requested) {
            case PermissionStatus.granted: _download(shareIds, itemSelectionType: itemSelectionType);
            break;
            default: _appNavigation.popBack();
            break;
          }
        }
      }
    });
  }

  void _download(List<ShareId> shareIds, {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    store.dispatch(_downloadFileAction(shareIds));
    _appNavigation.popBack();
    if (itemSelectionType == ItemSelectionType.multiple) {
      cancelSelection();
    }
  }

  OnlineThunkAction _downloadFileAction(List<ShareId> shareIds) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _downloadReceivedSharesInteractor.execute(shareIds).then((result) => result.fold(
        (failure) => store.dispatch(ReceivedShareAction(Left(failure))),
        (success) => store.dispatch(ReceivedShareAction(Right(success)))));
    });
  }

  void _showPrepareToPreviewFileDialog(BuildContext context, ReceivedShare receivedShare, CancelToken cancelToken) {
    showCupertinoDialog(
      context: context,
      builder: (_) => DownloadingFileBuilder(cancelToken, _appNavigation)
        .key(Key('prepare_to_preview_file_dialog'))
        .title(AppLocalizations.of(context).preparing_to_preview_file)
        .content(AppLocalizations.of(context).downloading_file(receivedShare.name))
        .actionText(AppLocalizations.of(context).cancel)
        .build()
    );
  }

  void onClickPreviewFile(BuildContext context, ReceivedShare receivedShare) {
    store.dispatch(OnlineThunkAction((Store<AppState> store) async {
      _previewReceivedShare(context, receivedShare);
    }));
  }

  void _previewReceivedShare(BuildContext context, ReceivedShare receivedShare) {
    _appNavigation.popBack();
    final canPreviewReceivedShare = Platform.isIOS ? receivedShare.mediaType.isIOSSupportedPreview() : receivedShare.mediaType.isAndroidSupportedPreview();
    if (canPreviewReceivedShare || (receivedShare.hasThumbnail != null && receivedShare.hasThumbnail)) {
      final cancelToken = CancelToken();
      _showPrepareToPreviewFileDialog(context, receivedShare, cancelToken);

      var downloadPreviewType = DownloadPreviewType.original;
      if (receivedShare.mediaType.isImageFile()) {
        downloadPreviewType = DownloadPreviewType.image;
      } else if (!canPreviewReceivedShare) {
        downloadPreviewType = DownloadPreviewType.thumbnail;
      }
      store.dispatch(_handleDownloadPreviewReceivedShare(receivedShare, downloadPreviewType, cancelToken));
    }
  }

  OnlineThunkAction _handleDownloadPreviewReceivedShare(ReceivedShare receivedShare, DownloadPreviewType downloadPreviewType, CancelToken cancelToken) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _downloadPreviewReceivedShareInteractor
          .execute(receivedShare, downloadPreviewType, cancelToken)
          .then((result) => result.fold(
              (failure) {
                if (failure is DownloadPreviewReceivedShareFailure && !(failure.downloadPreviewException is CancelDownloadFileException)) {
                  store.dispatch(ReceivedShareAction(Left(NoReceivedSharePreviewAvailable())));
                }
              },
              (success) {
                if (success is DownloadPreviewReceivedShareViewState) {
                  _openDownloadedPreviewReceivedShare(receivedShare, success);
                }
          }));
    });
  }

  void _openDownloadedPreviewReceivedShare(ReceivedShare receivedShare, DownloadPreviewReceivedShareViewState viewState) async {
    _appNavigation.popBack();

    final openResult = await open_file.OpenFile.open(
        viewState.filePath,
        type: Platform.isAndroid ? receivedShare.mediaType.mimeType : null,
        uti:  Platform.isIOS ? receivedShare.mediaType.getDocumentUti().value : null);

    if (openResult.type != open_file.ResultType.done) {
      store.dispatch(ReceivedShareAction(Left(NoReceivedSharePreviewAvailable())));
    }
  }

  void getSorterAndAllReceivedSharesAction() {
    store.dispatch(_getSorterAndAllReceivedSharesAction());
  }

  OnlineThunkAction _getSorterAndAllReceivedSharesAction() {
    return OnlineThunkAction((Store<AppState> store) async {
      store.dispatch(StartReceivedShareLoadingAction());

      await Future.wait([
        _getSorterInteractor.execute(OrderScreen.receivedShares),
        _getAllReceivedInteractor.execute()
      ]).then((response) async {
        response[0].fold((failure) {
          store.dispatch(ReceivedShareGetSorterAction(Sorter.fromOrderScreen(OrderScreen.receivedShares)));
        }, (success) {
          store.dispatch(ReceivedShareGetSorterAction(success is GetSorterSuccess
              ? success.sorter
              : Sorter.fromOrderScreen(OrderScreen.receivedShares)));
        });
        response[1].fold((failure) {
          store.dispatch(ReceivedShareGetAllReceivedSharesAction(Left(failure)));
          _receivedSharesList = [];
        }, (success) {
          store.dispatch(ReceivedShareGetAllReceivedSharesAction(Right(success)));
          _receivedSharesList =
              success is GetAllReceivedShareSuccess ? success.receivedShares : [];
        });
      });

      store.dispatch(_sortFilesAction(store.state.receivedShareState.sorter));
    });
  }

  ThunkAction<AppState> _sortFilesAction(Sorter sorter) {
    return (Store<AppState> store) async {
      await Future.wait([
        _saveSorterInteractor.execute(sorter),
        _sortInteractor.execute(_receivedSharesList, sorter)
      ]).then((response) => response[1].fold((failure) {
            _receivedSharesList = [];
            store.dispatch(ReceivedShareSortReceivedShareAction(_receivedSharesList, sorter));
          }, (success) {
            _receivedSharesList =
                success is GetAllReceivedShareSuccess ? success.receivedShares : [];
            store.dispatch(ReceivedShareSortReceivedShareAction(_receivedSharesList, sorter));
          }));
    };
  }

  void openPopupMenuSorter(BuildContext context, Sorter currentSorter) {
    ContextMenuBuilder(context)
        .addHeader(SimpleBottomSheetHeaderBuilder(Key('order_by_menu_header'))
            .addLabel(AppLocalizations.of(context).order_by)
            .build())
        .addTiles(OrderByDialogBottomSheetBuilder(context, currentSorter)
            .onSelectSorterAction((sorterSelected) => _sortFiles(sorterSelected))
            .build())
        .build();
  }

  void _sortFiles(Sorter sorter) {
    final newSorter = store.state.receivedShareState.sorter == sorter ? sorter.getSorterByOrderType(sorter.orderType) : sorter;
    _appNavigation.popBack();
    store.dispatch(_sortFilesAction(newSorter));
  }

  void openSearchState() {
    store.dispatch(EnableSearchStateAction(SearchDestination.receivedShares));
    store.dispatch((ReceivedShareSetSearchResultAction([])));
  }

  @override
  void onDisposed() {
    cancelSelection();
    super.onDisposed();
    _storeStreamSubscription.cancel();
  }
}
