import 'package:data/data.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:mockito/mockito.dart';

class MockDeviceManager extends Mock implements DeviceManager {}

class MockLinShareHttpClient extends Mock implements LinShareHttpClient {}

class MockRemoteExceptionThrower extends Mock implements RemoteExceptionThrower {}

class MockFlutterUploader extends Mock implements FlutterUploader {}

class MockDioClient extends Mock implements DioClient {}

class MockLinShareDownloadManager extends Mock implements LinShareDownloadManager {}

class MockLocalBiometricService extends Mock implements LocalBiometricService {}

class MockBiometricExceptionThrower extends Mock implements BiometricExceptionThrower {}