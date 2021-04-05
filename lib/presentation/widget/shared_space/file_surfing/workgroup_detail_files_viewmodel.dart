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
//

import 'package:dartz/dartz.dart';
import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/shared_space_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/ui_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/upload_file_action.dart';
import 'package:linshare_flutter_app/presentation/redux/online_thunk_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/ui_state.dart';
import 'package:linshare_flutter_app/presentation/util/local_file_picker.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/util/router/route_paths.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/context_menu_builder.dart';
import 'package:linshare_flutter_app/presentation/view/header/simple_bottom_sheet_header_builder.dart';
import 'package:linshare_flutter_app/presentation/view/modal_sheets/edit_text_modal_sheet_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space/file_surfing/workgroup_nodes_surfling_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/upload_file_arguments.dart';
import 'package:redux/src/store.dart';
import 'package:redux_thunk/redux_thunk.dart';

class WorkGroupDetailFilesViewModel extends BaseViewModel {
  final LocalFilePicker _localFilePicker;
  final AppNavigation _appNavigation;
  final VerifyNameInteractor _verifyNameInteractor;
  final GetAllChildNodesInteractor _getAllChildNodesInteractor;
  final CreateSharedSpaceFolderInteractor _createSharedSpaceFolderInteractor;
  List _workGroupNodesList;

  WorkGroupDetailFilesViewModel(
      Store<AppState> store,
      this._localFilePicker,
      this._appNavigation,
      this._verifyNameInteractor,
      this._getAllChildNodesInteractor,
      this._createSharedSpaceFolderInteractor)
      : super(store);

  void openAddNewFileOrFolderMenu(BuildContext context, List<Widget> actionTiles) {
    store.dispatch(_handleAddNewFileOrFolderMenuAction(context, actionTiles));
  }

  void openCreateFolderModal(BuildContext context, WorkGroupNodesSurfingArguments arguments) {
    _appNavigation.popBack();
    store.dispatch(_handleCreateNewFolderModalAction(context, arguments));
  }

  void openUploadFileMenu(BuildContext context, List<Widget> actionTiles) {
    _appNavigation.popBack();
    store.dispatch(_handleUploadFileMenuAction(context, actionTiles));
  }

  void openFilePickerByType(
      WorkGroupNodesSurfingArguments workGroupNodesSurfingArguments, FileType fileType) {
    _appNavigation.popBack();
    store.dispatch(pickFileAction(workGroupNodesSurfingArguments, fileType));
  }

  ThunkAction<AppState> pickFileAction(
      WorkGroupNodesSurfingArguments workGroupNodesSurfingArguments, FileType fileType) {
    return (Store<AppState> store) async {
      await _localFilePicker.pickFiles(fileType: fileType).then((result) => result.fold(
          (failure) => store.dispatch(UploadFileAction(Left(failure))),
          (success) =>
              store.dispatch(pickFileSuccessAction(success, workGroupNodesSurfingArguments))));
    };
  }

  ThunkAction<AppState> _handleAddNewFileOrFolderMenuAction(
      BuildContext context, List<Widget> actionTiles) {
    return (Store<AppState> store) async {
      ContextMenuBuilder(context, areTilesHorizontal: true)
          .addHeader(SimpleBottomSheetHeaderBuilder(
                  Key('add_new_file_or_folders_bottom_sheet_header_builder'))
              .addLabel(AppLocalizations.of(context).add_new_file_or_folder)
              .build())
          .addTiles(actionTiles)
          .build();
    };
  }

  ThunkAction<AppState> _handleUploadFileMenuAction(
      BuildContext context, List<Widget> actionTiles) {
    return (Store<AppState> store) async {
      ContextMenuBuilder(context)
          .addHeader(SimpleBottomSheetHeaderBuilder(Key('file_picker_bottom_sheet_header_builder'))
              .addLabel(AppLocalizations.of(context).upload_file_title)
              .build())
          .addTiles(actionTiles)
          .build();
    };
  }

