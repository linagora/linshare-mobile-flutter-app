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
import 'package:linshare_flutter_app/presentation/model/file/selectable_element.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/functionality_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/upload_request_group_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/simple_horizontal_context_menu_action_builder.dart';
import 'package:linshare_flutter_app/presentation/view/search/search_bottom_bar_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_group/active_closed/active_closed_upload_request_group_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_group/archived/archived_upload_request_group_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_group/created/created_upload_request_group_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_group/upload_request_group_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/redux/states/ui_state.dart';

class UploadRequestGroupWidget extends StatefulWidget {
  UploadRequestGroupWidget({Key? key}) : super(key: key);

  @override
  _UploadRequestGroupWidgetState createState() => _UploadRequestGroupWidgetState();
}

class _UploadRequestGroupWidgetState extends State<UploadRequestGroupWidget> {
  final _model = getIt<UploadRequestGroupViewModel>();
  final imagePath = getIt<AppImagePaths>();

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      _model.initState();
    });
    super.initState();
  }

  @override
  void dispose() {
    _model.onDisposed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: _model.store.state.uiState.uploadRequestGroupTabIndex,
        length: 3,
        child: Scaffold(
          appBar: TabBar(
              unselectedLabelColor: AppColor.uploadRequestLabelsColor,
              unselectedLabelStyle: TextStyle(fontSize: 16),
              labelStyle: TextStyle(fontSize: 16),
              labelColor: AppColor.primaryColor,
              indicatorColor: AppColor.primaryColor,
              onTap: (index) {
                _model.setTabIndex(index);
                _model.cancelSelection();
              },
              tabs: [
                FittedBox(
                  fit: BoxFit.contain,
                  child: Tab(
                    text: AppLocalizations.of(context).pending,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.none,
                  child: Tab(
                    text: AppLocalizations.of(context).active_closed,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.contain,
                  child: Tab(
                    text: AppLocalizations.of(context).archived,
                  ),
                ),
              ]),
          body: StoreConnector<AppState, UploadRequestGroupState>(
            converter: (store) => store.state.uploadRequestGroupState,
            builder: (_, state) => TabBarView(
              children: [
                getIt<CreatedUploadRequestGroupWidget>(),
                getIt<ActiveClosedUploadRequestGroupWidget>(),
                getIt<ArchivedUploadRequestGroupWidget>(),
              ],
            ),
          ),
          bottomNavigationBar: StoreConnector<AppState, AppState>(
              converter: (store) => store.state,
              builder: (context, appState) {
                final isInMultipleSelectMode = (appState.activeClosedUploadRequestGroupState.selectMode == SelectMode.ACTIVE ||
                    appState.createdUploadRequestGroupState.selectMode == SelectMode.ACTIVE ||
                    appState.archivedUploadRequestGroupState.selectMode == SelectMode.ACTIVE);
                if (!appState.uiState.isInSearchState() && !isInMultipleSelectMode) {
                  return SearchBottomBarBuilder().key(Key('search_bottom_bar')).onSearchActionClick(() {
                    _model.openSearchState();
                  }).build();
                }
                return SizedBox.shrink();
              }),
          floatingActionButton: StoreConnector<AppState, AppState>(
              converter: (store) => store.state,
              builder: (context, appState) {
                final isInMultipleSelectMode = (appState.activeClosedUploadRequestGroupState.selectMode == SelectMode.ACTIVE ||
                    appState.createdUploadRequestGroupState.selectMode == SelectMode.ACTIVE ||
                    appState.archivedUploadRequestGroupState.selectMode == SelectMode.ACTIVE);
                if (!appState.uiState.isInSearchState() && !isInMultipleSelectMode) {
                  return FloatingActionButton(
                    key: Key('upload_request_add_button'),
                    onPressed: () => _model.openUploadRequestAddMenu(context, _addNewUploadRequestMenuActionTiles(context, appState.functionalityState)),
                    backgroundColor: AppColor.primaryColor,
                    child: SvgPicture.asset(
                      imagePath.icPlus,
                      width: 24,
                      height: 24,
                    ),
                  );
                }
                return SizedBox.shrink();
              }),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        ));
  }

  List<Widget> _addNewUploadRequestMenuActionTiles(BuildContext context, FunctionalityState state) {
    final uploadRequestFunctionality = state.getAllEnabledUploadRequest();
    return [_addCollectiveAction(context, uploadRequestFunctionality), _addIndividualAction(context, uploadRequestFunctionality)];
  }

  Widget _addCollectiveAction(BuildContext context, List<Functionality?> uploadRequestFunctionalities) => SimpleHorizontalContextMenuActionBuilder(
          Key('add_collective_ur_context_menu_action'),
          SvgPicture.asset(imagePath.icUploadRequestCollective, width: 24, height: 24, fit: BoxFit.fill, color: AppColor.uploadRequestAddNewIconColor),
          AppLocalizations.of(context).collective_upload)
      .onActionClick((_) => _model.addNewUploadRequest(UploadRequestCreationType.COLLECTIVE, uploadRequestFunctionalities))
      .build();

  Widget _addIndividualAction(BuildContext context, List<Functionality?> uploadRequestFunctionalities) => SimpleHorizontalContextMenuActionBuilder(
          Key('add_individual_ur_context_menu_action'),
          SvgPicture.asset(imagePath.icUploadRequestIndividual, width: 24, height: 24, fit: BoxFit.fill, color: AppColor.uploadRequestAddNewIconColor),
          AppLocalizations.of(context).individual_upload)
      .onActionClick((_) => _model.addNewUploadRequest(UploadRequestCreationType.INDIVIDUAL, uploadRequestFunctionalities))
      .build();
}
