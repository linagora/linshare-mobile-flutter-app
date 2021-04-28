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

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/ui_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/router/route_paths.dart';

typedef OnCancelSearchPressed = Function();
typedef OnNewSearchQuery = Function(String);

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController _typeAheadController = TextEditingController();
  final imagePath = getIt<AppImagePaths>();
  final GlobalKey<ScaffoldState> _scaffoldKey;
  final OnCancelSearchPressed _onCancelSearchPressed;
  final OnNewSearchQuery _onNewSearchQuery;

  HomeAppBar(this._scaffoldKey, this._onCancelSearchPressed, this._onNewSearchQuery);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, UIState>(
        converter: (store) => store.state.uiState,
        builder: (context, uiState) {
          if (uiState.searchState.searchStatus == SearchStatus.ACTIVE) {
            return _searchAppBar(context, uiState.searchState.searchDestination);
          }
          return _homeAppBar(context);
        }
    );
  }

  Widget _searchAppBar(BuildContext context, SearchDestination searchDestination) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Transform(
        transform: Matrix4.translationValues(-5, 0.0, 0.0),
        child: TypeAheadFormField(
          textFieldConfiguration: TextFieldConfiguration(
              controller: _typeAheadController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                  border: _searchBorder(),
                  focusedBorder: _searchBorder(),
                  enabledBorder: _searchBorder(),
                  fillColor: AppColor.searchBottomBarColor,
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                  hintText: _getSearchHintText(context, searchDestination),
                  hintStyle: TextStyle(
                      color: AppColor.uploadFileFileSizeTextColor,
                      fontSize: 16.0),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 24.0,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () => _typeAheadController.clear(),
                    child: Icon(
                      Icons.cancel,
                      size: 20.0,
                    ),
                  ))),
          debounceDuration: Duration(milliseconds: 300),
          suggestionsCallback: (pattern) async {
            if (_onNewSearchQuery != null) {
              _onNewSearchQuery(pattern);
            }
            return null;
          },
          itemBuilder: (BuildContext context, itemData) {
            return null;
          },
          onSuggestionSelected: (suggestion) {},
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      actions: [
        Center(
          child: Padding(
            padding:
            const EdgeInsets.only(left: 8.0, right: 16.0),
            child: GestureDetector(
                onTap: () {
                  if (_onCancelSearchPressed != null) {
                    _onCancelSearchPressed();
                  }
                  _typeAheadController.clear();
                },
                child: Text(
                  AppLocalizations.of(context).cancel,
                  style:
                  TextStyle(color: AppColor.primaryColor, fontSize: 16.0),
                )),
          ),
        )
      ],
    );
  }

  OutlineInputBorder _searchBorder() {
    return OutlineInputBorder(
      borderSide: BorderSide(color: AppColor.searchBottomBarColor, width: 2.0),
      borderRadius: const BorderRadius.all(
        Radius.circular(36.0),
      ),
    );
  }

  AppBar _homeAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: StoreConnector<AppState, UIState>(
          converter: (store) => store.state.uiState,
          distinct: true,
          builder: (context, uiState) => Text(
              getAppBarTitle(context, uiState),
              style: TextStyle(fontSize: 24, color: Colors.white))
      ),
      centerTitle: true,
      backgroundColor: AppColor.primaryColor,
      leading: IconButton(
          icon: SvgPicture.asset(imagePath.icLinShareMenu),
          onPressed: () => _scaffoldKey.currentState.openDrawer()),
    );
  }

  String getAppBarTitle(BuildContext context, UIState uiState) {
    switch (uiState.routePath) {
      case RoutePaths.mySpace:
        return AppLocalizations.of(context).my_space_title;
      case RoutePaths.sharedSpace:
        return AppLocalizations.of(context).shared_space;
      case RoutePaths.sharedSpaceInside:
        return uiState.selectedSharedSpace.name;
      case RoutePaths.account_details:
        return AppLocalizations.of(context).account_details_title;
      case RoutePaths.received_shares:
        return AppLocalizations.of(context).received;
      default:
        return AppLocalizations.of(context).my_space_title;
    }
  }

  String _getSearchHintText(BuildContext context, SearchDestination searchDestination) {
    switch (searchDestination) {
      case SearchDestination.mySpace:
        return AppLocalizations.of(context).search_in_my_space;
      case SearchDestination.sharedSpace:
        return AppLocalizations.of(context).search_in_shared_space_files;
      case SearchDestination.allSharedSpaces:
        return AppLocalizations.of(context).search_in_shared_space;
      case SearchDestination.receivedShares:
        return AppLocalizations.of(context).search_in_my_received_shares;
      default:
        return '';
    }
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
