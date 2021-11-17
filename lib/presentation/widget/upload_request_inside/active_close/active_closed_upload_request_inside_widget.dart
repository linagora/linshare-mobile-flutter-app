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

import 'dart:io';

import 'package:domain/domain.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/model/item_selection_type.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/upload_request_entry_context_menu_action_builder.dart';
import 'package:linshare_flutter_app/presentation/view/multiple_selection_bar/uploadrequest_entry_multiple_selection_action_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/active_close/active_closed_upload_request_inside_view_model.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/upload_request_inside_navigator_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/upload_request_inside_widget.dart';

import '../upload_request_inside_viewmodel.dart';

class ActiveClosedUploadRequestInsideWidget extends UploadRequestInsideWidget {
  ActiveClosedUploadRequestInsideWidget(
    OnBackUploadRequestClickedCallback onBackUploadRequestClickedCallback,
    OnUploadRequestClickedCallback onUploadRequestClickedCallback
  ) : super(onBackUploadRequestClickedCallback, onUploadRequestClickedCallback);

  @override
  UploadRequestInsideWidgetState createState() {
    return _ActiveCloseUploadRequestInsideWidgetState();
  }
}

class _ActiveCloseUploadRequestInsideWidgetState extends UploadRequestInsideWidgetState {

  @override
  UploadRequestInsideViewModel get viewModel => getIt<ActiveCloseUploadRequestInsideViewModel>();

  Widget _downloadFileMultipleSelection(List<UploadRequestEntry> uploadRequestEntries) {
    return UploadRequestEntryMultipleSelectionActionBuilder(
        Key('multiple_selection_download_action'),
        SvgPicture.asset(
          Platform.isAndroid
              ? imagePath.icFileDownload
              : imagePath.icExportFile,
          width: 24,
          height: 24,
          fit: BoxFit.fill,
        ),
        uploadRequestEntries)
      .onActionClick((entries) => Platform.isAndroid
        ? viewModel.downloadEntries(entries, itemSelectionType: ItemSelectionType.multiple)
        : viewModel.exportFiles(context, entries, itemSelectionType: ItemSelectionType.multiple))
      .build();
  }

  Widget _removeFileMultipleSelection(List<UploadRequestEntry> uploadRequestEntries) {
    return UploadRequestEntryMultipleSelectionActionBuilder(
        Key('multiple_selection_remove_action'),
        SvgPicture.asset(imagePath.icDelete, width: 24, height: 24, fit: BoxFit.fill),
        uploadRequestEntries)
      .onActionClick((entries) => viewModel.removeFiles(
        context,
        entries,
        itemSelectionType: ItemSelectionType.multiple))
      .build();
  }

  Widget _moreActionMultipleSelection(BuildContext context, List<UploadRequestEntry> entries) {
    return UploadRequestEntryMultipleSelectionActionBuilder(
        Key('multiple_selection_more_action'),
        SvgPicture.asset(
          imagePath.icMoreVertical,
          width: 24,
          height: 24,
          fit: BoxFit.fill,
        ),
        entries)
      .onActionClick((entries) => viewModel.openMoreActionBottomMenu(
        context,
        entries,
        _moreActionList(context, entries),
        SizedBox.shrink()))
      .build();
  }

  List<Widget> _moreActionList(BuildContext context, List<UploadRequestEntry> entries) {
    return [
      _exportFileAction(entries, itemSelectionType: ItemSelectionType.multiple),
      _removeFileAction(entries, itemSelectionType: ItemSelectionType.multiple),
      _copyToMySpaceAction(entries, itemSelectionType: ItemSelectionType.multiple),
      if (Platform.isAndroid) _downloadFilesAction(entries, itemSelectionType: ItemSelectionType.multiple),
    ];
  }

