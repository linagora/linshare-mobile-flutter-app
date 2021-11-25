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
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/redux/states/add_recipients_upload_request_group_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/view/avatar/label_avatar_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_group_add_recipient/add_recipients_upload_request_group_arguments.dart';

import 'add_recipients_upload_request_group_viewmodel.dart';

class AddRecipientsUploadRequestGroupWidget extends StatefulWidget {
  AddRecipientsUploadRequestGroupWidget({Key? key}) : super(key: key);

  @override
  _AddSharedSpaceMemberWidgetState createState() => _AddSharedSpaceMemberWidgetState();
}

class _AddSharedSpaceMemberWidgetState extends State<AddRecipientsUploadRequestGroupWidget> {
  final _model = getIt<AddRecipientsUploadRequestGroupViewModel>();
  final imagePath = getIt<AppImagePaths>();
  final TextEditingController _typeAheadController = TextEditingController();
  final appNavigation = getIt<AppNavigation>();

  AddRecipientsUploadRequestGroupArgument? _arguments;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      _arguments = ModalRoute.of(context)?.settings.arguments as AddRecipientsUploadRequestGroupArgument;
      if (_arguments != null) {
        _model.initState(_arguments!);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _typeAheadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _arguments = ModalRoute.of(context)?.settings.arguments as AddRecipientsUploadRequestGroupArgument;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          key: Key('add_recipient_upload_request_group_arrow_back_button'),
          icon: Image.asset(imagePath.icArrowBack),
          onPressed: () => _model.backToUploadRequest(),
        ),
        centerTitle: true,
        title: Text(_arguments?.uploadRequestGroup.label ?? '',
            key: Key('add_recipient_upload_request_group_title'),
            style: TextStyle(fontSize: 24, color: Colors.white)),
        backgroundColor: AppColor.primaryColor,
      ),
      body: StoreConnector<AppState, AddRecipientsUploadRequestGroupState>(
          converter: (store) => store.state.addRecipientsUploadRequestGroupState,
          builder: (context, state) => _buildRecipientsWidget(
              context, state.currentRecipientsSet.toList(), state.newRecipientsSet.toList())),
      floatingActionButton: StoreConnector<AppState, List<GenericUser>>(
          converter: (store) =>
              store.state.addRecipientsUploadRequestGroupState.newRecipientsSet.toList(),
          builder: (context, recipientsList) {
            return IgnorePointer(
              ignoring: recipientsList.isEmpty,
              child: FloatingActionButton.extended(
                  key: Key('add_recipients_button'),
                  backgroundColor: recipientsList.isNotEmpty
                      ? AppColor.primaryColor
                      : AppColor.uploadButtonDisableBackgroundColor,
                  onPressed: () => _model.sendRecipientsList(
                      context,
                      _arguments!.destination,
                      _arguments!.tab,
                      _arguments!.uploadRequestGroup.uploadRequestGroupId,
                      recipientsList),
                  label: Text(
                    AppLocalizations.of(context).add,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                      fontStyle: FontStyle.normal,
                    ),
                  )),
            );
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildRecipientsWidget(BuildContext buildContext, List<GenericUser> currentRecipientsList,
      List<GenericUser> newRecipientsList) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              AppLocalizations.of(context).add_recipients,
              style: TextStyle(fontSize: 16.0, color: AppColor.uploadFileFileNameTextColor),
            ),
          ),
          SizedBox(
            height: 17.0,
          ),
          TypeAheadFormField(
              textFieldConfiguration: TextFieldConfiguration(
                  controller: _typeAheadController,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                      hintText: AppLocalizations.of(context).add_people,
                      hintStyle:
                          TextStyle(color: AppColor.uploadRequestHintTextColor, fontSize: 16.0),
                      prefixIcon: Icon(
                        Icons.person_add,
                        size: 24.0,
                      ))),
              debounceDuration: Duration(milliseconds: 300),
              suggestionsCallback: (pattern) async {
                if (pattern.length >= 3) {
                  return (await _model.getAutoCompleteSharing(pattern))
                      .where((autoComplete) => (!{...currentRecipientsList, ...newRecipientsList}
                          .map((recipient) => recipient.mail)
                          .contains(autoComplete.getSuggestionMail())))
                      .toList();
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
                      style: TextStyle(fontSize: 14.0, color: AppColor.userTagTextColor)),
                  subtitle: Text(autoCompleteResult.getSuggestionMail(),
                      style: TextStyle(
                          fontSize: 14.0, color: AppColor.userTagRemoveButtonBackgroundColor)),
                );
              },
              onSuggestionSelected: (autoCompleteResult) {
                _typeAheadController.text = '';
                _model.addRecipientToList(autoCompleteResult as AutoCompleteResult);
              },
              hideOnEmpty: true,
              hideOnLoading: true),
          SizedBox(
            height: 16.0,
          ),
          _buildTagList(context)
        ],
      ),
    );
  }

  Widget _buildTagList(BuildContext context) {
    return StoreConnector<AppState, List<GenericUser>>(
        converter: (store) =>
            store.state.addRecipientsUploadRequestGroupState.newRecipientsSet.toList(),
        builder: (context, recipientsList) {
          return Align(
            alignment: Alignment.topLeft,
            child: Tags(
              alignment: WrapAlignment.start,
              spacing: 10.0,
              itemCount: recipientsList.length,
              itemBuilder: (index) {
                return ItemTags(
                  index: index,
                  combine: ItemTagsCombine.withTextAfter,
                  title: recipientsList[index].mail,
                  image: ItemTagsImage(
                      child: LabelAvatarBuilder(
                              recipientsList[index].mail.characters.first.toUpperCase())
                          .key(Key('label_avatar'))
                          .build()),
                  pressEnabled: false,
                  activeColor: AppColor.userTagBackgroundColor,
                  textActiveColor: AppColor.userTagTextColor,
                  textStyle: TextStyle(fontSize: 16.0),
                  removeButton: ItemTagsRemoveButton(
                      color: Colors.white,
                      backgroundColor: AppColor.userTagRemoveButtonBackgroundColor,
                      onRemoved: () {
                        _model.removeRecipientFromList(recipientsList[index]);
                        return true;
                      }),
                );
              },
            ),
          );
        });
  }
}
