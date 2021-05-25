// LinShare is an open source filesharing software, part of the LinPKI software
// suite, developed by Linagora.
//
// Copyright (C) 2020 LINAGORA
//
// This program is free software: you can redistribute it and/or modify it under the
// terms of the GNU Affero General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later version,
// provided you comply with the Additional Terms applicable for LinShare software by
// Linagora pursuant to Section 7 of the GNU Affero General Public License,
// subsections (b), (c), and (e), pursuant to which you must notably (i) retain the
// display in the interface of the “LinShare™” trademark/logo, the "Libre & Free" mention,
// the words “You are using the Free and Open Source version of LinShare™, powered by
// Linagora © 2009–2020. Contribute to Linshare R&D by subscribing to an Enterprise
// offer!”. You must also retain the latter notice in all asynchronous messages such as
// e-mails sent with the Program, (ii) retain all hypertext links between LinShare and
// http://www.linshare.org, between linagora.com and Linagora, and (iii) refrain from
// infringing Linagora intellectual property rights over its trademarks and commercial
// brands. Other Additional Terms apply, see
// <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf>
// for more details.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for
// more details.
// You should have received a copy of the GNU Affero General Public License and its
// applicable Additional Terms for LinShare along with this program. If not, see
// <http://www.gnu.org/licenses/> for the GNU Affero General Public License version
//  3 and <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf> for
//  the Additional Terms applicable to LinShare software.

import 'package:flutter/widgets.dart';

class ResponsiveUtils {

  static const int _minLargeWidth = 950;
  static const int _minMediumWidth = 600;

  static const double _listItemHorizontalPaddingLargeWidth = 132.0;

  static const double _destinationPickerHorizontalMarginMediumScreen = 144.0;
  static const double _destinationPickerVerticalMarginMediumScreen = 234.0;
  static const double _destinationPickerHorizontalMarginLargeScreen = 234.0;
  static const double _destinationPickerVerticalMarginLargeScreen = 144.0;

  static const double _orderByButtonHorizontalPaddingLargeWidth = 155.0;
  static const double _orderByButtonHorizontalPaddingDefault = 16.0;

  static const double _contextMenuHorizontalMargin = 144.0;

  static const double _loginTextBuilderWidthSmallScreen = 280.0;
  static const double _loginTextBuilderWidthLargeScreen = 320.0;

  static const double _loginButtonWidth = 240.0;

  static const double _radiusDestinationPickerView = 20.0;

  double getSizeWidthScreen(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  double getSizeHeightScreen(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  bool isLargeScreen(BuildContext context) {
    return getSizeWidthScreen(context) >= _minLargeWidth;
  }

  bool isSmallScreen(BuildContext context) {
    return getSizeWidthScreen(context) < _minMediumWidth;
  }

  bool isMediumScreen(BuildContext context) {
    return getSizeWidthScreen(context) >= _minMediumWidth
      && getSizeWidthScreen(context) < _minLargeWidth;
  }

  EdgeInsets getPaddingListItemForScreen(BuildContext context) {
    return isLargeScreen(context) ? EdgeInsets.symmetric(horizontal: _listItemHorizontalPaddingLargeWidth) : EdgeInsets.zero;
  }

  EdgeInsets getPaddingOrderByButtonForScreen(BuildContext context) {
    return isLargeScreen(context)
      ? EdgeInsets.symmetric(horizontal: _orderByButtonHorizontalPaddingLargeWidth)
      : EdgeInsets.symmetric(horizontal: _orderByButtonHorizontalPaddingDefault);
  }

  EdgeInsets getMarginForDestinationPicker(BuildContext context) {
    if (isMediumScreen(context)) {
      return getSizeHeightScreen(context) <= _destinationPickerVerticalMarginMediumScreen * 2
        ? EdgeInsets.symmetric(
            horizontal: _destinationPickerHorizontalMarginMediumScreen,
            vertical: 0.0)
        : EdgeInsets.symmetric(
            horizontal: _destinationPickerHorizontalMarginMediumScreen,
            vertical: _destinationPickerVerticalMarginMediumScreen);
    } else if (isLargeScreen(context)) {
      return getSizeHeightScreen(context) <= _destinationPickerVerticalMarginLargeScreen * 2
        ? EdgeInsets.symmetric(
            horizontal: _destinationPickerHorizontalMarginLargeScreen,
            vertical: 0.0)
        : EdgeInsets.symmetric(
            horizontal: _destinationPickerHorizontalMarginLargeScreen,
            vertical: _destinationPickerVerticalMarginLargeScreen);
    } else {
      return EdgeInsets.zero;
    }
  }

  BorderRadius getBorderRadiusView(BuildContext context) {
    if (isMediumScreen(context)) {
      return getSizeHeightScreen(context) <= _destinationPickerVerticalMarginMediumScreen * 2
        ? BorderRadius.only(
            topLeft: Radius.circular(_radiusDestinationPickerView),
            topRight: Radius.circular(_radiusDestinationPickerView))
        : BorderRadius.circular(_radiusDestinationPickerView);
    } else if (isLargeScreen(context)) {
      return getSizeHeightScreen(context) <= _destinationPickerVerticalMarginLargeScreen * 2
        ? BorderRadius.only(
            topLeft: Radius.circular(_radiusDestinationPickerView),
            topRight: Radius.circular(_radiusDestinationPickerView))
        : BorderRadius.circular(_radiusDestinationPickerView);
    } else {
      return BorderRadius.zero;
    }
  }

  EdgeInsets getMarginContextMenuForScreen(BuildContext context) {
    return isSmallScreen(context)
        ? EdgeInsets.zero
        : EdgeInsets.symmetric(horizontal: _contextMenuHorizontalMargin);
  }

  double getWidthLoginTextBuilder(BuildContext context) => isSmallScreen(context)
      ? _loginTextBuilderWidthSmallScreen
      : _loginTextBuilderWidthLargeScreen;

  double getWidthLoginButton() => _loginButtonWidth;
}