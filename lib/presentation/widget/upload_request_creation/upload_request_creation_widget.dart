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

import 'package:dartz/dartz.dart' as dartz;
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/model/file_size_type.dart';
import 'package:linshare_flutter_app/presentation/model/nolitication_language.dart';
import 'package:linshare_flutter_app/presentation/model/unit_time_type.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/app_toast.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/styles.dart';
import 'package:linshare_flutter_app/presentation/util/value_notifier_common.dart';
import 'package:linshare_flutter_app/presentation/view/avatar/label_avatar_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_creation/upload_request_creation_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_creation/upload_request_creation_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/datetime_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/string_extensions.dart';

class UploadRequestCreationWidget extends StatefulWidget {
  const UploadRequestCreationWidget({Key? key}) : super(key: key);

  @override
  _UploadRequestCreationWidgetState createState() => _UploadRequestCreationWidgetState();
}

class _UploadRequestCreationWidgetState extends State<UploadRequestCreationWidget> {

  final imagePath = getIt<AppImagePaths>();
  final _model = getIt<UploadRequestCreationViewModel>();
  final _appToast = getIt<AppToast>();

  UploadRequestCreationArguments? _arguments;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _typeAheadController = TextEditingController();
  final TextEditingController _emailSubjectController = TextEditingController();
  final TextEditingController _emailMessageController = TextEditingController();
  final TextEditingController _maxNumberFilesController = TextEditingController();
  final TextEditingController _maxFileSizeController = TextEditingController();
  final TextEditingController _totalFileSizeController = TextEditingController();

  final DateTimeTextValueNotifier _textActivationNotifier = DateTimeTextValueNotifier();
  final DateTimeTextValueNotifier _textExpirationNotifier = DateTimeTextValueNotifier();
  final ValueNotifier<bool> _advanceVisibilityNotifier = ValueNotifier<bool>(false);
  final DateTimeTextValueNotifier _textReminderNotifier = DateTimeTextValueNotifier();
  final FileSizeValueNotifier _maxFileSizeTypeNotifier = FileSizeValueNotifier();
  final FileSizeValueNotifier _totalFileSizeTypeNotifier = FileSizeValueNotifier();
  final NotificationLanguageValueNotifier _notificationLanguageNotifier = NotificationLanguageValueNotifier();
  final ValueNotifier<bool> _passwordProtectNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _allowDeletionNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _allowClosureNotifier = ValueNotifier<bool>(true);

  late DateTime _creationDateRoundUp;
  late DateTime _initActivationDateRoundUp;
  late DateTime _initExpirationDateRoundUp;
  late DateTime _initReminderDateRoundUp;

  late DateTime _maxActivationDateRoundUp;
  late DateTime _maxExpirationDateRoundUp;
  late DateTime _minReminderDateRoundUp;

  FunctionalityTime? activationSetting;
  FunctionalityTime? expirationSetting;
  FunctionalityTime? notificationSetting;
  FunctionalitySize? totalFileSize;
  FunctionalityInteger? maxFileCount;
  FunctionalitySize? maxFileSize;
  FunctionalityBoolean? canClose;
  FunctionalityBoolean? canDelete;
  FunctionalityBoolean? protectPassword;
  FunctionalitySimple? enableReminderNotification;
  FunctionalityLanguage? notificationLanguage;

  void _initialize() {
    _getFunctionalityData();

    _getRoundUpDate();
    _getActivationDate(isInitialize: true);
    _getExpirationDate();
    _getReminderDate();

    _initDefaultData();
  }

