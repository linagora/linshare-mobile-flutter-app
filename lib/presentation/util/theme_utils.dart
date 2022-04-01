import 'package:flutter/material.dart';

import 'constants_ui.dart';
import 'extensions/color_extension.dart';

ThemeData appTheme() {
  return ThemeData(
    scaffoldBackgroundColor: Colors.white,
    fontFamily: ConstantsUI.fontApp,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    primarySwatch: Colors.blue,
    unselectedWidgetColor: AppColor.unselectedElementColor
  );
}
