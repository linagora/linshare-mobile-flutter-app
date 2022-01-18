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

import 'package:equatable/equatable.dart';
import 'package:linshare_flutter_app/presentation/redux/states/account_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/add_shared_space_node_member_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/add_shared_space_members_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/advance_search_settings_workgroup_node_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/authentication_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/biometric_authentication_login_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/delete_shared_space_members_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/document_details_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/biometric_authentication_setting_state.dart';
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

import 'add_recipients_upload_request_group_state.dart';
import 'destination_picker_state.dart';

class AppState with EquatableMixin {
  final UIState uiState;
  final AuthenticationState authenticationState;
  final SignUpAuthenticationState signUpAuthenticationState;
  final UploadFileState uploadFileState;
  final MySpaceState mySpaceState;
  final ShareState shareState;
  final SharedSpaceState sharedSpaceState;
  final WorkgroupState workgroupState;
  final SharedSpaceDocumentState sharedSpaceDocumentState;
  final SharedSpaceDocumentDestinationPickerState sharedSpaceDocumentDestinationPickerState;
  final ReceivedShareState receivedShareState;
  final DestinationPickerState destinationPickerState;
  final NetworkConnectivityState networkConnectivityState;
  final AccountState account;
  final FunctionalityState functionalityState;
  final SharedSpaceDetailsState sharedSpaceDetailsState;
  final AddSharedSpaceNodeMemberState addSharedSpaceNodeMemberState;
  final AddSharedSpaceMembersState addSharedSpaceMembersState;
  final UpdateSharedSpaceMembersState updateSharedSpaceMembersState;
  final DeleteSharedSpaceMembersState deleteSharedSpaceMembersState;
  final DocumentDetailsState documentDetailsState;
  final SharedSpaceNodeDetailsState sharedSpaceNodeDetailsState;
  final BiometricAuthenticationSettingState biometricAuthenticationSettingState;
  final SharedSpaceNodeVersionsState sharedSpaceNodeVersionsState;
  final BiometricAuthenticationLoginState biometricAuthenticationLoginState;
  final UploadRequestGroupState uploadRequestGroupState;
  final UploadRequestGroupDetailsState uploadRequestGroupDetailsState;
  final UploadRequestRecipientDetailsState uploadRequestRecipientDetailsState;
  final UploadRequestCreationState uploadRequestCreationState;
  final EditUploadRequestState editUploadRequestState;
  final CreatedUploadRequestGroupState createdUploadRequestGroupState;
  final ActiveClosedUploadRequestGroupState activeClosedUploadRequestGroupState;
  final ArchivedUploadRequestGroupState archivedUploadRequestGroupState;
  final UploadRequestInsideState uploadRequestInsideState;
  final UploadRequestFileDetailsState uploadRequestFileDetailsState;
  final ActiveClosedUploadRequestInsideState activeClosedUploadRequestInsideState;
  final CreatedUploadRequestInsideState createdUploadRequestInsideState;
  final ArchivedUploadRequestInsideState archivedUploadRequestInsideState;
  final ReceivedShareDetailsState receivedShareDetailsState;
  final AddRecipientsUploadRequestGroupState addRecipientsUploadRequestGroupState;
  final AdvancedSearchSettingsWorkgroupNodeState advanceSearchSettingsWorkgroupNodeState;