  void _getFunctionalityData() {
    final listFunctionalities = _arguments?.uploadRequestFunctionalities ?? [];
    activationSetting = listFunctionalities.firstWhere((element) =>
        (element != null && element.identifier == FunctionalityIdentifier.UPLOAD_REQUEST__DELAY_BEFORE_ACTIVATION)) as FunctionalityTime?;
    expirationSetting = listFunctionalities.firstWhere((element) =>
        (element != null && element.identifier == FunctionalityIdentifier.UPLOAD_REQUEST__DELAY_BEFORE_EXPIRATION)) as FunctionalityTime?;
    notificationSetting = listFunctionalities.firstWhere((element) =>
        (element != null && element.identifier == FunctionalityIdentifier.UPLOAD_REQUEST__DELAY_BEFORE_NOTIFICATION)) as FunctionalityTime?;
    totalFileSize = listFunctionalities.firstWhere((element) =>
        (element != null && element.identifier == FunctionalityIdentifier.UPLOAD_REQUEST__MAXIMUM_DEPOSIT_SIZE)) as FunctionalitySize?;
    maxFileCount = listFunctionalities.firstWhere((element) =>
        (element != null && element.identifier == FunctionalityIdentifier.UPLOAD_REQUEST__MAXIMUM_FILE_COUNT)) as FunctionalityInteger?;
    maxFileSize = listFunctionalities.firstWhere((element) =>
        (element != null && element.identifier == FunctionalityIdentifier.UPLOAD_REQUEST__MAXIMUM_FILE_SIZE)) as FunctionalitySize?;
    canClose = listFunctionalities.firstWhere(
        (element) => (element != null && element.identifier == FunctionalityIdentifier.UPLOAD_REQUEST__CAN_CLOSE)) as FunctionalityBoolean?;
    canDelete = listFunctionalities.firstWhere(
        (element) => (element != null && element.identifier == FunctionalityIdentifier.UPLOAD_REQUEST__CAN_DELETE)) as FunctionalityBoolean?;
    protectPassword = listFunctionalities.firstWhere((element) =>
        (element != null && element.identifier == FunctionalityIdentifier.UPLOAD_REQUEST__PROTECTED_BY_PASSWORD)) as FunctionalityBoolean?;
    enableReminderNotification = listFunctionalities.firstWhere((element) =>
        (element != null && element.identifier == FunctionalityIdentifier.UPLOAD_REQUEST__REMINDER_NOTIFICATION)) as FunctionalitySimple?;
    notificationLanguage = listFunctionalities.firstWhere((element) =>
        (element != null && element.identifier == FunctionalityIdentifier.UPLOAD_REQUEST__NOTIFICATION_LANGUAGE)) as FunctionalityLanguage?;
  }

  void _getRoundUpDate() {
    _creationDateRoundUp = DateTime.now().roundUpHour(1);
  }

  void _getActivationDate({required bool isInitialize}) {
    switch(activationSetting?.unit.toUnitTimeType()) {
      case UnitTimeType.DAY:
        _initActivationDateRoundUp = _creationDateRoundUp.add(Duration(days: activationSetting!.value));
        _maxActivationDateRoundUp = _creationDateRoundUp.add(Duration(days: activationSetting!.maxValue));
        break;
      case UnitTimeType.WEEK:
        _initActivationDateRoundUp = _creationDateRoundUp.add(Duration(days: activationSetting!.value * 7));
        _maxActivationDateRoundUp = _creationDateRoundUp.add(Duration(days: activationSetting!.maxValue * 7));
        break;
      case UnitTimeType.MONTH:
        _initActivationDateRoundUp = _creationDateRoundUp.copyWith(month: _creationDateRoundUp.month + activationSetting!.value);
        _maxActivationDateRoundUp = _creationDateRoundUp.copyWith(month: _creationDateRoundUp.month + activationSetting!.maxValue);
        break;
      case null:
        _initActivationDateRoundUp = _creationDateRoundUp;
        _maxActivationDateRoundUp = _creationDateRoundUp;
        break;
    }
    if(isInitialize) {
      _textActivationNotifier.value = dartz.Tuple2(_initActivationDateRoundUp, _initActivationDateRoundUp.getYMMMMdFormatWithJm());
    }
  }

