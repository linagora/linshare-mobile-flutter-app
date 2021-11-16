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

import 'package:domain/domain.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/edit_upload_request_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/view/upload_request/checkbox_input_field_builder.dart';
import 'package:linshare_flutter_app/presentation/view/upload_request/combo_box_input_field_builder.dart';
import 'package:linshare_flutter_app/presentation/view/upload_request/date_time_input_field_builder.dart';
import 'package:linshare_flutter_app/presentation/view/upload_request/date_time_no_change_input_field_builder.dart';
import 'package:linshare_flutter_app/presentation/view/upload_request/email_message_input_field_builder.dart';
import 'package:linshare_flutter_app/presentation/view/upload_request/number_input_field_builder.dart';
import 'package:linshare_flutter_app/presentation/view/upload_request/file_size_input_field_builder.dart';
import 'package:linshare_flutter_app/presentation/view/upload_request/upload_request_view_builder.dart';
import 'package:linshare_flutter_app/presentation/view/upload_request/pair_text_input_field_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/edit_upload_request/edit_upload_request_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/edit_upload_request/edit_upload_request_type.dart';
import 'package:linshare_flutter_app/presentation/widget/edit_upload_request/edit_upload_request_viewmodel.dart';
import 'package:redux/redux.dart';

class EditUploadRequestWidget extends StatefulWidget {
  const EditUploadRequestWidget({Key? key}) : super(key: key);

  @override
  _EditUploadRequestWidgetState createState() => _EditUploadRequestWidgetState();
}

class _EditUploadRequestWidgetState extends State<EditUploadRequestWidget> {

  final imagePath = getIt<AppImagePaths>();
  final _model = getIt<EditUploadRequestViewModel>();

