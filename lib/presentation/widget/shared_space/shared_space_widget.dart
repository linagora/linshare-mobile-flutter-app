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
import 'package:flutter_svg/svg.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/shared_space_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/view/background_widgets/background_widget_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space/shared_space_viewmodel.dart';
import 'package:redux/redux.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/datetime_extension.dart';

class SharedSpaceWidget extends StatefulWidget {
  @override
  _SharedSpaceWidgetState createState() => _SharedSpaceWidgetState();
}

class _SharedSpaceWidgetState extends State<SharedSpaceWidget> {
  final sharedSpaceViewModel = getIt<SharedSpaceViewModel>();
  final imagePath = getIt<AppImagePaths>();

  @override
  void initState() {
    super.initState();
    sharedSpaceViewModel.getAllSharedSpaces();
  }

  @override
  void dispose() {
    super.dispose();
    sharedSpaceViewModel.onDisposed();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StoreConnector<AppState, SharedSpaceState>(
          converter: (store) => store.state.sharedSpaceState,
          distinct: true,
          builder: (context, state) {
            return state.viewState.fold(
              (failure) => SizedBox.shrink(),
              (success) => (success is LoadingState)
                  ? Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        valueColor:
                          AlwaysStoppedAnimation<Color>(
                            AppColor.primaryColor),
                      ),
                    )) : SizedBox.shrink());
            }
        ),
        StoreConnector<AppState, SharedSpaceState>(
          converter: (store) => store.state.sharedSpaceState,
          distinct: true,
          builder: (context, state) => Expanded(child: _buildSharedSpacesList(context, state))
        )
      ],
    );
  }

  Widget _buildSharedSpacesList(BuildContext context, SharedSpaceState state) {
    return state.viewState.fold(
      (failure) =>
        RefreshIndicator(
          onRefresh: () async => sharedSpaceViewModel.getAllSharedSpaces(),
          child: failure is SharedSpaceFailure ? 
            BackgroundWidgetBuilder()
                .key(Key('shared_space_error_background'))
                .image(SvgPicture.asset(
                  imagePath.icUnexpectedError,
                  width: 120,
                  height: 120,
                  fit: BoxFit.fill))
                .text(AppLocalizations.of(context).common_error_occured_message)
                .build() : _buildSharedSpacesListView(context, state.sharedSpacesList)
        ),
      (success) => success is LoadingState ?
        _buildSharedSpacesListView(context, state.sharedSpacesList) :
        RefreshIndicator(
          onRefresh: () async => sharedSpaceViewModel.getAllSharedSpaces(),
          child: _buildSharedSpacesListView(context, state.sharedSpacesList)
        )
    );
  }

  Widget _buildSharedSpacesListView(BuildContext context, List<SharedSpaceNodeNested> sharedSpacesList) {
    if (sharedSpacesList.isEmpty) {
      return _buildNoWorkgroupYet(context);
    } else {
      return ListView.builder(
        key: Key('shared_spaces_list'),
        padding: EdgeInsets.zero,
        itemCount: sharedSpacesList.length,
        itemBuilder: (context, index) {
          return _buildSharedSpaceListItem(context, sharedSpacesList[index]);
        },
      );
    }
  }

  Widget _buildNoWorkgroupYet(BuildContext context) {
    return BackgroundWidgetBuilder()
      .key(Key('shared_space_no_workgroup_yet'))
      .image(SvgPicture.asset(
        imagePath.icSharedSpaceNoWorkGroup,
        width: 120,
        height: 120,
        fit: BoxFit.fill))
      .text(AppLocalizations.of(context).do_not_have_any_workgroup).build();
  }

  Widget _buildSharedSpaceListItem(BuildContext context, SharedSpaceNodeNested sharedSpace) {
    return ListTile(
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            imagePath.icSharedSpace,
            width: 20,
            height: 24,
            fit: BoxFit.fill)
        ]
      ),
      title: Transform(
          transform: Matrix4.translationValues(-16, 0.0, 0.0),
          child: _buildSharedSpaceName(sharedSpace.name),
      ),
      subtitle: Transform(
        transform: Matrix4.translationValues(-16, 0.0, 0.0),
        child: Row(
          children: [
            _buildModifiedSharedSpaceText(AppLocalizations.of(context).item_last_modified(
               sharedSpace.modificationDate.getMMMddyyyyFormatString()))
          ],
        ),
      ),
    );
  }

  Widget _buildSharedSpaceName(String sharedSpaceName) {
    return Text(
      sharedSpaceName,
      maxLines: 1,
      style: TextStyle(fontSize: 14, color: AppColor.documentNameItemTextColor),
    );
  }

  Widget _buildModifiedSharedSpaceText(String modificationDate) {
    return Text(
      modificationDate,
      style: TextStyle(fontSize: 13, color: AppColor.documentModifiedDateItemTextColor),
    );
  }
}
