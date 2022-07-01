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
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/model/file_size_type.dart';
import 'package:linshare_flutter_app/presentation/model/notification_language.dart';
import 'package:linshare_flutter_app/presentation/model/unit_time_type.dart';
import 'package:linshare_flutter_app/presentation/model/upload_request_presentation.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_request_creation_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_request_group_action.dart';
import 'package:linshare_flutter_app/presentation/redux/online_thunk_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/saas/saas_utils.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/app_toast.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/datetime_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/list_functionalities_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/string_extensions.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/util/value_notifier_common.dart';
import 'package:linshare_flutter_app/presentation/view/modal_sheets/modal_card.dart';
import 'package:linshare_flutter_app/presentation/view/modal_sheets/reach_limitation_alert.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/upload_file_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_creation/upload_request_creation_arguments.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:redux/src/store.dart';
import 'package:rxdart/rxdart.dart';

class UploadRequestCreationViewModel extends BaseViewModel {

  final AppNavigation _appNavigation;

  // main stuff
  final AddNewUploadRequestInteractor _addNewUploadRequestInteractor;
  final GetAllUploadRequestGroupsInteractor _getAllUploadRequestGroupsInteractor;
  final AppToast _appToast;
  final FToast _fToast;
  final AppImagePaths _imagePaths;

  // auto complete
  final GetAutoCompleteSharingInteractor _getAutoCompleteSharingInteractor;
  final GetAutoCompleteSharingWithDeviceContactInteractor _getAutoCompleteSharingWithDeviceContactInteractor;
  late StreamSubscription _autoCompleteResultListSubscription;
  ContactSuggestionSource _contactSuggestionSource = ContactSuggestionSource.linShareContact;

  final BehaviorSubject<bool> _enableCreateButton = BehaviorSubject.seeded(false);
  StreamView<bool> get enableCreateButton => _enableCreateButton;

  final BehaviorSubject<List<AutoCompleteResult>> _autoCompleteResultListObservable = BehaviorSubject.seeded([]);
  StreamView<List<AutoCompleteResult>> get autoCompleteResultListObservable => _autoCompleteResultListObservable;
  
  final BehaviorSubject<String> _emailSubjectObservable = BehaviorSubject.seeded('');
  StreamView<String> get emailSubjectObservable => _emailSubjectObservable;

  final TextEditingController recipientsController = TextEditingController();
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
  final ValueNotifier<bool> passwordProtectNotifier = ValueNotifier<bool>(false);
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
  FunctionalityBoolean? _canCloseSetting;
  FunctionalityBoolean? _canDeleteSetting;
  FunctionalityBoolean? _protectPasswordSetting;
  FunctionalitySimple? _enableReminderNotificationSetting;
  FunctionalityLanguage? _notificationLanguageSetting;

  UploadRequestCreationArguments? arguments;

  UploadRequestCreationViewModel(
    Store<AppState> store,
    this._appNavigation,
    this._addNewUploadRequestInteractor,
    this._getAllUploadRequestGroupsInteractor,
    this._getAutoCompleteSharingInteractor,
    this._getAutoCompleteSharingWithDeviceContactInteractor,
    this._appToast,
    this._fToast,
    this._imagePaths
  ) : super(store) {
    _autoCompleteResultListSubscription = Rx.combineLatest2(_autoCompleteResultListObservable, _emailSubjectObservable, (List<AutoCompleteResult> shareMails, String emailSubject) {
      return (shareMails.isNotEmpty && emailSubject.isNotEmpty);
    }).listen((event) {
      event ? _enableCreateButton.add(true) : _enableCreateButton.add(false);
    });

    Future.delayed(Duration(milliseconds: 500), () => _checkContactPermission());
  }

  void _disposeValueNotifier() {
    recipientsController.clear();
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
    passwordProtectNotifier.dispose();
    allowDeletionNotifier.dispose();
    allowClosureNotifier.dispose();
  }

  void initialize(UploadRequestCreationArguments? creationArguments) {
    arguments = creationArguments;
    _getFunctionalityData();

    _getRoundUpDate();
    _getActivationDate(isInitialize: true);
    _getExpirationDate();
    _getReminderDate();

    _initDefaultData();

    final uploadRequestCreation = _generateUploadRequestCreation();
    store.dispatch(UpdateUploadRequestCreationAction(uploadRequestCreation));
  }