  void _getExpirationDate() {
    switch(expirationSetting?.unit.toUnitTimeType()) {
      case UnitTimeType.DAY:
        _initExpirationDateRoundUp = _textActivationNotifier.value!.value1.add(Duration(days: expirationSetting!.value));
        _maxExpirationDateRoundUp = _creationDateRoundUp.add(Duration(days: expirationSetting!.maxValue));
        break;
      case UnitTimeType.WEEK:
        _initExpirationDateRoundUp = _textActivationNotifier.value!.value1.add(Duration(days: expirationSetting!.value * 7));
        _maxExpirationDateRoundUp = _creationDateRoundUp.add(Duration(days: expirationSetting!.maxValue * 7));
        break;
      case UnitTimeType.MONTH:
        _initExpirationDateRoundUp = _textActivationNotifier.value!.value1.copyWith(month: _textActivationNotifier.value!.value1.month + expirationSetting!.value);
        _maxExpirationDateRoundUp = _creationDateRoundUp.copyWith(month: _creationDateRoundUp.month + expirationSetting!.maxValue);
        break;
      case null:
        _initExpirationDateRoundUp = _textActivationNotifier.value!.value1;
        _maxExpirationDateRoundUp = _creationDateRoundUp;
        break;
    }
    _textExpirationNotifier.value = dartz.Tuple2(_initExpirationDateRoundUp, _initExpirationDateRoundUp.getYMMMMdFormatWithJm());
  }

  void _getReminderDate() {
    switch(notificationSetting?.unit.toUnitTimeType()) {
      case UnitTimeType.DAY:
        _initReminderDateRoundUp = _textExpirationNotifier.value!.value1.subtract(Duration(days: notificationSetting!.value));
        _minReminderDateRoundUp = _textExpirationNotifier.value!.value1.subtract(Duration(days: notificationSetting!.maxValue));
        break;
      case UnitTimeType.WEEK:
        _initReminderDateRoundUp = _textExpirationNotifier.value!.value1.subtract(Duration(days: notificationSetting!.value * 7));
        _minReminderDateRoundUp = _textExpirationNotifier.value!.value1.subtract(Duration(days: notificationSetting!.maxValue * 7));
        break;
      case UnitTimeType.MONTH:
        _initReminderDateRoundUp = _textExpirationNotifier.value!.value1.copyWith(month: _textExpirationNotifier.value!.value1.month - notificationSetting!.value);
        _minReminderDateRoundUp = _textExpirationNotifier.value!.value1.copyWith(month: _textExpirationNotifier.value!.value1.month - notificationSetting!.maxValue);
        break;
      case null:
        _initReminderDateRoundUp = _textExpirationNotifier.value!.value1;
        _minReminderDateRoundUp = _textExpirationNotifier.value!.value1;
        break;
    }
    _textReminderNotifier.value = dartz.Tuple2(_initReminderDateRoundUp, _initReminderDateRoundUp.getYMMMMdFormatWithJm());
  }

  void _initDefaultData() {
    _maxFileSizeTypeNotifier.value = maxFileSize?.unit.toFileSizeType() ?? FileSizeType.GB;
    _totalFileSizeTypeNotifier.value = totalFileSize?.unit.toFileSizeType() ?? FileSizeType.GB;
    _notificationLanguageNotifier.value = notificationLanguage?.value.toNotificationLanguage() ?? NotificationLanguage.FRENCH;

    _maxNumberFilesController.text = maxFileCount?.value.toString() ?? '0';
    _maxFileSizeController.text = maxFileSize?.value.toString() ?? '0';
    _totalFileSizeController.text = totalFileSize?.value.toString() ?? '0';

    _passwordProtectNotifier.value = protectPassword?.value ?? false;
    _allowDeletionNotifier.value = canDelete?.value ?? true;
    _allowClosureNotifier.value = canClose?.value ?? true;
  }

