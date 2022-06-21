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

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/manager/upload_and_share_file/upload_and_share_file_manager.dart';
import 'package:linshare_flutter_app/presentation/model/file/selected_presentation_file.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/my_space_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_file_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/media_type_extension.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/util/router/route_paths.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/destination_picker/destination_picker_action/choose_destination_picker_action.dart';
import 'package:linshare_flutter_app/presentation/widget/destination_picker/destination_picker_action/negative_destination_picker_action.dart';
import 'package:linshare_flutter_app/presentation/widget/destination_picker/destination_picker_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_document_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/destination_type.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/upload_file_arguments.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:rxdart/rxdart.dart';

enum ContactSuggestionSource {
  all, linShareContact, deviceContact
}

class UploadFileViewModel extends BaseViewModel {
  final AppNavigation _appNavigation;
  final UploadShareFileManager _uploadShareFileManager;
  final GetAutoCompleteSharingInteractor _getAutoCompleteSharingInteractor;
  final GetAutoCompleteSharingWithDeviceContactInteractor _getAutoCompleteSharingWithDeviceContactInteractor;
  late StreamSubscription _autoCompleteResultListSubscription;
  ContactSuggestionSource _contactSuggestionSource = ContactSuggestionSource.linShareContact;

  List<FileInfo>? _uploadFilesArgument;

  ShareType _shareTypeArgument = ShareType.uploadAndShare;
  ShareType get shareTypeArgument => _shareTypeArgument;

  ShareDestination? _shareDestination;
  List<Document>? _documentsArgument;
  WorkGroupDocumentUploadInfo? _workGroupDocumentUploadInfoArgument;
  WorkGroupDocumentUploadInfo? get workGroupDocumentUploadInfoArgument => _workGroupDocumentUploadInfoArgument;

  final BehaviorSubject<List<AutoCompleteResult>> _autoCompleteResultListObservable = BehaviorSubject.seeded([]);
  StreamView<List<AutoCompleteResult>> get autoCompleteResultListObservable => _autoCompleteResultListObservable;

  final BehaviorSubject<bool> _enableUploadAndShareButton = BehaviorSubject.seeded(true);
  StreamView<bool> get enableUploadAndShareButton => _enableUploadAndShareButton;

  final BehaviorSubject<ShareButtonType> _uploadAndShareButtonType = BehaviorSubject.seeded(ShareButtonType.justUpload);
  StreamView<ShareButtonType> get uploadAndShareButtonType => _uploadAndShareButtonType;

  final BehaviorSubject<DestinationType> _uploadDestinationTypeObservable = BehaviorSubject.seeded(DestinationType.mySpace);
  BehaviorSubject<DestinationType> get uploadDestinationTypeObservable => _uploadDestinationTypeObservable;

  UploadFileViewModel(
    Store<AppState> store,
    this._appNavigation,
    this._uploadShareFileManager,
    this._getAutoCompleteSharingInteractor,
    this._getAutoCompleteSharingWithDeviceContactInteractor,
  ) : super(store) {
    _autoCompleteResultListSubscription = _autoCompleteResultListObservable.listen((shareMails) {
      switch (_shareTypeArgument) {
        case ShareType.quickShare:
          shareMails.isEmpty
              ? _enableUploadAndShareButton.add(false)
              : _enableUploadAndShareButton.add(true);
          break;
        case ShareType.uploadAndShare:
          final shareButtonType = shareMails.isEmpty
              ? ShareButtonType.justUpload
              : ShareButtonType.uploadAndShare;
          _uploadAndShareButtonType.add(shareButtonType);
          break;
        case ShareType.none:
          _uploadAndShareButtonType.add(ShareButtonType.workGroup);
          break;
        case ShareType.uploadFromOutside:
          break;
      }
    });

    Future.delayed(Duration(milliseconds: 500), () => _checkContactPermission());
  }

  void backToMySpace() {
    _appNavigation.popBack();
    store.dispatch(CleanUploadStateAction());
  }

  void setUploadFilesArgument(List<FileInfo> uploadFiles) {
    _uploadFilesArgument = uploadFiles;
  }

  void setShareTypeArgument(ShareType shareType) {
    _shareTypeArgument = shareType;
  }

  void setDocumentsArgument(List<Document>? documents) {
    _documentsArgument = documents;
  }

  void setShareDestinationArgument(ShareDestination? shareDestination) {
    _shareDestination = shareDestination;
  }

