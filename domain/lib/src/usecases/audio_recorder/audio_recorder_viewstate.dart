
import 'package:domain/domain.dart';

class AudioRecorderSuccessViewState extends Success {
  final List<FileInfo> file;
  AudioRecorderSuccessViewState(this.file);

  @override
  List<Object> get props => [file];
}

class AudioRecorderStarted extends Success {
  @override
  List<Object> get props => [];
}
class AudioRecorderPaused extends Success {
  @override
  List<Object> get props => [];
}


class AudioRecorderFailed extends FeatureFailure {
  @override
  List<Object> get props => [];
}

class NoAudioRecordingFound extends FeatureFailure {
  @override
  List<Object> get props => [];
}

class AudioPermissionDenied extends FeatureFailure {

  final bool isPermanentlyDenied;

  AudioPermissionDenied(this.isPermanentlyDenied);

  @override
  List<Object> get props => [isPermanentlyDenied];
}
