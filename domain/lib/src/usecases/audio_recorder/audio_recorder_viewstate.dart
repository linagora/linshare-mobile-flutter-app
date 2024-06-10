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

class AudioRecorderFailed extends FeatureFailure {
  @override
  List<Object> get props => [];
}

class AudioPermissionDenied extends FeatureFailure {
  @override
  List<Object> get props => [];
}
