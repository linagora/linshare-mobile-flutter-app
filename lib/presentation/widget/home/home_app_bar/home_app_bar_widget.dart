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
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/redux/states/advance_search_settings_workgroup_node_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/ui_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/util/router/route_paths.dart';
import 'package:linshare_flutter_app/presentation/widget/advance_search/advance_search_settings_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_details/shared_space_details_arguments.dart';

import 'home_app_bar_viewmodel.dart';

typedef OnCancelSearchPressed = Function();
typedef OnNewSearchQuery = Function(String);

class HomeAppBarWidget extends StatefulWidget implements PreferredSizeWidget {
  final OnCancelSearchPressed? onCancelSearchPressed;
  final OnNewSearchQuery? onNewSearchQuery;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  HomeAppBarWidget({Key? key, this.scaffoldKey, this.onCancelSearchPressed, this.onNewSearchQuery})
      : super(key: key);

  @override
  _HomeAppBarWidgetState createState() => _HomeAppBarWidgetState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _HomeAppBarWidgetState extends State<HomeAppBarWidget> {
  final TextEditingController _typeAheadController = TextEditingController();
  final imagePath = getIt<AppImagePaths>();
  final _model = getIt<HomeAppBarViewModel>();
  final _appNavigation = getIt.get<AppNavigation>();

    @override
  void initState() {
    _model.registerViewStateHandler(_typeAheadController);
    super.initState();
  }

  @override
  void dispose() {
    _model.onDisposed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          if (state.uiState.searchState.searchStatus == SearchStatus.ACTIVE) {
            return _searchAppBar(
              context,
              state.uiState.searchState.searchDestination,
              state.uiState.searchState.destinationName,
              state.uiState,
              state.advanceSearchSettingsWorkgroupNodeState);
          }
          return _homeAppBar(context, state.uiState);
        }
    );
  }

  Widget _searchAppBar(BuildContext context,
      SearchDestination searchDestination,
      String destinationName,
      UIState uiState,
      AdvancedSearchSettingsWorkgroupNodeState advancedSearchSettingState) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Transform(
        transform: Matrix4.translationValues(-16, 0.0, 0.0),
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            TypeAheadFormField(
              textFieldConfiguration: TextFieldConfiguration(
                  controller: _typeAheadController,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                      border: _searchBorder(),
                      focusedBorder: _searchBorder(),
                      enabledBorder: _searchBorder(),
                      fillColor: AppColor.searchBarColor,
                      filled: true,
                      contentPadding: searchDestination == SearchDestination.sharedSpace
                          ? EdgeInsets.fromLTRB(0, 0, 80, 0)
                          : EdgeInsets.symmetric(vertical: 0),
                      hintText: destinationName,
                      hintStyle: TextStyle(
                          color: AppColor.uploadFileFileSizeTextColor,
                          fontSize: 15.0),
                      labelStyle: TextStyle(
                          color: AppColor.searchTextColor,
                          fontSize: 15.0),
                      prefixIcon: Icon(
                        Icons.search,
                        size: 24.0,
                        color: AppColor.searchFilterButtonColor,
                      ),
                      suffixIcon: searchDestination != SearchDestination.sharedSpace
                        ? GestureDetector(
                            onTap: () => _typeAheadController.clear(),
                            child: Icon(
                              Icons.cancel,
                              size: 20.0,
                                color: AppColor.searchFilterButtonColor
                            ))
                        : null
                  )),
              debounceDuration: Duration(milliseconds: 300),
              suggestionsCallback: (pattern) async {
                if (widget.onNewSearchQuery != null) {
                  widget.onNewSearchQuery!(pattern);
                }
                return [];
              },
              itemBuilder: (BuildContext context, itemData) {
                return SizedBox.shrink();
              },
              onSuggestionSelected: (suggestion) {},
              noItemsFoundBuilder: (context) => SizedBox(),
              hideOnEmpty: true,
              hideOnError: true,
              hideOnLoading: true,
              hideSuggestionsOnKeyboardHide: true,
            ),
            if (searchDestination == SearchDestination.sharedSpace)
              Container(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          padding: EdgeInsets.only(left: 16),
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onPressed: () => _goToAdvanceSearchScreen(searchDestination, uiState),
                          icon: SvgPicture.asset(imagePath.icFilter,
                              width: 20.0,
                              height: 20.0,
                              color: advancedSearchSettingState.isApplyAdvancedSearch()
                                  ? AppColor.searchFilterButtonSelectedColor
                                  : AppColor.searchFilterButtonColor)),
                      IconButton(
                        padding: EdgeInsets.zero,
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onPressed: () => _typeAheadController.clear(),
                        icon: Icon(
                            Icons.cancel,
                            size: 20.0,
                            color: AppColor.searchFilterButtonColor),
                      ),
                    ]
                  )
              ),
          ],
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      leading: IconButton(
          padding: EdgeInsets.zero,
          highlightColor: Colors.transparent,
          onPressed: () {
            if (widget.onCancelSearchPressed != null) {
              widget.onCancelSearchPressed!();
            }
            _typeAheadController.clear();
          },
          icon: SvgPicture.asset(imagePath.icArrowBackRound,
              width: 30.0,
              height: 30.0,
              color: AppColor.searchBackButtonColor)),
    );
  }

  OutlineInputBorder _searchBorder() {
    return OutlineInputBorder(
      borderSide: BorderSide(color: AppColor.searchBarColor, width: 0.0),
      borderRadius: const BorderRadius.all(
        Radius.circular(15.0),
      ),
    );
  }

  AppBar _homeAppBar(BuildContext context, UIState uiState) {
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
          onPressed: () => widget.scaffoldKey!.currentState!.openDrawer()),
      actions: [
        if (uiState.routePath == RoutePaths.sharedSpaceInside && uiState.selectedParentNode == null)
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: IconButton(
              icon: SvgPicture.asset(imagePath.icInfo, width: 28, height: 28, color: Colors.white),
              onPressed: () => _goToSharedSpaceDetails(uiState.selectedSharedSpace)))
      ],
    );
  }

  String getAppBarTitle(BuildContext context, UIState uiState) {
    switch (uiState.routePath) {
      case RoutePaths.mySpace:
        return AppLocalizations.of(context).my_space_title;
      case RoutePaths.sharedSpace:
        return AppLocalizations.of(context).shared_space;
      case RoutePaths.insideSharedSpaceNode:
        return uiState.selectedParentNode?.name ?? AppLocalizations.of(context).shared_space;
      case RoutePaths.sharedSpaceInside:
        if (uiState.selectedParentNode != null) {
          return uiState.selectedParentNode!.name;
        }
        return uiState.selectedSharedSpace?.name ?? AppLocalizations.of(context).shared_space;
      case RoutePaths.account_details:
        return AppLocalizations.of(context).account_details_title;
      case RoutePaths.received_shares:
        return AppLocalizations.of(context).received;
      case RoutePaths.uploadRequestGroup:
        return AppLocalizations.of(context).upload_requests;
      case RoutePaths.uploadRequestInside:
        return uiState.uploadRequestGroup?.label ?? AppLocalizations.of(context).upload_requests;
      default:
        return AppLocalizations.of(context).my_space_title;
    }
  }

  void _goToAdvanceSearchScreen(SearchDestination searchDestination, UIState uiState) {
    if(searchDestination == SearchDestination.sharedSpace) {
      _appNavigation.push(
          RoutePaths.advanceSearchSettings,
          arguments: AdvanceSearchSettingsArguments(searchDestination, query: _typeAheadController.text, sharedSpaceId: uiState.selectedSharedSpace?.sharedSpaceId)
      );
    }
  }

  void _goToSharedSpaceDetails(SharedSpaceNodeNested? sharedSpaceNodeNested) {
    if (sharedSpaceNodeNested != null) {
      _appNavigation.push(
          RoutePaths.sharedSpaceDetails,
          arguments: SharedSpaceDetailsArguments(sharedSpaceNodeNested)
      );
    }
  }
}