  void _disposeValueNotifier() {
    _typeAheadController.clear();
    _emailSubjectController.clear();
    _emailMessageController.clear();
    _maxNumberFilesController.clear();
    _maxFileSizeController.clear();
    _totalFileSizeController.clear();

    _textActivationNotifier.dispose();
    _textExpirationNotifier.dispose();
    _textReminderNotifier.dispose();
    _maxFileSizeTypeNotifier.dispose();
    _totalFileSizeTypeNotifier.dispose();
    _notificationLanguageNotifier.dispose();
    _advanceVisibilityNotifier.dispose();
    _passwordProtectNotifier.dispose();
    _allowDeletionNotifier.dispose();
    _allowClosureNotifier.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _arguments = ModalRoute.of(context)?.settings.arguments as UploadRequestCreationArguments;
      _initialize();
    });
  }

  @override
  void dispose() {
    _disposeValueNotifier();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _arguments = ModalRoute.of(context)?.settings.arguments as UploadRequestCreationArguments;
    final _bottom = MediaQuery.of(context).viewInsets.bottom;
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: SingleChildScrollView(
          reverse: true,
          child: Padding(
            padding: EdgeInsets.only(top: 24.0, left: 20.0, bottom: _bottom, right: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: _buildBodyInputs(),
              ),
            ),
          ),
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
                onPressed: () => _validateFormData(),
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

  List<Widget> _buildBodyInputs() => <Widget>[
    _buildRecipients(),
    _buildEmail(),
    _buildSettingSimple(),
    _buildSettingAdvance(),
    SizedBox(height: 72.0)
  ];

  Widget _buildRecipients() {
    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Row(
            children: [
              Text(
                AppLocalizations.of(context).add_recipients,
                style: TextStyle(
                    fontSize: 16.0, color: AppColor.uploadRequestTitleTextColor),
              ),
              Container(
                  margin: EdgeInsets.only(left: 4.0),
                  child: Text('*',
                      style: TextStyle(
                          color: AppColor.uploadRequestTitleRequiredTextColor)))
            ],
          ),
        ),
        SizedBox(
          height: 16.0,
        ),
        TypeAheadFormField(
            textFieldConfiguration: TextFieldConfiguration(
                controller: _typeAheadController,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                    hintText: AppLocalizations.of(context).add_people,
                    hintStyle: TextStyle(
                        color: AppColor.uploadRequestHintTextColor,
                        fontSize: 16.0),
                    prefixIcon: Icon(
                      Icons.person_add,
                      size: 24.0,
                    ))),
            debounceDuration: Duration(milliseconds: 300),
            suggestionsCallback: (pattern) async {
              if (pattern.length >= 3) {
                return await _model.getAutoCompleteSharing(pattern);
              }
              return <AutoCompleteResult>[];
            },
            itemBuilder: (context, AutoCompleteResult autoCompleteResult) {
              return ListTile(
                leading: LabelAvatarBuilder(autoCompleteResult
                    .getSuggestionDisplayName()
                    .characters
                    .first
                    .toUpperCase())
                    .key(Key('label_avatar'))
                    .build(),
                title: Text(autoCompleteResult.getSuggestionDisplayName(),
                    style: TextStyle(
                        fontSize: 14.0, color: AppColor.userTagTextColor)),
                subtitle: Text(autoCompleteResult.getSuggestionMail(),
                    style: TextStyle(
                        fontSize: 14.0,
                        color: AppColor.userTagRemoveButtonBackgroundColor)),
              );
            },
            onSuggestionSelected: (autoCompleteResult) {
              _typeAheadController.text = '';
              _model.addUserEmail(autoCompleteResult as AutoCompleteResult);
            },
            hideOnEmpty: true,
            hideOnLoading: true
        ),
        SizedBox(
          height: 16.0,
        ),
        _buildTagList(context)
      ],
    );
  }

  Widget _buildTagList(BuildContext context) {
    return StreamBuilder(
      stream: _model.autoCompleteResultListObservable,
      initialData: <AutoCompleteResult>[],
      builder: (context, AsyncSnapshot<List<AutoCompleteResult>> snapshot) {
      return Align(
        alignment: Alignment.topLeft,
        child: Tags(
          alignment: WrapAlignment.start,
          spacing: 10.0,
          itemCount: snapshot.data?.length ?? 0,
          itemBuilder: (index) {
            return ItemTags(
              index: index,
              combine: ItemTagsCombine.withTextAfter,
              title: snapshot.data?[index].getSuggestionDisplayName() ?? '',
              image: ItemTagsImage(
                child: LabelAvatarBuilder(snapshot.data?[index]
                  .getSuggestionDisplayName()
                  .characters
                  .first
                  .toUpperCase() ?? '')
                  .key(Key('label_avatar'))
                  .build()),
              pressEnabled: false,
              activeColor: AppColor.userTagBackgroundColor,
              textActiveColor: AppColor.userTagTextColor,
              textStyle: TextStyle(fontSize: 16.0),
              removeButton: ItemTagsRemoveButton(
                color: Colors.white,
                backgroundColor:
                AppColor.userTagRemoveButtonBackgroundColor,
                onRemoved: () {
                  _model.removeUserEmail(index);
                  return true;
                }),
            );
          },
        ),
      );
      });
  }

  Widget _buildEmail() => Container(
    margin: EdgeInsets.only(top: 40.0),
    child: Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Row(
            children: [
              Text(
                AppLocalizations.of(context).email_message,
                style: TextStyle(fontSize: 16.0, color: AppColor.uploadRequestTitleTextColor),
              ),
              Container(
                  margin: EdgeInsets.only(left: 4.0),
                  child: Text('*', style: TextStyle(color: AppColor.uploadRequestTitleRequiredTextColor)))
            ],
          ),
        ),
        SizedBox(
          height: 16.0,
        ),
        TextField(
            style: TextStyle(fontSize: 16),
            scrollPadding: EdgeInsets.only(bottom: 8),
            decoration: InputDecoration(
                hintText: AppLocalizations.of(context).email_subject,
                hintStyle: TextStyle(color: AppColor.uploadRequestHintTextColor)),
            controller: _emailSubjectController,
            onChanged: (value) => _model.updateEmailSubjectObservable(value),
        ),
        SizedBox(
          height: 16.0,
        ),
        TextField(
            keyboardType: TextInputType.multiline,
            maxLines: 5,
            minLines: 3,
            style: TextStyle(fontSize: 16),
            scrollPadding: EdgeInsets.only(bottom: 8),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).email_message,
              hintStyle: TextStyle(color: AppColor.uploadRequestHintTextColor)),
            controller: _emailMessageController)
      ],
    ),
  );

  Widget _buildSettingSimple() => Container(
    margin: EdgeInsets.only(top: 40.0),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppLocalizations.of(context).settings,
              style: TextStyle(fontSize: 16.0, color: AppColor.uploadRequestTitleTextColor)),
            GestureDetector(
              onTap: () {
                _advanceVisibilityNotifier.value = !_advanceVisibilityNotifier.value;
              },
              child: Text(AppLocalizations.of(context).advanced_options,
                style: TextStyle(fontSize: 15.0, color: AppColor.uploadRequestTextClickableColor)),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 28),
          child: Column(
            children: [
              _buildActivationDateWidget(),
              _buildExpirationDateWidget(),
              _buildMaxNumberFilesWidget(),
              _buildMaxFileSizeWidget(),
            ],
          )
        ),
      ],
    ),
  );

  Widget _buildActivationDateWidget() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(AppLocalizations.of(context).activation_date,
          style: CommonTextStyle.textStyleUploadRequestSettingsTitle),
      GestureDetector(
        onTap: () {
          _getRoundUpDate();
          _getActivationDate(isInitialize: false);
          DatePicker.showDateTimePicker(context,
              showTitleActions: true,
              minTime: _creationDateRoundUp,
              maxTime: _maxActivationDateRoundUp,
              onChanged: (date) {
              }, onConfirm: (date) {
                _textActivationNotifier.value = dartz.Tuple2(date, date.getYMMMMdFormatWithJm());
                _getExpirationDate();
                _getReminderDate();
              },
              currentTime: _textActivationNotifier.value?.value1);
        },
        child: ValueListenableBuilder(
          valueListenable: _textActivationNotifier,
          builder: (BuildContext context, dartz.Tuple2? value, Widget? child) =>
              Text(value?.value2 ?? '', style: CommonTextStyle.textStyleUploadRequestSettingsValue),
        ),
      ),
    ],
  );

  Widget _buildExpirationDateWidget() => Container(
    margin: EdgeInsets.only(top: 28.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(AppLocalizations.of(context).expiration_date,
            style: CommonTextStyle.textStyleUploadRequestSettingsTitle),
        GestureDetector(
          onTap: () {
            _getRoundUpDate();
            DatePicker.showDateTimePicker(context,
                showTitleActions: true,
                minTime: _textActivationNotifier.value!.value1,
                maxTime: _maxExpirationDateRoundUp,
                onChanged: (date) {
                }, onConfirm: (date) {
                  _textExpirationNotifier.value = dartz.Tuple2(date, date.getYMMMMdFormatWithJm());
                  _getReminderDate();
                },
                currentTime: _textExpirationNotifier.value?.value1);
          },
          child: ValueListenableBuilder(
              valueListenable: _textExpirationNotifier,
              builder: (BuildContext context, dartz.Tuple2? value, Widget? child) =>
                  Text(value?.value2 ?? '', style: CommonTextStyle.textStyleUploadRequestSettingsValue)),
        ),
      ],
    ),
  );

  Widget _buildMaxNumberFilesWidget() => Container(
    margin: EdgeInsets.only(top: 28.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(AppLocalizations.of(context).max_number_of_files,
            style: CommonTextStyle.textStyleUploadRequestSettingsTitle),
        Container(
          width: 40.0,
          child: TextFormField(
              maxLength: 4,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly
              ],
              textAlign: TextAlign.right,
              style: CommonTextStyle.textStyleUploadRequestSettingsValue,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(0),
                  isDense: true,
                  hintText: '0',
                  counterText: '',
                  hintStyle: TextStyle(color: AppColor.uploadRequestHintTextColor)),
              controller: _maxNumberFilesController
          ),
        )
      ],
    ),
  );

  Widget _buildMaxFileSizeWidget() {
    final listFileSizeTypes = maxFileSize?.units.map((unit) => unit.toFileSizeType()).toList() ?? [];
    return Container(
      margin: EdgeInsets.only(top: 28.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(AppLocalizations.of(context).max_size_of_a_file,
              style: CommonTextStyle.textStyleUploadRequestSettingsTitle),
          Row(
            children: [
              Container(
                width: 40.0,
                child: TextFormField(
                    maxLength: 3,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    textAlign: TextAlign.right,
                    style: CommonTextStyle.textStyleUploadRequestSettingsValue,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(0),
                        isDense: true,
                        hintText: '0',
                        counterText: '',
                        hintStyle: TextStyle(color: AppColor.uploadRequestHintTextColor)),
                    controller: _maxFileSizeController
                ),
              ),
              SizedBox(width: 16.0),
              ValueListenableBuilder(
                valueListenable: _maxFileSizeTypeNotifier,
                builder: (context, FileSizeType value, child) => DropdownButtonHideUnderline(
                    child: DropdownButton<FileSizeType>(
                      iconEnabledColor: AppColor.uploadRequestTextClickableColor,
                      items: <FileSizeType>[...listFileSizeTypes].map((FileSizeType value) {
                        return DropdownMenuItem<FileSizeType>(
                          value: value,
                          child: Text(value.text,
                              style: CommonTextStyle.textStyleNormal
                                  .copyWith(color: AppColor.uploadRequestTextClickableColor)),
                        );
                      }).toList(),
                      onChanged: (selectedItem) {
                        _maxFileSizeTypeNotifier.value = selectedItem!;
                      },
                      value: value,
                    )
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSettingAdvance() => ValueListenableBuilder(
      valueListenable: _advanceVisibilityNotifier,
      builder: (BuildContext context, bool visible, Widget? child) {
        return visible
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Column(
                  children: [
                    _buildReminderDateWidget(),
                    _buildTotalFileSizeWidget(),
                    _buildPasswordProtectedWidget(),
                    _buildAllowDeletionWidget(),
                    _buildAllowClosureWidget(),
                    _buildNotificationLanguageWidget(),
                  ],
                ))
            : SizedBox.shrink();
      });

  Widget _buildReminderDateWidget() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(AppLocalizations.of(context).reminder_date,
          style: CommonTextStyle.textStyleUploadRequestSettingsTitle),
      GestureDetector(
        onTap: () {
          var minDateRemind = _minReminderDateRoundUp;
          if(_minReminderDateRoundUp.compareTo(_textActivationNotifier.value!.value1) < 0) {
            minDateRemind = _textActivationNotifier.value!.value1;
          }
          DatePicker.showDateTimePicker(context,
              showTitleActions: true,
              minTime: minDateRemind,
              maxTime: _textExpirationNotifier.value!.value1,
              onChanged: (date) {
              }, onConfirm: (date) {
                _textReminderNotifier.value = dartz.Tuple2(date, date.getYMMMMdFormatWithJm());
              },
              currentTime: _textReminderNotifier.value?.value1);
        },
        child: ValueListenableBuilder(
            valueListenable: _textReminderNotifier,
            builder: (BuildContext context, dartz.Tuple2? value, Widget? child) =>
                Text(value?.value2 ?? '', style: CommonTextStyle.textStyleUploadRequestSettingsValue)),
      ),
    ],
  );

  Widget _buildTotalFileSizeWidget() {
    final totalFileSizeTypes = totalFileSize?.units.map((unit) => unit.toFileSizeType()).toList() ?? [];
    return Container(
      margin: EdgeInsets.only(top: 28.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(AppLocalizations.of(context).total_size_of_files,
              style: CommonTextStyle.textStyleUploadRequestSettingsTitle),
          Row(
            children: [
              Container(
                width: 40.0,
                child: TextFormField(
                    maxLength: 3,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    textAlign: TextAlign.right,
                    style: CommonTextStyle.textStyleUploadRequestSettingsValue,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(0),
                        isDense: true,
                        hintText: '0',
                        counterText: '',
                        hintStyle: TextStyle(color: AppColor.uploadRequestHintTextColor)),
                    controller: _totalFileSizeController
                ),
              ),
              SizedBox(width: 16.0),
              ValueListenableBuilder(
                valueListenable: _totalFileSizeTypeNotifier,
                builder: (context, FileSizeType value, child) => DropdownButtonHideUnderline(
                    child: DropdownButton<FileSizeType>(
                      iconEnabledColor: AppColor.uploadRequestTextClickableColor,
                      items: <FileSizeType>[...totalFileSizeTypes].map((FileSizeType value) {
                        return DropdownMenuItem<FileSizeType>(
                          value: value,
                          child: Text(value.text,
                              style: CommonTextStyle.textStyleNormal
                                  .copyWith(color: AppColor.uploadRequestTextClickableColor)),
                        );
                      }).toList(),
                      onChanged: (selectedItem) {
                        _totalFileSizeTypeNotifier.value = selectedItem!;
                      },
                      value: value,
                    )
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPasswordProtectedWidget() => Container(
    margin: EdgeInsets.only(top: 28.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(AppLocalizations.of(context).password_protected,
            style: CommonTextStyle.textStyleUploadRequestSettingsTitle),
        ValueListenableBuilder(
          valueListenable: _passwordProtectNotifier,
            builder: (BuildContext context, bool valueChange, Widget? child) =>
                Checkbox(
                    value: valueChange,
                    onChanged: (bool? value) {
                      _passwordProtectNotifier.value = value ?? false;
                    },
                    activeColor: AppColor.primaryColor)
        )
      ],
    ),
  );

  Widget _buildAllowDeletionWidget() => Container(
    margin: EdgeInsets.only(top: 28.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(AppLocalizations.of(context).allow_deletion,
            style: CommonTextStyle.textStyleUploadRequestSettingsTitle),
        ValueListenableBuilder(
          valueListenable: _allowDeletionNotifier,
          builder: (BuildContext context, bool valueChange, Widget? child) => Checkbox(
            value: valueChange,
            onChanged: (bool? value) {
              _allowDeletionNotifier.value = value ?? true;
            },
            activeColor: AppColor.primaryColor))
          ],
    ),
  );

  Widget _buildAllowClosureWidget() => Container(
    margin: EdgeInsets.only(top: 28.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(AppLocalizations.of(context).allow_closure,
            style: CommonTextStyle.textStyleUploadRequestSettingsTitle),
        ValueListenableBuilder(
          valueListenable: _allowClosureNotifier,
          builder: (BuildContext context, bool valueChange, Widget? child) => Checkbox(
            value: valueChange,
            onChanged: (bool? value) {
              _allowClosureNotifier.value = value ?? true;
            },
            activeColor: AppColor.primaryColor)
        )
      ],
    ),
  );

  Widget _buildNotificationLanguageWidget() {
    final listNotificationLanguages =
        notificationLanguage?.units.map((unit) => unit.toNotificationLanguage()).toList() ?? [];
    return Container(
      margin: EdgeInsets.only(top: 28.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(AppLocalizations.of(context).notification_language,
              style: CommonTextStyle.textStyleUploadRequestSettingsTitle),
          ValueListenableBuilder(
            valueListenable: _notificationLanguageNotifier,
            builder: (context, NotificationLanguage value, child) => DropdownButtonHideUnderline(
              child: DropdownButton<NotificationLanguage>(
                iconEnabledColor: AppColor.uploadRequestTextClickableColor,
                items: <NotificationLanguage>[...listNotificationLanguages].map((NotificationLanguage value) {
                  return DropdownMenuItem<NotificationLanguage>(
                    value: value,
                    child: Text(value.text,
                        style: CommonTextStyle.textStyleNormal
                            .copyWith(color: AppColor.uploadRequestTextClickableColor)),
                  );
                }).toList(),
                onChanged: (selectedItem) {
                  _notificationLanguageNotifier.value = selectedItem ?? NotificationLanguage.FRENCH;
                },
                value: value,
              )
            ),
          ),
        ],
      ),
    );
  }

  void _validateFormData() {
    final numberFiles = int.tryParse(_maxNumberFilesController.text) ?? 0;
    final maxFilesConfig = maxFileCount?.maxValue ?? 0;
    if (numberFiles <= 0 || numberFiles >= maxFilesConfig) {
      _appToast.showErrorToast(AppLocalizations.of(context).max_number_files_error);
      return;
    }

    final inputSize = int.tryParse(_maxFileSizeController.text) ?? 0;
    final fileSizeInByte = _maxFileSizeTypeNotifier.value.toByte(inputSize);
    final maxFileSizeConfig = maxFileSize?.maxValue ?? 0;
    final maxFileSizeTypeConfig = maxFileSize?.maxUnit.toFileSizeType() ?? FileSizeType.GB;
    if (fileSizeInByte <= 0 ||
        (inputSize >= maxFileSizeConfig && _maxFileSizeTypeNotifier.value == maxFileSizeTypeConfig)) {
      _appToast.showErrorToast(AppLocalizations.of(context).max_file_size_error);
      return;
    }

    final totalSizeOfFiles = int.tryParse(_totalFileSizeController.text) ?? 0;
    final totalSizeOfFilesInByte = _totalFileSizeTypeNotifier.value.toByte(totalSizeOfFiles);
    final totalFileSizeConfig = totalFileSize?.maxValue ?? 0;
    final totalFileSizeTypeConfig = totalFileSize?.maxUnit.toFileSizeType() ?? FileSizeType.GB;
    if (totalSizeOfFilesInByte <= 0 ||
        (totalSizeOfFiles >= totalFileSizeConfig && _maxFileSizeTypeNotifier.value == totalFileSizeTypeConfig)) {
      _appToast.showErrorToast(AppLocalizations.of(context).total_file_size_error);
      return;
    }

    // TODO:
    // Once user change the time, prefer to get picked time.
    // Otherwise, passing null for server can handle by itself (temporary solution)
    var activateDate;
    if(_textActivationNotifier.value?.value1.compareTo(_initActivationDateRoundUp) != 0) {
      activateDate = _textActivationNotifier.value!.value1;
    }

    _model.performCreateUploadRequest(
        _arguments?.type ?? UploadRequestCreationType.COLLECTIVE,
        maxFileCount: numberFiles,
        maxFileSize: fileSizeInByte,
        expirationDate: _textExpirationNotifier.value?.value1 ?? _initExpirationDateRoundUp,
        emailMessage: _emailMessageController.text,
        activationDate: activateDate,
        notificationDate: _textReminderNotifier.value?.value1 ?? _initReminderDateRoundUp,
        maxDepositSize: totalSizeOfFilesInByte,
        protectedByPassword: _passwordProtectNotifier.value,
        canClose: _allowClosureNotifier.value,
        canDelete: _allowDeletionNotifier.value,
        enableNotification: enableReminderNotification?.enable ?? true,
        locale: _notificationLanguageNotifier.value.text
    );
  }

}