  ThunkAction<AppState> _handleCreateNewFolderModalAction(
      BuildContext context, WorkGroupNodesSurfingArguments arguments) {
    return (Store<AppState> store) async {
      loadAllChildNodes(arguments);

      EditTextModalSheetBuilder(_appNavigation)
          .key(Key('create_new_folder_modal'))
          .title(AppLocalizations.of(context).create_new_folder)
          .cancelText(AppLocalizations.of(context).cancel)
          .hintText(AppLocalizations.of(context).new_folder)
          .setTextController(TextEditingController())
          .onConfirmAction(AppLocalizations.of(context).rename,
              (value) => this.store.dispatch(_createNewFolderAction(value, arguments)))
          .setErrorString((value) => getErrorString(context, value, arguments))
          .show(context);
    };
  }

  String getErrorString(
      BuildContext context, String value, WorkGroupNodesSurfingArguments arguments) {
    return _verifyNameInteractor
        .execute(
            value,
            [EmptyNameValidator(), DuplicateNameValidator(
                _workGroupNodesList
                  .whereType<WorkGroupFolder>()
                  .map((node) => node.name)
                  .toList())
            ]
        )
        .fold((failure) {
      if (failure is VerifyNameFailure) {
        if (failure.exception is EmptyNameException) {
          return AppLocalizations.of(context).name_not_empty;
        } else if (failure.exception is DuplicatedNameException) {
          return AppLocalizations.of(context).name_already_exists;
        } else {
          return null;
        }
      } else {
        return null;
      }
    }, (success) => null);
  }

  ThunkAction<AppState> pickFileSuccessAction(FilePickerSuccessViewState success,
      WorkGroupNodesSurfingArguments workGroupNodesSurfingArguments) {
    return (Store<AppState> store) async {
      store.dispatch(UploadFileAction(Right(success)));
      await _appNavigation.push(RoutePaths.uploadDocumentRoute,
          arguments: UploadFileArguments(success.pickedFiles,
              shareType: ShareType.none,
              workGroupDocumentUploadInfo: WorkGroupDocumentUploadInfo(
                  workGroupNodesSurfingArguments.sharedSpaceNodeNested,
                  workGroupNodesSurfingArguments.folder,
                  workGroupNodesSurfingArguments.folderType)));
    };
  }

  void openSearchState() {
    store.dispatch(EnableSearchStateAction(SearchDestination.SHARED_SPACE));
    store.dispatch(SharedSpaceAction(Right(ClearWorkGroupNodesListViewState())));
  }

  void loadAllChildNodes(WorkGroupNodesSurfingArguments arguments) async {
    final isRootFolder = arguments.folderType == FolderNodeType.root;
    final result = await _getAllChildNodesInteractor.execute(
      isRootFolder ? arguments.sharedSpaceNodeNested.sharedSpaceId : arguments.folder.sharedSpaceId,
      parentId: isRootFolder ? null : arguments.folder.workGroupNodeId,
    );

    result.fold(
      (failure) {
        _workGroupNodesList = [];
      },
      (success) {
        _workGroupNodesList = (success as GetChildNodesViewState).workGroupNodes;
      },
    );
  }

  OnlineThunkAction _createNewFolderAction(
      String newName, WorkGroupNodesSurfingArguments arguments) {
    _appNavigation.popBack();
    return OnlineThunkAction((Store<AppState> store) async {
      final isRootFolder = arguments.folderType == FolderNodeType.root;
      await _createSharedSpaceFolderInteractor
          .execute(
              isRootFolder
                  ? arguments.sharedSpaceNodeNested.sharedSpaceId
                  : arguments.folder.sharedSpaceId,
              CreateSharedSpaceNodeFolderRequest(
                newName,
                isRootFolder ? null : arguments.folder.workGroupNodeId,
              ))
          .then((result) => result.fold(
              (failure) => store.dispatch(SharedSpaceAction(Left(failure))),
              (success) => store.dispatch(SharedSpaceAction(Right(success)))));
    });
  }
}
