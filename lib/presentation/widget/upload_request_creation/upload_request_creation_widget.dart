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
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/app_toast.dart';
import 'package:linshare_flutter_app/presentation/util/constant.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/styles.dart';
import 'package:linshare_flutter_app/presentation/view/avatar/label_avatar_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_creation/upload_request_creation_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_creation/upload_request_creation_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/datetime_extension.dart';

class DateTimeTextValueNotifier extends ValueNotifier<dartz.Tuple2<DateTime, String>?> {
  DateTimeTextValueNotifier() : super(null);
}

class FileSizeValueNotifier extends ValueNotifier<FileSizeType> {
  FileSizeValueNotifier() : super(FileSizeType.GB);
}

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
  final TextEditingController _typeAheadController = TextEditingController();
  final TextEditingController _emailSubjectController = TextEditingController();
  final TextEditingController _emailMessageController = TextEditingController();
  final TextEditingController _maxNumberFilesController = TextEditingController();
  final TextEditingController _maxFileSizeController = TextEditingController();
  final DateTimeTextValueNotifier _textActivationNotifier = DateTimeTextValueNotifier();
  final DateTimeTextValueNotifier _textExpirationNotifier = DateTimeTextValueNotifier();
  final FileSizeValueNotifier _maxFileSizeTypeNotifier = FileSizeValueNotifier();
  late DateTime _initActivationDateRoundUp;
  late DateTime _initExpirationDateRoundUp;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _arguments = ModalRoute.of(context)?.settings.arguments as UploadRequestCreationArguments;
    });
    _initDisplayData();
  }

  void _initDisplayData() {
    _getRoundUpDate();

    _textActivationNotifier.value =
        dartz.Tuple2(_initActivationDateRoundUp, _initActivationDateRoundUp.getYMMMMdFormatWithJm());
    _textExpirationNotifier.value =
        dartz.Tuple2(_initExpirationDateRoundUp, _initExpirationDateRoundUp.getYMMMMdFormatWithJm());

    _maxNumberFilesController.text = Constant.MAX_NUMBER_FILES_INIT.toString();
    _maxFileSizeController.text = Constant.MAX_FILE_SIZE_INIT.toString();
    _maxFileSizeTypeNotifier.value = FileSizeType.GB;
  }

  void _getRoundUpDate() {
    _initActivationDateRoundUp = DateTime.now().roundUpHour(1);
    _initExpirationDateRoundUp = DateTime.now().roundUpHour(1).add(Duration(days: Constant.EXPIRATION_DATE_INIT));
  }

  @override
  void dispose() {
    _textActivationNotifier.dispose();
    _textExpirationNotifier.dispose();
    _maxFileSizeTypeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              onTap: () {},
              child: Text(AppLocalizations.of(context).advanced_options,
                style: TextStyle(fontSize: 15.0, color: AppColor.uploadRequestTextClickableColor)),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 24),
          child: Column(
            children: [
              _buildActivationDateWidget(),
              _buildExpirationDateWidget(),
              _buildMaxFilesWidget(),
              _buildFileSizeWidget(),
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
          DatePicker.showDateTimePicker(context,
              showTitleActions: true,
              minTime: _initActivationDateRoundUp,
              maxTime: _initActivationDateRoundUp.add(Duration(days: Constant.ACTIVATION_DATE_MAX)),
              onChanged: (date) {
              }, onConfirm: (date) {
                _textActivationNotifier.value = dartz.Tuple2(date, date.getYMMMMdFormatWithJm());
              },
              currentTime: _textActivationNotifier.value?.value1,
              locale: LocaleType.en);
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
                minTime: _initExpirationDateRoundUp.subtract(Duration(days: Constant.EXPIRATION_DATE_MIN)),
                maxTime: _initExpirationDateRoundUp.add(Duration(days: Constant.EXPIRATION_DATE_MAX)),
                onChanged: (date) {
                }, onConfirm: (date) {
                  _textExpirationNotifier.value = dartz.Tuple2(date, date.getYMMMMdFormatWithJm());
                },
                currentTime: _textExpirationNotifier.value?.value1,
                locale: LocaleType.en);
          },
          child: ValueListenableBuilder(
              valueListenable: _textExpirationNotifier,
              builder: (BuildContext context, dartz.Tuple2? value, Widget? child) =>
                  Text(value?.value2 ?? '', style: CommonTextStyle.textStyleUploadRequestSettingsValue)),
        ),
      ],
    ),
  );

  Widget _buildMaxFilesWidget() => Container(
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

  Widget _buildFileSizeWidget() => Container(
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
                    items: <FileSizeType>[FileSizeType.KB, FileSizeType.MB, FileSizeType.GB].map((FileSizeType value) {
                      return DropdownMenuItem<FileSizeType>(
                        value: value,
                        child: Text(value.text),
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

  Widget _buildSettingAdvance() => Container(
    margin: EdgeInsets.only(top: 40.0),
    child: Column(
      children: [

      ],
    ),
  );

  void _validateFormData() {
    final numberFiles = int.tryParse(_maxNumberFilesController.text) ?? 0;
    if (numberFiles <= 0 || numberFiles >= Constant.MAX_NUMBER_FILES_LIMIT) {
      _appToast.showErrorToast(AppLocalizations.of(context).max_number_files_error);
      return;
    }

    final inputSize = int.tryParse(_maxFileSizeController.text) ?? 0;
    final fileSizeInByte = _maxFileSizeTypeNotifier.value.toByte(inputSize);
    if (fileSizeInByte <= 0 ||
        (inputSize >= Constant.MAX_FILE_SIZE_LIMIT && _maxFileSizeTypeNotifier.value == FileSizeType.GB)) {
      _appToast.showErrorToast(AppLocalizations.of(context).max_file_size_error);
      return;
    }

    // Note:
    // Once user change the time, prefer to get picked time.
    // Otherwise, get the exactly current time (not rounded time)
    var activateDate;
    if(_textActivationNotifier.value?.value1.compareTo(_initActivationDateRoundUp) != 0) {
      activateDate = _textActivationNotifier.value!.value1;
    }

    _model.performCreateUploadRequest(
        _arguments?.type ?? UploadRequestCreationType.COLLECTIVE,
        numberFiles,
        fileSizeInByte,
        _textExpirationNotifier.value?.value1 ?? _initExpirationDateRoundUp,
        emailMessage: _emailMessageController.text,
        activationDate: activateDate
    );
  }

}
