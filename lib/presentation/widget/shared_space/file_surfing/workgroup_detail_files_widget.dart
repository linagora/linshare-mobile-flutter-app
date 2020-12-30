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
import 'package:flutter_svg/svg.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space/file_surfing/workgroup_nodes_surfing_navigator.dart';

class WorkGroupDetailFilesWidget extends StatefulWidget {
  final SharedSpaceNodeNested sharedSpaceNode;
  final OnBackClickedCallback onBackClickedCallback;

  WorkGroupDetailFilesWidget(this.sharedSpaceNode, this.onBackClickedCallback);

  @override
  _WorkGroupDetailFilesWidgetState createState() => _WorkGroupDetailFilesWidgetState();
}

class _WorkGroupDetailFilesWidgetState extends State<WorkGroupDetailFilesWidget> {
  final AppImagePaths imagePath = getIt<AppImagePaths>();
  final GlobalKey<WorkGroupNodesSurfingNavigatorState> _workgroupNavigatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WorkGroupNodesSurfingNavigator(
          _workgroupNavigatorKey,
          widget.sharedSpaceNode.sharedSpaceId,
          widget.onBackClickedCallback,
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: 76,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 56,
                    color: AppColor.workgroupDetailFilesBottomBarColor,
                    child: Row(
                      children: [],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: GestureDetector(
                    onTap: () {
                      print(_workgroupNavigatorKey.currentState.widget.currentPageData.folder.name);
                    },
                    child: _buildUploadWidget(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadWidget() {
    final readerRole = widget.sharedSpaceNode.sharedSpaceRole.name == SharedSpaceRoleName.READER;
    final buttonColor = readerRole
        ? AppColor.workgroupDetailFilesUploadDisableColor
        : AppColor.workgroupDetailFilesUploadActiveColor;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(28.0)),
          color: buttonColor,
          boxShadow: [
            BoxShadow(
              color: buttonColor.withOpacity(0.3),
              blurRadius: 20.0,
              offset: Offset(0, 10),
            )
          ]
      ),
      child: Center(
        child: SvgPicture.asset(
          imagePath.icPlus,
          width: 24,
          height: 24,
        ),
      ),
    );
  }
}
