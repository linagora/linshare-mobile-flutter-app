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

import 'package:dartz/dartz.dart';
import 'package:domain/domain.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/model/file_size_type.dart';
import 'package:linshare_flutter_app/presentation/model/nolitication_language.dart';
import 'package:linshare_flutter_app/presentation/model/unit_time_type.dart';
import 'package:linshare_flutter_app/presentation/model/upload_request_presentation.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/edit_upload_request_action.dart';
import 'package:linshare_flutter_app/presentation/redux/online_thunk_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_toast.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/util/value_notifier_common.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/edit_upload_request/edit_upload_request_arguments.dart';
import 'package:redux/src/store.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/string_extensions.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/datetime_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/file_size_extension.dart';
import 'package:rxdart/rxdart.dart';

class EditUploadRequestViewModel extends BaseViewModel {

  final AppNavigation _appNavigation;
  final AppToast _appToast;
  final EditUploadRequestInteractor _editUploadRequestInteractor;

  final TextEditingController emailSubjectController = TextEditingController();
  final TextEditingController emailMessageController = TextEditingController();
  final TextEditingController maxNumberFilesController = TextEditingController();
  final TextEditingController maxFileSizeController = TextEditingController();
  final TextEditingController totalFileSizeController = TextEditingController();

  final DateTimeTextValueNotifier textActivationNotifier = DateTimeTextValueNotifier();
  final DateTimeTextValueNotifier textExpirationNotifier = DateTimeTextValueNotifier();
  final ValueNotifier<bool> advanceVisibilityNotifier = ValueNotifier<bool>(false);
  final DateTimeTextValueNotifier textReminderNotifier = DateTimeTextValueNotifier();
  final FileSizeValueNotifier maxFileSizeTypeNotifier = FileSizeValueNotifier();
  final FileSizeValueNotifier totalFileSizeTypeNotifier = FileSizeValueNotifier();
  final NotificationLanguageValueNotifier notificationLanguageNotifier = NotificationLanguageValueNotifier();
  final ValueNotifier<bool> allowDeletionNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<bool> allowClosureNotifier = ValueNotifier<bool>(true);

  late DateTime _creationDateRoundUp;
  late DateTime _initActivationDateRoundUp;
  late DateTime _initExpirationDateRoundUp;
  late DateTime _initReminderDateRoundUp;

  late DateTime _maxActivationDateRoundUp;
  late DateTime _maxExpirationDateRoundUp;
  late DateTime _minReminderDateRoundUp;

  FunctionalityTime? _activationSetting;
  FunctionalityTime? _expirationSetting;
  FunctionalityTime? _notificationSetting;
  FunctionalitySize? _totalFileSizeSetting;
  FunctionalityInteger? _maxFileCountSetting;
  FunctionalitySize? _maxFileSizeSetting;
  FunctionalitySimple? _enableReminderNotificationSetting;
  FunctionalityLanguage? _notificationLanguageSetting;

  EditUploadRequestArguments? arguments;

  final BehaviorSubject<bool> _enableCreateButton = BehaviorSubject.seeded(false);
  StreamView<bool> get enableCreateButton => _enableCreateButton;

  String _emailSubject = '';

  String get emailSubject => _emailSubject;

  void setEmailSubject(String subject) {
    _emailSubject = subject;
    _emailSubject.isNotEmpty ? _enableCreateButton.add(true) : _enableCreateButton.add(false);
  }

  EditUploadRequestViewModel(
    Store<AppState> store,
    this._appNavigation,
    this._appToast,
    this._editUploadRequestInteractor,
  ) : super(store);

  void _disposeValueNotifier() {
    emailSubjectController.clear();
    emailMessageController.clear();
    maxNumberFilesController.clear();
    maxFileSizeController.clear();
    totalFileSizeController.clear();

    textActivationNotifier.dispose();
    textExpirationNotifier.dispose();
    textReminderNotifier.dispose();
    advanceVisibilityNotifier.dispose();
    maxFileSizeTypeNotifier.dispose();
    totalFileSizeTypeNotifier.dispose();
    notificationLanguageNotifier.dispose();
    allowDeletionNotifier.dispose();
    allowClosureNotifier.dispose();
  }