  void _getFunctionalityData() {
    final listFunctionalities = arguments?.uploadRequestFunctionalities ?? [];
    if (listFunctionalities.isNotEmpty) {
      _activationSetting = listFunctionalities.findFunctionality(FunctionalityIdentifier.UPLOAD_REQUEST__DELAY_BEFORE_ACTIVATION) as FunctionalityTime?;
      _expirationSetting = listFunctionalities.findFunctionality(FunctionalityIdentifier.UPLOAD_REQUEST__DELAY_BEFORE_EXPIRATION) as FunctionalityTime?;
      _notificationSetting = listFunctionalities.findFunctionality(FunctionalityIdentifier.UPLOAD_REQUEST__DELAY_BEFORE_NOTIFICATION) as FunctionalityTime?;
      _totalFileSizeSetting = listFunctionalities.findFunctionality(FunctionalityIdentifier.UPLOAD_REQUEST__MAXIMUM_DEPOSIT_SIZE) as FunctionalitySize?;
      _maxFileCountSetting = listFunctionalities.findFunctionality(FunctionalityIdentifier.UPLOAD_REQUEST__MAXIMUM_FILE_COUNT) as FunctionalityInteger?;
      _maxFileSizeSetting = listFunctionalities.findFunctionality(FunctionalityIdentifier.UPLOAD_REQUEST__MAXIMUM_FILE_SIZE) as FunctionalitySize?;
      _canCloseSetting = listFunctionalities.findFunctionality(FunctionalityIdentifier.UPLOAD_REQUEST__CAN_CLOSE) as FunctionalityBoolean?;
      _canDeleteSetting = listFunctionalities.findFunctionality(FunctionalityIdentifier.UPLOAD_REQUEST__CAN_DELETE) as FunctionalityBoolean?;
      _protectPasswordSetting = listFunctionalities.findFunctionality(FunctionalityIdentifier.UPLOAD_REQUEST__PROTECTED_BY_PASSWORD) as FunctionalityBoolean?;
      _enableReminderNotificationSetting = listFunctionalities.findFunctionality(FunctionalityIdentifier.UPLOAD_REQUEST__REMINDER_NOTIFICATION) as FunctionalitySimple?;
      _notificationLanguageSetting = listFunctionalities.findFunctionality(FunctionalityIdentifier.UPLOAD_REQUEST__NOTIFICATION_LANGUAGE) as FunctionalityLanguage?;
    }
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
    if(isInitialize) {
      textActivationNotifier.value = Tuple2(_initActivationDateRoundUp, _initActivationDateRoundUp.getYMMMMdFormatWithJm());
    }
  }

  void _getExpirationDate() {
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
    textExpirationNotifier.value = Tuple2(_initExpirationDateRoundUp, _initExpirationDateRoundUp.getYMMMMdFormatWithJm());
  }

  void _getReminderDate() {
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
    if(_minReminderDateRoundUp.compareTo(textActivationNotifier.value!.value1) < 0) {
      _minReminderDateRoundUp = textActivationNotifier.value!.value1;
    }
    if(_initReminderDateRoundUp.compareTo(textActivationNotifier.value!.value1) < 0) {
      _initReminderDateRoundUp = textActivationNotifier.value!.value1;
    }
    textReminderNotifier.value = Tuple2(_initReminderDateRoundUp, _initReminderDateRoundUp.getYMMMMdFormatWithJm());
  }

  void _initDefaultData() {
    maxFileSizeTypeNotifier.value = _maxFileSizeSetting?.unit.toFileSizeType() ?? FileSizeType.MB;
    totalFileSizeTypeNotifier.value = _totalFileSizeSetting?.unit.toFileSizeType() ?? FileSizeType.MB;
    notificationLanguageNotifier.value = _notificationLanguageSetting?.value.toNotificationLanguage() ?? NotificationLanguage.ENGLISH;

    maxNumberFilesController.text = _maxFileCountSetting?.value.toString() ?? '10';
    maxFileSizeController.text = _maxFileSizeSetting?.value.toString() ?? '10';
    totalFileSizeController.text = _totalFileSizeSetting?.value.toString() ?? '500';

    passwordProtectNotifier.value = _protectPasswordSetting?.value ?? false;
    allowDeletionNotifier.value = _canDeleteSetting?.value ?? true;
    allowClosureNotifier.value = _canCloseSetting?.value ?? true;
  }

