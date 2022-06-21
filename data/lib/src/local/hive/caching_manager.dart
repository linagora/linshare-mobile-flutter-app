
import 'package:data/src/local/hive/app_mode_cache_client.dart';
import 'package:flutter/foundation.dart';

class CachingManager {

  final AppModeCacheClient _appModeCacheClient;

  CachingManager(
    this._appModeCacheClient,
  );

  Future<void> clearAll() async {
    if (kIsWeb) {
      await Future.wait([
        _appModeCacheClient.clearAllData(),
      ]);
    } else {
      await Future.wait([
        _appModeCacheClient.deleteBox(),
      ]);
    }
  }
}