  void initialize(EditUploadRequestArguments? editArguments) {
    arguments = editArguments;

    _getFunctionalityData();
    _getRoundUpDate();
    _getActivationDate(isInitialize: true);
    _getExpirationDate(isInitialize: true);
    _getReminderDate(isInitialize: true);
    _initDefaultData();

    final uploadRequest = _generateUploadRequestPresentation();
    store.dispatch(UpdateUploadRequestPresentationAction(uploadRequest));
  }

  void _getFunctionalityData() {
    final listFunctionalities = arguments?.uploadRequestFunctionalities ?? [];
    _activationSetting = listFunctionalities.firstWhere((element) =>
        (element != null && element.identifier == FunctionalityIdentifier.UPLOAD_REQUEST__DELAY_BEFORE_ACTIVATION)) as FunctionalityTime?;
    _expirationSetting = listFunctionalities.firstWhere((element) =>
        (element != null && element.identifier == FunctionalityIdentifier.UPLOAD_REQUEST__DELAY_BEFORE_EXPIRATION)) as FunctionalityTime?;
    _notificationSetting = listFunctionalities.firstWhere((element) =>
        (element != null && element.identifier == FunctionalityIdentifier.UPLOAD_REQUEST__DELAY_BEFORE_NOTIFICATION)) as FunctionalityTime?;
    _totalFileSizeSetting = listFunctionalities.firstWhere((element) =>
        (element != null && element.identifier == FunctionalityIdentifier.UPLOAD_REQUEST__MAXIMUM_DEPOSIT_SIZE)) as FunctionalitySize?;
    _maxFileCountSetting = listFunctionalities.firstWhere((element) =>
        (element != null && element.identifier == FunctionalityIdentifier.UPLOAD_REQUEST__MAXIMUM_FILE_COUNT)) as FunctionalityInteger?;
    _maxFileSizeSetting = listFunctionalities.firstWhere((element) =>
        (element != null && element.identifier == FunctionalityIdentifier.UPLOAD_REQUEST__MAXIMUM_FILE_SIZE)) as FunctionalitySize?;
    _enableReminderNotificationSetting = listFunctionalities.firstWhere((element) =>
        (element != null && element.identifier == FunctionalityIdentifier.UPLOAD_REQUEST__REMINDER_NOTIFICATION)) as FunctionalitySimple?;
    _notificationLanguageSetting = listFunctionalities.firstWhere((element) =>
        (element != null && element.identifier == FunctionalityIdentifier.UPLOAD_REQUEST__NOTIFICATION_LANGUAGE)) as FunctionalityLanguage?;
  }

  void _getRoundUpDate() {
    _creationDateRoundUp = DateTime.now().roundUpHour(1);
  }

  void _getActivationDate({required bool isInitialize}) {
    switch(_activationSetting?.unit.toUnitTimeType()) {
      case UnitTimeType.DAY:
        _initActivationDateRoundUp = _creationDateRoundUp.add(Duration(days: _activationSetting!.value));
        _maxActivationDateRoundUp = _creationDateRoundUp.add(Duration(days: _activationSetting!.maxValue));
        break;
      case UnitTimeType.WEEK:
        _initActivationDateRoundUp = _creationDateRoundUp.add(Duration(days: _activationSetting!.value * 7));
        _maxActivationDateRoundUp = _creationDateRoundUp.add(Duration(days: _activationSetting!.maxValue * 7));
        break;
      case UnitTimeType.MONTH:
        _initActivationDateRoundUp = _creationDateRoundUp.copyWith(month: _creationDateRoundUp.month + _activationSetting!.value);
        _maxActivationDateRoundUp = _creationDateRoundUp.copyWith(month: _creationDateRoundUp.month + _activationSetting!.maxValue);
        break;
      case null:
        _initActivationDateRoundUp = _creationDateRoundUp;
        _maxActivationDateRoundUp = _creationDateRoundUp;
        break;
    }
    if (isInitialize) {
      _initActivationDateRoundUp = arguments?.uploadRequestGroup.activationDate ?? _initActivationDateRoundUp;
      textActivationNotifier.value = Tuple2(_initActivationDateRoundUp, _initActivationDateRoundUp.getYMMMMdFormatWithJm());
    }
  }

