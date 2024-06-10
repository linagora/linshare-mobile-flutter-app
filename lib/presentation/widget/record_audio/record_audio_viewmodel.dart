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
import 'package:linshare_flutter_app/presentation/redux/actions/audio_recorder_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_file_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/audio_recorder_state.dart';
import 'package:linshare_flutter_app/presentation/util/audio_recorder.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/util/router/route_paths.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/upload_file_arguments.dart';
import 'package:redux/redux.dart';

class RecordAudioViewModel extends BaseViewModel {
  final AppNavigation _appNavigation;
  final AudioRecorder audioRecorder;
  final stopwatch = Stopwatch();
  UploadFileArguments? uploadFileArguments;
  var duration;

  RecordAudioViewModel(
      Store<AppState> store, this._appNavigation, this.audioRecorder)
      : super(store);

  void startAudioRecording() {
    audioRecorder.startRecordingAudio().then((result) {
      result.fold((failure) {
        store.dispatch(StopRecording());
      }, (success) {
        store.dispatch(StartRecording());
        stopwatch.start();
      });
    });
  }

  void pauseAudioRecordingAction() {
    store.dispatch(PauseRecording());
    stopwatch.stop();
    audioRecorder.pauseRecording();
  }

  void saveAudioRecording() {
    stopwatch.stop();
    audioRecorder.stopRecordingAndSave().then((result) {
      result.fold((failure) {
        store.dispatch(StopRecording());
        store.dispatch(UploadFileAction(Left(failure)));
      }, (success) async {
        store.dispatch(StopRecording());
        _appNavigation.popBack();
        store.dispatch(UploadFileAction(Right(success)));
        var uploadArgs = UploadFileArguments(success.file);
        if (uploadFileArguments != null) {
          uploadArgs.shareType = uploadFileArguments!.shareType;
          uploadArgs.workGroupDocumentUploadInfo =
              uploadFileArguments!.workGroupDocumentUploadInfo;
        }
        await _appNavigation.push(RoutePaths.uploadDocumentRoute,
            arguments: uploadArgs);
      });
    });
  }

  void cancelAudioRecording() {
    store.dispatch(StopRecording());
    stopwatch.stop();
    stopwatch.reset();
    audioRecorder.stopRecording();
  }

  void resumeAudioRecording() {
    store.dispatch(ResumeRecording());
    stopwatch.start();
    audioRecorder.resumeRecording();
  }

  void pauseAndStartAudioRecording() {
    switch (store.state.audioRecorderState.status) {
      case RecordingStatus.recording:
        pauseAudioRecordingAction();
        break;
      case RecordingStatus.idle:
        startAudioRecording();
        break;
      default:
        resumeAudioRecording();
        break;
    }
  }

  String formatElapsedTime() {
    final minutes = stopwatch.elapsed.inMilliseconds ~/ 60000;
    final seconds = (stopwatch.elapsed.inMilliseconds ~/ 1000) % 60;
    final remainingMilliseconds =
        (stopwatch.elapsed.inMilliseconds % 1000) ~/ 10;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${remainingMilliseconds.toString().padLeft(2, '0')}';
  }

  Stream<String> get elapsedTimeStream {
    return Stream.periodic(const Duration(milliseconds: 50), (_) {
      return formatElapsedTime();
    }).distinct();
  }

  @override
  void onDisposed() {
    super.onDisposed();
    store.dispatch(StopRecording());
    audioRecorder.stopRecording();
    audioRecorder.recorderController.dispose();
  }
}
