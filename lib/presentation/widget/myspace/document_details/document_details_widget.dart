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
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/document_details_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/media_type_extension.dart';
import 'package:linshare_flutter_app/presentation/view/custom_list_tiles/document_recipient_list_tile_builder.dart';
import 'package:domain/src/model/generic_user.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/datetime_extension.dart';

import 'document_details_arguments.dart';
import 'document_details_viewmodel.dart';

class DocumentDetailsWidget extends StatefulWidget {
  @override
  _DocumentDetailsWidgetState createState() => _DocumentDetailsWidgetState();
}

class _DocumentDetailsWidgetState extends State<DocumentDetailsWidget> {
  final _model = getIt<DocumentDetailsViewModel>();
  final imagePath = getIt<AppImagePaths>();
  final _editDescriptionController = TextEditingController();

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      var arguments = ModalRoute.of(context)?.settings.arguments as DocumentDetailsArguments;
        _model.initState(arguments);
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
    final arguments = ModalRoute.of(context)?.settings.arguments as DocumentDetailsArguments;
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            key: Key('document_details_arrow_back_button'),
            icon: Image.asset(imagePath.icArrowBack),
            onPressed: () => _model.backToMySpace(),
          ),
          centerTitle: true,
          title: Text(arguments.document.name,
              key: Key('document_details_title'),
              style: TextStyle(fontSize: 24, color: Colors.white)),
          backgroundColor: AppColor.primaryColor,
        ),
        body: Column(
          children: [
            Expanded(
              child: StoreConnector<AppState, DocumentDetailsState>(
                converter: (store) => store.state.documentDetailsState,
                builder: (_, state) => _detailsTabWidget(state),
              ),
            )
          ],
        )
    );
  }

  Widget _detailsTabWidget(DocumentDetailsState state) {
    if (state.document == null) {
      return Container(
          color: AppColor.userTagBackgroundColor,
          child: Align(
            alignment: Alignment.center,
            child: Container(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                backgroundColor: AppColor.primaryColor,
              ),
            ),
          ));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _documentDetailsTitleTileWidget(state),
          Divider(),
          Column(
            children: [
              _documentInformationTile(AppLocalizations.of(context).modified,
                  state.document?.modificationDate.getMMMddyyyyFormatString() ?? ''),
              _documentInformationTile(AppLocalizations.of(context).created,
                  state.document?.creationDate.getMMMddyyyyFormatString() ?? ''),
              _documentInformationTile(AppLocalizations.of(context).expiration,
                  state.document?.expirationDate?.getMMMddyyyyFormatString() ?? AppLocalizations.of(context).no_results_found),
            ],
          ),
          Divider(),
          _descriptionWidget(state),
          _sharedWidget(state)
        ],
      ));
  }

  ListTile _documentDetailsTitleTileWidget(DocumentDetailsState state) {
    return ListTile(
      leading: Padding(
          padding: EdgeInsets.only(left: 10),
          child: SvgPicture.asset(state.document?.mediaType.getFileTypeImagePath(imagePath) ?? imagePath.icFileTypeFile,
              width: 20, height: 24, fit: BoxFit.fill)),
      title: Text(state.document?.name ?? '',
          style: TextStyle(
              color: AppColor.workGroupDetailsName, fontWeight: FontWeight.normal, fontSize: 14.0)),
      trailing: Text(
        filesize(state.document?.size),
        style: TextStyle(
          fontSize: 14,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.normal,
          color: AppColor.uploadFileFileSizeTextColor,
        ),
      ),
    );
  }

  Widget _sharedWidget(DocumentDetailsState state) {
    return Container(
        margin: EdgeInsets.only(top: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 16),
            height: 56,
            color: AppColor.topBarBackgroundColor,
            child: Text(AppLocalizations.of(context).shared_with(state.document?.shares.length ?? 0),
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    fontStyle: FontStyle.normal,
                    color: AppColor.documentDetailsSharedTitleColor)),
          ),
          ListView.builder(
              shrinkWrap: true,
              physics: ScrollPhysics(),
              itemCount: state.document?.shares.length,
              itemBuilder: (context, index) {
                var recipient = state.document?.shares[index].recipient;
                return DocumentRecipientListTileBuilder(recipient?.fullName() ?? '', recipient?.mail ?? '')
                    .build();
              })
        ]));
  }

  Container _descriptionWidget(DocumentDetailsState state) {
    if (_editDescriptionController.text.isEmpty) {
      _editDescriptionController.text = state.document?.description ?? '';
    }

    return Container(
        margin: EdgeInsets.only(left: 16, top: 10, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(AppLocalizations.of(context).description,
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                      color: AppColor.workGroupDetailsName)),
              IconButton(
                icon: state.isEditingDescription ? Icon(Icons.check) : Icon(Icons.edit),
                onPressed: () => {
                  if (state.isEditingDescription) {
                      _model.editDescription(context, state.document, _editDescriptionController.text)
                  } else {
                    _model.toggleDescriptionEditing()
                  }
                },
              )
            ]),
            Padding(
                padding: EdgeInsets.only(top: 18),
                child: state.isEditingDescription
                    ? TextField(
                        autofocus: true,
                        style: TextStyle(fontSize: 16),
                        scrollPadding: EdgeInsets.only(bottom: 65),
                        decoration: InputDecoration(
                            hintText: AppLocalizations.of(context).no_description,
                            hintStyle: TextStyle(fontStyle: FontStyle.italic)),
                        controller: _editDescriptionController,
                        onSubmitted: (value) => _model.editDescription(context, state.document, value))
                    : Padding(
                        padding: EdgeInsets.only(top: 14.5),
                        child: Text(
                            (state.document == null || state.document!.description.isEmpty)
                                ? AppLocalizations.of(context).no_description
                                : state.document!.description,
                            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)))),
          ],
        ));
  }

  ListTile _documentInformationTile(String category, String value) {
    return ListTile(
      dense: true,
      title: Text(category,
          style: TextStyle(
              color: AppColor.searchResultsCountTextColor,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w500,
              fontSize: 16.0)),
      trailing: Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColor.searchResultsCountTextColor,
        ),
      ),
    );
  }
}
