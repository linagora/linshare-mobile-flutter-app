import 'package:flutter/material.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

class LocalizedCameraPickerTextDelegate extends CameraPickerTextDelegate {
  final BuildContext context;
  final String language;
  const LocalizedCameraPickerTextDelegate(this.context, this.language);

  @override
  String get languageCode => language;

  @override
  String get confirm => AppLocalizations.of(context).confirm;

  @override
  String get shootingTips => AppLocalizations.of(context).shootingTips;

  @override
  String get shootingWithRecordingTips =>
      AppLocalizations.of(context).shootingWithRecordingTips;

  @override
  String get shootingOnlyRecordingTips =>
      AppLocalizations.of(context).shootingOnlyRecordingTips;

  @override
  String get shootingTapRecordingTips =>
      AppLocalizations.of(context).shootingTapRecordingTips;

  @override
  String get loadFailed => AppLocalizations.of(context).loadFailed;

  @override
  String get loading => AppLocalizations.of(context).loading;

  @override
  String get saving => AppLocalizations.of(context).saving;

  @override
  String get sActionManuallyFocusHint =>
      AppLocalizations.of(context).sActionManuallyFocusHint;

  @override
  String get sActionPreviewHint =>
      AppLocalizations.of(context).sActionPreviewHint;

  @override
  String get sActionRecordHint =>
      AppLocalizations.of(context).sActionRecordHint;

  @override
  String get sActionShootHint => AppLocalizations.of(context).sActionShootHint;

  @override
  String get sActionShootingButtonTooltip =>
      AppLocalizations.of(context).sActionShootingButtonTooltip;

  @override
  String get sActionStopRecordingHint =>
      AppLocalizations.of(context).sActionStopRecordingHint;

  @override
  String sCameraLensDirectionLabel(CameraLensDirection value) =>
      AppLocalizations.of(context).sCameraLensDirectionLabel(value.name);

  @override
  String? sCameraPreviewLabel(CameraLensDirection? value) {
    if (value == null) {
      return null;
    }
    return AppLocalizations.of(context).sCameraPreviewLabel(value.name);
  }

  @override
  String sFlashModeLabel(FlashMode mode) =>
      AppLocalizations.of(context).sFlashModeLabel(mode.name);

  @override
  String sSwitchCameraLensDirectionLabel(CameraLensDirection value) =>
      AppLocalizations.of(context).sSwitchCameraLensDirectionLabel(value.name);
}
