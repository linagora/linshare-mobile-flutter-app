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
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/functionality_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/media_type_extension.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/view/avatar/label_avatar_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/upload_file_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/upload_file_viewmodel.dart';
import 'package:redux/redux.dart';
import 'package:rxdart/rxdart.dart';

import 'upload_destination_type.dart';

class UploadFileWidget extends StatefulWidget {
  @override
  _UploadFileWidgetState createState() => _UploadFileWidgetState();
}

class _UploadFileWidgetState extends State<UploadFileWidget> {
  final uploadFileViewModel = getIt<UploadFileViewModel>();
  final imagePath = getIt<AppImagePaths>();
  final appNavigation = getIt<AppNavigation>();
  final TextEditingController _typeAheadController = TextEditingController();
  bool isHeaderExpanded = false;

  @override
  void initState() {
    super.initState();
    uploadFileViewModel.cancelSelection();
  }

  @override
  void dispose() {
    uploadFileViewModel.onDisposed();
    _typeAheadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UploadFileArguments arguments = ModalRoute.of(context).settings.arguments;
    uploadFileViewModel.setUploadFilesArgument(arguments.uploadFiles);
    uploadFileViewModel.setShareTypeArgument(arguments.shareType);
    uploadFileViewModel.setDocumentsArgument(arguments.documents);
    if (arguments.workGroupDocumentUploadInfo != null) {
      uploadFileViewModel.setWorkGroupDocumentUploadInfoArgument(arguments.workGroupDocumentUploadInfo);
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: Key('upload_file_arrow_back_button'),
          icon: Image.asset(imagePath.icArrowBack),
          onPressed: () => uploadFileViewModel.backToMySpace(),
        ),
        centerTitle: true,
        title: Text(
            uploadFileViewModel.shareTypeArgument == ShareType.quickShare
                ? AppLocalizations.of(context).title_quick_share
                : AppLocalizations.of(context).upload_file_title,
            key: Key('upload_file_title'),
            style: TextStyle(fontSize: 24, color: Colors.white)),
        backgroundColor: AppColor.primaryColor,
      ),
      body: Container(
        child: Column(
          children: [
            uploadFileViewModel.filesInfos.length > 1
                ? ExpansionPanelList(
                    elevation: 1,
                    expandedHeaderPadding: EdgeInsets.all(0),
                    expansionCallback: (int index, bool isExpanded) {
                      setState(() {
                        isHeaderExpanded = !isHeaderExpanded;
                      });
                    },
                    children: [
                        ExpansionPanel(
                            headerBuilder: (BuildContext context, bool isExpanded) {
                              return ListTile(
                                title: Text(
                                    AppLocalizations.of(context)
                                        .items_selected(uploadFileViewModel.filesInfos.length),
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: AppColor.multipleSelectionBarTextColor)),
                              );
                            },
                            body: Padding(
                              padding: const EdgeInsets.only(bottom: 11.0),
                              child: ConstrainedBox(
                                  constraints: BoxConstraints(maxHeight: 209),
                                  child: ListView.builder(
                                      padding: EdgeInsets.only(left: 16),
                                      shrinkWrap: true,
                                      itemExtent: 38,
                                      itemCount: uploadFileViewModel.filesInfos.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        final fileInfo = uploadFileViewModel.filesInfos[index];
                                        return ListTile(
                                            dense: true,
                                            visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                                            leading: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                SvgPicture.asset(
                                                  fileInfo.mediaType
                                                      .getFileTypeImagePath(
                                                          imagePath),
                                                  width: 20,
                                                  height: 24,
                                                  fit: BoxFit.fill,
                                                ),
                                              ],
                                            ),
                                            title: Transform(
                                              transform: Matrix4.translationValues(-20, 0.0, 0.0),
                                              child: Text(fileInfo.fileName,
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: AppColor.multipleSelectionBarTextColor)),
                                            ),
                                            trailing: Text(
                                              '${filesize(fileInfo.fileSize)}',
                                              key: Key('upload_file_size'),
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: AppColor.uploadFileFileSizeTextColor),
                                            ));
                                      })),
                            ),
                            isExpanded: isHeaderExpanded),
                      ])
                : SizedBox(
                    width: double.maxFinite,
                    height: 56,
                    child: ListTile(
                        dense: true,
                        visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                        leading: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              uploadFileViewModel.filesInfos[0].mediaType.getFileTypeImagePath(imagePath),
                              width: 20,
                              height: 24,
                              fit: BoxFit.fill,
                            ),
                          ],
                        ),
                        title: Transform(
                          transform: Matrix4.translationValues(-20, 0.0, 0.0),
                          child: Text(uploadFileViewModel.filesInfos[0].fileName,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColor.multipleSelectionBarTextColor)),
                        ),
                        trailing: Text(
                          '${filesize(uploadFileViewModel.filesInfos[0].fileSize)}',
                          key: Key('upload_file_size'),
                          style: TextStyle(
                              fontSize: 14,
                              color: AppColor.uploadFileFileSizeTextColor),
                        )
                    )
                  ),
            StreamBuilder<UploadDestinationType>(
              stream: uploadFileViewModel.uploadDestinationTypeObservable,
              builder: (_, snapshot) {
                if (arguments.shareType == ShareType.none) {
                  return _buildWorkGroupUploadDestination(
                      context,
                      arguments.workGroupDocumentUploadInfo.isRootNode()
                          ? arguments.workGroupDocumentUploadInfo.sharedSpaceNodeNested.name
                          : arguments.workGroupDocumentUploadInfo.currentNode.name);
                } else if (arguments.shareType == ShareType.uploadFromOutside) {
                  return _buildUploadDestinationPicker();
                }
                return SizedBox.shrink();
              },
            ),
            StreamBuilder<UploadDestinationType>(
              stream: uploadFileViewModel.uploadDestinationTypeObservable,
              builder: (_, snapshot) {
                if (arguments.shareType != ShareType.none && snapshot.data == UploadDestinationType.mySpace) {
                  return _buildShareWidget(context);
                }
                return SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
      floatingActionButton: StreamBuilder(
        stream: uploadFileViewModel.enableUploadAndShareButton,
        initialData: true,
        builder: (context, AsyncSnapshot<bool> snapshot) {
          return IgnorePointer(
            ignoring: !snapshot.data,
            child: FloatingActionButton.extended(
                key: Key('upload_file_confirm_button'),
                backgroundColor: snapshot.data
                    ? AppColor.primaryColor
                    : AppColor.uploadButtonDisableBackgroundColor,
                onPressed: () =>
                    uploadFileViewModel.handleOnUploadAndSharePressed(),
                label: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: _buildUploadAndShareButton(
                    uploadFileViewModel.shareTypeArgument,
                    uploadFileViewModel.uploadAndShareButtonType,
                  ),
                )),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildUploadDestinationPicker() {
    return StoreConnector<AppState, FunctionalityState>(
      converter: (Store<AppState> store) => store.state.functionalityState,
      distinct: true,
      builder: (context, state) {
        if (state.isSharedSpaceEnable()) {
          return GestureDetector(
            onTap: () => uploadFileViewModel.onPickUploadDestinationPressed(context),
            child: _buildUploadDestinationPickerRow(),
          );
        }
        return _buildUploadDestinationPickerRow();
      }
    );
  }

  Widget _buildUploadDestinationPickerRow() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
      child: Column(
        children: [
          Align(
              alignment: AlignmentDirectional.topStart,
              child: Text(
                AppLocalizations.of(context).pick_the_destination,
                style: TextStyle(
                    fontSize: 16.0, color: AppColor.uploadFileFileNameTextColor),
              )),
          SizedBox(height: 16.0,),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 1.0, right: 8.0),
                child: SvgPicture.asset(
                    uploadFileViewModel.uploadDestinationTypeObservable.value == UploadDestinationType.mySpace
                        ? imagePath.icHome
                        : imagePath.icSharedSpace,
                    width: 20,
                    height: 20,
                    fit: BoxFit.fill),
              ),
              Expanded(
                child: StreamBuilder<UploadDestinationType>(
                  stream: uploadFileViewModel.uploadDestinationTypeObservable,
                  builder: (_, snapshot) {
                    if (snapshot.data == UploadDestinationType.workGroup) {
                      return _buildUploadDestinationSelectedName(
                          uploadFileViewModel.workGroupDocumentUploadInfoArgument.isRootNode()
                              ? uploadFileViewModel.workGroupDocumentUploadInfoArgument.sharedSpaceNodeNested.name
                              : uploadFileViewModel.workGroupDocumentUploadInfoArgument.currentNode.name);
                    }
                    return _buildUploadDestinationSelectedName(AppLocalizations.of(context).my_space_title);
                  },
                ),
              ),
              StoreConnector<AppState, FunctionalityState>(
                  converter: (Store<AppState> store) => store.state.functionalityState,
                  distinct: true,
                  builder: (context, state) {
                    if (state.isSharedSpaceEnable()) {
                      return SvgPicture.asset(imagePath.icArrowRight,
                          width: 18, height: 18, fit: BoxFit.fill);
                    }
                    return SizedBox.shrink();
                  }
              )
            ],
          ),
          SizedBox(height: 6.0,),
          Divider(
            height: 1.0,
            color: AppColor.uploadLineDividerWorkGroupDestination,
          )
        ],
      ),
    );
  }

  Widget _buildUploadDestinationSelectedName(String name) {
    return Text(name,
      maxLines: 1,
      style: TextStyle(
          fontSize: 16.0, color: AppColor.uploadFileFileSizeTextColor),
    );
  }

  Widget _buildUploadAndShareButton(
    ShareType shareType,
    BehaviorSubject<ShareButtonType> buttonTypeStream,
  ) {
    final style = TextStyle(
      fontSize: 16,
      color: Colors.white,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
    );

    if (shareType == ShareType.quickShare) {
      return Text(
        AppLocalizations.of(context).share,
        style: style,
      );
    } else if (shareType == ShareType.uploadFromOutside) {
      return StreamBuilder<UploadDestinationType>(
        stream: uploadFileViewModel.uploadDestinationTypeObservable,
        builder: (_, snapshot) {
          var buttonText;
          if (snapshot.data == UploadDestinationType.mySpace) {
            buttonText = AppLocalizations.of(context).upload_text_button;
          } else {
            buttonText = AppLocalizations.of(context).upload_to_workspace;
          }
          return Text(
            buttonText,
            style: style,
          );
        },
      );
    } else {
      return StreamBuilder<ShareButtonType>(
        stream: buttonTypeStream,
        builder: (_, snapshot) {
          var buttonText;
          if (snapshot.data == ShareButtonType.justUpload) {
            buttonText = AppLocalizations.of(context).upload_text_button;
          } else if (snapshot.data == ShareButtonType.uploadAndShare) {
            buttonText = AppLocalizations.of(context).upload_and_share_button;
          } else {
            buttonText = AppLocalizations.of(context).upload_to_workspace;
          }
          return Text(
            buttonText,
            style: style,
          );
        },
      );
    }
  }

  Widget _buildWorkGroupUploadDestination(
      BuildContext context, String workGroupName) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
      child: Column(
        children: [
          Align(
              alignment: AlignmentDirectional.topStart,
              child: Text(
                AppLocalizations.of(context).destination,
                style: TextStyle(
                    fontSize: 16.0, color: AppColor.uploadFileFileNameTextColor),
              )),
          SizedBox(height: 16.0,),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 1.0, right: 8.0),
                child: SvgPicture.asset(imagePath.icSharedSpaceDisable,
                    width: 20, height: 20, fit: BoxFit.fill),
              ),
              Text(
                workGroupName,
                maxLines: 1,
                style: TextStyle(
                    fontSize: 16.0, color: AppColor.uploadFileFileSizeTextColor),
              ),
            ],
          ),
          SizedBox(height: 6.0,),
          Divider(
            height: 1.0,
            color: AppColor.uploadLineDividerWorkGroupDestination,
          )
        ],
      ),
    );
  }

  Widget _buildShareWidget(BuildContext buildContext) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              AppLocalizations.of(context).add_recipients,
              style: TextStyle(
                  fontSize: 16.0, color: AppColor.uploadFileFileNameTextColor),
            ),
          ),
          SizedBox(
            height: 14.0,
          ),
          TypeAheadFormField(
              textFieldConfiguration: TextFieldConfiguration(
                  controller: _typeAheadController,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                      hintText: AppLocalizations.of(context).add_people,
                      hintStyle: TextStyle(
                          color: AppColor.uploadFileFileSizeTextColor,
                          fontSize: 16.0),
                      prefixIcon: Icon(
                        Icons.person_add,
                        size: 24.0,
                      ))),
              debounceDuration: Duration(milliseconds: 300),
              suggestionsCallback: (pattern) async {
                if (pattern.length >= 3) {
                  return await uploadFileViewModel
                      .getAutoCompleteSharing(pattern);
                }
                return null;
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
                uploadFileViewModel.addUserEmail(autoCompleteResult);
              },
              noItemsFoundBuilder: (context) => Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      AppLocalizations.of(context).unknown_user,
                      style: TextStyle(
                          fontSize: 14.0,
                          color: AppColor.toastErrorBackgroundColor),
                    ),
                  )),
          SizedBox(
            height: 16.0,
          ),
          _buildTagList(context)
        ],
      ),
    );
  }

  Widget _buildTagList(BuildContext context) {
    return StreamBuilder(
        stream: uploadFileViewModel.autoCompleteResultListObservable,
        initialData: <AutoCompleteResult>[],
        builder: (context, AsyncSnapshot<List<AutoCompleteResult>> snapshot) {
          return Align(
            alignment: Alignment.topLeft,
            child: Tags(
              alignment: WrapAlignment.start,
              spacing: 10.0,
              itemCount: snapshot.data.length,
              itemBuilder: (index) {
                return ItemTags(
                  index: index,
                  combine: ItemTagsCombine.withTextAfter,
                  title: snapshot.data[index].getSuggestionDisplayName(),
                  image: ItemTagsImage(
                      child: LabelAvatarBuilder(snapshot.data[index]
                              .getSuggestionDisplayName()
                              .characters
                              .first
                              .toUpperCase())
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
                        uploadFileViewModel.removeUserEmail(index);
                        return true;
                      }),
                );
              },
            ),
          );
        });
  }
}
