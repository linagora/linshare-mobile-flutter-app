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
// <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf
//
// for more details.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for
// more details.
// You should have received a copy of the GNU Affero General Public License and its
// applicable Additional Terms for LinShare along with this program. If not, see
// <http://www.gnu.org/licenses
// for the GNU Affero General Public License version
//
// 3 and <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf
// for
//
// the Additional Terms applicable to LinShare software.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';

typedef OnConfirmActionClick = void Function(String);
typedef SetErrorString = String Function(String);

class EditTextModalSheetBuilder {
  @protected
  TextEditingController _textController;

  @protected
  Key _key;

  @protected
  String _title = '';

  @protected
  String _cancelText = '';

  @protected
  String _confirmText = '';

  @protected
  String _hintText = '';

  @protected
  OnConfirmActionClick _onConfirmActionClick;

  @protected
  SetErrorString _setErrorString;

  @protected
  String _error;

  @protected
  Timer _debounce;

  EditTextModalSheetBuilder();

  EditTextModalSheetBuilder key(Key key) {
    _key = key;
    return this;
  }

  EditTextModalSheetBuilder title(String title) {
    _title = title;
    return this;
  }

  EditTextModalSheetBuilder cancelText(String cancelText) {
    _cancelText = cancelText;
    return this;
  }

  EditTextModalSheetBuilder hintText(String hintText) {
    _hintText = hintText;
    return this;
  }

  EditTextModalSheetBuilder setTextController(TextEditingController textEditingController) {
    _textController = textEditingController;
    return this;
  }

  EditTextModalSheetBuilder setErrorString(SetErrorString setErrorString) {
    _setErrorString = setErrorString;
    return this;
  }

  EditTextModalSheetBuilder onConfirmAction(
      String confirmText, OnConfirmActionClick onConfirmActionClick) {
    _onConfirmActionClick = onConfirmActionClick;
    _confirmText = confirmText;
    return this;
  }

  void _onTextChanged(String name, StateSetter setState) {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _error = _setErrorString(name);
      });
    });
  }

  void _onConfirmButtonPress(BuildContext context) {
    if (_error == null || _error.isEmpty) {
      Navigator.pop(context);
      _onConfirmActionClick(_textController.text);
    }
  }

  void _onCancelButtonPress(BuildContext context) {
    Navigator.pop(context);
    _debounce?.cancel();
  }

  void show(context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return Padding(
              key: _key,
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                  padding: EdgeInsets.only(left: 50, right: 50, top: 48, bottom: 20),
                  child: Wrap(
                    children: <Widget>[
                      Text(_title,
                          style:
                              TextStyle(fontSize: 20, color: AppColor.confirmDialogTitleTextColor),
                          textAlign: TextAlign.center),
                      Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: TextFormField(
                            onChanged: (value) => _onTextChanged(value, setState),
                            autofocus: true,
                            controller: _textController,
                            decoration: InputDecoration(
                                errorText: _error,
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColor.uploadLineDividerWorkGroupDestination),
                                ),
                                hintText: _hintText),
                          )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => _onCancelButtonPress(context),
                            child: Text(_cancelText.toUpperCase(),
                                style: TextStyle(color: AppColor.primaryColor)),
                          ),
                          TextButton(
                            onPressed: () => _onConfirmButtonPress(context),
                            child: Text(
                                _confirmText.toUpperCase(),
                                style: TextStyle(color: (_error == null || _error.isEmpty) ? AppColor.primaryColor : AppColor.unselectedElementColor)
                            ),
                          )
                        ],
                      )
                    ],
                  )));
        });
      },
    );
  }
}
