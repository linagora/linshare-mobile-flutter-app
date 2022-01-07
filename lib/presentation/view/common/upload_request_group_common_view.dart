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
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/view/background_widgets/background_widget_builder.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/simple_context_menu_action_builder.dart';
import 'package:linshare_flutter_app/presentation/view/multiple_selection_bar/multiple_selection_bar_builder.dart';
import 'package:linshare_flutter_app/presentation/view/multiple_selection_bar/uploadrequest_group_multiple_selection_action_builder.dart';

class UploadRequestGroupCommonView {

  final imagePath = getIt<AppImagePaths>();

  Widget buildCreateUploadRequestsHere(BuildContext context, String icon) {
    return BackgroundWidgetBuilder(context)
      .key(Key('create_upload_request_here'))
      .image(SvgPicture.asset(icon, width: 120, height: 120, fit: BoxFit.fill))
      .text(AppLocalizations.of(context).create_upload_requests_here)
      .build();
  }

  Widget buildMultipleSelectionBottomBar(BuildContext context,
    {required List<UploadRequestGroup> allSelectedGroups,
    required List<Widget> actionWidgets}) => MultipleSelectionBarBuilder()
      .key(Key('multiple_upload_request_group_selection_bar'))
      .text(AppLocalizations.of(context).items(allSelectedGroups.length))
      .actions(actionWidgets)
      .build();

  Widget moreActionMultipleSelection(List<UploadRequestGroup> groups, Function onActionClick) =>
    UploadRequestGroupMultipleSelectionActionBuilder(
      Key('upload_request_group_multiple_selection_more_action'),
      SvgPicture.asset(imagePath.icMoreVertical, width: 24, height: 24, fit: BoxFit.fill),
      groups)
    .onActionClick((entries) => onActionClick.call())
    .build();

  Widget viewDetailsUploadRequestGroupAction(BuildContext context, UploadRequestGroup group, Function(UploadRequestGroup) onActionClick) {
    return SimpleContextMenuActionBuilder(
        Key('upload_request_group_details_context_menu_action'),
        SvgPicture.asset(imagePath.icInfo, width: 24, height: 24, fit: BoxFit.fill),
        AppLocalizations.of(context).details)
      .onActionClick((data) => onActionClick.call(group))
      .build();
  }
}