  void _getExpirationDate({required bool isInitialize}) {
    switch(_expirationSetting?.unit.toUnitTimeType()) {
      case UnitTimeType.DAY:
        _initExpirationDateRoundUp = textActivationNotifier.value!.value1.add(Duration(days: _expirationSetting!.value));
        _maxExpirationDateRoundUp = textActivationNotifier.value!.value1.add(Duration(days: _expirationSetting!.maxValue));
        break;
      case UnitTimeType.WEEK:
        _initExpirationDateRoundUp = textActivationNotifier.value!.value1.add(Duration(days: _expirationSetting!.value * 7));
        _maxExpirationDateRoundUp = textActivationNotifier.value!.value1.add(Duration(days: _expirationSetting!.maxValue * 7));
        break;
      case UnitTimeType.MONTH:
        _initExpirationDateRoundUp = textActivationNotifier.value!.value1.copyWith(month: textActivationNotifier.value!.value1.month + _expirationSetting!.value);
        _maxExpirationDateRoundUp = textActivationNotifier.value!.value1.copyWith(month: _creationDateRoundUp.month + _expirationSetting!.maxValue);
        break;
      case null:
        _initExpirationDateRoundUp = textActivationNotifier.value!.value1;
        _maxExpirationDateRoundUp = textActivationNotifier.value!.value1;
        break;
    }
    if (isInitialize) {
      _initExpirationDateRoundUp = arguments?.uploadRequestGroup.expiryDate ?? _initExpirationDateRoundUp;
    }
    textExpirationNotifier.value = Tuple2(_initExpirationDateRoundUp, _initExpirationDateRoundUp.getYMMMMdFormatWithJm());
  }

  void _getReminderDate({required bool isInitialize}) {
    switch(_notificationSetting?.unit.toUnitTimeType()) {
      case UnitTimeType.DAY:
        _initReminderDateRoundUp = textExpirationNotifier.value!.value1.subtract(Duration(days: _notificationSetting!.value));
        _minReminderDateRoundUp = textExpirationNotifier.value!.value1.subtract(Duration(days: _notificationSetting!.maxValue));
        break;
      case UnitTimeType.WEEK:
        _initReminderDateRoundUp = textExpirationNotifier.value!.value1.subtract(Duration(days: _notificationSetting!.value * 7));
        _minReminderDateRoundUp = textExpirationNotifier.value!.value1.subtract(Duration(days: _notificationSetting!.maxValue * 7));
        break;
      case UnitTimeType.MONTH:
        _initReminderDateRoundUp = textExpirationNotifier.value!.value1.copyWith(month: textExpirationNotifier.value!.value1.month - _notificationSetting!.value);
        _minReminderDateRoundUp = textExpirationNotifier.value!.value1.copyWith(month: textExpirationNotifier.value!.value1.month - _notificationSetting!.maxValue);
        break;
      case null:
        _initReminderDateRoundUp = textExpirationNotifier.value!.value1;
        _minReminderDateRoundUp = textExpirationNotifier.value!.value1;
        break;
    }

    if (_minReminderDateRoundUp.compareTo(textActivationNotifier.value!.value1) < 0) {
      _minReminderDateRoundUp = textActivationNotifier.value!.value1;
    }
    if(_initReminderDateRoundUp.compareTo(textActivationNotifier.value!.value1) < 0) {
      _initReminderDateRoundUp = textActivationNotifier.value!.value1;
    }
    if (isInitialize) {
      _initReminderDateRoundUp = arguments?.uploadRequestGroup.notificationDate ?? _initReminderDateRoundUp;
    }
    textReminderNotifier.value = Tuple2(_initReminderDateRoundUp, _initReminderDateRoundUp.getYMMMMdFormatWithJm());
  }

