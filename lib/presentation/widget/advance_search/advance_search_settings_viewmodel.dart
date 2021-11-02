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

import 'package:domain/domain.dart';
import 'package:linshare_flutter_app/presentation/model/advance_search_date_state.dart';
import 'package:linshare_flutter_app/presentation/model/advance_search_kind_state.dart';
import 'package:linshare_flutter_app/presentation/model/advance_search_setting.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/advance_search_settings_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/shared_space_document_action.dart';
import 'package:linshare_flutter_app/presentation/redux/online_thunk_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/ui_state.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/advance_search_extension.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/widget/advance_search/advance_search_settings_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:redux/src/store.dart';

class AdvanceSearchSettingsViewModel extends BaseViewModel {

  final AppNavigation _appNavigation;
  final AdvanceSearchWorkgroupNodeInteractor advanceSearchWorkgroupNodeInteractor;
  late AdvanceSearchSettingsArguments _arguments;

  AdvanceSearchSettingsViewModel(Store<AppState> store, this._appNavigation,
      this.advanceSearchWorkgroupNodeInteractor)
      : super(store);

  void initState(AdvanceSearchSettingsArguments arguments) {
    _arguments = arguments;
  }

  void popBack() {
    _appNavigation.popBack();
  }

  void setNewKindState(AdvancedSearchKindState advanceSearchKindState) {
    store.dispatch(AdvanceSearchSettingsSetNewKindStateAction(advanceSearchKindState));
  }

  void setNewDateState(AdvancedSearchDateState advanceSearchDateState) {
    store.dispatch(AdvanceSearchSettingsSetNewDateStateAction(advanceSearchDateState));
  }

  void resetAllSettings() {
    store.dispatch(AdvanceSearchSettingsResetAllAction());
  }

  void applySearch(AdvanceSearchSetting advanceSearchSetting) {
    if(_arguments.searchDestination == SearchDestination.sharedSpace) {
      popBack();
      store.dispatch(_advanceSearchOnSharedSpaceAction(advanceSearchSetting));
    }
  }

  OnlineThunkAction _advanceSearchOnSharedSpaceAction(AdvanceSearchSetting advanceSearchSetting) {
      final searchRequest = AdvancedSearchRequest(
        pattern: _arguments.query,
        kinds: advanceSearchSetting.listKindState?.where((kindState) => kindState.selected == true)
          .map((e) => e.kind)
          .toList(),
        types: null,
        modificationDateAfter: advanceSearchSetting.listModificationDate?.firstWhere((e) => e.selected == true).date.dateAfter,
        modificationDateBefore: advanceSearchSetting.listModificationDate?.firstWhere((e) => e.selected == true).date.dateBefore,
        sortField: store.state.sharedSpaceDocumentState.sorter?.orderBy,
        sortOrder: store.state.sharedSpaceDocumentState.sorter?.orderType,
        tree: null,
      );
      return OnlineThunkAction((Store<AppState> store) async {
          await advanceSearchWorkgroupNodeInteractor.execute(_arguments.sharedSpaceId!, searchRequest)
              .then((result) => result.fold(
                  (failure) {
                    if (isInSearchState()) {
                      store.dispatch(SharedSpaceDocumentSetSearchResultAction([]));
                    }
                  },
                  (success) {
                    if (isInSearchState()) {
                      store.dispatch(SharedSpaceDocumentSetSearchResultAction(
                          success is SearchWorkGroupNodeSuccess
                              ? success.workGroupNodesList
                              : []));
                    }
                  }));
      });
  }

  bool isInSearchState() {
    return store.state.uiState.isInSearchState();
  }

  @override
  void onDisposed() {
    super.onDisposed();
  }

}