  Widget _exportFileAction(
    List<UploadRequestEntry> entries,
    {ItemSelectionType itemSelectionType = ItemSelectionType.single}
  ) {
    return UploadRequestEntryContextMenuTileBuilder(
        Key('export_file_context_menu_action'),
        SvgPicture.asset(imagePath.icExportFile, width: 24, height: 24, fit: BoxFit.fill),
        AppLocalizations.of(context).export_file,
        entries.first)
      .onActionClick((data) => viewModel.exportFiles(context, entries, itemSelectionType: itemSelectionType))
      .build();
  }

  Widget _downloadFilesAction(List<UploadRequestEntry> entries, {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    return UploadRequestEntryContextMenuTileBuilder(
        Key('download_file_context_menu_action'),
        SvgPicture.asset(imagePath.icFileDownload, width: 24, height: 24, fit: BoxFit.fill),
        AppLocalizations.of(context).download_to_device,
        entries.first)
      .onActionClick((data) => viewModel.downloadEntries(entries, itemSelectionType: itemSelectionType))
      .build();
  }

  Widget _copyToMySpaceAction(List<UploadRequestEntry> entries,
      {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    return UploadRequestEntryContextMenuTileBuilder(
        Key('copy_to_my_space_context_menu_action'),
        SvgPicture.asset(imagePath.icCopy, width: 24, height: 24, fit: BoxFit.fill),
        AppLocalizations.of(context).copy_to_my_space,
        entries.first)
        .onActionClick((data) => viewModel.copyToMySpace(entries, itemSelectionType: itemSelectionType))
        .build();
  }

  Widget _removeFileAction(List<UploadRequestEntry> entries,
      {ItemSelectionType itemSelectionType = ItemSelectionType.single}) {
    return UploadRequestEntryContextMenuTileBuilder(
        Key('remove_upload_request_entry_context_menu_action'),
        SvgPicture.asset(imagePath.icDelete, width: 24, height: 24, fit: BoxFit.fill),
        AppLocalizations.of(context).delete,
        entries.first)
      .onActionClick((data) => viewModel.removeFiles(context, entries, itemSelectionType: itemSelectionType))
      .build();
  }

  @override
  List<Widget> fileContextMenuActionTiles(BuildContext context, UploadRequestEntry entry) {
    return [
      _exportFileAction([entry]),
      _removeFileAction([entry]),
      _copyToMySpaceAction([entry]),
      if (Platform.isAndroid) _downloadFilesAction([entry])
    ];
  }

  @override
  Widget? fileFooterActionTile() {
    return null;
  }

  @override
  List<Widget> fileMultipleSelectionActions(BuildContext context, List<UploadRequestEntry> allSelectedEntries) {
    return [
      _downloadFileMultipleSelection(allSelectedEntries),
      _removeFileMultipleSelection(allSelectedEntries),
      _moreActionMultipleSelection(context, allSelectedEntries)
    ];
  }

  @override
  void openRecipientContextMenu(BuildContext context, UploadRequest uploadRequest) {
    super.openRecipientContextMenu(context, uploadRequest);
  }

  @override
  Widget buildRecipientMultipleSelectionBottomBar(BuildContext context, List<UploadRequest> allSelected) {
    return SizedBox.shrink();
  }

  @override
  List<Widget> recipientContextMenuActionTiles(BuildContext context, UploadRequest entry) {
    return [
      if (entry.status == UploadRequestStatus.ENABLED) editUploadRequestRecipientAction(context, entry)
    ];
  }

  @override
  Widget? recipientFooterActionTile(UploadRequest entry) {
    return null;
  }

  @override
  List<Widget> recipientMultipleSelectionActions(BuildContext context, List<UploadRequest> allSelected) {
    throw UnimplementedError();
  }

  @override
  Widget? recipientFooterMultipleSelectionMoreActionBottomMenuTile(List<UploadRequest> allSelected) {
    throw UnimplementedError();
  }

  @override
  List<Widget> recipientMultipleSelectionMoreActionBottomMenuTiles(BuildContext context, List<UploadRequest> allSelected) {
    throw UnimplementedError();
  }
}
