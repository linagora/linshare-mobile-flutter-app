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
import 'package:flutter_tags/flutter_tags.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/view/avatar/label_avatar_builder.dart';

typedef OnSuggestionCallback = Function(String);
typedef OnSuggestionSelectedAction = Function(AutoCompleteResult);
typedef OnRemoveSelectedAction = Function(int);

class AddRecipientsInputFieldBuilder {

  final BuildContext context;

  TextEditingController? _addRecipientsFieldController;
  OnSuggestionCallback? _onSuggestionCallback;
  OnSuggestionSelectedAction? _onSuggestionSelectedAction;
  OnRemoveSelectedAction? _onRemoveSelectedAction;
  Stream<List<AutoCompleteResult>>? _streamListRecipients;

  AddRecipientsInputFieldBuilder(this.context);

  void addRecipientsFieldController(TextEditingController? addRecipientsFieldController) {
    _addRecipientsFieldController = addRecipientsFieldController;
  }

  void addOnSuggestionSelectedAction(OnSuggestionSelectedAction? onSuggestionSelectedAction) {
    _onSuggestionSelectedAction = onSuggestionSelectedAction;
  }

  void addOnSuggestionCallback(OnSuggestionCallback? onSuggestionCallback) {
    _onSuggestionCallback = onSuggestionCallback;
  }

  void addOnRemoveSelectedAction(OnRemoveSelectedAction? onRemoveSelectedAction) {
    _onRemoveSelectedAction = onRemoveSelectedAction;
  }

  void addStreamListRecipients(Stream<List<AutoCompleteResult>>? streamListRecipients) {
    _streamListRecipients = streamListRecipients;
  }

  Widget build() {
    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Row(children: [
            Text(
              AppLocalizations.of(context).add_recipients,
              style: TextStyle(fontSize: 16.0, color: AppColor.uploadRequestTitleTextColor)),
            Container(
              margin: EdgeInsets.only(left: 4.0),
              child: Text('*', style: TextStyle(color: AppColor.uploadRequestTitleRequiredTextColor)))
          ])),
        SizedBox(height: 16.0),
        TypeAheadFormField<AutoCompleteResult>(
          textFieldConfiguration: TextFieldConfiguration(
            controller: _addRecipientsFieldController,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 15),
              hintText: AppLocalizations.of(context).add_people,
              hintStyle: TextStyle(color: AppColor.uploadRequestHintTextColor, fontSize: 16.0),
              prefixIcon: Icon(Icons.person_add, size: 24.0))),
          debounceDuration: Duration(milliseconds: 300),
          suggestionsCallback: (pattern) async {
            if (pattern.length >= 3 && _onSuggestionCallback != null) {
              return await _onSuggestionCallback!(pattern);
            }
            return <AutoCompleteResult>[];
          },
          itemBuilder: (context, AutoCompleteResult autoCompleteResult) {
            return ListTile(
              leading: LabelAvatarBuilder(autoCompleteResult.getSuggestionDisplayName().characters.first.toUpperCase())
                .key(Key('label_avatar'))
                .build(),
              title: Text(
                autoCompleteResult.getSuggestionDisplayName(),
                style: TextStyle(fontSize: 14.0, color: AppColor.userTagTextColor)),
              subtitle: Text(
                autoCompleteResult.getSuggestionMail(),
                style: TextStyle(fontSize: 14.0, color: AppColor.userTagRemoveButtonBackgroundColor)),
            );
          },
          onSuggestionSelected: (autoCompleteResult) {
            _addRecipientsFieldController?.clear();
            if (_onSuggestionSelectedAction != null) {
              _onSuggestionSelectedAction!(autoCompleteResult);
            }
          },
          hideOnEmpty: true,
          hideOnLoading: true),
        SizedBox(height: 16.0),
        _buildTagList()
      ],
    );
  }

  Widget _buildTagList() {
    return StreamBuilder(
      stream: _streamListRecipients,
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
                image: ItemTagsImage(child: LabelAvatarBuilder(snapshot.data?[index]
                      .getSuggestionDisplayName().characters.first.toUpperCase() ?? '')
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
                    if (_onRemoveSelectedAction != null) {
                      _onRemoveSelectedAction!(index);
                    }
                    return true;
                  }),
              );
            },
          ),
        );
      });
  }
}