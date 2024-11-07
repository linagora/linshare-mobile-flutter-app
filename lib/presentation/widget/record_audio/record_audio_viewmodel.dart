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

import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/audio_recorder_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/audio_recorder.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/util/router/route_paths.dart';
import 'package:linshare_flutter_app/presentation/view/dialog/open_settings_dialog.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/upload_file_arguments.dart';
import 'package:phone_state/phone_state.dart';
import 'package:redux/redux.dart';

class RecordAudioViewModel extends BaseViewModel {
  final AppNavigation _appNavigation;
  final AudioRecorder audioRecorder;
  final Stopwatch stopwatch;
  UploadFileArguments? uploadFileArguments;
  var _phoneStateSubscription;
  var duration;

  RecordAudioViewModel(Store<AppState> store, this._appNavigation,
      this.audioRecorder, this.stopwatch)
      : super(store) {
    _listenToPhoneState();
  }

  void _listenToPhoneState() {
    _phoneStateSubscription = PhoneState.phoneStateStream.listen(
      (status) {
        if (status == PhoneStateStatus.CALL_INCOMING) {
          pauseAudioRecording();
        }
      },
    );
  }

  void startAudioRecording() {
    audioRecorder.startRecordingAudio().then((result) {
      result.fold((failure) {
        store.dispatch(
          StopRecording(),
        );
        store.dispatch(
          AudioRecorderAction(
            Left(
              failure,
            ),
          ),
        );
        if (failure is AudioPermissionDenied && !failure.isPermanentlyDenied) {
          _appNavigation.popBack();
        }
      }, (success) {
        store.dispatch(
          StartRecording(),
        );
        stopwatch.start();
      });
    });
  }

  void saveAudioRecording() {
    stopwatch.stop();
    audioRecorder.stopRecordingAndSave().then(
      (result) {
        result.fold(
          (failure) {
            store.dispatch(
              AudioRecorderAction(
                Left(failure),
              ),
            );
            store.dispatch(StopRecording());
            if (failure is AudioRecorderFailed) {
              _appNavigation.popBack();
            }
          },
          (success) async {
            cancelAudioRecording();
            store.dispatch(
              AudioRecorderAction(
                Right(success),
              ),
            );
            _appNavigation.popBack();
            var uploadArgs = UploadFileArguments(
              success.file,
            );
            if (uploadFileArguments != null) {
              uploadArgs.shareType = uploadFileArguments!.shareType;
              uploadArgs.workGroupDocumentUploadInfo =
                  uploadFileArguments!.workGroupDocumentUploadInfo;
            }
            await _appNavigation.push(
              RoutePaths.uploadDocumentRoute,
              arguments: uploadArgs,
            );
          },
        );
      },
    );
  }

  void cancelAudioRecording() {
    audioRecorder.stopRecording().fold(
      (
        failure,
      ) {
        store.dispatch(
          StopRecording(),
        );
        store.dispatch(
          AudioRecorderAction(
            Left(
              failure,
            ),
          ),
        );
        _appNavigation.popBack();
      },
      (success) {
        store.dispatch(
          StopRecording(),
        );
        stopwatch.stop();
        stopwatch.reset();
      },
    );
  }

  void resumeAudioRecording() {
    audioRecorder.resumeRecording().fold(
      (failure) {
        store.dispatch(StopRecording());
        store.dispatch(
          AudioRecorderAction(
            Left(failure),
          ),
        );
        _appNavigation.popBack();
      },
      (success) {
        store.dispatch(
          ResumeRecording(),
        );
        stopwatch.start();
      },
    );
  }

  void pauseAndStartAudioRecording() {
    store.state.audioRecorderState.viewState.fold(
      (failure) => null,
      (success) {
        if (success is IdleState) {
          startAudioRecording();
        } else if (success is AudioRecorderStarted) {
          pauseAudioRecording();
        } else if (success is AudioRecorderPaused) {
          resumeAudioRecording();
        }
      },
    );
  }

  void pauseAudioRecording() {
    audioRecorder.pauseRecording().fold(
      (failure) {
        store.dispatch(
          StopRecording(),
        );
        store.dispatch(
          AudioRecorderAction(
            Left(failure),
          ),
        );
        _appNavigation.popBack();
      },
      (success) {
        store.dispatch(
          PauseRecording(),
        );
        stopwatch.stop();
      },
    );
  }

  Stream<String> get elapsedTimeStream {
    return Stream.periodic(
      const Duration(milliseconds: 50),
      (_) {
        return audioRecorder.formatElapsedTime(stopwatch.elapsedMilliseconds);
      },
    ).distinct();
  }

  Future<void> showAppSettingsDialog(BuildContext context) async {
    store.dispatch(
      StopRecording(),
    );
    Future.delayed(
      Duration.zero,
      () {
        showDialog(
          context: context,
          builder: (context) => OpenSettingsDialog(
            _appNavigation,
          ),
        );
      },
    );
  }

  @override
  void onDisposed() {
    super.onDisposed();
    stopwatch.stop();
    stopwatch.reset();
    store.dispatch(
      StopRecording(),
    );
    audioRecorder.stopRecording();
    audioRecorder.recorderController.dispose();
  }
}
