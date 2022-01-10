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
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/ui_state.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/upload_request_status_extension.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/simple_context_menu_action_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/file_context_menu_mixin.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/recipient_context_menu_mixin.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/upload_request_inside_navigator_widget.dart';

abstract class UploadRequestInsideWidget extends StatefulWidget {
  final OnBackUploadRequestClickedCallback onBackUploadRequestClickedCallback;
  final OnUploadRequestClickedCallback onUploadRequestClickedCallback;

  UploadRequestInsideWidget(this.onBackUploadRequestClickedCallback, this.onUploadRequestClickedCallback);

  @override
  UploadRequestInsideWidgetState createState();
}

abstract class UploadRequestInsideWidgetState extends State<UploadRequestInsideWidget>
    with FileContextMenuMixin, RecipientContextMenuMixin {

  Widget buildTopBar({required Widget titleTopBar}) {
    return StoreConnector<AppState, SearchStatus>(
      converter: (store) => store.state.uiState.searchState.searchStatus,
      builder: (context, searchStatus) => searchStatus == SearchStatus.ACTIVE
        ? SizedBox.shrink()
        : Container(
            height: 48,
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: Offset(0, 4))
            ]),
            child: Row(children: [
                GestureDetector(
                  onTap: widget.onBackUploadRequestClickedCallback,
                  child: Container(
                    width: 48,
                    height: 48,
                    child: Align(
                      alignment: Alignment.center,
                      heightFactor: 24,
                      widthFactor: 24,
                      child: SvgPicture.asset(imagePath.icBackBlue, width: 24, height: 24),
                    ),
                  ),
                ),
                titleTopBar
              ]
            ))
    );
  }

  Widget buildItemTitle(String title) {
    return Text(
      title,
      maxLines: 1,
      style: TextStyle(fontSize: 14, color: AppColor.uploadRequestTitleTextColor));
  }

  Widget buildRecipientText(String recipient) {
    return Text(
      recipient,
      style: TextStyle(fontSize: 13, color: AppColor.uploadRequestHintTextColor));
  }

  Widget buildRecipientStatus(UploadRequestStatus status) {
    return Row(children: [
      Container(
        margin: EdgeInsets.only(right: 4),
        width: 7.0,
        height: 7.0,
        decoration: BoxDecoration(color: status.displayColor, shape: BoxShape.circle)),
      Text(
        status.displayValue(context),
        style: TextStyle(fontSize: 13, color: AppColor.uploadRequestHintTextColor))]);
  }

  Widget viewDetailsUploadRequestRecipientAction(BuildContext context, UploadRequest uploadRequest, Function(UploadRequest) onActionClick) {
    return SimpleContextMenuActionBuilder(
        Key('upload_request_recipient_details_context_menu_action'),
        SvgPicture.asset(imagePath.icInfo, width: 24, height: 24, fit: BoxFit.fill),
        AppLocalizations.of(context).details)
      .onActionClick((data) => onActionClick.call(uploadRequest))
      .build();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
