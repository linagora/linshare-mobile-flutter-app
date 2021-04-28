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
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/shared_space_node_details_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_node_details/shared_space_node_details_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_node_details/shared_space_node_details_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/datetime_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/media_type_extension.dart';

class SharedSpaceNodeDetailsWidget extends StatefulWidget {
  SharedSpaceNodeDetailsWidget({Key key}) : super(key: key);

  @override
  _SharedSpaceNodeDetailsWidgetState createState() => _SharedSpaceNodeDetailsWidgetState();
}

class _SharedSpaceNodeDetailsWidgetState extends State<SharedSpaceNodeDetailsWidget> {
  final _model = getIt<SharedSpaceNodeDetailsViewModel>();
  final imagePath = getIt<AppImagePaths>();

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      _model.initState(ModalRoute.of(context).settings.arguments);
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
    final SharedSpaceNodeDetailsArguments arguments = ModalRoute.of(context).settings.arguments;

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            key: Key('shared_space_node_details_arrow_back_button'),
            icon: Image.asset(imagePath.icArrowBack),
            onPressed: () => _model.backToMyWorkGroupNodesList(),
          ),
          centerTitle: true,
          title: Text(arguments.workGroupNode.name,
              key: Key('shared_space_node_details_title'),
              style: TextStyle(fontSize: 24, color: Colors.white)),
          backgroundColor: AppColor.primaryColor,
        ),
        body: StoreConnector<AppState, SharedSpaceNodeDetailsState>(
          converter: (store) => store.state.sharedSpaceNodeDetailsState,
          builder: (_, state) => _detailsTabWidget(state),
        ));
  }

  Widget _detailsTabWidget(SharedSpaceNodeDetailsState state) {
    if (state.workgroupNode == null) {
      return Container(
          color: AppColor.userTagBackgroundColor,
          child: Align(
            alignment: Alignment.center,
            child: Container(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                backgroundColor: AppColor.primaryColor,
              ),
            ),
          ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.workgroupNode is WorkGroupDocument)
          _workGroupDocumentDetailsTitleTileWidget(state.workgroupNode),
        if (state.workgroupNode is WorkGroupFolder)
          _workGroupFolderDetailsTitleTileWidget(state.workgroupNode),
        Divider(),
        Column(
          children: [
            _sharedSpaceNodeInformationTile(AppLocalizations.of(context).modified,
                state.workgroupNode.modificationDate.getMMMddyyyyFormatString()),
            _sharedSpaceNodeInformationTile(
                AppLocalizations.of(context).modified_by, state.workgroupNode.lastAuthor.name),
            _sharedSpaceNodeInformationTile(AppLocalizations.of(context).created,
                state.workgroupNode.creationDate.getMMMddyyyyFormatString()),
          ],
        ),
        Divider(),
        _descriptionWidget(state),
      ],
    );
  }

  Container _descriptionWidget(SharedSpaceNodeDetailsState state) {
    return Container(
        margin: EdgeInsets.only(left: 16, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).description,
                style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                    color: AppColor.workGroupDetailsName)),
            Padding(
                padding: EdgeInsets.only(top: 18),
                child: Text(
                    state.workgroupNode.description == null ||
                            state.workgroupNode.description.isEmpty
                        ? AppLocalizations.of(context).no_description
                        : state.workgroupNode.description,
                    style: TextStyle(
                        color: AppColor.searchResultsCountTextColor,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.normal,
                        fontSize: 16.0)))
          ],
        ));
  }

  ListTile _workGroupDocumentDetailsTitleTileWidget(WorkGroupDocument document) {
    return ListTile(
      leading: Padding(
          padding: EdgeInsets.only(left: 10),
          child: SvgPicture.asset(document.mediaType.getFileTypeImagePath(imagePath),
              width: 20, height: 24, fit: BoxFit.fill)),
      title: Text(document.name,
          style: TextStyle(
              color: AppColor.workGroupDetailsName, fontWeight: FontWeight.normal, fontSize: 14.0)),
      trailing: Text(
        filesize(document.size),
        style: TextStyle(
          fontSize: 14,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.normal,
          color: AppColor.uploadFileFileSizeTextColor,
        ),
      ),
    );
  }

  ListTile _workGroupFolderDetailsTitleTileWidget(WorkGroupFolder folder) {
    return ListTile(
      leading: Padding(
          padding: EdgeInsets.only(left: 10),
          child: SvgPicture.asset(imagePath.icFolder, width: 20, height: 24, fit: BoxFit.fill)),
      title: Text(folder.name,
          style: TextStyle(
              color: AppColor.workGroupDetailsName, fontWeight: FontWeight.normal, fontSize: 14.0)),
    );
  }

  ListTile _sharedSpaceNodeInformationTile(String category, String value) {
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
