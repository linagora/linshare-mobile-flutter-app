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

import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:dartz/dartz.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/util/permission_service.dart';
import 'package:linshare_flutter_app/presentation/view/dialog/permission_dialog.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecorder {
  final RecorderController recorderController = RecorderController();
  String? recordingPath;

  Future<Either<Failure, Success>> startRecordingAudio(
      BuildContext context) async {
    try {
      if (!await PermissionService.arePermissionsGranted(
          [Permission.microphone, Permission.phone])) {
        final confirmExplanation =
            await PermissionDialog.showPermissionExplanationDialog(
                context,
                Center(
                  child: Icon(Icons.warning, color: Colors.orange, size: 40),
                ),
                AppLocalizations.of(context)
                    .explain_audio_recorder_permission) ??
            false;
        if (!confirmExplanation) {
          return Left(AudioPermissionDenied(false));
        }
      }
      final microphonePermission =
          await PermissionService.tryToGetPermissionForAudioRecording();
      await PermissionService.tryToGetPermissionForPhoneState();
      if (microphonePermission.isGranted) {
        final tempPath = Directory.systemTemp.path;
        final currentTime = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'audio_$currentTime.m4a';
        recordingPath = '$tempPath/$fileName';
        await recorderController.record(recordingPath);
        return Right(AudioRecorderStarted());
      } else {
        return Left(
            AudioPermissionDenied(microphonePermission.isPermanentlyDenied));
      }
    } catch (exception) {
      return Left(AudioRecorderFailed());
    }
  }

  Future<Either<Failure, AudioRecorderSuccessViewState>>
      stopRecordingAndSave() async {
    FileInfo file;
    List<FileInfo> pickedFiles = [];
    try {
      await recorderController.stop().then((value) {
        if (value != null) {
          var recordedFile = File(value);
          file = FileInfo(recordedFile.path.split('/').last,
              '${recordedFile.parent.path}/', recordedFile.lengthSync());
          pickedFiles.add(file);
        }
      });
      if (pickedFiles.isNotEmpty) {
        return Right(AudioRecorderSuccessViewState(pickedFiles));
      }
      return Left(NoAudioRecordingFound());
    } catch (exception) {
      return Left(AudioRecorderFailed());
    }
  }

  Either<Failure, Success> pauseRecording() {
    try {
      recorderController.pause();
      return Right(AudioRecorderPaused());
    } catch (exception) {
      return Left(AudioRecorderFailed());
    }
  }

  Either<Failure, Success> stopRecording() {
    try {
      recorderController.stop();
      return Right(AudioRecorderPaused());
    } catch (exception) {
      return Left(AudioRecorderFailed());
    }
  }

  Either<Failure, Success> resumeRecording() {
    try {
      recorderController.record();
      return Right(AudioRecorderStarted());
    } catch (exception) {
      return Left(AudioRecorderFailed());
    }
  }

  String formatElapsedTime(int elapsedMilliseconds) {
    final minutes = elapsedMilliseconds ~/ 60000;
    final seconds = (elapsedMilliseconds ~/ 1000) % 60;
    final remainingMilliseconds = (elapsedMilliseconds % 1000) ~/ 10;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${remainingMilliseconds.toString().padLeft(2, '0')}';
  }
}
