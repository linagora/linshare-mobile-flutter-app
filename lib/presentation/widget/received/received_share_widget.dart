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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/model/file/selectable_element.dart';
import 'package:linshare_flutter_app/presentation/model/item_selection_type.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/received_share_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/view/background_widgets/background_widget_builder.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/share_context_menu_action_builder.dart';
import 'package:linshare_flutter_app/presentation/view/multiple_selection_bar/multiple_selection_bar_builder.dart';
import 'package:linshare_flutter_app/presentation/view/multiple_selection_bar/received_share_multiple_selection_action_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/received/received_share_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/datetime_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/media_type_extension.dart';

class ReceivedShareWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ReceivedShareWidgetState();
}

class _ReceivedShareWidgetState extends State<ReceivedShareWidget> {
  final receivedShareViewModel = getIt<ReceivedShareViewModel>();
  final imagePath = getIt<AppImagePaths>();

  @override
  void initState() {
    super.initState();
    receivedShareViewModel.getAllReceivedShare();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ReceivedShareState>(
      converter: (store) => store.state.receivedShareState,
      builder: (context, state) {
        return Column(children: [
          state.selectMode == SelectMode.ACTIVE
              ? ListTile(
                  leading: SvgPicture.asset(imagePath.icSelectAll,
                      width: 28,
                      height: 28,
                      fit: BoxFit.fill,
                      color: state.isAllReceivedSharesSelected()
                          ? AppColor.unselectedElementColor
                          : AppColor.primaryColor),
                  title: Transform(
                      transform: Matrix4.translationValues(-16, 0.0, 0.0),
                      child: state.isAllReceivedSharesSelected()
                          ? Text(AppLocalizations.of(context).unselect_all,
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 14, color: AppColor.documentNameItemTextColor))
                          : Text(
                              AppLocalizations.of(context).select_all,
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 14, color: AppColor.documentNameItemTextColor),
                            )),
                  tileColor: AppColor.topBarBackgroundColor,
                  onTap: () => receivedShareViewModel.toggleSelectAllReceivedShares(),
                  trailing: TextButton(
                      onPressed: () => receivedShareViewModel.cancelSelection(),
                      child: Text(
                        AppLocalizations.of(context).cancel,
                        maxLines: 1,
                        style: TextStyle(fontSize: 14, color: AppColor.primaryColor),
                      )),
                )
              : SizedBox.shrink(),
          state.viewState.fold(
              (failure) => SizedBox.shrink(),
              (success) => (success is LoadingState)
                  ? Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
                        ),
                      ))
                  : SizedBox.shrink()),
          Expanded(child: _buildReceivedShareList(context, state)),
          state.selectMode == SelectMode.ACTIVE && state.getAllSelectedReceivedShares().isNotEmpty
              ? MultipleSelectionBarBuilder()
                  .key(Key('multiple_received_shares_selection_bar'))
                  .text(AppLocalizations.of(context)
                      .items(state.getAllSelectedReceivedShares().length))
                  .actions(_multipleSelectionActions(state.getAllSelectedReceivedShares()))
                  .build()
              : SizedBox.shrink()
        ]);
      },
    );
  }

  Widget _buildReceivedShareList(BuildContext context, ReceivedShareState state) {
    return state.viewState.fold(
        (failure) => RefreshIndicator(
            onRefresh: () async => receivedShareViewModel.getAllReceivedShare(),
            child: failure is SharedSpaceFailure
                ? BackgroundWidgetBuilder()
                    .key(Key('received_share_error_background'))
                    .image(SvgPicture.asset(imagePath.icUnexpectedError,
                        width: 120, height: 120, fit: BoxFit.fill))
                    .text(AppLocalizations.of(context).common_error_occured_message)
                    .build()
                : _buildReceivedShareListView(context, state.receivedSharesList)),
        (success) => success is LoadingState
            ? _buildReceivedShareListView(context, state.receivedSharesList)
            : RefreshIndicator(
                onRefresh: () async => receivedShareViewModel.getAllReceivedShare(),
                child: _buildReceivedShareListView(context, state.receivedSharesList)));
  }

  Widget _buildReceivedShareListView(
      BuildContext context, List<SelectableElement<ReceivedShare>> receivedList) {
    if (receivedList.isEmpty) {
      return _buildNoReceivedShareYet(context);
    } else {
      return ListView.builder(
        key: Key('received_share_list'),
        padding: EdgeInsets.zero,
        itemCount: receivedList.length,
        itemBuilder: (context, index) {
          return _buildReceivedShareListItem(context, receivedList[index]);
        },
      );
    }
  }

  Widget _buildNoReceivedShareYet(BuildContext context) {
    return BackgroundWidgetBuilder()
        .key(Key('no_received_share_yet'))
        .image(
            SvgPicture.asset(imagePath.icNotReceivedYet, width: 120, height: 120, fit: BoxFit.fill))
        .text(AppLocalizations.of(context).not_have_received_yet)
        .build();
  }

  Widget _buildReceivedShareListItem(
      BuildContext context, SelectableElement<ReceivedShare> shareItem) {
    return ListTile(
        leading: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          SvgPicture.asset(shareItem.element.mediaType.getFileTypeImagePath(imagePath),
              width: 20, height: 24, fit: BoxFit.fill)
        ]),
        title: Transform(
          transform: Matrix4.translationValues(-16, 0.0, 0.0),
          child: _buildFileName(shareItem.element.name),
        ),
        subtitle: Transform(
          transform: Matrix4.translationValues(-16, 0.0, 0.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSenderName(shareItem.element.sender.fullName()),
                    _buildModifiedDateText(AppLocalizations.of(context).item_created_date(
                        shareItem.element.creationDate.getMMMddyyyyFormatString())),
                  ],
                ),
              )
            ],
          ),
        ),
        trailing: StoreConnector<AppState, SelectMode>(
            converter: (store) => store.state.receivedShareState.selectMode,
            builder: (context, selectMode) {
              return selectMode == SelectMode.ACTIVE
                  ? Checkbox(
                      value: shareItem.selectMode == SelectMode.ACTIVE,
                      onChanged: (bool value) => receivedShareViewModel.selectItem(shareItem),
                      activeColor: AppColor.primaryColor,
                    )
                  : IconButton(
                      icon: SvgPicture.asset(
                        imagePath.icContextMenu,
                        width: 24,
                        height: 24,
                        fit: BoxFit.fill,
                      ),
                      onPressed: () => receivedShareViewModel.openContextMenu(context,
                          shareItem.element, _contextMenuActionTiles(context, shareItem.element)));
            }),
        onTap: () {},
        onLongPress: () => receivedShareViewModel.selectItem(shareItem));
  }

  Widget _buildFileName(String fileName) {
    return Padding(
      padding: const EdgeInsets.only(top: 28.0),
      child: Text(
        fileName,
        maxLines: 1,
        style: TextStyle(fontSize: 14, color: AppColor.documentNameItemTextColor),
      ),
    );
  }

  Widget _buildModifiedDateText(String modificationDate) {
    return Text(
      modificationDate,
      style: TextStyle(fontSize: 13, color: AppColor.documentModifiedDateItemTextColor),
    );
  }

  Widget _buildSenderName(String sender) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Text(
        sender,
        style: TextStyle(fontSize: 13, color: AppColor.documentModifiedDateItemTextColor),
      ),
    );
  }

  List<Widget> _contextMenuActionTiles(BuildContext context, ReceivedShare share) {
    return [
      _copyToMySpaceAction(context, share),
    ];
  }

  Widget _copyToMySpaceAction(BuildContext context, ReceivedShare receivedShare) {
    return ShareContextMenuTileBuilder(
            Key('copy_to_my_space_context_menu_action'),
            SvgPicture.asset(imagePath.icCopy, width: 24, height: 24, fit: BoxFit.fill),
            AppLocalizations.of(context).copy_to_my_space,
            receivedShare)
        .onActionClick((data) => receivedShareViewModel.copyToMySpace([receivedShare]))
        .build();
  }

  List<Widget> _multipleSelectionActions(List<ReceivedShare> receivedShares) {
    return [
      _copyToMySpaceMultipleSelection(receivedShares)
    ];
  }

  Widget _copyToMySpaceMultipleSelection(List<ReceivedShare> receivedShares) {
    return ReceivedShareMultipleSelectionActionBuilder(
      Key('multiple_selection_copy_action'),
      SvgPicture.asset(
        imagePath.icCopy,
        width: 24,
        height: 24,
        fit: BoxFit.fill,
      ),
      receivedShares)
      .onActionClick((documents) => receivedShareViewModel.copyToMySpace(receivedShares, itemSelectionType: ItemSelectionType.multiple))
      .build();
  }
}
