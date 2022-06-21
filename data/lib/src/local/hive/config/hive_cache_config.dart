import 'dart:io';

import 'package:data/src/local/hive/type_adapter/app_mode_type_adapter.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class HiveCacheConfig {

  Future setUp({String? cachePath}) async {
    await initializeDatabase(databasePath: cachePath);
    registerAdapter();
  }

  Future initializeDatabase({String? databasePath}) async {
    if (databasePath != null) {
      Hive.init(databasePath);
    } else {
      if (!kIsWeb) {
        Directory directory = await path_provider.getApplicationDocumentsDirectory();
        Hive.init(directory.path);
      }
    }
  }

  void registerAdapter() {
    Hive.registerAdapter(AppModeTypeAdapter());
  }

  Future closeHive() async {
    await Hive.close();
  }
}