  void _initDefaultData() {
    emailSubjectController.text = arguments?.uploadRequestGroup.label ?? '';
    emailMessageController.text = arguments?.uploadRequestGroup.body ?? '';

    setEmailSubject(emailSubjectController.text);

    final maxFileSize = arguments?.uploadRequestGroup.maxFileSize?.toFileSize();
    final totalFileSize = arguments?.uploadRequestGroup.maxDepositSize.toFileSize();

    maxFileSizeTypeNotifier.value = maxFileSize?.value2 ?? FileSizeType.GB;
    totalFileSizeTypeNotifier.value = totalFileSize?.value2 ?? FileSizeType.GB;
    notificationLanguageNotifier.value = arguments?.uploadRequestGroup.locale?.toNotificationLanguage() ?? NotificationLanguage.FRENCH;

    maxNumberFilesController.text = arguments?.uploadRequestGroup.maxFileCount.toString() ?? '0';
    maxFileSizeController.text = maxFileSize?.value1 ?? '0';
    totalFileSizeController.text = totalFileSize?.value1 ?? '0';

    allowDeletionNotifier.value = arguments?.uploadRequestGroup.canDelete ?? true;
    allowClosureNotifier.value = arguments?.uploadRequestGroup.canClose ?? true;
  }

  UploadRequestPresentation _generateUploadRequestPresentation() {
    final activationDate = textActivationNotifier.value?.value2;
    final status = arguments?.uploadRequestGroup.status;
    final passwordProtected = arguments?.uploadRequestGroup.protectedByPassword ?? false;
    final _listMaxFileSizeType = _maxFileSizeSetting?.units.map((unit) => unit.toFileSizeType()).toList() ?? [];
    final _listTotalFileSizeType = _totalFileSizeSetting?.units.map((unit) => unit.toFileSizeType()).toList() ?? [];
    final _listNotificationLanguages = _notificationLanguageSetting?.units.map((unit) => unit.toNotificationLanguage()).toList() ?? [];

    final uploadRequest = UploadRequestPresentation(
      activationDate: activationDate,
      status: status,
      passwordProtected: passwordProtected,
      listMaxFileSizeType: _listMaxFileSizeType,
      listTotalFileSizeType: _listTotalFileSizeType,
      listNotificationLanguages: _listNotificationLanguages,
    );

    return uploadRequest;
  }

  void showDateTimeActivationAction(BuildContext context) {
    _getRoundUpDate();
    _getActivationDate(isInitialize: false);
    DatePicker.showDateTimePicker(context,
      showTitleActions: true,
      minTime: _creationDateRoundUp,
      maxTime: _maxActivationDateRoundUp,
      onConfirm: (date) {
        textActivationNotifier.value = Tuple2(date, date.getYMMMMdFormatWithJm());
        _getExpirationDate(isInitialize: false);
        _getReminderDate(isInitialize: false);
      },
      currentTime: textActivationNotifier.value?.value1);
  }

  void showDateTimeExpirationAction(BuildContext context) {
    _getRoundUpDate();
    DatePicker.showDateTimePicker(context,
      showTitleActions: true,
      minTime: arguments?.uploadRequestGroup.status == UploadRequestStatus.ENABLED
        ? _creationDateRoundUp
        : textActivationNotifier.value!.value1,
      maxTime: _maxExpirationDateRoundUp,
      onConfirm: (date) {
        textExpirationNotifier.value = Tuple2(date, date.getYMMMMdFormatWithJm());
        _getReminderDate(isInitialize: false);
      },
      currentTime: textExpirationNotifier.value?.value1);
  }

  void showDateTimeReminderAction(BuildContext context) {
    DatePicker.showDateTimePicker(context,
      showTitleActions: true,
      minTime: _minReminderDateRoundUp,
      maxTime: textExpirationNotifier.value!.value1,
      onChanged: (date) {},
      onConfirm: (date) => textReminderNotifier.value = Tuple2(date, date.getYMMMMdFormatWithJm()),
      currentTime: textReminderNotifier.value?.value1);
  }

  void backToUploadRequestGroup() {
    _appNavigation.popBack();
  }

