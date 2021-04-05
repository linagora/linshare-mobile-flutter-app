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

import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:linshare_flutter_app/presentation/redux/online_thunk_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_toast.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/util/router/route_paths.dart';
import 'package:linshare_flutter_app/presentation/widget/authentication/authentication_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/enter_otp/enter_otp_argument.dart';
import 'package:redux/src/store.dart';

class EnterOTPViewModel extends BaseViewModel {
  final AppNavigation _appNavigation;
  final CreatePermanentTokenInteractor _getPermanentTokenInteractor;
  final DynamicUrlInterceptors _dynamicUrlInterceptors;
  final AppToast _appToast;
  EnterOTPArgument _enterOTPArgument;

  EnterOTPViewModel(
    Store<AppState> store,
    this._appNavigation,
    this._getPermanentTokenInteractor,
    this._dynamicUrlInterceptors,
    this._appToast
  ) : super(store);

  void setEnterOTPArgument(EnterOTPArgument argument) {
    _enterOTPArgument = argument;
  }

  void onBackPressed() {
    _appNavigation.popBack();
  }

  void onLoginPressed(String otp) {
    store.dispatch(_loginWithOTPAction(otp));
  }

  OnlineThunkAction _loginWithOTPAction(String otp) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _getPermanentTokenInteractor
          .execute(_enterOTPArgument.baseUrl, _enterOTPArgument.email, _enterOTPArgument.password, otpCode: OTPCode(otp))
          .then(
              (result) => result.fold(
                  (failure) => {
                    // todo show toast message here
                    _appToast.showErrorToast('invalid otp')
                  },
                  ((success) => _loginSuccess())));
    });
  }

  void _loginSuccess() async {
    _dynamicUrlInterceptors.changeBaseUrl(_enterOTPArgument.baseUrl.origin);
    await _appNavigation.pushAndRemoveAll(RoutePaths.authentication, arguments: AuthenticationArguments(_enterOTPArgument.baseUrl));
  }
}
