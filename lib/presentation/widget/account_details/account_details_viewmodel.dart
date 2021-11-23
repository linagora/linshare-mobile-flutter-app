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

import 'package:dartz/dartz.dart';
import 'package:domain/domain.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/account_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/ui_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/util/router/route_paths.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

class AccountDetailsViewModel extends BaseViewModel {
  final DeletePermanentTokenInteractor deletePermanentTokenInteractor;
  final AppNavigation _appNavigation;
  final IsAvailableBiometricInteractor _isAvailableBiometricInteractor;
  final GetAuthorizedInteractor _getAuthorizedInteractor;
  final DisableBiometricInteractor _disableBiometricInteractor;
  final GetLastLoginInteractor _getLastLoginInteractor;
  final GetQuotaInteractor _getQuotaInteractor;
  final DeleteAllOfflineDocumentInteractor _deleteAllOfflineDocumentInteractor;
  final DeleteAllSharedSpaceOfflineInteractor _deleteAllSharedSpaceOfflineInteractor;
  final SaveAuthorizedUserInteractor _saveAuthorizedUserInteractor;
  final SaveLastLoginInteractor _saveLastLoginInteractor;
  final SaveQuotaInteractor _saveQuotaInteractor;

  AccountDetailsViewModel(
    Store<AppState> store,
    this.deletePermanentTokenInteractor,
    this._appNavigation,
    this._isAvailableBiometricInteractor,
    this._getAuthorizedInteractor,
    this._disableBiometricInteractor,
    this._getLastLoginInteractor,
    this._getQuotaInteractor,
    this._deleteAllOfflineDocumentInteractor,
    this._deleteAllSharedSpaceOfflineInteractor,
    this._saveAuthorizedUserInteractor,
    this._saveLastLoginInteractor,
    this._saveQuotaInteractor,
  ) : super(store);

  void logout() {
    store.dispatch(_resetBiometricSetting());
    store.dispatch(logoutAction());
    _appNavigation.pushAndRemoveAll(RoutePaths.loginRoute);
    store.dispatch(ClearCurrentView());
  }

  ThunkAction<AppState> logoutAction() {
    return (Store<AppState> store) async {
      await Future.wait([
        deletePermanentTokenInteractor.execute(),
        _deleteAllOfflineDocumentInteractor.execute(),
        _deleteAllSharedSpaceOfflineInteractor.execute()
      ]);
    };
  }

  void getSupportBiometricState() {
    store.dispatch((Store<AppState> store) async {
      await _isAvailableBiometricInteractor.execute()
        .then((result) => result.fold(
          (failure) => store.dispatch(SetSupportBiometricStateAction(SupportBiometricState.unavailable)),
          (success) {
            success is IsAvailableBiometricViewState
              ? store.dispatch(SetSupportBiometricStateAction(success.supportBiometricState))
              : store.dispatch(SetSupportBiometricStateAction(SupportBiometricState.unavailable));
          })
        );
    });
  }

  void getLastLogin() {
    store.dispatch((Store<AppState> store) async {
      await _getLastLoginInteractor.execute()
        .then((result) => result.fold(
          (failure) => store.dispatch(AccountAction(Left(failure))),
          (success) {
            if (success is GetLastLoginViewState) {
              store.dispatch(_saveLastLogin(success.lastLogin));
              store.dispatch(SetLastLoginAction(success.lastLogin));
            }
          })
        );
    });
  }

  void getUserInformation() {
    final currentUser = store.state.account.user;

    if (currentUser != null) {
      getAccountQuota(currentUser.quotaUuid);
    } else {
      store.dispatch(_getAuthorizedUserAction());
    }
    getLastLogin();
  }

  void getAccountQuota(QuotaId quotaId) {
    store.dispatch((Store<AppState> store) async {
      await _getQuotaInteractor.execute(quotaId)
        .then((result) => result.fold(
          (failure) => store.dispatch(AccountAction(Left(failure))),
          (success) {
            if (success is AccountQuotaViewState) {
              store.dispatch(_saveAccountQuota(success.accountQuota));
              store.dispatch(SetAccountQuotaAction(success.accountQuota));
            }
          }));
    });
  }

  ThunkAction<AppState> _getAuthorizedUserAction() {
    return (Store<AppState> store) async {
      store.dispatch(StartAccountLoadingAction());

      await _getAuthorizedInteractor.execute()
        .then((result) => result.fold(
          (left) => store.dispatch(GetAccountInformationAction(Left(left))),
          (success) {
            if (success is GetAuthorizedUserViewState) {
              store.dispatch(_saveAuthorizedUserAction(success.user));
            }
            store.dispatch(GetAccountInformationAction(Right(success)));
          }));
    };
  }

  ThunkAction<AppState> _saveAccountQuota(AccountQuota accountQuota) {
    return (Store<AppState> store) async {
      await _saveQuotaInteractor.execute(accountQuota);
    };
  }

  ThunkAction<AppState> _saveAuthorizedUserAction(User user) {
    return (Store<AppState> store) async {
      await _saveAuthorizedUserInteractor.execute(user);
    };
  }

  ThunkAction<AppState> _saveLastLogin(LastLogin lastLogin) {
    return (Store<AppState> store) async {
      await _saveLastLoginInteractor.execute(lastLogin);
    };
  }

  void goToBiometricAuthentication() {
    _appNavigation.push(RoutePaths.biometricAuthenticationSetting);
  }

  ThunkAction<AppState> _resetBiometricSetting() {
    return (Store<AppState> store) async {
      await _disableBiometricInteractor.execute();
    };
  }

  @override
  void onDisposed() {
    super.onDisposed();
  }
}
