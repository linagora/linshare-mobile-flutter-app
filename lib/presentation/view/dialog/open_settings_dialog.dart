import 'package:flutter/material.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:permission_handler/permission_handler.dart';

class OpenSettingsDialog extends StatelessWidget {
  VoidCallback? settingsButtonCallback;
  VoidCallback? cancelButtonCallback;
  final AppNavigation _appNavigation;
  OpenSettingsDialog(this._appNavigation,
      {this.settingsButtonCallback, this.cancelButtonCallback});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        AppLocalizations.of(context).permission_required,
        textAlign: TextAlign.center,
      ),
      content: Text(AppLocalizations.of(context).give_access_in_settings),
      actions: <Widget>[
        TextButton(
          onPressed: cancelButtonCallback ?? () => _appNavigation.popBack(),
          child: Text(AppLocalizations.of(context).cancel),
        ),
        TextButton(
          onPressed: settingsButtonCallback ??
              () {
                openAppSettings();
                Navigator.of(context).pop();
              },
          child: Text(AppLocalizations.of(context).settings),
        ),
      ],
    );
  }
}
