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
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/received_share_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/view/background_widgets/background_widget_builder.dart';
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
    return Column(
      children: [
        StoreConnector<AppState, ReceivedShareState>(
            converter: (store) => store.state.receivedShareState,
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
                          valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
                        ),
                      ))
                    : SizedBox.shrink());
            }
        ),
        StoreConnector<AppState, ReceivedShareState>(
            converter: (store) => store.state.receivedShareState,
            distinct: true,
            builder: (context, state) => Expanded(child: _buildReceivedShareList(context, state))
        )
      ],
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
                  width: 120,
                  height: 120,
                  fit: BoxFit.fill))
                .text(AppLocalizations.of(context).common_error_occured_message)
                .build()
            : _buildReceivedShareListView(context, state.receivedList)
        ),
      (success) => success is LoadingState
          ? _buildReceivedShareListView(context, state.receivedList)
          : RefreshIndicator(
            onRefresh: () async => receivedShareViewModel.getAllReceivedShare(),
            child: _buildReceivedShareListView(context, state.receivedList)
      ));
  }

  Widget _buildReceivedShareListView(BuildContext context, List<Share> receivedList) {
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
        .image(SvgPicture.asset(
          imagePath.icNotReceivedYet,
          width: 120,
          height: 120,
          fit: BoxFit.fill))
        .text(AppLocalizations.of(context).not_have_received_yet).build();
  }

  Widget _buildReceivedShareListItem(BuildContext context, Share shareItem) {
    return ListTile(
      leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
                shareItem.mediaType.getFileTypeImagePath(imagePath),
                width: 20,
                height: 24,
                fit: BoxFit.fill)
          ]
      ),
      title: Transform(
        transform: Matrix4.translationValues(-16, 0.0, 0.0),
        child: _buildFileName(shareItem.name),
      ),
      subtitle: Transform(
        transform: Matrix4.translationValues(-16, 0.0, 0.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSenderName(shareItem.sender.fullName()),
                  _buildModifiedDateText(AppLocalizations.of(context).item_created_date(
                      shareItem.creationDate.getMMMddyyyyFormatString())),
                ],
              ),
            )
          ],
        ),
      ),
      onTap: () {},
    );
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
}
