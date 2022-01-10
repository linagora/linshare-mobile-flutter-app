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

import 'package:dartz/dartz.dart' as dartz;
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/model/file_size_type.dart';
import 'package:linshare_flutter_app/presentation/model/nolitication_language.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/upload_request_recipient_details_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/view/avatar/label_avatar_builder.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/datetime_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/string_extensions.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/file_size_extension.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/recipient_details/upload_request_recipient_details_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/recipient_details/upload_request_recipient_details_viewmodel.dart';

class UploadRequestRecipientDetailsWidget extends StatefulWidget {
  @override
  _UploadRequestRecipientDetailsWidgetState createState() => _UploadRequestRecipientDetailsWidgetState();
}

class _UploadRequestRecipientDetailsWidgetState extends State<UploadRequestRecipientDetailsWidget> {
  final _model = getIt<UploadRequestRecipientDetailsViewModel>();
  final imagePath = getIt<AppImagePaths>();
  final appNavigation = getIt<AppNavigation>();

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      var arg = ModalRoute.of(context)?.settings.arguments as UploadRequestRecipientDetailsArguments;
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
    var arguments = ModalRoute.of(context)?.settings.arguments as UploadRequestRecipientDetailsArguments;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: Key('upload_request_recipient_details_arrow_back_button'),
          icon: Image.asset(imagePath.icArrowBack),
          onPressed: () => _model.backToUploadRequest(),
        ),
        title: Text(arguments.uploadRequest.recipients.first.mail, style: TextStyle(fontSize: 24, color: Colors.white)),
        backgroundColor: AppColor.primaryColor,
      ),
      body: SafeArea(child: _buildDetailsView()),
    );
  }

  Widget _buildLoadingView() {
    return StoreConnector<AppState, dartz.Either<Failure, Success>>(
      converter: (store) => store.state.uploadRequestRecipientDetailsState.viewState,
      builder: (context, viewState) {
        return viewState.fold(
          (failure) => SizedBox.shrink(),
          (success) => (success is LoadingState)
            ? Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),),
                  )))
            : SizedBox.shrink());
      },
    );
  }

  Widget _buildDetailsView() {
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state) {
        if (state.uploadRequestRecipientDetailsState.uploadRequest == null) {
          return _buildLoadingView();
        }
        return SingleChildScrollView(child: Column(children: [
          _numberOfUploadedFilesWidget(state.uploadRequestRecipientDetailsState),
          _messagesUploadRequestGroupWidget(state.uploadRequestRecipientDetailsState),
          _ownerUploadRequestGroupWidget(state),
          _metaDataUploadRequestGroupWidget(state.uploadRequestRecipientDetailsState),
        ]));
      },
    );
  }

  Widget _numberOfUploadedFilesWidget(UploadRequestRecipientDetailsState state) {
    return Container(
      color: AppColor.uploadRequestGroupDetailHeaderColor,
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(children: [
        Container(
          width: 70,
          height: 70,
          alignment: Alignment.center,
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(35))),
          child: Text(
              _getNumberFileUploaded(state.uploadRequest),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppColor.uploadRequestGroupDetailHeaderColor, fontWeight: FontWeight.bold, fontSize: 18.0)),
        ),
        Expanded(child: Padding(
            padding: EdgeInsets.only(right: 30, left: 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                  AppLocalizations.of(context).files_uploaded,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 18.0)),
            ))
        )
      ]),
    );
  }

  String _getNumberFileUploaded(UploadRequest? uploadRequest) {
    if (uploadRequest != null && uploadRequest.nbrUploadedFiles > 999) {
      return '999+';
    }
    return '${uploadRequest?.nbrUploadedFiles ?? 0}';
  }

  Widget _ownerUploadRequestGroupWidget(AppState state) {
    return ListTile(
        leading: LabelAvatarBuilder(state.uploadRequestRecipientDetailsState.uploadRequest?.owner.fullName().characters.first.toUpperCase()
            ?? state.uploadRequestRecipientDetailsState.uploadRequest?.owner.mail.characters.first.toUpperCase()
                ?? '')
            .key(Key('label_upload_request_recipient_owner_avatar'))
            .build(),
        title: Text(
            state.uploadRequestRecipientDetailsState.uploadRequest?.owner.fullName() ?? state.uploadRequestRecipientDetailsState.uploadRequest?.owner.mail ?? '',
            style: TextStyle(color: AppColor.uploadRequestGroupOwnerNameColor, fontWeight: FontWeight.w500, fontSize: 16.0)),
        subtitle:Text(
            AppLocalizations.of(context).upload_request_group_modification_date(state.uploadRequestRecipientDetailsState.uploadRequest?.modificationDate.getMMMddyyyyFormatString() ?? ''),
            style: TextStyle(color: AppColor.uploadFileFileNameTextColor, fontSize: 14.0)),
        trailing: state.uploadRequestRecipientDetailsState.uploadRequest?.owner.userId?.uuid == state.account.user?.userId.uuid
            ? Text(
                AppLocalizations.of(context).owner,
                style: TextStyle(fontSize: 14, color: AppColor.uploadFileFileNameTextColor))
            : null);
  }

  Widget _messagesUploadRequestGroupWidget(UploadRequestRecipientDetailsState state) {
    if (state.uploadRequest?.body?.isNotEmpty == true) {
      return Column(
        children: [
          StreamBuilder(
              stream: _model.isDisplayFullMessages,
              initialData: false,
              builder: (context, AsyncSnapshot<bool> snapshot) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      child: Text(state.uploadRequest?.body ?? '',
                          maxLines: snapshot.data == true ? null : 1,
                          overflow: snapshot.data == true ? null : TextOverflow.ellipsis,
                          style: TextStyle(
                              color: AppColor.uploadFileFileNameTextColor,
                              fontWeight: FontWeight.normal,
                              fontStyle: FontStyle.italic,
                              fontSize: 14.0)),
                    )),
                    IconButton(
                        onPressed: () => _model.toggleDisplayMessages(),
                        icon: SvgPicture.asset(
                            snapshot.data == true ? imagePath.icUploadRequestCancel : imagePath.icEye,
                            color: AppColor.uploadFileFileNameTextColor,
                            width: 20,
                            height: 20,
                            fit: BoxFit.fill))
                  ],
                );
              }),
          Divider()
        ],
      );
    }
    return SizedBox.shrink();
  }

  Widget _metaDataUploadRequestGroupWidget(UploadRequestRecipientDetailsState state) {
    if (state.uploadRequest != null) {
      return Padding(
          padding: EdgeInsets.only(left: 18, right: 18, top: 20, bottom: 30),
          child: Column(children: [
            Row(children: [
              SvgPicture.asset(imagePath.icFileTypeDoc,
                  color: AppColor.uploadRequestGroupOwnerNameColor,
                  width: 20,
                  height: 20,
                  fit: BoxFit.fill),
              Expanded(
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(AppLocalizations.of(context).meta_data,
                          style: TextStyle(
                              color: AppColor.uploadRequestGroupOwnerNameColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 16.0)))),
            ]),
            Padding(
              padding: EdgeInsets.only(left: 16),
              child: _buildListMetaData(state.uploadRequest!)),
          ]));
    }
    return SizedBox.shrink();
  }

  Widget _buildListMetaData(UploadRequest uploadRequest) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildItemMetaData(AppLocalizations.of(context).created_at,
                uploadRequest.creationDate.getMMMddyyyyFormatString()),
            _buildItemMetaData(AppLocalizations.of(context).expiration_date,
                uploadRequest.expiryDate.getMMMddyyyyFormatString()),
            _buildItemMetaData(AppLocalizations.of(context).max_number_of_files,
                '${uploadRequest.maxFileCount}'),
            _buildItemMetaData(AppLocalizations.of(context).max_size_per_file,
                '${uploadRequest.maxFileSize.toFileSize().value1} ${uploadRequest.maxFileSize.toFileSize().value2.text}'),
            _buildItemMetaData(
                AppLocalizations.of(context).allow_deletion,
                uploadRequest.canDeleteDocument == true
                    ? AppLocalizations.of(context).yes
                    : AppLocalizations.of(context).no),
            _buildItemMetaData(AppLocalizations.of(context).reminder_date,
                uploadRequest.notificationDate.getMMMddyyyyFormatString()),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildItemMetaData(AppLocalizations.of(context).activated_at,
                uploadRequest.activationDate.getMMMddyyyyFormatString()),
            _buildItemMetaData(
                AppLocalizations.of(context).collective,
                uploadRequest.collective
                    ? AppLocalizations.of(context).yes
                    : AppLocalizations.of(context).no),
            _buildItemMetaData(AppLocalizations.of(context).max_total_file_size,
                '${uploadRequest.maxDepositSize.toFileSize().value1} ${uploadRequest.maxDepositSize.toFileSize().value2.text}'),
            _buildItemMetaData(
                AppLocalizations.of(context).password_protected,
                uploadRequest.protectedByPassword
                    ? AppLocalizations.of(context).yes
                    : AppLocalizations.of(context).no),
            _buildItemMetaData(
                AppLocalizations.of(context).allow_closure,
                uploadRequest.canClose == true
                    ? AppLocalizations.of(context).yes
                    : AppLocalizations.of(context).no),
            _buildItemMetaData(
                AppLocalizations.of(context).notification_language,
                uploadRequest.locale.toNotificationLanguage().text.capitalizeFirst()),
          ]),
        ]);
  }

  Widget _buildItemMetaData(String name, String value) {
    return Padding(
        padding: EdgeInsets.only(top: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name,
              style: TextStyle(
                  color: AppColor.uploadFileFileNameTextColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.0)),
          SizedBox(height: 5),
          Text(value,
              style: TextStyle(
                  color: AppColor.uploadRequestGroupOwnerNameColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.0)),
        ]));
  }
}