  void setWorkGroupDocumentUploadInfoArgument(WorkGroupDocumentUploadInfo? workGroupDocumentUploadInfo) {
    _workGroupDocumentUploadInfoArgument = workGroupDocumentUploadInfo;
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

  List<SelectedPresentationFile>? get filesInfos {
    return (_shareTypeArgument == ShareType.quickShare)
        ? _convertDocumentsToPresentationFile(_documentsArgument!)
        : _convertFilesToPresentationFile(_uploadFilesArgument!);
  }

  void onPickUploadDestinationPressed(BuildContext context) {
    final cancelAction = NegativeDestinationPickerAction(context,
        label: AppLocalizations.of(context).cancel.toUpperCase());
    cancelAction.onDestinationPickerActionClick((_) => _appNavigation.popBack());

    final chooseAction = ChooseDestinationPickerAction(context);
    chooseAction.onDestinationPickerActionClick((data) {
      _appNavigation.popBack();
      if (data != null && data is SharedSpaceDocumentArguments) {
        setWorkGroupDocumentUploadInfoArgument(WorkGroupDocumentUploadInfo(
            data.sharedSpaceNode,
            data.workGroupFolder,
            data.documentType));
        _uploadDestinationTypeObservable.add(DestinationType.workGroup);
      } else {
        _uploadDestinationTypeObservable.add(DestinationType.mySpace);
      }
    });

    _appNavigation.push(RoutePaths.destinationPicker,
        arguments: DestinationPickerArguments(
            actionList: [chooseAction, cancelAction],
            operator: Operation.upload));
  }

  void handleOnUploadAndSharePressed() {
    if (_shareTypeArgument == ShareType.quickShare) {
      _handleQuickShare();
    } else if (_shareTypeArgument == ShareType.uploadAndShare) {
      _handleUploadAndShare();
    } else if (_shareTypeArgument == ShareType.uploadFromOutside) {
      _handleUploadForUploadFromOutside();
    } else {
      _handleUploadToSharedSpace();
    }
    _appNavigation.popBack();
  }

  void _handleUploadForUploadFromOutside() {
    if (_uploadFilesArgument == null) {
      return;
    }
    if (_uploadDestinationTypeObservable.value == DestinationType.workGroup) {
      _uploadToSharedSpace(_uploadFilesArgument!);
    } else {
      if (_autoCompleteResultListObservable.value.isEmpty) {
        _uploadShareFileManager.justUploadFiles(_uploadFilesArgument!);
      } else {
        _uploadShareFileManager.uploadFilesThenShare(
          _uploadFilesArgument!,
          _autoCompleteResultListObservable.value,
        );
      }
    }
  }

  void _handleQuickShare() {
    if (_documentsArgument != null && _documentsArgument!.isNotEmpty) {
      store.dispatch(shareAction());
    }
  }

  void _handleUploadAndShare() {
    if (_uploadFilesArgument != null) {
      store.dispatch(uploadAndShareFileAction(_uploadFilesArgument!));
    }
  }

  void _handleUploadToSharedSpace() {
    if (_uploadFilesArgument != null && _workGroupDocumentUploadInfoArgument != null) {
      store.dispatch(uploadAndShareFileAction(_uploadFilesArgument!));
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

  ThunkAction<AppState> shareAction() {
    return (Store<AppState> store) async {
      final documentIdList = _documentsArgument?.map((document) => document.documentId).toList();
      await _uploadShareFileManager.justShare(
        _autoCompleteResultListObservable.value,
        documentIdList,
        shareDestination: _shareDestination,
      );
    };
  }

  ThunkAction<AppState> uploadAndShareFileAction(List<FileInfo> uploadFiles) {
    return (Store<AppState> store) async {
      final uploadType = _uploadAndShareButtonType.value;
      switch (uploadType) {
        case ShareButtonType.justUpload:
          await _uploadShareFileManager.justUploadFiles(uploadFiles);
          break;
        case ShareButtonType.uploadAndShare:
          await _uploadShareFileManager.uploadFilesThenShare(
            uploadFiles,
            _autoCompleteResultListObservable.value,
          );
          break;
        case ShareButtonType.workGroup:
          _uploadToSharedSpace(uploadFiles);
          break;
        default:
      }
    };
  }

  void _uploadToSharedSpace(List<FileInfo> uploadFiles) async {
    if(_workGroupDocumentUploadInfoArgument == null || _workGroupDocumentUploadInfoArgument!.sharedSpaceNodeNested == null) {
      return;
    }
    _uploadShareFileManager.uploadToSharedSpace(
        uploadFiles,
        _workGroupDocumentUploadInfoArgument!.sharedSpaceNodeNested!.sharedSpaceId,
        parentNodeId: _workGroupDocumentUploadInfoArgument!.isRootNode()
            ? null
            : _workGroupDocumentUploadInfoArgument!.currentNode?.workGroupNodeId);
  }

  List<SelectedPresentationFile>? _convertDocumentsToPresentationFile(List<Document>? documents) {
    if(documents == null) {
      return null;
    }
    return documents.map((document) {
      return SelectedPresentationFile(document.name, document.size, mediaType: document.mediaType);
    }).toList();
  }

  List<SelectedPresentationFile>? _convertFilesToPresentationFile(List<FileInfo>? filesInfo) {
    if(filesInfo == null) {
      return null;
    }
    return filesInfo.map((uploadFiles) {
      return SelectedPresentationFile(uploadFiles.fileName, uploadFiles.fileSize, mediaType: uploadFiles.fileName.getMediaType());
    }).toList();
  }

  void cancelSelection() {
    store.dispatch(MySpaceClearSelectedDocumentsAction());
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
    super.onDisposed();
  }
}