  EditUploadRequestArguments? _arguments;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _arguments = ModalRoute.of(context)?.settings.arguments as EditUploadRequestArguments;
      _model.initialize(context, _arguments);
    });
  }

  @override
  void dispose() {
    _model.onDisposed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _arguments = ModalRoute.of(context)?.settings.arguments as EditUploadRequestArguments;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          key: Key('edit_upload_request_arrow_back_button'),
          icon: Image.asset(imagePath.icArrowBack),
          onPressed: () => _model.backToUploadRequestGroup()),
        centerTitle: true,
        title: Text(
            _arguments?.type == EditUploadRequestType.recipients
              ? _arguments?.uploadRequest?.label ?? ''
              : _arguments?.uploadRequestGroup?.label ?? '',
          key: Key('edit_upload_request_title'),
          style: TextStyle(fontSize: 24, color: Colors.white)),
        backgroundColor: AppColor.primaryColor),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: StoreConnector<AppState, EditUploadRequestState>(
            converter: (Store<AppState> store) => store.state.editUploadRequestState,
            builder: (context, state) {
              if (_arguments?.type == EditUploadRequestType.recipients) {
                return _buildFormEditUploadRequestRecipients(state);
              } else {
                return _buildFormEditUploadRequestGroup(state);
              }
            }
          )
        ),
      ),
      floatingActionButton: StreamBuilder(
        stream: _model.enableCreateButton,
        initialData: _model.emailSubject.isNotEmpty,
        builder: (context, AsyncSnapshot<bool> snapshot) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  primary: AppColor.documentNameItemTextColor,
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                onPressed: () => _model.backToUploadRequestGroup(),
                child: Text(AppLocalizations.of(context).cancel, style: TextStyle(fontSize: 16.0, color: Colors.black38)),),
              IgnorePointer(
                ignoring: !(snapshot.data ?? false),
                child: OutlinedButton(
                  onPressed: () =>  _model.validateFormData(context),
                  style: OutlinedButton.styleFrom(
                    primary: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 55, vertical: 12),
                    backgroundColor: (snapshot.data ?? false)
                      ? AppColor.primaryColor
                      : AppColor.uploadButtonDisableBackgroundColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                  child: Text(AppLocalizations.of(context).save, style: TextStyle(fontSize: 16.0, color: Colors.white)))
              )
            ]);
        }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildFormEditUploadRequestGroup(EditUploadRequestState state) {
    return (UploadRequestViewBuilder(context, EditUploadRequestType.group)
        ..key(_formKey)
        ..addEmailMessageInput((EmailMessageInputFieldBuilder(context)
              ..addEmailSubjectController(_model.emailSubjectController)
              ..addEmailMessageController(_model.emailMessageController)
              ..addOnChangeEmailSubject((value) => _model.setEmailSubject(value)))
            .build())
        ..addActivationDateInput(state.uploadRequest?.status == UploadRequestStatus.ENABLED
            ? (DateTimeNoChangeInputFieldBuilder()
                ..setKey(Key('activation_date_no_change_input'))
                ..setTitle(AppLocalizations.of(context).activation_date)
                ..setValue(state.uploadRequest?.activationDate))
              .build()
            : (DateTimeInputFieldBuilder()
                ..setKey(Key('activation_date_input'))
                ..setTitle(AppLocalizations.of(context).activation_date)
                ..addDateTimeTextValueNotifier(_model.textActivationNotifier)
                ..addOnDateTimeClickAction(() => _model.showDateTimeActivationAction(context)))
              .build())
        ..addExpirationDateInput((DateTimeInputFieldBuilder()
              ..setKey(Key('expiration_date_input'))
              ..setTitle(AppLocalizations.of(context).expiration_date)
              ..addDateTimeTextValueNotifier(_model.textExpirationNotifier)
              ..addOnDateTimeClickAction(() => _model.showDateTimeExpirationAction(context)))
            .build())
        ..addMaxNumberFileInput((NumberInputFieldBuilder(context)
              ..setKey(Key('max_number_files_input'))
              ..setTitle(AppLocalizations.of(context).max_number_of_files)
              ..addController(_model.maxNumberFilesController))
            .build())
        ..addMaxSizeFileInput((FileSizeInputFieldBuilder(context)
              ..setKey(Key('max_file_size_input'))
              ..setTitle(AppLocalizations.of(context).max_size_of_a_file)
              ..setListSizeType(state.uploadRequest?.listMaxFileSizeType)
              ..addController(_model.maxFileSizeController)
              ..addOnSizeTypeNotifier(_model.maxFileSizeTypeNotifier))
            .build())
        ..addReminderDateInput((DateTimeInputFieldBuilder()
              ..setKey(Key('reminder_date_input'))
              ..setTitle(AppLocalizations.of(context).reminder_date)
              ..addDateTimeTextValueNotifier(_model.textReminderNotifier)
              ..addOnDateTimeClickAction(() => _model.showDateTimeReminderAction(context)))
            .build())
        ..addTotalSizeFileInput((FileSizeInputFieldBuilder(context)
              ..setKey(Key('total_file_size_input'))
              ..setTitle(AppLocalizations.of(context).total_size_of_files)
              ..setListSizeType(state.uploadRequest?.listTotalFileSizeType)
              ..addController(_model.totalFileSizeController)
              ..addOnSizeTypeNotifier(_model.totalFileSizeTypeNotifier))
            .build())
        ..addPasswordProtectedNoChangeInput((PairTextInputFieldBuilder()
              ..setKey(Key('password_protected_no_change_input'))
              ..setTitle(AppLocalizations.of(context).password_protected)
              ..setValue(state.uploadRequest?.passwordProtected == true
                  ? AppLocalizations.of(context).yes
                  : AppLocalizations.of(context).no))
            .build())
        ..addAllowDeletionInput((CheckboxInputFieldBuilder()
              ..setKey(Key('allow_deletion_input'))
              ..setTitle(AppLocalizations.of(context).allow_deletion)
              ..addOnNotifier(_model.allowDeletionNotifier))
            .build())
        ..addAllowClosureInput((CheckboxInputFieldBuilder()
              ..setKey(Key('allow_closure_input'))
              ..setTitle(AppLocalizations.of(context).allow_closure)
              ..addOnNotifier(_model.allowClosureNotifier))
            .build())
        ..addNotificationLanguageInput((ComboBoxInputFieldBuilder()
              ..setKey(Key('notification_language_input'))
              ..setTitle(AppLocalizations.of(context).notification_language)
              ..setListValue(state.uploadRequest?.listNotificationLanguages)
              ..addOnNotifier(_model.notificationLanguageNotifier))
            .build())
        ..setAdvanceSettingVisibilityNotifier(_model.advanceVisibilityNotifier))
      .build();
  }

  Widget _buildFormEditUploadRequestRecipients(EditUploadRequestState state) {
    return (UploadRequestViewBuilder(context, EditUploadRequestType.recipients)
        ..key(_formKey)
        ..addActivationDateInput(state.uploadRequest?.status == UploadRequestStatus.ENABLED
            ? (DateTimeNoChangeInputFieldBuilder()
                ..setKey(Key('activation_date_no_change_input'))
                ..setTitle(AppLocalizations.of(context).activation_date)
                ..setValue(state.uploadRequest?.activationDate))
              .build()
            : (DateTimeInputFieldBuilder()
                ..setKey(Key('activation_date_input'))
                ..setTitle(AppLocalizations.of(context).activation_date)
                ..addDateTimeTextValueNotifier(_model.textActivationNotifier)
                ..addOnDateTimeClickAction(() => _model.showDateTimeActivationAction(context)))
              .build())
        ..addExpirationDateInput((DateTimeInputFieldBuilder()
              ..setKey(Key('expiration_date_input'))
              ..setTitle(AppLocalizations.of(context).expiration_date)
              ..addDateTimeTextValueNotifier(_model.textExpirationNotifier)
              ..addOnDateTimeClickAction(() => _model.showDateTimeExpirationAction(context)))
            .build())
        ..addMaxNumberFileInput((NumberInputFieldBuilder(context)
              ..setKey(Key('max_number_files_input'))
              ..setTitle(AppLocalizations.of(context).max_number_of_files)
              ..addController(_model.maxNumberFilesController))
            .build())
        ..addMaxSizeFileInput((FileSizeInputFieldBuilder(context)
              ..setKey(Key('max_file_size_input'))
              ..setTitle(AppLocalizations.of(context).max_size_of_a_file)
              ..setListSizeType(state.uploadRequest?.listMaxFileSizeType)
              ..addController(_model.maxFileSizeController)
              ..addOnSizeTypeNotifier(_model.maxFileSizeTypeNotifier))
            .build())
        ..addReminderDateInput((DateTimeInputFieldBuilder()
              ..setKey(Key('reminder_date_input'))
              ..setTitle(AppLocalizations.of(context).reminder_date)
              ..addDateTimeTextValueNotifier(_model.textReminderNotifier)
              ..addOnDateTimeClickAction(() => _model.showDateTimeReminderAction(context)))
            .build())
        ..addTotalSizeFileInput((FileSizeInputFieldBuilder(context)
              ..setKey(Key('total_file_size_input'))
              ..setTitle(AppLocalizations.of(context).total_size_of_files)
              ..setListSizeType(state.uploadRequest?.listTotalFileSizeType)
              ..addController(_model.totalFileSizeController)
              ..addOnSizeTypeNotifier(_model.totalFileSizeTypeNotifier))
            .build())
        ..addPasswordProtectedNoChangeInput((PairTextInputFieldBuilder()
              ..setKey(Key('password_protected_no_change_input'))
              ..setTitle(AppLocalizations.of(context).password_protected)
              ..setValue(state.uploadRequest?.passwordProtected == true
                  ? AppLocalizations.of(context).yes
                  : AppLocalizations.of(context).no))
            .build())
        ..addAllowDeletionInput((CheckboxInputFieldBuilder()
              ..setKey(Key('allow_deletion_input'))
              ..setTitle(AppLocalizations.of(context).allow_deletion)
              ..addOnNotifier(_model.allowDeletionNotifier))
            .build())
        ..addAllowClosureInput((CheckboxInputFieldBuilder()
              ..setKey(Key('allow_closure_input'))
              ..setTitle(AppLocalizations.of(context).allow_closure)
              ..addOnNotifier(_model.allowClosureNotifier))
            .build())
        ..addNotificationLanguageInput((ComboBoxInputFieldBuilder()
              ..setKey(Key('notification_language_input'))
              ..setTitle(AppLocalizations.of(context).notification_language)
              ..setListValue(state.uploadRequest?.listNotificationLanguages)
              ..addOnNotifier(_model.notificationLanguageNotifier))
            .build())
        ..setAdvanceSettingVisibilityNotifier(_model.advanceVisibilityNotifier))
      .build();
  }
}