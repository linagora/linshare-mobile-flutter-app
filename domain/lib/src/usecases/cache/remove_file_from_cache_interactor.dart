import 'dart:developer';
import 'dart:io';

class RemoveFileFromCacheInteractor {
  Future<void> execute(String file) async {
    try {
      await File(file).delete();
    } catch (exception) {
      log('RemoveFileFromCacheInteractor Failed');
    }
  }
}
