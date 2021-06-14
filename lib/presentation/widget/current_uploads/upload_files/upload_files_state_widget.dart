// LinShare is an open source filesharing software, part of the LinPKI software
// suite, developed by Linagora.
//
// Copyright (C) 2021 LINAGORA
//
// This program is free software: you can redistribute it and/or modify it under the
// terms of the GNU Affero General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later version,
// provided you comply with the Additional Terms applicable for LinShare software by
// Linagora pursuant to Section 7 of the GNU Affero General Public License,
// subsections (b), (c), and (e), pursuant to which you must notably (i) retain the
// display in the interface of the “LinShare™” trademark/logo, the "Libre & Free" mention,
// the words “You are using the Free and Open Source version of LinShare™, powered by
// Linagora © 2009–2021. Contribute to Linshare R&D by subscribing to an Enterprise
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

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/model/upload_and_share/upload_and_share_model.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/media_type_extension.dart';

class UploadFilesStateWidget extends StatelessWidget {

  final imagePath = getIt<AppImagePaths>();

  final List<UploadAndShareFileState?> files;

  UploadFilesStateWidget(this.files);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: files.length,
      itemBuilder: (context, index) => _buildItem(context, files[index]),
    );
  }

  Widget _buildItem(BuildContext context, UploadAndShareFileState? fileState) {
    return ListTile(
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            fileState?.file.fileName.getMediaType().getFileTypeImagePath(imagePath) ?? imagePath.icFileTypeFile,
            width: 20,
            height: 24,
            fit: BoxFit.fill,
          ),
        ],
      ),
      title: Transform(
        transform: Matrix4.translationValues(-16, 0.0, 0.0),
        child: Text(
          fileState?.file.fileName ?? '',
          maxLines: 1,
          style: TextStyle(fontSize: 14, color: AppColor.documentNameItemTextColor),
        ),
      ),
      subtitle: Transform(
        transform: Matrix4.translationValues(-16, 8.0, 0.0),
        child: _buildSubTitle(context, fileState),
      ),
      onTap: () {

      },
    );
  }

  Widget _buildSubTitle(BuildContext context, UploadAndShareFileState? fileState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (fileState?.uploadStatus == UploadFileStatus.uploading && (fileState?.uploadingProgress ?? 0) > 0)
          _buildLinearProgress(fileState?.uploadingProgress ?? 0),
        Text(
          _getStatusSubTitle(context, fileState?.uploadStatus, fileState?.uploadingProgress ?? 0),
          maxLines: 1,
          style: TextStyle(
            fontSize: 13,
            color: _getStatusSubTitleColor(fileState?.uploadStatus),
          ),
        )
      ],
    );
  }

  String _getStatusSubTitle(BuildContext context, UploadFileStatus? status, int progress) {
    switch (status) {
      case UploadFileStatus.waiting:
        return AppLocalizations.of(context).current_uploads_waiting_status;
      case UploadFileStatus.uploading:
        if (progress == 0) return AppLocalizations.of(context).current_uploads_waiting_status;
        return AppLocalizations.of(context).current_uploads_uploading_status;
      case UploadFileStatus.uploadFailed:
        return AppLocalizations.of(context).current_uploads_upload_failed_status;
      case UploadFileStatus.shareFailed:
        return AppLocalizations.of(context).current_uploads_share_failed_status;
      case UploadFileStatus.succeed:
        return AppLocalizations.of(context).current_uploads_succeed_status;
      case null:
        return '';
    }
  }

  Color _getStatusSubTitleColor(UploadFileStatus? status) {
    switch (status) {
      case UploadFileStatus.waiting:
      case UploadFileStatus.uploading:
        return AppColor.statusUploadInProgressSubTitleColor;
      case UploadFileStatus.uploadFailed:
      case UploadFileStatus.shareFailed:
        return AppColor.statusUploadFailedSubTitleColor;
      case UploadFileStatus.succeed:
        return AppColor.statusUploadCompletedSubTitleColor;
      case null:
        return AppColor.statusUploadInProgressSubTitleColor;
    }
  }

  Widget _buildLinearProgress(int progress) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: SizedBox(
        height: 4,
        child: LinearProgressIndicator(
          backgroundColor: AppColor.uploadProgressBackgroundColor,
          valueColor: AlwaysStoppedAnimation<Color>(AppColor.uploadProgressValueColor),
          value: progress.toDouble() / 100,
        ),
      ),
    );
  }
}
