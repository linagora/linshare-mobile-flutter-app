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

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/audio_recorder_state.dart';
import 'package:linshare_flutter_app/presentation/view/dialog/discard_confirmation_dialog.dart';
import 'package:linshare_flutter_app/presentation/widget/record_audio/record_audio_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/upload_file_arguments.dart';

class RecordAudioWidget extends StatefulWidget {
  @override
  RecordAudioWidgetState createState() => RecordAudioWidgetState();
}

class RecordAudioWidgetState extends State<RecordAudioWidget> {
  final recordAudioViewModel = getIt<RecordAudioViewModel>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      recordAudioViewModel.uploadFileArguments =
          ModalRoute.of(context)?.settings.arguments as UploadFileArguments;
    });
  }

  @override
  void dispose() {
    super.dispose();
    recordAudioViewModel.onDisposed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StoreConnector<AppState, AudioRecorderState>(
          converter: (store) => store.state.audioRecorderState,
          builder: (
            context,
            state,
          ) {
            return WillPopScope(
              onWillPop: () async {
                return state.viewState.fold((failure) {
                  return true;
                }, (success) async {
                  if (success is IdleState) {
                    return true;
                  } else if (success is AudioRecorderStarted) {
                    recordAudioViewModel.pauseAudioRecording();
                  }
                  final popAndDiscard = await DiscardConfirmationDialog()
                          .showExitConfirmationDialog(context) ??
                      false;
                  if (popAndDiscard) {
                    recordAudioViewModel.removeFileFromCache();
                  }
                  return popAndDiscard;
                });
              },
              child: Center(
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      const Spacer(),
                      elapsedTimeWidget(),
                      audioWaveformWidget(),
                      const Spacer(
                        flex: 2,
                      ),
                      audioControlButtons(),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  Widget elapsedTimeWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder<String>(
        stream: recordAudioViewModel.elapsedTimeStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Text(
              snapshot.data!,
              style: const TextStyle(fontSize: 45),
            );
          } else {
            return Text(
              '00:00.00',
              style: const TextStyle(fontSize: 45),
            );
          }
        },
      ),
    );
  }

  Widget audioWaveformWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AudioWaveforms(
        size: const Size(500, 150.0),
        recorderController:
            recordAudioViewModel.audioRecorder.recorderController,
        waveStyle: WaveStyle(
          middleLineColor: Colors.grey.shade200,
          waveColor: Colors.grey.shade300,
          extendWaveform: true,
        ),
      ),
    );
  }

  Widget audioControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        recordAudioCancelButton(),
        recordAudioStartPauseButton(),
        saveAudioButton(),
      ],
    );
  }

  Widget recordAudioCancelButton() {
    return FloatingActionButton(
      heroTag: 'record_audio_cancel_button',
      onPressed: recordAudioViewModel.cancelAudioRecording,
      backgroundColor: Colors.grey.shade300,
      child: Icon(
        Icons.delete_outline,
        color: Colors.grey.shade400,
      ),
    );
  }

  Widget recordAudioStartPauseButton() {
    return FloatingActionButton(
        heroTag: 'record_audio_start_pause_button',
        onPressed: recordAudioViewModel.pauseAndStartAudioRecording,
        backgroundColor: Colors.red,
        child: StoreConnector<AppState, AudioRecorderState>(
            converter: (store) => store.state.audioRecorderState,
            builder: (context, state) {
              return state.viewState.fold((failure) {
                if (failure is AudioPermissionDenied &&
                    failure.isPermanentlyDenied) {
                  recordAudioViewModel.showAppSettingsDialog(context);
                }
                return Icon(Icons.play_arrow);
              }, (success) {
                if (success is AudioRecorderStarted) {
                  return Icon(Icons.pause);
                }
                return Icon(Icons.play_arrow);
              });
            }));
  }

  Widget saveAudioButton() {
    return FloatingActionButton(
      heroTag: 'record_audio_save_button',
      onPressed: recordAudioViewModel.saveAudioRecording,
      backgroundColor: Colors.grey.shade300,
      child: Icon(
        Icons.check,
        color: Colors.grey.shade600,
      ),
    );
  }
}
