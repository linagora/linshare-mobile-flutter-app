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

import 'package:connectivity/connectivity.dart';
import 'package:dartz/dartz.dart';
import 'package:domain/domain.dart';
import 'package:get_it/get_it.dart';
import 'package:linshare_flutter_app/presentation/model/file/selectable_element.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/app_action.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/my_space_action.dart';
import 'package:linshare_flutter_app/presentation/redux/reducers/app_reducer.dart';
import 'package:linshare_flutter_app/presentation/redux/states/account_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/add_drive_member_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/add_recipients_upload_request_group_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/add_shared_space_members_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/advance_search_settings_workgroup_node_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/authentication_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/biometric_authentication_login_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/biometric_authentication_setting_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/delete_shared_space_members_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/destination_picker_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/document_details_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/edit_upload_request_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/functionality_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/my_space_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/network_connectivity_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/received_share_details_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/received_share_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/share_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/shared_space_details_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/shared_space_document_destination_picker_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/shared_space_document_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/upload_request_file_details_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/upload_request_group_details_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/upload_request_inside_active_closed_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/upload_request_inside_archived_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/upload_request_inside_created_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/signup_authentication_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/upload_request_recipient_details_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/workgroup_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/shared_space_node_details_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/shared_space_node_versions_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/shared_space_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/ui_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/update_shared_space_members_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/upload_file_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/upload_request_creation_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/upload_request_group_active_closed_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/upload_request_group_archived_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/upload_request_group_created_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/upload_request_group_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/upload_request_inside_state.dart';
import 'package:redux/redux.dart';
import 'package:redux_logging/redux_logging.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:test/test.dart';

void main() {
  group('network_connectivity_test', () {
    final getIt = GetIt.instance;
    Store<AppState> store;

    tearDown(() {
      getIt.unregister<Store<AppState>>();
    });

    test('appReducer should return NoInternetConnectionState when using online action without network connection', () async {
      final noNetworkState = createAppStateWithNetworkConnectivityState(NetworkConnectivityState(
          Right(IdleState()),
          ConnectivityResult.none
      ));

      getIt.registerSingleton<Store<AppState>>(Store<AppState>(appStateReducer,
          initialState: noNetworkState,
          middleware: [thunkMiddleware, LoggingMiddleware.printer()]));
      store = getIt<Store<AppState>>();

      store.dispatch(MockOnlineAction());

      final expectedState = createAppStateWithNetworkConnectivityState(NetworkConnectivityState(
          Right(NoInternetConnectionState()),
          ConnectivityResult.none
      ));

      expect(store.state, expectedState);
    });

    test('appReducer should return valid state when using online action with wifi connection', () async {
      final hasWifiNetworkState = createAppStateWithNetworkConnectivityState(NetworkConnectivityState(
          Right(IdleState()),
          ConnectivityResult.wifi
      ));

      getIt.registerSingleton<Store<AppState>>(Store<AppState>(appStateReducer,
          initialState: hasWifiNetworkState,
          middleware: [thunkMiddleware, LoggingMiddleware.printer()]));
      store = getIt<Store<AppState>>();

      store.dispatch(StartMySpaceLoadingAction());

      final expectedState = createAppStateWithNetworkConnectivityState(
          NetworkConnectivityState(Right(IdleState()), ConnectivityResult.wifi),
          mySpaceState: MySpaceState(Right(LoadingState()), [], SelectMode.INACTIVE, Sorter.fromOrderScreen(OrderScreen.mySpace)));

      expect(store.state, expectedState);
    });

    test('appReducer should return valid state when using online action with mobile connection', () async {
      final hasWifiNetworkState = createAppStateWithNetworkConnectivityState(NetworkConnectivityState(
          Right(IdleState()),
          ConnectivityResult.mobile
      ));

      getIt.registerSingleton<Store<AppState>>(Store<AppState>(appStateReducer,
          initialState: hasWifiNetworkState,
          middleware: [thunkMiddleware, LoggingMiddleware.printer()]));
      store = getIt<Store<AppState>>();

      store.dispatch(StartMySpaceLoadingAction());

      final expectedState = createAppStateWithNetworkConnectivityState(
          NetworkConnectivityState(Right(IdleState()), ConnectivityResult.mobile),
          mySpaceState: MySpaceState(Right(LoadingState()), [], SelectMode.INACTIVE, Sorter.fromOrderScreen(OrderScreen.mySpace)));

      expect(store.state, expectedState);
    });
  });
}

