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

import 'package:dartz/dartz.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

class MediaPickerFromCamera {
  Future<PermissionStatus> requestCameraPermission() async {
    var currentStatus = await Permission.camera.status;
    if (currentStatus.isDenied) {
      currentStatus = await Permission.camera.request();
    } else if (currentStatus.isPermanentlyDenied) {
      await openAppSettings();
    }
    return currentStatus;
  }

  Future<Either<Failure, MediaPickerSuccessViewState>> pickMediaFromCamera(
      BuildContext context) async {
    try {
      var fileinfo;
      List<FileInfo> pickedFiles = [];
      var status = await requestCameraPermission();

      if (status.isGranted || status.isLimited) {
        await CameraPicker.pickFromCamera(
          context,
          pickerConfig: CameraPickerConfig(
              onError: (exception, stacktrace) {
                throw exception;
              },
              onEntitySaving: ((context, viewType, file) {
                fileinfo = FileInfo(file.path.split('/').last,
                    '${file.parent.path}/', file.lengthSync());
                Navigator.pop(context);
                Navigator.pop(context);
              }),
              textDelegate: cameraPickerTextDelegateFromLocale(
                  Localizations.localeOf(context)),
              theme: Theme.of(context),
              enableRecording: true),
        );
        if (fileinfo != null) {
          pickedFiles.add(fileinfo);
          return Right(MediaPickerSuccessViewState(pickedFiles));
        } else {
          return Left(MediaPickerCanceled());
        }
      } else {
        throw (CameraPermissionDenied());
      }
    } catch (exception) {
      return Left(MediaPickerFailed(exception));
    }
  }
}
