import 'package:domain/domain.dart';

class MediaPickerSuccessViewState extends Success {
  final List<FileInfo> file;
  MediaPickerSuccessViewState(this.file);

  @override
  List<Object> get props => [file];
}

class MediaPickerCanceled extends FeatureFailure {
  @override
  List<Object> get props => [];
}

class MediaPickerFailed extends FeatureFailure {
  Object exception;
  MediaPickerFailed(this.exception);
  @override
  List<Object> get props => [exception];
}

class CameraPermissionDenied extends FeatureFailure {
  @override
  List<Object> get props => [];
}
