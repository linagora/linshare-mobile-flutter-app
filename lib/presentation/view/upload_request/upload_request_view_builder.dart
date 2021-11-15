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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/widget/edit_upload_request/edit_upload_request_type.dart';

class UploadRequestViewBuilder {

  final BuildContext context;
  final EditUploadRequestType editUploadRequestType;

  Key? _key;
  Widget? _recipientsInput;
  Widget? _emailMessageInput;
  Widget? _activationDateInput;
  Widget? _expirationDateInput;
  Widget? _maxNumberFileInput;
  Widget? _maxSizeFileInput;
  Widget? _reminderDateInput;
  Widget? _totalSizeFileInput;
  Widget? _passwordProtectedInput;
  Widget? _passwordProtectedNoChangeInput;
  Widget? _allowDeletionInput;
  Widget? _allowClosureInput;
  Widget? _notificationLanguageInput;

  ValueNotifier<bool>? _advanceSettingVisibilityNotifier;

  UploadRequestViewBuilder(this.context, this.editUploadRequestType);

  void key(Key key) {
    _key = key;
  }

  void addRecipientsInput(Widget? recipientsInput) {
    _recipientsInput = recipientsInput;
  }

  void addEmailMessageInput(Widget? emailMessageInput) {
    _emailMessageInput = emailMessageInput;
  }

  void addActivationDateInput(Widget? activationDateInput) {
    _activationDateInput = activationDateInput;
  }

  void addExpirationDateInput(Widget? expirationDateInput) {
    _expirationDateInput = expirationDateInput;
  }

  void addMaxNumberFileInput(Widget? maxNumberFileInput) {
    _maxNumberFileInput = maxNumberFileInput;
  }

  void addMaxSizeFileInput(Widget? maxSizeFileInput) {
    _maxSizeFileInput = maxSizeFileInput;
  }

  void addReminderDateInput(Widget? reminderDateInput) {
    _reminderDateInput = reminderDateInput;
  }

  void addTotalSizeFileInput(Widget? totalSizeFileInput) {
    _totalSizeFileInput = totalSizeFileInput;
  }

  void addPasswordProtectedInput(Widget? passwordProtectedInput) {
    _passwordProtectedInput = passwordProtectedInput;
  }

  void addPasswordProtectedNoChangeInput(Widget? passwordProtectedNoChangeInput) {
    _passwordProtectedNoChangeInput = passwordProtectedNoChangeInput;
  }

  void addAllowDeletionInput(Widget? allowDeletionInput) {
    _allowDeletionInput = allowDeletionInput;
  }

  void addAllowClosureInput(Widget? allowClosureInput) {
    _allowClosureInput = allowClosureInput;
  }

  void addNotificationLanguageInput(Widget? notificationLanguageInput) {
    _notificationLanguageInput = notificationLanguageInput;
  }

  void setAdvanceSettingVisibilityNotifier(ValueNotifier<bool> advanceVisibilityNotifier) {
    _advanceSettingVisibilityNotifier = advanceVisibilityNotifier;
  }

  Widget build() {
    return SingleChildScrollView(
      reverse: true,
      child: Padding(
        padding: EdgeInsets.only(
          top: 24.0,
          left: 20.0,
          bottom: MediaQuery.of(context).viewInsets.bottom,
          right: 20.0),
        child: Form(
          key: _key,
          child: Column(children: editUploadRequestType == EditUploadRequestType.recipients
            ? _buildFormUploadRequestRecipients()
            : _buildFormUploadRequestGroup()),
        ),
      ),
    );
  }

