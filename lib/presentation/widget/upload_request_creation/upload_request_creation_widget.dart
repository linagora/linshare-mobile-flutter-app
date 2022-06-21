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
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/upload_request_creation_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/view/upload_request/add_recipients_input_field_builder.dart';
import 'package:linshare_flutter_app/presentation/view/upload_request/checkbox_input_field_builder.dart';
import 'package:linshare_flutter_app/presentation/view/upload_request/combo_box_input_field_builder.dart';
import 'package:linshare_flutter_app/presentation/view/upload_request/date_time_input_field_builder.dart';
import 'package:linshare_flutter_app/presentation/view/upload_request/email_message_input_field_builder.dart';
import 'package:linshare_flutter_app/presentation/view/upload_request/number_input_field_builder.dart';
import 'package:linshare_flutter_app/presentation/view/upload_request/file_size_input_field_builder.dart';
import 'package:linshare_flutter_app/presentation/view/upload_request/upload_request_view_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/edit_upload_request/edit_upload_request_type.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_creation/upload_request_creation_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_creation/upload_request_creation_viewmodel.dart';
import 'package:redux/redux.dart';

class UploadRequestCreationWidget extends StatefulWidget {
  const UploadRequestCreationWidget({Key? key}) : super(key: key);

  @override
  _UploadRequestCreationWidgetState createState() => _UploadRequestCreationWidgetState();
}

class _UploadRequestCreationWidgetState extends State<UploadRequestCreationWidget> {

  final imagePath = getIt<AppImagePaths>();
  final _model = getIt<UploadRequestCreationViewModel>();

