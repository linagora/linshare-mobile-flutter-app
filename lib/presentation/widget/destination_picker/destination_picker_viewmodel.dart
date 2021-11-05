// LinShare is an open source filesharing software, part of the LinPKI software
// suite, developed by Linagora.
//
// Copyright (C) 2021 LINAGORA
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

import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/destination_picker_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/shared_space_destination_picker_action.dart';
import 'package:linshare_flutter_app/presentation/redux/online_thunk_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/shared_space_document_destination_picker_state.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/view/modal_sheets/edit_text_modal_sheet_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/destination_picker/destination_picker_action/base_destination_picker_action.dart';
import 'package:linshare_flutter_app/presentation/widget/destination_picker/destination_picker_action/choose_destination_picker_action.dart';
import 'package:linshare_flutter_app/presentation/widget/destination_picker/destination_picker_action/copy_destination_picker_action.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_document_arguments.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/suggest_name_type_extension.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_document_type.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/destination_type.dart';
import 'package:redux/src/store.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:rxdart/rxdart.dart';

class DestinationPickerViewModel extends BaseViewModel {
  final GetAllSharedSpacesInteractor _getAllSharedSpacesInteractor;
  final AppNavigation _appNavigation;
  final VerifyNameInteractor _verifyNameInteractor;
  final CreateSharedSpaceFolderInteractor _createSharedSpaceFolderInteractor;
  final BehaviorSubject<SharedSpaceDocumentArguments> currentNodeObservable = BehaviorSubject<SharedSpaceDocumentArguments>();
  final destinationTypeList = [DestinationType.mySpace, DestinationType.workGroup];

  SharedSpaceDocumentDestinationPickerState get sharedSpaceDestinationState =>
      store.state.sharedSpaceDocumentDestinationPickerState;

  WorkGroupNode? get workGroupNodeCurrent => sharedSpaceDestinationState.workGroupNode;

  SharedSpaceNodeNested? get sharedSpaceCurrent => sharedSpaceDestinationState.sharedSpaceNodeNested;

  SharedSpaceDocumentType get documentType => sharedSpaceDestinationState.documentType;

  SharedSpaceId? get sharedSpaceId => documentType == SharedSpaceDocumentType.root
    ? sharedSpaceCurrent?.sharedSpaceId
    : workGroupNodeCurrent?.sharedSpaceId;

  WorkGroupNodeId? get workGroupNodeId => documentType == SharedSpaceDocumentType.root
    ? null
    : workGroupNodeCurrent?.workGroupNodeId;

  DestinationPickerViewModel(
      Store<AppState> store,
      this._getAllSharedSpacesInteractor,
      this._appNavigation,
      this._verifyNameInteractor,
      this._createSharedSpaceFolderInteractor,
  ) : super(store);

  void setCurrentViewByOperation(Operation operation) {
    switch (operation) {
      case Operation.copyTo:
        store.dispatch(GoToChooseSpaceAction(operation));
        break;
      case Operation.upload:
        store.dispatch(GoToChooseSpaceAction(operation));
        break;
      default:
        store.dispatch(DestinationPickerGoToSharedSpaceAction(operation));
        getAllSharedSpaces(operation);
    }
  }

  void onChoseSpaceDestination(DestinationType choseDestinationType, Operation pickerForOperation, List<BaseDestinationPickerAction> actionList) {
    if (choseDestinationType == DestinationType.workGroup) {
      store.dispatch(DestinationPickerGoToSharedSpaceAction(pickerForOperation));
      getAllSharedSpaces(pickerForOperation);
    } else if (choseDestinationType == DestinationType.mySpace) {
      actionList.forEach((action) {
        if (action != null) {
          if (action is CopyDestinationPickerAction || action is ChooseDestinationPickerAction) {
            action.actionClick(choseDestinationType);
          }
        }
      });
    }
  }

  void getAllSharedSpaces(Operation operation) async {
    store.dispatch(_getAllSharedSpacesAction(operation));
  }

