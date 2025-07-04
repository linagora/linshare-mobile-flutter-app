import 'package:wechat_camera_picker/wechat_camera_picker.dart';

class LocalizedCameraPickerTextDelegate extends CameraPickerTextDelegate {
  final String language;

  const LocalizedCameraPickerTextDelegate(this.language);

  @override
  String get languageCode => language;

  @override
  String get confirm {
    switch (language) {
      case 'ru':
        return 'Подтвердить';
      case 'vi':
        return 'Xác nhận';
      case 'fr':
        return 'Confirmer';
      default:
        return 'Confirm';
    }
  }

  @override
  String get shootingTips {
    switch (language) {
      case 'ru':
        return 'Нажмите, чтобы сделать фото.';
      case 'vi':
        return 'Nhấn để chụp ảnh.';
      case 'fr':
        return 'Appuyez pour prendre une photo.';
      default:
        return 'Tap to take photo.';
    }
  }

  @override
  String get shootingWithRecordingTips {
    switch (language) {
      case 'ru':
        return 'Нажмите, чтобы сделать фото. Удерживайте для записи видео.';
      case 'vi':
        return 'Nhấn để chụp ảnh. Nhấn và giữ để quay hình.';
      case 'fr':
        return 'Appuyez pour prendre une photo. Appuyez longuement pour enregistrer une vidéo.';
      default:
        return 'Tap to take photo. Long press to record video.';
    }
  }

  @override
  String get shootingOnlyRecordingTips {
    switch (language) {
      case 'ru':
        return 'Удерживайте для записи видео.';
      case 'vi':
        return 'Nhấn và giữ để ghi hình.';
      case 'fr':
        return 'Appuyez longuement pour enregistrer une vidéo.';
      default:
        return 'Long press to record video.';
    }
  }

  @override
  String get shootingTapRecordingTips {
    switch (language) {
      case 'ru':
        return 'Нажмите, чтобы записать видео.';
      case 'vi':
        return 'Nhấn và giữ để quay hình.';
      case 'fr':
        return 'Appuyez pour enregistrer une vidéo.';
      default:
        return 'Tap to record video.';
    }
  }

  @override
  String get loadFailed {
    switch (language) {
      case 'ru':
        return 'Не удалось загрузить';
      case 'vi':
        return 'Tải thất bại';
      case 'fr':
        return 'Échec du chargement';
      default:
        return 'Load failed';
    }
  }

  @override
  String get loading {
    switch (language) {
      case 'ru':
        return 'Загрузка';
      case 'vi':
        return 'Đang xử lý';
      case 'fr':
        return 'Chargement';
      default:
        return 'Loading...';
    }
  }

  @override
  String get saving {
    switch (language) {
      case 'ru':
        return 'Сохранение...';
      case 'vi':
        return 'Đang lưu...';
      case 'fr':
        return 'Enregistrement...';
      default:
        return 'Saving...';
    }
  }

  @override
  String get sActionManuallyFocusHint {
    switch (language) {
      case 'ru':
        return 'ручная фокусировка';
      case 'vi':
        return 'Lấy nét thủ công';
      case 'fr':
        return 'mettre au point manuellement';
      default:
        return 'Manually focus';
    }
  }

  @override
  String get sActionPreviewHint {
    switch (language) {
      case 'ru':
        return 'предпросмотр';
      case 'vi':
        return 'Xem trước';
      case 'fr':
        return 'aperçu';
      default:
        return 'Preview';
    }
  }

  @override
  String get sActionRecordHint {
    switch (language) {
      case 'ru':
        return 'запись';
      case 'vi':
        return 'Ghi hình';
      case 'fr':
        return 'enregistrer';
      default:
        return 'Record';
    }
  }

  @override
  String get sActionShootHint {
    switch (language) {
      case 'ru':
        return 'сделать фото';
      case 'vi':
        return 'Chụp ảnh';
      case 'fr':
        return 'prendre une photo';
      default:
        return 'Take picture';
    }
  }

  @override
  String get sActionShootingButtonTooltip {
    switch (language) {
      case 'ru':
        return 'кнопка съемки';
      case 'vi':
        return 'Nút chụp';
      case 'fr':
        return 'bouton de prise de vue';
      default:
        return 'Shooting button';
    }
  }

  @override
  String get sActionStopRecordingHint {
    switch (language) {
      case 'ru':
        return 'остановить запись';
      case 'vi':
        return 'Dừng quay';
      case 'fr':
        return 'arrêter l\'enregistrement';
      default:
        return 'Stop recording';
    }
  }

  @override
  String sCameraLensDirectionLabel(CameraLensDirection value) {
    switch (language) {
      case 'ru':
        return 'Направление объектива камеры: ${value.name}';
      case 'vi':
        return 'Hướng ống kính camera: ${value.name}';
      case 'fr':
        return 'Direction de la lentille de la caméra : ${value.name}';
      default:
        return 'Camera lens direction: ${value.name}';
    }
  }

  @override
  String? sCameraPreviewLabel(CameraLensDirection? value) {
    if (value == null) {
      return null;
    }
    switch (language) {
      case 'ru':
        return 'Предпросмотр камеры: ${value.name}';
      case 'vi':
        return 'Xem trước máy ảnh:${value.name}';
      case 'fr':
        return 'Aperçu de la caméra : ${value.name}';
      default:
        return 'Camera preview: ${value.name}';
    }
  }

  @override
  String sFlashModeLabel(FlashMode mode) {
    switch (language) {
      case 'ru':
        return 'Режим вспышки: ${mode.name}';
      case 'vi':
        return 'Chế độ flash: ${mode.name}';
      case 'fr':
        return 'Mode flash : ${mode.name}';
      default:
        return 'Flash mode: ${mode.name}';
    }
  }

  @override
  String sSwitchCameraLensDirectionLabel(CameraLensDirection value) {
    switch (language) {
      case 'ru':
        return 'Переключиться на камеру ${value.name}';
      case 'vi':
        return 'Chuyển sang máy ảnh ${value.name}';
      case 'fr':
        return 'Passer à la caméra : ${value.name}';
      default:
        return 'Switch to the ${value.name} camera';
    }
  }
}