  Widget _buildSettingSimple() => Container(
    margin: EdgeInsets.only(top: 40.0),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context).settings,
              style: TextStyle(fontSize: 16.0, color: AppColor.uploadRequestTitleTextColor)),
            GestureDetector(
              onTap: () {
                if (_advanceSettingVisibilityNotifier != null) {
                  _advanceSettingVisibilityNotifier!.value = !_advanceSettingVisibilityNotifier!.value;
                }
              },
              child: ValueListenableBuilder(
                valueListenable: _advanceSettingVisibilityNotifier ?? ValueNotifier<bool>(false),
                builder: (BuildContext context, bool visible, Widget? child) => Text(
                  visible ? AppLocalizations.of(context).show_less : AppLocalizations.of(context).advanced_options,
                  style: TextStyle(fontSize: 15.0, color: AppColor.uploadRequestTextClickableColor)),
            )),
          ]),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Column(
            children: [
              if (_activationDateInput != null)
                Padding(padding: EdgeInsets.only(top: 28), child: _activationDateInput),
              if (_expirationDateInput != null)
                Padding(padding: EdgeInsets.only(top: 28), child: _expirationDateInput),
              if (_maxNumberFileInput != null)
                Padding(padding: EdgeInsets.only(top: 28), child: _maxNumberFileInput),
              if (_maxSizeFileInput != null)
                Padding(padding: EdgeInsets.only(top: 28), child: _maxSizeFileInput),
            ],
          )),
      ],
    ),
  );

  Widget _buildSettingAdvance() => ValueListenableBuilder(
    valueListenable: _advanceSettingVisibilityNotifier ?? ValueNotifier<bool>(false),
    builder: (BuildContext context, bool visible, Widget? child) {
      return visible
        ? Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: Column(
              children: [
                if (_reminderDateInput != null)
                  Padding(padding: EdgeInsets.only(top: 28), child: _reminderDateInput),
                if (_totalSizeFileInput != null)
                  Padding(padding: EdgeInsets.only(top: 28), child: _totalSizeFileInput),
                if (_passwordProtectedInput != null)
                  Padding(padding: EdgeInsets.only(top: 28), child: _passwordProtectedInput),
                if (_passwordProtectedNoChangeInput != null)
                  Padding(padding: EdgeInsets.only(top: 28), child: _passwordProtectedNoChangeInput),
                if (_allowDeletionInput != null)
                  Padding(padding: EdgeInsets.only(top: 28), child: _allowDeletionInput),
                if (_allowClosureInput != null)
                  Padding(padding: EdgeInsets.only(top: 28), child: _allowClosureInput),
                if (_notificationLanguageInput != null)
                  Padding(padding: EdgeInsets.only(top: 28), child: _notificationLanguageInput),
              ],
            ))
        : SizedBox.shrink();
    });

  List<Widget> _buildFormUploadRequestGroup() {
    return [
      if (_recipientsInput != null) _recipientsInput!,
      if (_emailMessageInput != null)
        Padding(padding: EdgeInsets.only(top: _recipientsInput != null ? 40 : 0), child: _emailMessageInput),
      _buildSettingSimple(),
      _buildSettingAdvance(),
      SizedBox(height: 120.0)
    ];
  }

  List<Widget> _buildFormUploadRequestRecipients() {
    return [
      if (_expirationDateInput != null)
        Padding(padding: EdgeInsets.only(top: 28, left: 4.0, right: 4.0), child: _expirationDateInput),
      if (_totalSizeFileInput != null)
        Padding(padding: EdgeInsets.only(top: 28, left: 4.0, right: 4.0), child: _totalSizeFileInput),
      if (_maxNumberFileInput != null)
        Padding(padding: EdgeInsets.only(top: 28, left: 4.0, right: 4.0), child: _maxNumberFileInput),
      if (_maxSizeFileInput != null)
        Padding(padding: EdgeInsets.only(top: 28, left: 4.0, right: 4.0), child: _maxSizeFileInput),
      if (_activationDateInput != null)
        Padding(padding: EdgeInsets.only(top: 28, left: 4.0, right: 4.0), child: _activationDateInput),
      if (_allowDeletionInput != null)
        Padding(padding: EdgeInsets.only(top: 28), child: _allowDeletionInput),
      if (_allowClosureInput != null)
        Padding(padding: EdgeInsets.only(top: 28), child: _allowClosureInput),
      if (_reminderDateInput != null)
        Padding(padding: EdgeInsets.only(top: 28), child: _reminderDateInput),
      if (_notificationLanguageInput != null)
        Padding(padding: EdgeInsets.only(top: 28), child: _notificationLanguageInput),
      SizedBox(height: 120.0)
    ];
  }
}