  ThunkAction<AppState> _getAllSharedSpacesAction(Operation operation) {
    return (Store<AppState> store) async {
      store.dispatch(StartDestinationPickerLoadingAction());
      await _getAllSharedSpacesInteractor.execute().then((result) => result.fold(
              (failure) => store.dispatch(DestinationPickerGetAllSharedSpacesAction([])),
              (success) => store.dispatch(DestinationPickerGetAllSharedSpacesAction(
                  (success as SharedSpacesViewState).sharedSpacesList
                      .where((element) {
                        if (operation == Operation.copyFromMySpace || operation == Operation.copyFromReceivedShare) {
                          return SharedSpaceOperationRole.copyToSharedSpaceRoles
                              .contains(element.sharedSpaceRole.name);
                        } else if (operation == Operation.upload) {
                          return SharedSpaceOperationRole.uploadToSharedSpaceRoles
                              .contains(element.sharedSpaceRole.name);
                        } else if (operation == Operation.copyTo) {
                          return SharedSpaceOperationRole.copyToSharedSpaceRoles
                              .contains(element.sharedSpaceRole.name);
                        } else if (operation == Operation.move) {
                          return SharedSpaceOperationRole.moveSharedSpaceNodeRoles
                              .contains(element.sharedSpaceRole.name);
                        }
                        return true;
                      })
                      .toList()))));
    };
  }

  void openSharedSpaceInside(SharedSpaceNodeNested sharedSpace) {
    store.dispatch(DestinationPickerGoInsideSharedSpaceAction(sharedSpace));
  }

  void backToSharedSpace() {
    store.dispatch(DestinationPickerBackToSharedSpaceAction());
  }

  void backToChooseSpaceDestination() {
    store.dispatch(GoToChooseSpaceAction(Operation.none));
  }

  void handleOnSharedSpaceBackPress() {
    _appNavigation.popBack();
  }

  void openCreateFolderModal(BuildContext context) {
    final workGroupNodeList = sharedSpaceDestinationState.workGroupNodeList
        .map((node) => node.element)
        .toList();
    final suggestName = SuggestNameType.WORKGROUP_FOLDER.suggestNewName(
        context,
        workGroupNodeList.whereType<WorkGroupFolder>().map((folder) => folder.name).toList()
    );

    EditTextModalSheetBuilder()
        .key(Key('create_new_folder_destination_picker_modal'))
        .title(AppLocalizations.of(context).create_new_folder)
        .cancelText(AppLocalizations.of(context).cancel)
        .setTextController(TextEditingController.fromValue(TextEditingValue(
              text: suggestName,
              selection: TextSelection(baseOffset: 0, extentOffset: suggestName.length)),
          ))
        .onConfirmAction(
          AppLocalizations.of(context).create,
          (value) {
            if (sharedSpaceId != null && value.isNotEmpty) {
              return store.dispatch(_createNewFolderAction(context, sharedSpaceId!, workGroupNodeId, value));
            }
          })
        .setErrorString((value) => _getErrorString(context, workGroupNodeList, workGroupNodeCurrent, value))
        .show(context);
  }

  String? _getErrorString(
      BuildContext context,
      List<WorkGroupNode> workGroupNodeList,
      WorkGroupNode? workGroupNode,
      String value
  ) {
    if(workGroupNode == null) {
      return '';
    }
    final listName = workGroupNode is WorkGroupDocument
      ? workGroupNodeList.whereType<WorkGroupDocument>().map((node) => node.name).toList()
      : workGroupNodeList.whereType<WorkGroupFolder>().map((node) => node.name).toList();

    return _verifyNameInteractor.execute(value, [
      EmptyNameValidator(),
      DuplicateNameValidator(listName),
      SpecialCharacterValidator(),
      if (workGroupNode is WorkGroupDocument) LastDotValidator()
    ]).fold((failure) {
      if (failure is VerifyNameFailure) {
        final nodeName = workGroupNode is WorkGroupDocument
          ? AppLocalizations.of(context).file
          : AppLocalizations.of(context).folder;
        if (failure.exception is EmptyNameException) {
          return AppLocalizations.of(context).node_name_not_empty(nodeName);
        } else if (failure.exception is DuplicatedNameException) {
          return AppLocalizations.of(context).node_name_already_exists(nodeName);
        } else if (failure.exception is SpecialCharacterException) {
          return AppLocalizations.of(context).node_name_contain_special_character(nodeName);
        } else if (failure.exception is LastDotException) {
          return AppLocalizations.of(context).node_name_contain_last_dot(nodeName);
        } else {
          return null;
        }
      } else {
        return null;
      }
    }, (success) => null);
  }

  OnlineThunkAction _createNewFolderAction(
      BuildContext context,
      SharedSpaceId sharedSpaceId,
      WorkGroupNodeId? parentNodeId,
      String newName
  ) {
    return OnlineThunkAction((Store<AppState> store) async {
      await _createSharedSpaceFolderInteractor
        .execute(sharedSpaceId, CreateSharedSpaceNodeFolderRequest(newName, parentNodeId))
        .then((result) => store.dispatch(SharedSpaceDestinationAction(result)));
    });
  }

  @override
  void onDisposed() {
    store.dispatch(CleanDestinationPickerStateAction());
  }
}