  UploadRequestCreationArguments? _arguments;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _arguments = ModalRoute.of(context)?.settings.arguments as UploadRequestCreationArguments;
      _model.initialize(_arguments);
    });
  }

  @override
  void dispose() {
    _model.onDisposed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _arguments = ModalRoute.of(context)?.settings.arguments as UploadRequestCreationArguments;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          key: Key('upload_request_creation_arrow_back_button'),
          icon: Image.asset(imagePath.icArrowBack),
          onPressed: () => _model.backToUploadRequestGroup(),
        ),
        centerTitle: true,
        title: Text(
            _arguments?.type == UploadRequestCreationType.COLLECTIVE
                ? AppLocalizations.of(context).create_collective_upload_request_title
                : AppLocalizations.of(context).create_individual_upload_request_title,
            key: Key('upload_request_creation_title'),
            style: TextStyle(fontSize: 24, color: Colors.white)),
        backgroundColor: AppColor.primaryColor,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: StoreConnector<AppState, UploadRequestCreationState>(
            converter: (Store<AppState> store) => store.state.uploadRequestCreationState,
            builder: (context, creationState) => (UploadRequestViewBuilder(context, EditUploadRequestType.group)
                ..key(_formKey)
                ..addRecipientsInput((AddRecipientsInputFieldBuilder(context)
                      ..addRecipientsFieldController(_model.recipientsController)
                      ..addStreamListRecipients(_model.autoCompleteResultListObservable)
                      ..addOnSuggestionCallback((pattern) => _model.getAutoCompleteSharing(pattern))
                      ..addOnSuggestionSelectedAction((autoCompleteResult) => _model.addUserEmail(autoCompleteResult))
                      ..addOnRemoveSelectedAction((index) => _model.removeUserEmail(index)))
                    .build())
                ..addEmailMessageInput((EmailMessageInputFieldBuilder(context)
                      ..addEmailSubjectController(_model.emailSubjectController)
                      ..addEmailMessageController(_model.emailMessageController)
                      ..addOnChangeEmailSubject((value) => _model.updateEmailSubjectObservable(value)))
                    .build())
                ..addActivationDateInput(creationState.uploadRequestCreation?.activationSetting != null
                    ? (DateTimeInputFieldBuilder()
                        ..setKey(Key('activation_date_input'))
                        ..setTitle(AppLocalizations.of(context).activation_date)
                        ..addDateTimeTextValueNotifier(_model.textActivationNotifier)
                        ..addOnDateTimeClickAction(() => _model.showDateTimeActivationAction(context)))
                      .build()
                    : null)
                ..addExpirationDateInput(creationState.uploadRequestCreation?.expirationSetting != null
                    ? (DateTimeInputFieldBuilder()
                        ..setKey(Key('expiration_date_input'))
                        ..setTitle(AppLocalizations.of(context).expiration_date)
                        ..addDateTimeTextValueNotifier(_model.textExpirationNotifier)
                        ..addOnDateTimeClickAction(() => _model.showDateTimeExpirationAction(context)))
                      .build()
                    : null)
                ..addMaxNumberFileInput(creationState.uploadRequestCreation?.maxFileCountSetting != null
                    ? (NumberInputFieldBuilder(context)
                        ..setKey(Key('max_number_files_input'))
                        ..setTitle(AppLocalizations.of(context).max_number_of_files)
                        ..addController(_model.maxNumberFilesController))
                      .build()
                    : null)
                ..addMaxSizeFileInput(creationState.uploadRequestCreation?.maxFileSizeSetting != null
                    ? (FileSizeInputFieldBuilder(context)
                        ..setKey(Key('max_file_size_input'))
                        ..setTitle(AppLocalizations.of(context).max_size_of_a_file)
                        ..setListSizeType(creationState.uploadRequestCreation?.listMaxFileSizeType)
                        ..addController(_model.maxFileSizeController)
                        ..addOnSizeTypeNotifier(_model.maxFileSizeTypeNotifier))
                      .build()
                    : null)
                ..addReminderDateInput(creationState.uploadRequestCreation?.notificationSetting != null
                    ? (DateTimeInputFieldBuilder()
                        ..setKey(Key('reminder_date_input'))
                        ..setTitle(AppLocalizations.of(context).reminder_date)
                        ..addDateTimeTextValueNotifier(_model.textReminderNotifier)
                        ..addOnDateTimeClickAction(() => _model.showDateTimeReminderAction(context)))
                      .build()
                    : null)
                ..addTotalSizeFileInput(creationState.uploadRequestCreation?.totalFileSizeSetting != null
                    ? (FileSizeInputFieldBuilder(context)
                        ..setKey(Key('total_file_size_input'))
                        ..setTitle(AppLocalizations.of(context).total_size_of_files)
                        ..setListSizeType(creationState.uploadRequestCreation?.listTotalFileSizeType)
                        ..addController(_model.totalFileSizeController)
                        ..addOnSizeTypeNotifier(_model.totalFileSizeTypeNotifier))
                      .build()
                    : null)
                ..addPasswordProtectedInput(creationState.uploadRequestCreation?.passwordProtected != null
                    ? (CheckboxInputFieldBuilder()
                        ..setKey(Key('password_protected_input'))
                        ..setTitle(AppLocalizations.of(context).password_protected)
                        ..addOnNotifier(_model.passwordProtectNotifier))
                      .build()
                    : null)
                ..addAllowDeletionInput(creationState.uploadRequestCreation?.canDeleteSetting != null
                    ? (CheckboxInputFieldBuilder()
                        ..setKey(Key('allow_deletion_input'))
                        ..setTitle(AppLocalizations.of(context).allow_deletion)
                        ..addOnNotifier(_model.allowDeletionNotifier))
                      .build()
                    : null)
                ..addAllowClosureInput(creationState.uploadRequestCreation?.canCloseSetting != null
                    ? (CheckboxInputFieldBuilder()
                        ..setKey(Key('allow_closure_input'))
                        ..setTitle(AppLocalizations.of(context).allow_closure)
                        ..addOnNotifier(_model.allowClosureNotifier))
                      .build()
                    : null)
                ..addNotificationLanguageInput(creationState.uploadRequestCreation?.notificationLanguageSetting != null
                    ? (ComboBoxInputFieldBuilder()
                        ..setKey(Key('notification_language_input'))
                        ..setTitle(AppLocalizations.of(context).notification_language)
                        ..setListValue(creationState.uploadRequestCreation?.listNotificationLanguages)
                        ..addOnNotifier(_model.notificationLanguageNotifier))
                      .build()
                    : null)
                ..setAdvanceSettingVisibilityNotifier(_model.advanceVisibilityNotifier))
              .build()
          )
        ),
      ),
      floatingActionButton: StreamBuilder(
        stream: _model.enableCreateButton,
        initialData: true,
        builder: (context, AsyncSnapshot<bool> snapshot) {
          return IgnorePointer(
            ignoring: !(snapshot.data ?? false),
            child: FloatingActionButton.extended(
                key: Key('upload_request_create_button'),
                backgroundColor: (snapshot.data ?? false)
                    ? AppColor.primaryColor
                    : AppColor.uploadButtonDisableBackgroundColor,
                onPressed: () => _model.validateFormData(context),
                label: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(AppLocalizations.of(context).create_upload_request_button,
                    style: TextStyle(fontSize: 16.0)),
                )),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}