class MockOnlineAction extends ActionOnline {}

AppState createAppStateWithNetworkConnectivityState(NetworkConnectivityState networkConnectivityState, {MySpaceState? mySpaceState}) {
  return AppState(
    authenticationState: AuthenticationState.initial(),
    signUpAuthenticationState: SignUpAuthenticationState.initial(),
    uploadFileState: UploadFileState.initial(),
    mySpaceState: mySpaceState ?? MySpaceState.initial(),
    shareState: ShareState.initial(),
    sharedSpaceState: SharedSpaceState.initial(),
    workgroupState: WorkgroupState.initial(),
    sharedSpaceDocumentState: SharedSpaceDocumentState.initial(),
    uiState: UIState.initial(),
    account: AccountState.initial(),
    destinationPickerState: DestinationPickerState.initial(),
    networkConnectivityState: networkConnectivityState,
    functionalityState: FunctionalityState.initial(),
    addSharedSpaceMembersState: AddSharedSpaceMembersState.initial(),
    sharedSpaceDetailsState: SharedSpaceDetailsState.initial(),
    addDriveMemberState: AddDriveMemberState.initial(),
    receivedShareState: ReceivedShareState.initial(),
    biometricAuthenticationLoginState: BiometricAuthenticationLoginState.initial(),
    biometricAuthenticationSettingState: BiometricAuthenticationSettingState.initial(),
    deleteSharedSpaceMembersState: DeleteSharedSpaceMembersState.initial(),
    documentDetailsState: DocumentDetailsState.initial(),
    sharedSpaceDocumentDestinationPickerState: SharedSpaceDocumentDestinationPickerState.initial(),
    sharedSpaceNodeDetailsState: SharedSpaceNodeDetailsState.initial(),
    sharedSpaceNodeVersionsState: SharedSpaceNodeVersionsState.initial(),
    updateSharedSpaceMembersState: UpdateSharedSpaceMembersState.initial(),
    uploadRequestGroupState: UploadRequestGroupState.initial(),
    uploadRequestGroupDetailsState: UploadRequestGroupDetailsState.initial(),
    uploadRequestRecipientDetailsState: UploadRequestRecipientDetailsState.initial(),
    uploadRequestCreationState: UploadRequestCreationState.initial(),
    editUploadRequestState: EditUploadRequestState.initial(),
    createdUploadRequestGroupState: CreatedUploadRequestGroupState.initial(),
    activeClosedUploadRequestGroupState: ActiveClosedUploadRequestGroupState.initial(),
    archivedUploadRequestGroupState: ArchivedUploadRequestGroupState.initial(),
    uploadRequestInsideState: UploadRequestInsideState.initial(),
    uploadRequestFileDetailsState: UploadRequestFileDetailsState.initial(),
    activeClosedUploadRequestInsideState: ActiveClosedUploadRequestInsideState.initial(),
    createdUploadRequestInsideState: CreatedUploadRequestInsideState.initial(),
    archivedUploadRequestInsideState: ArchivedUploadRequestInsideState.initial(),
    receivedShareDetailsState: ReceivedShareDetailsState.initial(),
    addRecipientsUploadRequestGroupState: AddRecipientsUploadRequestGroupState.initial(),
    advanceSearchSettingsWorkgroupNodeState: AdvancedSearchSettingsWorkgroupNodeState.initial()
  );
}