  AppState(
      {required this.uiState,
      required this.authenticationState,
      required this.signUpAuthenticationState,
      required this.uploadFileState,
      required this.mySpaceState,
      required this.shareState,
      required this.sharedSpaceState,
      required this.workgroupState,
      required this.sharedSpaceDocumentState,
      required this.sharedSpaceDocumentDestinationPickerState,
      required this.receivedShareState,
      required this.destinationPickerState,
      required this.networkConnectivityState,
      required this.account,
      required this.functionalityState,
      required this.sharedSpaceDetailsState,
      required this.addSharedSpaceNodeMemberState,
      required this.addSharedSpaceMembersState,
      required this.updateSharedSpaceMembersState,
      required this.deleteSharedSpaceMembersState,
      required this.documentDetailsState,
      required this.sharedSpaceNodeDetailsState,
      required this.biometricAuthenticationSettingState,
      required this.biometricAuthenticationLoginState,
      required this.sharedSpaceNodeVersionsState,
      required this.uploadRequestGroupState,
      required this.uploadRequestGroupDetailsState,
      required this.uploadRequestRecipientDetailsState,
      required this.uploadRequestCreationState,
      required this.editUploadRequestState,
      required this.uploadRequestInsideState,
      required this.uploadRequestFileDetailsState,
      required this.activeClosedUploadRequestInsideState,
      required this.createdUploadRequestInsideState,
      required this.archivedUploadRequestInsideState,
      required this.receivedShareDetailsState,
      required this.addRecipientsUploadRequestGroupState,
      required this.createdUploadRequestGroupState,
      required this.activeClosedUploadRequestGroupState,
      required this.archivedUploadRequestGroupState,
      required this.advanceSearchSettingsWorkgroupNodeState});

  factory AppState.initial() {
    return AppState(
        uiState: UIState.initial(),
        authenticationState: AuthenticationState.initial(),
        signUpAuthenticationState: SignUpAuthenticationState.initial(),
        uploadFileState: UploadFileState.initial(),
        mySpaceState: MySpaceState.initial(),
        shareState: ShareState.initial(),
        sharedSpaceState: SharedSpaceState.initial(),
        workgroupState: WorkgroupState.initial(),
        sharedSpaceDocumentState: SharedSpaceDocumentState.initial(),
        sharedSpaceDocumentDestinationPickerState: SharedSpaceDocumentDestinationPickerState.initial(),
        receivedShareState: ReceivedShareState.initial(),
        destinationPickerState: DestinationPickerState.initial(),
        networkConnectivityState: NetworkConnectivityState.initial(),
        account: AccountState.initial(),
        functionalityState: FunctionalityState.initial(),
        sharedSpaceDetailsState: SharedSpaceDetailsState.initial(),
        addSharedSpaceNodeMemberState: AddSharedSpaceNodeMemberState.initial(),
        addSharedSpaceMembersState: AddSharedSpaceMembersState.initial(),
        updateSharedSpaceMembersState: UpdateSharedSpaceMembersState.initial(),
        deleteSharedSpaceMembersState: DeleteSharedSpaceMembersState.initial(),
        documentDetailsState: DocumentDetailsState.initial(),
        sharedSpaceNodeDetailsState: SharedSpaceNodeDetailsState.initial(),
        biometricAuthenticationSettingState: BiometricAuthenticationSettingState.initial(),
        biometricAuthenticationLoginState: BiometricAuthenticationLoginState.initial(),
        sharedSpaceNodeVersionsState: SharedSpaceNodeVersionsState.initial(),
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

  @override
  List<Object> get props => [
        uiState,
        authenticationState,
        signUpAuthenticationState,
        uploadFileState,
        mySpaceState,
        shareState,
        sharedSpaceState,
        workgroupState,
        sharedSpaceDocumentState,
        sharedSpaceDocumentDestinationPickerState,
        receivedShareState,
        destinationPickerState,
        networkConnectivityState,
        account,
        functionalityState,
        sharedSpaceDetailsState,
        addSharedSpaceNodeMemberState,
        addSharedSpaceMembersState,
        deleteSharedSpaceMembersState,
        documentDetailsState,
        sharedSpaceNodeDetailsState,
        biometricAuthenticationSettingState,
        biometricAuthenticationLoginState,
        sharedSpaceNodeVersionsState,
        uploadRequestGroupState,
        uploadRequestGroupDetailsState,
        uploadRequestRecipientDetailsState,
        uploadRequestCreationState,
        editUploadRequestState,
        createdUploadRequestGroupState,
        activeClosedUploadRequestGroupState,
        archivedUploadRequestGroupState,
        uploadRequestInsideState,
        uploadRequestFileDetailsState,
        activeClosedUploadRequestInsideState,
        createdUploadRequestInsideState,
        archivedUploadRequestInsideState,
        receivedShareDetailsState,
        addRecipientsUploadRequestGroupState,
        advanceSearchSettingsWorkgroupNodeState
      ];
}
