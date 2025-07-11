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
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/localizations/localized_camera_picker_text_delegate.dart';
import 'package:linshare_flutter_app/presentation/util/permission_service.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/view/camera_picker/custom_camera_picker_viewer.dart';
import 'package:linshare_flutter_app/presentation/view/dialog/open_settings_dialog.dart';
import 'package:linshare_flutter_app/presentation/view/dialog/permission_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state/phone_state.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

class MediaPickerFromCamera {
  var _phoneStateSubscription;
  FileInfo? fileInfo;

  void _listenToPhoneState(
    Function onCallReceived,
    CameraPickerState cameraPickerState,
    BuildContext context,
  ) {
    _phoneStateSubscription = PhoneState.phoneStateStream.listen(
      (status) {
        if (status == PhoneStateStatus.CALL_INCOMING) {
          onCallReceived.call(cameraPickerState, context);
        }
      },
    );
  }

  Future<Either<Failure, MediaPickerSuccessViewState>> pickMediaFromCamera(
    BuildContext context,
    AppNavigation appNavigation,
  ) async {
    // Get the AppLocalizations instance before opening the camera picker
    final localizations = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    try {
      if (!await PermissionService.arePermissionsGranted(
          [Permission.camera, Permission.microphone])) {
        final confirmExplanation =
            await PermissionDialog.showPermissionExplanationDialog(
                    context,
                    Center(
                      child:
                          Icon(Icons.warning, color: Colors.orange, size: 40),
                    ),
                    AppLocalizations.of(context).explain_camera_permission) ??
                false;
        if (!confirmExplanation) {
          return Left(
            CameraPermissionDenied(),
          );
        }
      }
      final cameraPermission =
          await PermissionService.tryToGetPermissionForCamera();

      final microphonePermission =
          await PermissionService.tryToGetPermissionForAudioRecording();
      final phonePermission =
          await PermissionService.tryToGetPermissionForPhoneState();

      if (cameraPermission.isGranted && microphonePermission.isGranted) {
        List<FileInfo> pickedFiles = [];
        CameraPickerState cameraPickerState = CameraPickerState();
        fileInfo = null;
        if (phonePermission.isGranted) {
          _listenToPhoneState(handleIncomingPhoneCallWhileRecordingCallback,
              cameraPickerState, context);
        }
        await CameraPicker.pickFromCamera(
          createPickerState: () => cameraPickerState,
          context,
          pickerConfig: CameraPickerConfig(
            maximumRecordingDuration: null,
            onError: (
              exception,
              stacktrace,
            ) {
              throw exception;
            },
            onXFileCaptured: (
              xFile,
              view,
            ) {
              var entity = CameraPickerViewer.pushToViewer(
                context,
                pickerConfig: CameraPickerConfig(
                  shouldDeletePreviewFile: true,
                  onEntitySaving: ((context, viewType, file) {
                    fileInfo = FileInfo(
                      file.path.split('/').last,
                      '${file.parent.path}/',
                      file.lengthSync(),
                    );
                    Navigator.of(context)
                      ..pop()
                      ..pop();
                  }),
                  textDelegate: LocalizedCameraPickerTextDelegate(
                    locale.languageCode,
                  ),
                ),
                viewType: view,
                previewXFile: xFile,
                createViewerState: () => CustomCameraPickerViewer(),
              );
              entity.then((value) {
                if (value == null) {
                  resumeCameraPreview(cameraPickerState);
                }
              });

              return true;
            },
            shouldDeletePreviewFile: true,
            textDelegate: LocalizedCameraPickerTextDelegate(
              locale.languageCode,
            ),
            theme: Theme.of(context),
            enableRecording: true,
          ),
        );

        if (fileInfo != null) {
          pickedFiles.add(fileInfo!);
          return Right(
            MediaPickerSuccessViewState(pickedFiles),
          );
        } else {
          return Left(
            MediaPickerCanceled(),
          );
        }
      } else if (cameraPermission.isPermanentlyDenied ||
          microphonePermission.isPermanentlyDenied) {
        await showDialog(
          context: context,
          builder: (context) => OpenSettingsDialog(appNavigation),
        );
        return Left(
          CameraPermissionDenied(),
        );
      } else {
        return Left(
          CameraPermissionDenied(),
        );
      }
    } catch (exception) {
      return Left(
        MediaPickerFailed(exception),
      );
    }
  }

  Future<void> handleIncomingPhoneCallWhileRecordingCallback(
    CameraPickerState cameraPickerState,
    BuildContext context,
  ) async {
    // Get the AppLocalizations instance before opening the camera picker
    final localizations = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    
    if (cameraPickerState.controller.value.isRecordingVideo) {
      final xFile = await cameraPickerState.controller.stopVideoRecording();
      await CameraPickerViewer.pushToViewer(
        context,
        pickerConfig: CameraPickerConfig(
          shouldDeletePreviewFile: true,
          onEntitySaving: ((context, viewType, file) {
            fileInfo = FileInfo(
              file.path.split('/').last,
              '${file.parent.path}/',
              file.lengthSync(),
            );
            Navigator.of(context)
              ..pop()
              ..pop();
          }),
          textDelegate: LocalizedCameraPickerTextDelegate(
            locale.languageCode,
          ),
        ),
        viewType: CameraPickerViewType.video,
        previewXFile: xFile,
        createViewerState: () => CustomCameraPickerViewer(),
      );
    }
  }

  void resumeCameraPreview(CameraPickerState cameraPickerState) async {
    await cameraPickerState.controller.resumePreview();
  }

  CameraPickerTextDelegate getTextDelegateForLocale(
    BuildContext context,
  ) {
    final locale = Localizations.localeOf(context);
    final localizations = AppLocalizations.of(context);
    // Always use LocalizedCameraPickerTextDelegate for all languages
    return LocalizedCameraPickerTextDelegate(
      locale.languageCode,
    );
  }
}
