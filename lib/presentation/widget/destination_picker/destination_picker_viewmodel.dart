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

import 'package:domain/domain.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/destination_picker_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/destination_picker/destination_picker_action/base_destination_picker_action.dart';
import 'package:linshare_flutter_app/presentation/widget/destination_picker/destination_picker_action/choose_destination_picker_action.dart';
import 'package:linshare_flutter_app/presentation/widget/destination_picker/destination_picker_action/copy_destination_picker_action.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_document_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/destination_type.dart';
import 'package:redux/src/store.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:rxdart/rxdart.dart';

class DestinationPickerViewModel extends BaseViewModel {
  final GetAllSharedSpacesInteractor _getAllSharedSpacesInteractor;
  final AppNavigation _appNavigation;
  final BehaviorSubject<SharedSpaceDocumentArguments> currentNodeObservable = BehaviorSubject<SharedSpaceDocumentArguments>();
  final destinationTypeList = [DestinationType.mySpace, DestinationType.workGroup];

  DestinationPickerViewModel(Store<AppState> store, this._getAllSharedSpacesInteractor, this._appNavigation) : super(store);

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

  @override
  void onDisposed() {
    store.dispatch(CleanDestinationPickerStateAction());
  }
}
