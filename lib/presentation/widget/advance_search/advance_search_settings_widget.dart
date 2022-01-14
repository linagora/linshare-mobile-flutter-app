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

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/model/advance_search_date_state.dart';
import 'package:linshare_flutter_app/presentation/model/advance_search_kind_state.dart';
import 'package:linshare_flutter_app/presentation/model/advance_search_setting.dart';
import 'package:linshare_flutter_app/presentation/redux/states/advance_search_settings_workgroup_node_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/advance_search_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/helper/responsive_utils.dart';
import 'package:linshare_flutter_app/presentation/util/styles.dart';
import 'package:linshare_flutter_app/presentation/view/listview/sliver_grid_delegate_fixed_height.dart';
import 'package:linshare_flutter_app/presentation/widget/advance_search/advance_search_settings_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/advance_search/advance_search_settings_viewmodel.dart';

class AdvanceSearchSettingsWidget extends StatefulWidget {
  const AdvanceSearchSettingsWidget({Key? key}) : super(key: key);

  @override
  _AdvanceSearchSettingsWidgetState createState() => _AdvanceSearchSettingsWidgetState();
}

class _AdvanceSearchSettingsWidgetState extends State<AdvanceSearchSettingsWidget> {

  final _model = getIt<AdvanceSearchSettingsViewModel>();
  final _imagePath = getIt<AppImagePaths>();
  final _responsiveUtils = getIt<ResponsiveUtils>();

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      var arg = ModalRoute.of(context)?.settings.arguments as AdvanceSearchSettingsArguments;
      _model.initState(arg);
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
    return GestureDetector(
        onTap: () => _model.popBack(),
        child: Card(
            margin: EdgeInsets.zero,
            borderOnForeground: false,
            color: Colors.transparent,
            child: Container(
              margin: _responsiveUtils.getMarginForAdvancedSearch(context),
              child: ClipRRect(
                borderRadius: _responsiveUtils.getBorderRadiusAdvancedSearchView(context),
                child: GestureDetector(
                    onTap: () => {},
                    child: Scaffold(
                      backgroundColor: Colors.white,
                      body: StoreConnector<AppState, AdvancedSearchSettingsWorkgroupNodeState>(
                        converter: (store) => store.state.advanceSearchSettingsWorkgroupNodeState,
                        builder: (context, state) => Stack(alignment: Alignment.topCenter, children: [
                          Container(
                            margin: EdgeInsets.only(top: 80),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  _buildListFileTypesLayout(state, state.advanceSearchSetting),
                                  _buildModificationDateLayout(state.advanceSearchSetting),
                                  Divider(),
                                  _buildLayoutButtonActions(state.advanceSearchSetting),
                                  SizedBox(height: 20)
                                ],
                              ),
                            )),
                          Container(
                            alignment: Alignment.topCenter,
                            height: 70,
                            margin: EdgeInsets.only(top: 20),
                            child: Column(children: [
                                Row(children: [
                                  Expanded(child: Padding(
                                    padding: EdgeInsets.only(left: 50),
                                    child: Text(
                                        AppLocalizations.of(context).advance_search_setting(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: AppColor.searchTextColor)))),
                                  IconButton(
                                      onPressed: () => _model.popBack(),
                                      icon: SvgPicture.asset(_imagePath.icCloseAdvancedSearch, width: 24, height: 24))
                                ]),
                              Divider(),
                            ])
                          ),
                        ]),
                      ),
                    )
                ),
              )
            )
        )
    );
  }

  Widget _buildListFileTypesLayout(AdvancedSearchSettingsWorkgroupNodeState advancedSearchState, AdvanceSearchSetting advanceSearchSetting) {
    return Column(
      children: [
        Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(child: Text(
                    AppLocalizations.of(context).file_type,
                    style: TextStyle(fontSize: 14, color: AppColor.advancedSearchSettingLabelColor, fontWeight: FontWeight.w500))),
                if (advanceSearchSetting.listKindState?.isNotEmpty == true)
                  TextButton(
                    onPressed: () => !advancedSearchState.isSelectedAllKindState() ? _model.checkAllFileTypeSettings() : null,
                    child: Text(AppLocalizations.of(context).check_all,
                      style: TextStyle(fontSize: 14, color: AppColor.advancedSearchSettingTextColor, fontWeight: FontWeight.w500)),
                  ),
              ],
            )
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 24.0),
          padding: EdgeInsets.zero,
          child: advanceSearchSetting.listKindState != null
             ? GridView.builder(
                key: Key('list_file_type'),
                primary: false,
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: advanceSearchSetting.listKindState!.length,
                gridDelegate: SliverGridDelegateFixedHeight(
                    height: 40,
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 0.0),
                itemBuilder: (context, index) => _buildFileTypeItem(advanceSearchSetting.listKindState![index]))
            : SizedBox.shrink()
        ),
      ]
    );
  }

  Widget _buildFileTypeItem(AdvancedSearchKindState kindState) => Row(
    children: [
      Checkbox(
        activeColor: AppColor.advancedSearchSettingTextColor,
        value: kindState.selected,
        onChanged: (value) {
          _model.setNewKindState(kindState.copyWith(selected: value));
        },
      ),
      Expanded(child: Text(
          kindState.kind.getDisplayName(context),
          style: CommonTextStyle.textStyleNormal.copyWith(fontSize: 16, color: Colors.black))),
    ],
  );

  Widget _buildModificationDateLayout(AdvanceSearchSetting advanceSearchSetting) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Text(AppLocalizations.of(context).modification_date,
              style: TextStyle(fontSize: 14, color: AppColor.advancedSearchSettingLabelColor, fontWeight: FontWeight.w500))
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 24.0),
          padding: EdgeInsets.zero,
          child: advanceSearchSetting.listModificationDate != null
              ? GridView.builder(
                  key: Key('list_modification_date'),
                  primary: false,
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: advanceSearchSetting.listModificationDate!.length,
                  gridDelegate: SliverGridDelegateFixedHeight(
                      height: 40,
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 0.0),
                  itemBuilder: (context, index) =>
                      _buildModificationDateListItem(advanceSearchSetting, advanceSearchSetting.listModificationDate![index]))
              : SizedBox.shrink(),
        ),
    ]);
  }

  Widget _buildModificationDateListItem(AdvanceSearchSetting advanceSearchSetting, AdvancedSearchDateState dateState) => Row(
    children: [
      Radio(
        value: dateState,
        onChanged: (value) {
          _model.setNewDateState(dateState.copyWith(selected: true));
        },
        groupValue: advanceSearchSetting.listModificationDate?.firstWhere((e) => e.selected == true),
      ),
      Expanded(
        child: InkWell(
          onTap: () => _model.setNewDateState(dateState.copyWith(selected: true)),
          child: Text(dateState.date.getDisplayName(context),
              style: CommonTextStyle.textStyleNormal.copyWith(fontSize: 16, color: Colors.black)),
        ),
      ),
    ],
  );

  Widget _buildLayoutButtonActions(AdvanceSearchSetting advanceSearchSetting) => Container(
    margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                  backgroundColor: AppColor.advancedSearchSettingButtonResetColor,
                  padding: EdgeInsets.symmetric(horizontal: 60, vertical: 12),
                  side: BorderSide(color: AppColor.advancedSearchSettingButtonResetColor, width: 0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
              onPressed: () => _model.resetAllSettings(),
              child: Text(
                  AppLocalizations.of(context).advance_search_button_reset(),
                  style: TextStyle(fontSize: 16.0, color: AppColor.advancedSearchSettingTextColor, fontWeight: FontWeight.w500)),
            ),
            OutlinedButton(
                onPressed: () => _model.applySearch(advanceSearchSetting),
                style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 60, vertical: 12),
                    backgroundColor: AppColor.advancedSearchSettingTextColor,
                    side: BorderSide(color: AppColor.advancedSearchSettingButtonResetColor, width: 0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                child: Text(
                    AppLocalizations.of(context).advance_search_button_apply(),
                    style: TextStyle(fontSize: 16.0, color: Colors.white, fontWeight: FontWeight.w500)))
          ]
    )
  );
}
