import 'package:flutter/material.dart';
import 'package:linshare_flutter_app/presentation/view/dialog/discard_confirmation_dialog.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

class CustomCameraPickerViewer extends CameraPickerViewerState {
  @override
  Widget buildConfirmButton(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var popAndDiscard = await DiscardConfirmationDialog()
                .showExitConfirmationDialog(context) ??
            false;
        if (popAndDiscard) {
          await previewFile.delete();
        }
        return popAndDiscard;
      },
      child: super.buildConfirmButton(context),
    );
  }
}
