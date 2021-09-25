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
// Linagora © 2009–2021. Contribute to Linshare R&D by subscribing to an Enterprise
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
import 'package:linshare_flutter_app/presentation/redux/actions/account_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/ui_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/util/router/route_paths.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/second_factor_authentication/second_factor_authentication_arguments.dart';
import 'package:redux/src/store.dart';
import 'package:redux_thunk/redux_thunk.dart';

import 'authentication_arguments.dart';

class AuthenticationViewModel extends BaseViewModel {
  final GetAuthorizedInteractor _getAuthorizedInteractor;
  final DeletePermanentTokenInteractor deletePermanentTokenInteractor;
  final AppNavigation _appNavigation;
  AuthenticationArguments? _authenticationArguments;

  AuthenticationViewModel(
    Store<AppState> store,
    this._getAuthorizedInteractor,
    this.deletePermanentTokenInteractor,
    this._appNavigation,
  ) : super(store) {
    _getAuthorizedUser();
  }

  void setAuthenticationArguments(AuthenticationArguments arguments) {
    _authenticationArguments = arguments;
  }

  void _getAuthorizedUser() {
    store.dispatch(_getAuthorizedUserAction());
  }

  ThunkAction<AppState> _getAuthorizedUserAction() {
    return (Store<AppState> store) async {
      await _getAuthorizedInteractor.execute().then((result) => result.fold(
              (failure) => _getAuthorizedUserFailure(failure),
              (success) {
                if(success is GetAuthorizedUserViewState) {
                  _getAuthorizedUserSuccess(success);
                }
              }));
    };
  }

  void _getAuthorizedUserSuccess(GetAuthorizedUserViewState success) {
    store.dispatch(SetAccountInformationsAction(success.user));
    store.dispatch(initializeHomeView(_appNavigation, _authenticationArguments!.baseUrl));
  }

  void _getAuthorizedUserFailure(Failure failure) {
    if (failure is NeedSetup2FA) {
      store.dispatch(logoutAction());
      _appNavigation.popAndPush(
        RoutePaths.second_factor_authentication,
        arguments: SecondFactorAuthenticationArguments(_authenticationArguments!.baseUrl));
    } else {
      store.dispatch(initializeHomeView(_appNavigation, _authenticationArguments!.baseUrl));
    }
  }

  ThunkAction<AppState> logoutAction() {
    return (Store<AppState> store) async {
      await deletePermanentTokenInteractor.execute();
    };
  }
}
