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
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/redux/states/account_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/view/modal_sheets/confirm_modal_sheet_builder.dart';
import 'package:redux/redux.dart';
import 'account_details_viewmodel.dart';

class AccountDetailsWidget extends StatefulWidget {
  @override
  _AccountDetailsWidgetState createState() => _AccountDetailsWidgetState();
}

class _AccountDetailsWidgetState extends State<AccountDetailsWidget> {
  final accountDetailsViewModel = getIt<AccountDetailsViewModel>();
  final imagePath = getIt<AppImagePaths>();
  final appNavigation = getIt<AppNavigation>();

  @override
  void initState() {
    super.initState();
    accountDetailsViewModel.getSupportBiometricState();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AccountState>(
      converter: (store) => store.state.account,
      builder: (context, state) => Column(
        children: [
          ListTile(
            leading: CircleAvatar(backgroundColor: Colors.blueGrey[900], child: Text(state.user != null ? state.user.firstName[0] : '')),
            isThreeLine: true,
            subtitle: Text(
              state.user != null ? state.user.mail : '',
              style: TextStyle(
                fontSize: 14,
                color: AppColor.documentModifiedDateItemTextColor
              )
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 24),
            child: Column(
              children: [
                _buildAccountDetailsTile(AppLocalizations.of(context).first_name, state.user != null ? state.user.firstName : ''),
                _buildAccountDetailsTile(AppLocalizations.of(context).last_name, state.user != null ? state.user.lastName : ''),
                Divider(),
                _buildBiometricAuthentication(),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context).logout,
                      style: TextStyle(fontSize: 16, color: AppColor.documentModifiedDateItemTextColor)
                    ),
                    IconButton(
                      padding: EdgeInsets.only(left: 24),
                      icon: SvgPicture.asset(
                        imagePath.icDelete,
                        fit: BoxFit.none,
                        color: AppColor.documentNameItemTextColor
                        ),
                        onPressed: () => ConfirmModalSheetBuilder(appNavigation)
                          .key(Key('logout_confirm_modal'))
                          .title(AppLocalizations.of(context).confirm_remove_account_title)
                          .cancelText(AppLocalizations.of(context).cancel)
                          .onConfirmAction(AppLocalizations.of(context).logout, () => accountDetailsViewModel.logout())
                          .show(context)
                    )
                  ]
                )
              ],
            )
          ),
        ]
      )
    );
  }

  Widget _buildAccountDetailsTile(String categoryName, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            categoryName,
            style: TextStyle(fontSize: 16, color: AppColor.documentModifiedDateItemTextColor)
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, color: AppColor.documentModifiedDateItemTextColor)
          )
        ]
      )
    );
  }

  Widget _buildBiometricAuthentication() {
    return StoreConnector<AppState, AccountState>(
      converter: (Store<AppState> store) => store.state.account,
      builder: (context, accountState) {
        return accountState.supportBiometricState == SupportBiometricState.available
          ? GestureDetector(
              onTap: () => accountDetailsViewModel.goBiometricAuthentication(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context).biometric_authentication,
                    style: TextStyle(fontSize: 16, color: AppColor.documentModifiedDateItemTextColor)),
                  IconButton(
                    padding: EdgeInsets.only(left: 24),
                    icon: SvgPicture.asset(
                      imagePath.icExpandMore,
                      fit: BoxFit.none,
                      color: AppColor.documentNameItemTextColor),
                    onPressed: () => accountDetailsViewModel.goBiometricAuthentication(),
                  )
                ]))
          : SizedBox.shrink();
        }
    );
  }
}