  void validateFormData(BuildContext context) {
    final numberFiles = int.tryParse(maxNumberFilesController.text) ?? 0;
    final maxFilesConfig = _maxFileCountSetting?.maxValue ?? 0;
    if (numberFiles <= 0 || numberFiles >= maxFilesConfig) {
      _appToast.showErrorToast(AppLocalizations.of(context).max_number_files_error);
      return;
    }

    final inputSize = int.tryParse(maxFileSizeController.text) ?? 0;
    final fileSizeInByte = maxFileSizeTypeNotifier.value.toByte(inputSize);
    final maxFileSizeConfig = _maxFileSizeSetting?.maxValue ?? 0;
    final maxFileSizeTypeConfig = _maxFileSizeSetting?.maxUnit.toFileSizeType() ?? FileSizeType.GB;
    if (fileSizeInByte <= 0 ||
        (inputSize >= maxFileSizeConfig && maxFileSizeTypeNotifier.value == maxFileSizeTypeConfig)) {
      _appToast.showErrorToast(AppLocalizations.of(context).max_file_size_error);
      return;
    }

    final totalSizeOfFiles = int.tryParse(totalFileSizeController.text) ?? 0;
    final totalSizeOfFilesInByte = totalFileSizeTypeNotifier.value.toByte(totalSizeOfFiles);
    final totalFileSizeConfig = _totalFileSizeSetting?.maxValue ?? 0;
    final totalFileSizeTypeConfig = _totalFileSizeSetting?.maxUnit.toFileSizeType() ?? FileSizeType.GB;
    if (totalSizeOfFilesInByte <= 0 ||
        (totalSizeOfFiles >= totalFileSizeConfig && maxFileSizeTypeNotifier.value == totalFileSizeTypeConfig)) {
      _appToast.showErrorToast(AppLocalizations.of(context).total_file_size_error);
      return;
    }

    // Once user change the time, prefer to get picked time.
    // Otherwise, passing null for server can handle by itself (temporary solution)
    var activateDate;
    if(textActivationNotifier.value?.value1.compareTo(_initActivationDateRoundUp) != 0) {
      activateDate = textActivationNotifier.value!.value1;
    }

    _editUploadRequestAction(
      arguments!.uploadRequestGroup.uploadRequestGroupId,
      maxFileCount: numberFiles,
      maxFileSize: fileSizeInByte,
      expirationDate: textExpirationNotifier.value?.value1 ?? _initExpirationDateRoundUp,
      emailSubject: emailSubjectController.text,
      emailMessage: emailMessageController.text,
      activationDate: activateDate,
      notificationDate: textReminderNotifier.value?.value1 ?? _initReminderDateRoundUp,
      maxDepositSize: totalSizeOfFilesInByte,
      canClose: allowClosureNotifier.value,
      canDelete: allowDeletionNotifier.value,
      enableNotification: _enableReminderNotificationSetting?.enable ?? true,
      locale: notificationLanguageNotifier.value.text);
  }

  void _editUploadRequestAction(
    UploadRequestGroupId groupId,
    {
      required int maxFileCount,
      required int maxFileSize,
      required DateTime expirationDate,
      required String emailSubject,
      required String emailMessage,
      required DateTime? activationDate,
      required DateTime notificationDate,
      required int maxDepositSize,
      required bool canDelete,
      required bool canClose,
      required String locale,
      required bool enableNotification
    }
  ) {
    final editUploadRequest = EditUploadRequest(
      activationDate,
      notificationDate,
      enableNotification,
      emailMessage,
      canClose,
      canDelete,
      expirationDate,
      emailSubject,
      locale,
      maxDepositSize,
      maxFileCount,
      maxFileSize);

    store.dispatch(_editUploadRequest(groupId, editUploadRequest));
  }

  OnlineThunkAction _editUploadRequest(UploadRequestGroupId groupId, EditUploadRequest editUploadRequest) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _editUploadRequestInteractor.execute(groupId, editUploadRequest).then((result) =>
        result.fold(
          (failure) => store.dispatch(EditUploadRequestAction(Left(failure))),
          (success) {
            backToUploadRequestGroup();
            return store.dispatch(EditUploadRequestAction(Right(success)));
          }));
    });
  }

  @override
  void onDisposed() {
    _disposeValueNotifier();
    super.onDisposed();
  }
}