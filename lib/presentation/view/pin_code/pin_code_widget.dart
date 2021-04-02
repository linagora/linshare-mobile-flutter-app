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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:linshare_flutter_app/presentation/model/pin_code_validation_type.dart';
import 'package:linshare_flutter_app/presentation/view/button/button_text_action_builder.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:domain/domain.dart';

typedef ButtonCallback = void Function(String enteredPin);

class PinCodeValidationNotifier extends ValueNotifier<PinCodeValidationType> {
  PinCodeValidationNotifier() : super(PinCodeValidationType.CORRECT);
}

/// Pin Code Widget which combines title, pin fields for inputting and submit button
/// All child widgets are organized by vertical
class PinCodeWidget extends StatefulWidget {
  /// Vertical space between widget
  final double distanceSpaceVertical;

  /// Title properties
  final String title;
  final TextStyle titleStyle;

  /// Sub-title properties
  final String subTitle;
  final TextStyle subTitleStyle;

  /// Pin fields background color
  final Color pinCodeFieldBackgroundColor;

  /// Pin fields horizontal padding from left and right of parent
  final double pinCodeFieldPaddingHorizontal;

  /// Total of pin field.
  final int pinCount;

  /// Pin fields settings
  final double pinSizeWidth;
  final double pinSizeHeight;
  final double pinBorderRadius;
  final TextStyle pinTextStyle;
  final Color pinBackgroundColor;

  /// Error message settings
  final String errorText;
  final TextStyle errorStyle;

  /// Button action settings
  final String buttonText;
  final double buttonWidth;
  final double buttonHeight;
  final double buttonBorderRadius;
  final TextStyle buttonStyle;
  final Color buttonBackgroundColor;
  final ButtonCallback onButtonClick;

  const PinCodeWidget({
    Key key,
    this.distanceSpaceVertical,
    this.title,
    this.titleStyle,
    this.subTitle,
    this.subTitleStyle,
    this.pinCodeFieldBackgroundColor,
    this.pinCodeFieldPaddingHorizontal,
    this.pinSizeWidth,
    this.pinSizeHeight,
    this.pinBorderRadius,
    this.pinBackgroundColor,
    this.pinCount,
    this.pinTextStyle,
    this.errorText,
    this.errorStyle,
    this.buttonText,
    this.buttonStyle,
    this.buttonBackgroundColor,
    this.buttonWidth,
    this.buttonHeight,
    this.buttonBorderRadius,
    this.onButtonClick
  }) : super(key: key);

  const PinCodeWidget.twoFactorAuthen({
    key = const Key('two_factor_authen_pin_code_widget'),
    this.distanceSpaceVertical = 20,
    this.pinCodeFieldPaddingHorizontal = 36,
    this.pinCount = 6,
    this.pinSizeWidth = 36,
    this.pinSizeHeight = 40,
    this.pinBorderRadius = 4,
    this.title,
    this.titleStyle,
    this.subTitle,
    this.subTitleStyle,
    this.pinCodeFieldBackgroundColor,
    this.pinTextStyle,
    this.pinBackgroundColor,
    this.errorText,
    this.errorStyle,
    this.buttonWidth = 240,
    this.buttonHeight = 48,
    this.buttonBorderRadius = 80,
    this.buttonText,
    this.buttonStyle,
    this.buttonBackgroundColor,
    this.onButtonClick
  });

  @override
  _PinCodeWidgetState createState() => _PinCodeWidgetState();
}

class _PinCodeWidgetState extends State<PinCodeWidget> {
  StreamController<ErrorAnimationType> errorController;

  String currentText = '';
  final formKey = GlobalKey<FormState>();
  PinCodeValidationNotifier pinCodeValueNotifier = PinCodeValidationNotifier();

  @override
  void initState() {
    super.initState();
    errorController = StreamController<ErrorAnimationType>();
  }

  @override
  void dispose() {
    errorController.close();
    pinCodeValueNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.title,
          style: widget.titleStyle,
        ),
        SizedBox(height: widget.distanceSpaceVertical),
        Text(
          widget.subTitle,
          style: widget.subTitleStyle,
        ),
        SizedBox(height: widget.distanceSpaceVertical),
        _buildListPinCodeFields,
        SizedBox(height: widget.distanceSpaceVertical),
        ButtonTextActionBuilder(
          Key('button_action_pin_code'),
          text: widget.buttonText,
          onButtonClick: () {
            formKey.currentState.validate();
            if (currentText.length != widget.pinCount) {
              errorController.add(ErrorAnimationType.shake);
              pinCodeValueNotifier.value = PinCodeValidationType.ERROR;
            } else {
              pinCodeValueNotifier.value = PinCodeValidationType.CORRECT;
              widget.onButtonClick.call(currentText);
            }
          })
          .setTextStyle(widget.buttonStyle)
          .setWidth(widget.buttonWidth)
          .setHeight(widget.buttonHeight)
          .setBackgroundColor(widget.buttonBackgroundColor)
          .setBorderRadius(BorderRadius.all(Radius.circular(widget.buttonBorderRadius)))
          .build(context)
      ],
    );
  }

  Widget get _buildListPinCodeFields => ValueListenableBuilder(
    valueListenable: pinCodeValueNotifier,
    builder: (BuildContext context, PinCodeValidationType type, Widget child) {
      return Container(
        child: Column(
          children: [
            Form(
              key: formKey,
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: widget.pinCodeFieldPaddingHorizontal),
                  child: PinCodeTextField(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    appContext: context,
                    pastedTextStyle: widget.pinTextStyle,
                    length: widget.pinCount,
                    blinkWhenObscuring: false,
                    animationType: AnimationType.fade,
                    validator: (v) {
                      return null;
                    },
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(widget.pinBorderRadius),
                      borderWidth: 0,
                      fieldWidth: widget.pinSizeWidth,
                      fieldHeight: widget.pinSizeHeight,
                      activeFillColor: widget.pinBackgroundColor,
                      inactiveFillColor: widget.pinBackgroundColor,
                      selectedFillColor: widget.pinBackgroundColor,
                      inactiveColor: widget.pinBackgroundColor,
                      selectedColor: widget.pinBackgroundColor,
                      activeColor: widget.pinBackgroundColor,
                      disabledColor: widget.pinBackgroundColor,
                    ),
                    showCursor: false,
                    autoFocus: true,
                    animationDuration: Duration(milliseconds: 300),
                    enableActiveFill: true,
                    errorAnimationController: errorController,
                    keyboardType: TextInputType.number,
                    backgroundColor: widget.pinCodeFieldBackgroundColor,
                    boxShadows: [
                      BoxShadow(
                        offset: Offset(0, 1),
                        color: Colors.black12,
                        blurRadius: widget.pinBorderRadius,
                      )
                    ],
                    onCompleted: (v) {
                      pinCodeValueNotifier.value = PinCodeValidationType.CORRECT;
                    },
                    onChanged: (value) {
                      currentText = value;
                    },
                    beforeTextPaste: (text) {
                      return text.isIntegerNumber();
                    },
                  )),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.pinCodeFieldPaddingHorizontal),
              child: Text(
                type == PinCodeValidationType.CORRECT ? '' : widget.errorText,
                style: widget.errorStyle,
              ),
            ),
          ],
        ),
      );
    }
  );
}
