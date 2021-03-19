import 'package:data/data.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockDeviceManager extends Mock implements DeviceManager {}

class MockLinShareHttpClient extends Mock implements LinShareHttpClient {}

class MockRemoteExceptionThrower extends Mock implements RemoteExceptionThrower {}

class MockFlutterUploader extends Mock implements FlutterUploader {}

class MockDioClient extends Mock implements DioClient {}

class MockSharedPreferences extends Mock implements SharedPreferences {}