  UploadRequestPresentation _generateUploadRequestCreation() {
    final _listMaxFileSizeType = _maxFileSizeSetting?.units.map((unit) =>
        unit.toFileSizeType()).toList() ?? FileSizeType.values;
    final _listTotalFileSizeType = _totalFileSizeSetting?.units.map((unit) =>
        unit.toFileSizeType()).toList() ?? FileSizeType.values;
    final _listNotificationLanguages = _notificationLanguageSetting?.units.map((unit) =>
        unit.toNotificationLanguage()).toList() ?? NotificationLanguage.values;

    final uploadRequestCreation = UploadRequestPresentation(
      listMaxFileSizeType: _listMaxFileSizeType,
      listTotalFileSizeType: _listTotalFileSizeType,
      listNotificationLanguages: _listNotificationLanguages,
      activationSetting: _activationSetting,
      expirationSetting: _expirationSetting,
      notificationSetting: _notificationSetting,
      totalFileSizeSetting: _totalFileSizeSetting,
      maxFileCountSetting: _maxFileCountSetting,
      maxFileSizeSetting: _maxFileSizeSetting,
      canCloseSetting: _canCloseSetting,
      canDeleteSetting: _canDeleteSetting,
      protectPasswordSetting: _protectPasswordSetting,
      enableReminderNotificationSetting: _enableReminderNotificationSetting,
      notificationLanguageSetting: _notificationLanguageSetting,
    );

    return uploadRequestCreation;
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
        _getExpirationDate();
        _getReminderDate();
      },
      currentTime: textActivationNotifier.value?.value1);
  }

  void showDateTimeExpirationAction(BuildContext context) {
    _getRoundUpDate();
    DatePicker.showDateTimePicker(context,
      showTitleActions: true,
      minTime: textActivationNotifier.value!.value1,
      maxTime: _maxExpirationDateRoundUp,
      onConfirm: (date) {
        textExpirationNotifier.value = Tuple2(date, date.getYMMMMdFormatWithJm());
        _getReminderDate();
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
    var numberFiles;
    if (_maxFileCountSetting != null) {
      numberFiles = int.tryParse(maxNumberFilesController.text) ?? 0;
      final maxFilesConfig = _maxFileCountSetting!.maxValue;
      if (numberFiles <= 0 || numberFiles >= maxFilesConfig) {
        _appToast.showErrorToast(AppLocalizations.of(context).max_number_files_error);
        return;
      }
    }

    var fileSizeInByte;
    if (_maxFileSizeSetting != null) {
      final inputSize = int.tryParse(maxFileSizeController.text) ?? 0;
      fileSizeInByte = maxFileSizeTypeNotifier.value.toByte(inputSize);
      final maxFileSizeConfig = _maxFileSizeSetting!.maxValue;
      final maxFileSizeTypeConfig = _maxFileSizeSetting!.maxUnit.toFileSizeType();
      if (fileSizeInByte <= 0 ||
          (inputSize >= maxFileSizeConfig && maxFileSizeTypeNotifier.value == maxFileSizeTypeConfig)) {
        _appToast.showErrorToast(AppLocalizations.of(context).max_file_size_error);
        return;
      }
    }

    var totalSizeOfFilesInByte;
    if (_totalFileSizeSetting != null) {
      final totalSizeOfFiles = int.tryParse(totalFileSizeController.text) ?? 0;
      totalSizeOfFilesInByte = totalFileSizeTypeNotifier.value.toByte(totalSizeOfFiles);
      final totalFileSizeConfig = _totalFileSizeSetting!.maxValue;
      final totalFileSizeTypeConfig = _totalFileSizeSetting!.maxUnit.toFileSizeType();
      if (totalSizeOfFilesInByte <= 0 ||
          (totalSizeOfFiles >= totalFileSizeConfig && maxFileSizeTypeNotifier.value == totalFileSizeTypeConfig)) {
        _appToast.showErrorToast(AppLocalizations.of(context).total_file_size_error);
        return;
      }
    }

    // Once user change the time, prefer to get picked time.
    // Otherwise, passing null for server can handle by itself (temporary solution)
    var activateDate;
    if( _activationSetting != null && textActivationNotifier.value?.value1.compareTo(_initActivationDateRoundUp) != 0) {
      activateDate = textActivationNotifier.value!.value1;
    }
    final expirationDate = _expirationSetting != null ? textExpirationNotifier.value?.value1 ?? _initExpirationDateRoundUp : null;
    final notificationDate = _notificationSetting != null ? textReminderNotifier.value?.value1 ?? _initReminderDateRoundUp : null;
    final canClose = _canCloseSetting != null ? allowClosureNotifier.value : null;
    final canDelete = _canDeleteSetting != null ? allowDeletionNotifier.value : null;
    final protectedByPassword = _protectPasswordSetting != null ? passwordProtectNotifier.value : null;

    _createUploadRequestAction(
      context,
      arguments?.type ?? UploadRequestCreationType.COLLECTIVE,
      maxFileCount: numberFiles,
      maxFileSize: fileSizeInByte,
      expirationDate: expirationDate,
      emailMessage: emailMessageController.text,
      activationDate: activateDate,
      notificationDate: notificationDate,
      maxDepositSize: totalSizeOfFilesInByte,
      protectedByPassword: protectedByPassword,
      canClose: canClose,
      canDelete: canDelete,
      enableNotification: _enableReminderNotificationSetting?.enable ?? true,
      locale: notificationLanguageNotifier.value.text);
  }

  void _createUploadRequestAction(
    BuildContext context,
    UploadRequestCreationType creationType,
    {
      required int? maxFileCount,
      required int? maxFileSize,
      required DateTime? expirationDate,
      required String? emailMessage,
      required DateTime? activationDate,
      required DateTime? notificationDate,
      required int? maxDepositSize,
      required bool? canDelete,
      required bool? canClose,
      required String locale,
      required bool? protectedByPassword,
      required bool enableNotification
    }
  ) {
    final listEmails = _autoCompleteResultListObservable.value.map((e) => e.getSuggestionMail()).toList();
    final emailSubject = _emailSubjectObservable.value.toString();
    final addUploadRequest = AddUploadRequest(
        listEmails,
        emailSubject,
        emailMessage,
        activationDate,
        expirationDate,
        maxFileCount,
        maxFileSize,
        notificationDate,
        maxDepositSize,
        canDelete,
        canClose,
        locale,
        protectedByPassword,
        enableNotification);
    store.dispatch(_addNewUploadRequest(context, creationType, addUploadRequest));
  }

  OnlineThunkAction _addNewUploadRequest(BuildContext context, UploadRequestCreationType creationType, AddUploadRequest addUploadRequest) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _addNewUploadRequestInteractor.execute(creationType, addUploadRequest)
        .then((result) => result.fold(
          (failure) {
            if (failure is UploadRequestLimitFailure) {
              _showUploadRequestLimitationMessage(context, store);
            } else {
              store.dispatch(UploadRequestGroupAction(Left(failure)));
              backToUploadRequestGroup();
            }
          },
          (success) {
            store.dispatch(UploadRequestGroupAction(Right(success)));
            backToUploadRequestGroup();
          }));
    });
  }

  void updateEmailSubjectObservable(String newData) {
    _emailSubjectObservable.add(newData);
  }

  void addUserEmail(AutoCompleteResult autoCompleteResult) {
    final newAutoCompleteResultList = _autoCompleteResultListObservable.value;
    if (newAutoCompleteResultList != null) {
      newAutoCompleteResultList.add(autoCompleteResult);
      _autoCompleteResultListObservable.add(newAutoCompleteResultList);
    }
  }

  void removeUserEmail(int index) {
    final newAutoCompleteResultList = _autoCompleteResultListObservable.value;
    if (newAutoCompleteResultList != null) {
      newAutoCompleteResultList.removeAt(index);
      _autoCompleteResultListObservable.add(newAutoCompleteResultList);
    }
  }

  Future<List<AutoCompleteResult>> getAutoCompleteSharing(String pattern) async {
    if (_contactSuggestionSource == ContactSuggestionSource.all) {
      return await _getAutoCompleteSharingWithDeviceContactInteractor
          .execute(AutoCompletePattern(pattern), AutoCompleteType.SHARING)
          .then(
            (viewState) => viewState.fold(
              (failure) => <AutoCompleteResult>[],
              (success) => (success as AutoCompleteViewState).results,
        ),
      );
    }
    return await _getAutoCompleteSharingInteractor
        .execute(AutoCompletePattern(pattern), AutoCompleteType.SHARING)
        .then(
          (viewState) => viewState.fold(
            (failure) => <AutoCompleteResult>[],
            (success) => (success as AutoCompleteViewState).results,
      ),
    );
  }

  void _checkContactPermission() async {
    final permissionStatus = await Permission.contacts.status;
    if (permissionStatus.isGranted) {
      _contactSuggestionSource = ContactSuggestionSource.all;
    } else if (!permissionStatus.isPermanentlyDenied) {
      final requestedPermission = await Permission.contacts.request();
      _contactSuggestionSource = requestedPermission == PermissionStatus.granted
          ? ContactSuggestionSource.all
          : _contactSuggestionSource;
    }
  }

  @override
  void onDisposed() {
    _autoCompleteResultListSubscription.cancel();
    _disposeValueNotifier();
    super.onDisposed();
  }

  void _showUploadRequestLimitationMessage(BuildContext context, Store<AppState> store) {
    if (store.state.settingsState.appMode == AppMode.SaaS) {
      showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return ModalCardWidget(
              child: ReachLimitationAlert(
                AppLocalizations.of(context).failed_request,
                AppLocalizations.of(context).reach_upload_request_limit_message_saas,
                AppLocalizations.of(context).contact_now,
                _appNavigation,
                onContactNowPress: () => SaaSUtils.goToConsoleHomepage(_appNavigation, context),
              )
          );
        }
      );
    } else {
      _appToast.showToastWithIcon(
          context,
          _fToast,
          AppLocalizations.of(context).reach_upload_request_limit_message_own_server,
          _imagePaths.icWarningLimitationToast,
          duration: Duration(milliseconds: 1500)
      );
    }
  }
}