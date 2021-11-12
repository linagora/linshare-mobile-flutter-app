/*
 * LinShare is an open source filesharing software, part of the LinPKI software
 * suite, developed by Linagora.
 *
 * Copyright (C) 2021 LINAGORA
 *
 * This program is free software: you can redistribute it and/or modify it under the
 * terms of the GNU Affero General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version,
 * provided you comply with the Additional Terms applicable for LinShare software by
 * Linagora pursuant to Section 7 of the GNU Affero General Public License,
 * subsections (b), (c), and (e), pursuant to which you must notably (i) retain the
 * display in the interface of the “LinShare™” trademark/logo, the "Libre & Free" mention,
 * the words “You are using the Free and Open Source version of LinShare™, powered by
 * Linagora © 2009–2021. Contribute to Linshare R&D by subscribing to an Enterprise
 * offer!”. You must also retain the latter notice in all asynchronous messages such as
 * e-mails sent with the Program, (ii) retain all hypertext links between LinShare and
 * http://www.linshare.org, between linagora.com and Linagora, and (iii) refrain from
 * infringing Linagora intellectual property rights over its trademarks and commercial
 * brands. Other Additional Terms apply, see
 * <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf>
 * for more details.
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for
 * more details.
 * You should have received a copy of the GNU Affero General Public License and its
 * applicable Additional Terms for LinShare along with this program. If not, see
 * <http://www.gnu.org/licenses/> for the GNU Affero General Public License version
 *  3 and <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf> for
 *  the Additional Terms applicable to LinShare software.
 */

import 'package:domain/domain.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/model/item_selection_type.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/upload_request_context_menu_action_builder.dart';
import 'package:linshare_flutter_app/presentation/view/multiple_selection_bar/upload_request_multiple_selection_action_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/upload_request_inside_navigator_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/upload_request_inside_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/upload_request_inside_widget.dart';

import 'archived_upload_request_inside_view_model.dart';

class ArchivedUploadRequestInsideWidget extends UploadRequestInsideWidget {
  ArchivedUploadRequestInsideWidget(
    OnBackUploadRequestClickedCallback onBackUploadRequestClickedCallback,
    OnUploadRequestClickedCallback onUploadRequestClickedCallback
  ) : super(onBackUploadRequestClickedCallback, onUploadRequestClickedCallback);

  @override
  UploadRequestInsideWidgetState createState() {
    return _ArchivedUploadRequestInsideWidgetState();
  }
}

class _ArchivedUploadRequestInsideWidgetState extends UploadRequestInsideWidgetState {

  @override
  void openFileContextMenu(BuildContext context, UploadRequestEntry entry) {
  }

  @override
  UploadRequestInsideViewModel get viewModel => getIt<ArchivedUploadRequestInsideViewModel>();

  @override
  List<Widget> fileContextMenuActionTiles(BuildContext context, UploadRequestEntry entry) {
    throw UnimplementedError();
  }

  @override
  Widget? fileFooterActionTile() {
    return null;
  }

  @override
  List<Widget> fileMultipleSelectionActions(BuildContext context, List<UploadRequestEntry> allSelectedEntries) {
    throw UnimplementedError();
  }

  @override
  List<Widget> recipientContextMenuActionTiles(BuildContext context, UploadRequest entry) {
    return [
      _removeRecipientAction([entry])
    ];
  }

  @override
  Widget? recipientFooterActionTile() {
    return null;
  }

  Widget _removeRecipientAction(
    List<UploadRequest> entries,
    {ItemSelectionType itemSelectionType = ItemSelectionType.single}
  ) {
    return UploadRequestContextMenuActionBuilder(
        Key('remove_upload_request_entry_context_menu_action'),
        SvgPicture.asset(imagePath.icDelete, width: 24, height: 24, fit: BoxFit.fill),
        AppLocalizations.of(context).delete,
        entries.first)
      .onActionClick((data) => (viewModel as ArchivedUploadRequestInsideViewModel)
        .removeRecipients(context, entries, itemSelectionType: itemSelectionType))
      .build();
  }


  Widget _removeRecipientMultipleSelection(List<UploadRequest> uploadRequestEntries) {
    return UploadRequestMultipleSelectionActionBuilder(
        Key('multiple_selection_remove_action'),
        SvgPicture.asset(imagePath.icDelete, width: 24, height: 24, fit: BoxFit.fill),
        uploadRequestEntries)
      .onActionClick((entries) => (viewModel as ArchivedUploadRequestInsideViewModel)
        .removeRecipients(context, entries, itemSelectionType: ItemSelectionType.multiple))
      .build();
  }

  @override
  List<Widget> recipientMultipleSelectionActions(BuildContext context, List<UploadRequest> allSelected) {
    return [
      _removeRecipientMultipleSelection(allSelected)
    ];
  }
}