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
import 'package:linshare_flutter_app/presentation/model/advance_search_setting.dart';
import 'package:linshare_flutter_app/presentation/redux/states/advance_search_settings_workgroup_node_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/styles.dart';
import 'package:linshare_flutter_app/presentation/widget/advance_search/advance_search_settings_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/advance_search/advance_search_settings_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/advance_search_extension.dart';

class AdvanceSearchSettingsWidget extends StatefulWidget {
  const AdvanceSearchSettingsWidget({Key? key}) : super(key: key);

  @override
  _AdvanceSearchSettingsWidgetState createState() => _AdvanceSearchSettingsWidgetState();
}

class _AdvanceSearchSettingsWidgetState extends State<AdvanceSearchSettingsWidget> {

  final _model = getIt<AdvanceSearchSettingsViewModel>();
  final _imagePath = getIt<AppImagePaths>();

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.advanceSearchAppbarBackgroundColor,
        leading: IconButton(
          icon: SvgPicture.asset(_imagePath.icClose, color: AppColor.advanceSearchAppbarTitleColor),
          onPressed: () => _model.popBack(),
        ),
        title: Text(AppLocalizations.of(context).advance_search_setting(),
          style:
            TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColor.advanceSearchAppbarTitleColor)),
      ),
      body: StoreConnector<AppState, AdvanceSearchSettingsWorkgroupNodeState>(
        converter: (store) => store.state.advanceSearchSettingsWorkgroupNodeState,
        builder: (context, state) => SingleChildScrollView(
          child: Column(
            children: [
              _buildListFileTypesLayout(state.advanceSearchSetting),
              _buildModificationDateLayout(state.advanceSearchSetting),
              _buildLayoutButtonActions(state.advanceSearchSetting)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListFileTypesLayout(AdvanceSearchSetting advanceSearchSetting) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        children: advanceSearchSetting.listKindState?.map((kindState) {
          return CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.all(0),
            title: Text(kindState.kind.getDisplayName(context),
                style: CommonTextStyle.textStyleNormal.copyWith(fontSize: 14, color: Colors.black)),
            value: kindState.selected,
            onChanged: (value) {
              _model.setNewKindState(kindState.copyWith(selected: value));
            });
        }).toList() ?? []
   ),
    );
  }

  Widget _buildModificationDateLayout(AdvanceSearchSetting advanceSearchSetting) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Text(AppLocalizations.of(context).modification_date)
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: _buildModificationDateList(advanceSearchSetting)
    ),
        ),
    ]);
  }

  List<Widget> _buildModificationDateList(AdvanceSearchSetting advanceSearchSetting) =>
    advanceSearchSetting.listModificationDate?.map((dateState) {
      return _buildModificationDateListItem(advanceSearchSetting, dateState);
    }).toList() ?? [];

  Widget _buildModificationDateListItem(AdvanceSearchSetting advanceSearchSetting, AdvanceSearchDateState dateState) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: InkWell(
          onTap: () => _model.setNewDateState(dateState.copyWith(selected: true)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(dateState.date.getDisplayName(context),
                style: CommonTextStyle.textStyleNormal.copyWith(fontSize: 14, color: Colors.black)),
          ),
        ),
      ),
      Radio(
        value: dateState,
        onChanged: (value) {
          _model.setNewDateState(dateState.copyWith(selected: true));
        },
        groupValue: advanceSearchSetting.listModificationDate?.firstWhere((e) => e.selected == true),
      )
    ],
  );

  Widget _buildLayoutButtonActions(AdvanceSearchSetting advanceSearchSetting) => Container(
    margin: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => _model.resetAllSettings(),
            child: Text(AppLocalizations.of(context).advance_search_button_reset(),
              style: CommonTextStyle.textStyleNormal.copyWith(fontSize: 16, color: AppColor.advanceSearchButtonResetColor))
          ),
          TextButton(
            onPressed: () => _model.applySearch(advanceSearchSetting),
            child: Text(AppLocalizations.of(context).advance_search_button_apply(),
                style: CommonTextStyle.textStyleNormal.copyWith(fontSize: 16))
          )
        ],
    ),
  );
}
