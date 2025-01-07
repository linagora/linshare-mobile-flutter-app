import 'package:device_info/device_info.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> arePermissionsGranted(
      List<Permission> permissions) async {
    for (var permission in permissions) {
      if (!await permission.isGranted) {
        return false;
      }
    }
    return true;
  }

  static Future<PermissionStatus> tryToGetPermissionForCamera() async {
    final status = await Permission.camera.request();
    return status;
  }

  static Future<PermissionStatus> tryToGetPermissionForAudioRecording() async {
    final status = await Permission.microphone.request();
    return status;
  }

  static Future<PermissionStatus> tryToGetPermissionForPhoneState() async {
    final status = await Permission.phone.request();
    return status;
  }

  static Future<PermissionStatus>
      handleMediaPickerPermissionAndroidHigher33() async {
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

  static Future<PermissionStatus>
      tryToGetPermissionForStorageForAndroid32AndLower() async {
    final status = await Permission.storage.request();
    return status;
  }

  static Future<bool> isAndroid32AndLower() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final androidInfo = await deviceInfoPlugin.androidInfo;
    final apiLevel = androidInfo.version.sdkInt;
    return apiLevel <= 32;
  }

}
