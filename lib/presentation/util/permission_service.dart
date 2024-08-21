import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<PermissionStatus> tryToGetPermissionForCamera() async {
    final status = await Permission.camera.request();
    return status;
  }

  Future<PermissionStatus> tryToGetPermissionForAudioRecording() async {
    final status = await Permission.microphone.request();
    return status;
  }

  Future<PermissionStatus> handleMediaPickerPermissionAndroidHigher33() async {
    PermissionStatus? photoPermission = await Permission.photos.status;
    if (photoPermission == PermissionStatus.denied) {
      photoPermission = await Permission.photos.request();
    }

    PermissionStatus? videosPermission = await Permission.videos.status;
    if (videosPermission == PermissionStatus.denied) {
      videosPermission = await Permission.videos.request();
    }
    if (photoPermission.isPermanentlyDenied ||
        videosPermission.isPermanentlyDenied) {
      return PermissionStatus.permanentlyDenied;
    }

    if (photoPermission == PermissionStatus.granted &&
        videosPermission == PermissionStatus.granted) {
      return PermissionStatus.granted;
    }

    return PermissionStatus.denied;
  }
}
