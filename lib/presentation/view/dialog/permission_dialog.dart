import 'package:flutter/material.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';

class PermissionDialog {
  static Future<bool?> showPermissionExplanationDialog(
      BuildContext context, Widget title, String content) async {
    return showDialog<bool>(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
              title: title,
              content: Text(content),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(AppLocalizations.of(context).not_now),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(AppLocalizations.of(context).allow),
                ),
              ],
            ));
  }
}
