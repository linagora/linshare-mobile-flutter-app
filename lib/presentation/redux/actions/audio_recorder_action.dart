import 'package:dartz/dartz.dart';
import 'package:domain/domain.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/app_action.dart';

class AudioRecorderAction extends ActionOffline {
  final Either<Failure, Success> viewState;

  AudioRecorderAction(this.viewState);
}

class StartRecording extends ActionOffline {}

class PauseRecording extends ActionOffline {}

class ResumeRecording extends ActionOffline {}

class StopRecording extends ActionOffline {}
