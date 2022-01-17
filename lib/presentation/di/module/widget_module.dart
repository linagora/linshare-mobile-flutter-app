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

import 'package:connectivity/connectivity.dart';
import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/manager/offline_mode/auto_sync_offline_manager.dart';
import 'package:linshare_flutter_app/presentation/manager/upload_and_share_file/upload_and_share_file_manager.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_toast.dart';
import 'package:linshare_flutter_app/presentation/util/generate_password_utils.dart';
import 'package:linshare_flutter_app/presentation/util/local_file_picker.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/view/common/common_view.dart';
import 'package:linshare_flutter_app/presentation/view/common/upload_request_group_common_view.dart';
import 'package:linshare_flutter_app/presentation/widget/account_details/account_details_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/account_details/account_details_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/advance_search/advance_search_settings_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/advance_search/advance_search_settings_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/authentication/authentication_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/authentication/authentication_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/biometric_authentication/biometric_authentication_login_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/biometric_authentication/biometric_authentication_login_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/biometric_authentication/biometric_authentication_setting_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/biometric_authentication/biometric_authentication_setting_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/current_uploads/current_uploads_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/current_uploads/current_uploads_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/destination_picker/destination_picker_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/destination_picker/destination_picker_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/edit_upload_request/edit_upload_request_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/edit_upload_request/edit_upload_request_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/enter_otp/enter_otp_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/enter_otp/enter_otp_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/home/home_app_bar/home_app_bar_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/home/home_app_bar/home_app_bar_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/home/home_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/home/home_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/initialize/initialize_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/initialize_get_it/initialize_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/login/login_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/login/login_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/myspace/document_details/document_details_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/myspace/document_details/document_details_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/myspace/my_space_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/myspace/my_space_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/received/received_share_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/received/received_share_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/received_share_details/received_share_details_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/received_share_details/received_share_details_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/second_factor_authentication/second_factor_authentication_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/second_factor_authentication/second_factor_authentication_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space/shared_space_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space/shared_space_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_details/add_drive_member/add_drive_member_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_details/add_drive_member/add_drive_member_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_details/add_shared_space_member/add_shared_space_member_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_details/add_shared_space_member/add_shared_space_member_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_details/shared_space_details_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_details/shared_space_details_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_document_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_node_details/shared_space_node_details_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_node_details/shared_space_node_details_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_node_versions/shared_space_node_versions_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_node_versions/shared_space_node_versions_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/sign_up/sign_up_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/sign_up/sign_up_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_group_details/upload_request_group_details_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_group_details/upload_request_group_details_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/recipient_details/upload_request_recipient_details_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/recipient_details/upload_request_recipient_details_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/file_details/upload_request_file_details_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/file_details/upload_request_file_details_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/workgroup/workgroup_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/workgroup/workgroup_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/side_menu/side_menu_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/side_menu/side_menu_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/upload_file_manager.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/upload_file_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/upload_file_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_creation/upload_request_creation_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_creation/upload_request_creation_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_group/active_closed/active_closed_upload_request_group_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_group/active_closed/active_closed_upload_request_group_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_group/archived/archived_upload_request_group_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_group/archived/archived_upload_request_group_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_group/created/created_upload_request_group_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_group/created/created_upload_request_group_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_group/upload_request_group_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_group/upload_request_group_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_group_add_recipient/add_recipients_upload_request_group_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_group_add_recipient/add_recipients_upload_request_group_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/active_close/active_closed_upload_request_inside_view_model.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/archived/archived_upload_request_inside_view_model.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/pending/pending_upload_request_inside_view_model.dart';
import 'package:redux/redux.dart';

class WidgetModule {
  WidgetModule() {
    _provideLoginComponent();
    _provideSignUpComponent();
    _provideHomeComponent();
    _provideMySpaceComponent();
    _provideUploadFileComponent();
    _provideInitializeComponent();
    _provideSideMenuComponent();
    _provideSharedSpaceComponent();
    _provideWorkgroupComponent();
    _provideSharedSpaceDocumentComponent();
    _provideCurrentUploadsComponent();
    _provideDestinationPickerComponent();
    _provideAccountDetailsComponent();
    _provideReceivedShareWidgetComponent();
    _provideSharedSpaceDetailsWidgetComponent();
    _provideAddDriveMemberWidgetComponent();
    _provideAuthenticationWidgetComponent();
    _provideEnterOTPWidgetComponent();
    _provide2FAWidgetComponent();
    _provideAddSharedSpaceMemberComponent();
    _provideDocumentDetailsComponent();
    _provideSharedSpaceNodeDetailsComponent();
    _provideBiometricAuthenticationLoginComponent();
    _provideBiometricAuthenticationSettingComponent();
    _provideSharedSpaceNodeVersionsComponent();
    _provideUploadRequestGroupComponent();
    _provideUploadRequestCreationComponent();
    _provideEditUploadRequestComponent();
    _provideUploadRequestInsideComponent();
    _provideUploadRequestFileDetailsComponent();
    _provideHomeAppBarComponent();
    _provideReceivedShareDetailsComponent();
    _provideAddRecipientsUploadRequestGroupComponent();
    _provideWidgetCommonView();
    _provideAdvanceSearchWidgetComponent();
    _provideUploadRequestGroupDetailsWidgetComponent();
    _provideUploadRequestRecipientDetailsWidgetComponent();
  }

  void _provideLoginComponent() {
    getIt.registerFactory(() => LoginWidget());
    getIt.registerFactory(() => LoginViewModel(
      getIt.get<Store<AppState>>(),
      getIt.get<CreatePermanentTokenInteractor>(),
      getIt.get<CreatePermanentTokenOIDCInteractor>(),
      getIt.get<GetTokenOIDCInteractor>(),
      getIt.get<AppNavigation>(),
      getIt.get<DynamicUrlInterceptors>(),
      getIt<GetOIDCConfigurationInteractor>(),
      getIt<VerifyNameInteractor>(),
      getIt<GetSaaSConfigurationInteractor>(),
    ));
  }

  void _provideSignUpComponent() {
    getIt.registerFactory(() => SignUpWidget());
    getIt.registerFactory(() => SignUpViewModel(
      getIt.get<Store<AppState>>(),
      getIt.get<AppNavigation>(),
      getIt.get<GeneratePasswordUtils>(),
      getIt<VerifyNameInteractor>(),
      getIt<GetSaaSConfigurationInteractor>(),
      getIt<GetOIDCConfigurationInteractor>(),
      getIt<GetSecretTokenInteractor>(),
      getIt<VerifyEmailSaaSInteractor>(),
      getIt<SignUpForSaaSInteractor>(),
      getIt<GetTokenOIDCInteractor>(),
      getIt<CreatePermanentTokenOIDCInteractor>(),
      getIt<DynamicUrlInterceptors>(),
    ));
  }

  void _provideHomeComponent() {
    getIt.registerFactory(() => HomeWidget());
    getIt.registerFactory(() => HomeViewModel(
      getIt<Store<AppState>>(),
      getIt<AppNavigation>(),
      getIt<GetAuthorizedInteractor>(),
      getIt<SaveAuthorizedUserInteractor>(),
      getIt<UploadFileManager>(),
      getIt<Connectivity>(),
      getIt<GetAllFunctionalityInteractor>(),
      getIt<GetBiometricSettingInteractor>()
    ));
  }

  void _provideMySpaceComponent() {
    getIt.registerFactory(() => MySpaceWidget());
    getIt.registerFactory(() => MySpaceViewModel(
      getIt.get<Store<AppState>>(),
      getIt.get<LocalFilePicker>(),
      getIt.get<AppNavigation>(),
      getIt.get<GetAllDocumentInteractor>(),
      getIt.get<DownloadFileInteractor>(),
      getIt<CopyMultipleFilesToSharedSpaceInteractor>(),
      getIt<RemoveMultipleDocumentsInteractor>(),
      getIt<DownloadMultipleFileIOSInteractor>(),
      getIt<SearchDocumentInteractor>(),
      getIt<DownloadPreviewDocumentInteractor>(),
      getIt<SortInteractor>(),
      getIt<GetSorterInteractor>(),
      getIt<SaveSorterInteractor>(),
      getIt<RenameDocumentInteractor>(),
      getIt<VerifyNameInteractor>(),
      getIt<DuplicateMultipleFilesInMySpaceInteractor>(),
      getIt<MakeAvailableOfflineDocumentInteractor>(),
      getIt<DisableAvailableOfflineDocumentInteractor>(),
      getIt<GetAllDocumentOfflineInteractor>(),
      getIt<EnableAvailableOfflineDocumentInteractor>(),
      getIt<AutoSyncOfflineManager>(),
      getIt<DeviceManager>()
    ));
  }

  void _provideUploadFileComponent() {
    getIt.registerFactory(() => UploadFileWidget());
    getIt.registerFactory(() => UploadFileViewModel(
      getIt.get<Store<AppState>>(),
      getIt.get<AppNavigation>(),
      getIt.get<UploadShareFileManager>(),
      getIt.get<GetAutoCompleteSharingInteractor>(),
      getIt.get<GetAutoCompleteSharingWithDeviceContactInteractor>()
    ));
  }

  void _provideInitializeComponent() {
    getIt.registerFactory(() => InitializeWidget());
    getIt.registerFactory(() => InitializeViewModel(
      getIt.get<Store<AppState>>(),
      getIt.get<GetCredentialInteractor>(),
      getIt.get<AppNavigation>(),
      getIt.get<DynamicUrlInterceptors>(),
      getIt.get<RetryAuthenticationInterceptors>(),
      getIt.get<UploadFileManager>(),
      getIt<Connectivity>(),
      getIt<GetBiometricSettingInteractor>(),
      getIt<DisableBiometricInteractor>(),
    ));
  }

  void _provideSideMenuComponent() {
    getIt.registerFactory(() => SideMenuDrawerWidget());
    getIt.registerFactory(() => SideMenuDrawerViewModel(
      getIt.get<Store<AppState>>(),
      getIt.get<AppNavigation>(),
      getIt.get<DeletePermanentTokenInteractor>(),
    ));
  }

  void _provideSharedSpaceComponent() {
    getIt.registerFactory(() => SharedSpaceWidget());
    getIt.registerFactory(() => SharedSpaceViewModel(
      getIt.get<Store<AppState>>(),
      getIt.get<AppNavigation>(),
      getIt.get<GetAllSharedSpacesInteractor>(),
      getIt<SearchSharedSpaceNodeNestedInteractor>(),
      getIt.get<RemoveMultipleSharedSpacesInteractor>(),
      getIt.get<CreateWorkGroupInteractor>(),
      getIt.get<VerifyNameInteractor>(),
      getIt<SortInteractor>(),
      getIt<GetSorterInteractor>(),
      getIt<SaveSorterInteractor>(),
      getIt<RenameWorkGroupInteractor>(),
      getIt<RenameDriveInteractor>(),
      getIt<GetAllSharedSpaceOfflineInteractor>(),
      getIt<CreateNewDriveInteractor>(),
      getIt<CreateNewWorkSpaceInteractor>(),
    ));
  }

  void _provideWorkgroupComponent() {
    getIt.registerFactory(() => WorkGroupWidget());
    getIt.registerFactory(() => WorkGroupViewModel(
      getIt.get<Store<AppState>>(),
      getIt.get<AppNavigation>(),
      getIt<GetAllWorkgroupsInteractor>(),
      getIt<GetAllWorkgroupsOfflineInteractor>(),
      getIt<SearchWorkgroupInsideDriveInteractor>(),
      getIt<RemoveMultipleSharedSpacesInteractor>(),
      getIt<CreateWorkGroupInteractor>(),
      getIt<VerifyNameInteractor>(),
      getIt<SortInteractor>(),
      getIt<GetSorterInteractor>(),
      getIt<SaveSorterInteractor>(),
      getIt<RenameWorkGroupInteractor>(),
    ));
  }

  void _provideSharedSpaceDocumentComponent() {
    getIt.registerFactory(() => SharedSpaceDocumentNodeViewModel(
        getIt.get<Store<AppState>>(),
        getIt.get<AppNavigation>(),
        getIt.get<LocalFilePicker>(),
        getIt.get<VerifyNameInteractor>(),
        getIt.get<GetAllChildNodesInteractor>(),
        getIt.get<CreateSharedSpaceFolderInteractor>(),
        getIt.get<GetSorterInteractor>(),
        getIt.get<SaveSorterInteractor>(),
        getIt.get<SortInteractor>(),
        getIt.get<RenameSharedSpaceNodeInteractor>(),
        getIt.get<SearchWorkGroupNodeInteractor>(),
        getIt.get<DownloadWorkGroupNodeInteractor>(),
        getIt.get<DownloadPreviewWorkGroupDocumentInteractor>(),
        getIt.get<DownloadMultipleNodeIOSInteractor>(),
        getIt.get<CopyMultipleFilesToMySpaceInteractor>(),
        getIt.get<CopyMultipleFilesToSharedSpaceInteractor>(),
        getIt.get<RemoveMultipleSharedSpaceNodesInteractor>(),
        getIt.get<GetSharedSpaceNodeInteractor>(),
        getIt.get<MakeAvailableOfflineSharedSpaceDocumentInteractor>(),
        getIt.get<DisableAvailableOfflineWorkGroupDocumentInteractor>(),
        getIt.get<GetAllSharedSpaceDocumentOfflineInteractor>(),
        getIt.get<AutoSyncOfflineManager>(),
        getIt.get<EnableAvailableOfflineSharedSpaceDocumentInteractor>(),
        getIt<DeviceManager>(),
        getIt<GetSharedSpacesRootNodeInfoInteractor>(),
        getIt<MoveMultipleWorkgroupNodesInteractor>(),
        getIt.get<AdvanceSearchWorkgroupNodeInteractor>()
    ));
  }

  void _provideCurrentUploadsComponent() {
    getIt.registerFactory(() => CurrentUploadsWidget());
    getIt.registerFactory(() => CurrentUploadsViewModel(
      getIt.get<Store<AppState>>(),
      getIt.get<AppNavigation>()
    ));
  }

  void _provideDestinationPickerComponent() {
    getIt.registerFactory(() => DestinationPickerWidget());
    getIt.registerFactory(() => DestinationPickerViewModel(
      getIt.get<Store<AppState>>(),
      getIt.get<GetAllSharedSpacesInteractor>(),
      getIt.get<AppNavigation>(),
      getIt.get<VerifyNameInteractor>(),
      getIt.get<CreateSharedSpaceFolderInteractor>(),
      getIt.get<GetAllWorkgroupsInteractor>(),
      getIt.get<SortInteractor>(),
      getIt.get<GetSorterInteractor>(),
      getIt.get<SaveSorterInteractor>(),
    ));
  }

  void _provideAccountDetailsComponent() {
    getIt.registerFactory(() => AccountDetailsWidget());
    getIt.registerFactory(() => AccountDetailsViewModel(
      getIt.get<Store<AppState>>(),
      getIt.get<DeletePermanentTokenInteractor>(),
      getIt.get<DeleteTokenOidcInteractor>(),
      getIt.get<AppNavigation>(),
      getIt.get<IsAvailableBiometricInteractor>(),
      getIt.get<GetAuthorizedInteractor>(),
      getIt.get<DisableBiometricInteractor>(),
      getIt.get<GetLastLoginInteractor>(),
      getIt.get<GetQuotaInteractor>(),
      getIt.get<DeleteAllOfflineDocumentInteractor>(),
      getIt.get<DeleteAllSharedSpaceOfflineInteractor>(),
      getIt.get<SaveAuthorizedUserInteractor>(),
      getIt.get<SaveLastLoginInteractor>(),
      getIt.get<SaveQuotaInteractor>(),
      getIt<LogoutOidcInteractor>()
    ));
  }

  void _provideReceivedShareWidgetComponent() {
    getIt.registerFactory(() => ReceivedShareWidget());
    getIt.registerFactory(() => ReceivedShareViewModel(
        getIt.get<Store<AppState>>(),
        getIt.get<GetAllReceivedSharesInteractor>(),
        getIt.get<AppNavigation>(),
        getIt.get<CopyMultipleFilesFromReceivedSharesToMySpaceInteractor>(),
        getIt.get<DownloadReceivedSharesInteractor>(),
        getIt.get<DownloadPreviewReceivedShareInteractor>(),
        getIt<GetSorterInteractor>(),
        getIt<SaveSorterInteractor>(),
        getIt<SortInteractor>(),
        getIt.get<SearchReceivedSharesInteractor>(),
        getIt<DeviceManager>(),
        getIt<RemoveMultipleReceivedSharesInteractor>(),
        getIt<ExportMultipleReceivedSharesInteractor>(),
        getIt<CopyMultipleFilesToSharedSpaceInteractor>(),
        getIt<MakeReceivedShareOfflineInteractor>(),
        getIt<DisableOfflineReceivedShareInteractor>(),
    ));
  }

  void _provideSharedSpaceDetailsWidgetComponent() {
    getIt.registerFactory(() => SharedSpaceDetailsWidget());
    getIt.registerFactory(() => SharedSpaceDetailsViewModel(
        getIt.get<Store<AppState>>(),
        getIt.get<AppNavigation>(),
        getIt.get<GetSharedSpaceInteractor>(),
        getIt.get<GetQuotaInteractor>(),
        getIt.get<GetAllSharedSpaceMembersInteractor>(),
        getIt.get<SharedSpaceActivitiesInteractor>(),
        getIt.get<GetAllSharedSpaceRolesInteractor>(),
        getIt.get<UpdateSharedSpaceMemberInteractor>(),
        getIt.get<UpdateDriveMemberInteractor>(),
        getIt.get<DeleteSharedSpaceMemberInteractor>(),
        getIt.get<EnableVersioningWorkgroupInteractor>(),
    ));
  }

  void _provideAddDriveMemberWidgetComponent() {
    getIt.registerFactory(() => AddDriveMemberWidget());
    getIt.registerFactory(() => AddDriveMemberViewModel(
      getIt.get<Store<AppState>>(),
      getIt.get<AppNavigation>(),
      getIt.get<GetSharedSpaceInteractor>(),
      getIt.get<GetAllSharedSpaceMembersInteractor>(),
      getIt.get<GetAutoCompleteSharingInteractor>(),
      getIt.get<AddSharedSpaceMemberInteractor>(),
      getIt.get<GetAllSharedSpaceRolesInteractor>(),
      getIt.get<DeleteSharedSpaceMemberInteractor>(),
      getIt.get<UpdateDriveMemberInteractor>(),
    ));
  }

  void _provideAddSharedSpaceMemberComponent() {
    getIt.registerFactory(() => AddSharedSpaceMemberWidget());
    getIt.registerFactory(() => AddSharedSpaceMemberViewModel(
          getIt.get<Store<AppState>>(),
          getIt.get<AppNavigation>(),
          getIt.get<GetSharedSpaceInteractor>(),
          getIt.get<GetAutoCompleteSharingInteractor>(),
          getIt.get<AddSharedSpaceMemberInteractor>(),
          getIt.get<UpdateSharedSpaceMemberInteractor>(),
          getIt.get<GetAllSharedSpaceMembersInteractor>(),
          getIt.get<SharedSpaceActivitiesInteractor>(),
          getIt.get<DeleteSharedSpaceMemberInteractor>(),
        ));
  }

  void _provideDocumentDetailsComponent() {
    getIt.registerFactory(() => DocumentDetailsWidget());
    getIt.registerFactory(() => DocumentDetailsViewModel(
        getIt.get<Store<AppState>>(),
        getIt.get<AppNavigation>(),
        getIt.get<GetDocumentInteractor>(),
        getIt.get<EditDescriptionDocumentInteractor>()
    ));
  }

  void _provideAuthenticationWidgetComponent() {
    getIt.registerFactory(() => AuthenticationWidget());
    getIt.registerFactory(() => AuthenticationViewModel(
        getIt<Store<AppState>>(),
        getIt<GetAuthorizedInteractor>(),
        getIt<DeletePermanentTokenInteractor>(),
        getIt<AppNavigation>(),
        getIt<SaveAuthorizedUserInteractor>(),
    ));
  }

  void _provideEnterOTPWidgetComponent() {
    getIt.registerFactory(() => EnterOTPWidget());
    getIt.registerFactory(() => EnterOTPViewModel(
        getIt<Store<AppState>>(),
        getIt<AppNavigation>(),
        getIt<CreatePermanentTokenInteractor>(),
        getIt<CreatePermanentTokenOIDCInteractor>(),
        getIt<DynamicUrlInterceptors>(),
        getIt<AppToast>()
    ));
  }

  void _provide2FAWidgetComponent() {
    getIt.registerFactory(() => SecondFactorAuthenticationWidget());
    getIt.registerFactory(() => SecondFactorAuthenticationViewModel(
      getIt<Store<AppState>>(),
      getIt<AppNavigation>(),));
  }

  void _provideSharedSpaceNodeDetailsComponent() {
    getIt.registerFactory(() => SharedSpaceNodeDetailsWidget());
    getIt.registerFactory(() => SharedSpaceNodeDetailsViewModel(
        getIt.get<Store<AppState>>(),
        getIt.get<AppNavigation>(),
        getIt.get<GetSharedSpaceNodeInteractor>()
    ));
  }

  void _provideBiometricAuthenticationSettingComponent() {
    getIt.registerFactory(() => BiometricAuthenticationSettingWidget());
    getIt.registerFactory(() =>
      BiometricAuthenticationSettingViewModel(
        getIt.get<Store<AppState>>(),
        getIt.get<AppNavigation>(),
        getIt.get<AuthenticationBiometricInteractor>(),
        getIt.get<EnableBiometricInteractor>(),
        getIt.get<GetAvailableBiometricInteractor>(),
        getIt.get<GetBiometricSettingInteractor>(),
        getIt.get<DisableBiometricInteractor>()
      ));
  }

  void _provideSharedSpaceNodeVersionsComponent() {
    getIt.registerFactory(() => SharedSpaceNodeVersionsWidget());
    getIt.registerFactory(() => SharedSpaceNodeVersionsViewModel(
        getIt.get<Store<AppState>>(),
        getIt.get<AppNavigation>(),
        getIt.get<GetAllChildNodesInteractor>(),
        getIt.get<RestoreWorkGroupDocumentVersionInteractor>(),
        getIt.get<DownloadPreviewWorkGroupDocumentInteractor>(),
        getIt.get<RemoveSharedSpaceNodeInteractor>(),
        getIt.get<DownloadNodeIOSInteractor>(),
        getIt.get<DeviceManager>(),
        getIt.get<DownloadWorkGroupNodeInteractor>(),
        getIt.get<CopyToMySpaceInteractor>(),
        getIt.get<CopyDocumentsToSharedSpaceInteractor>(),
    ));
  }

  void _provideBiometricAuthenticationLoginComponent() {
    getIt.registerFactory(() => BiometricAuthenticationLoginWidget());
    getIt.registerFactory(() =>
      BiometricAuthenticationLoginViewModel(
        getIt.get<Store<AppState>>(),
        getIt.get<AppNavigation>(),
        getIt.get<AuthenticationBiometricInteractor>(),
        getIt.get<GetAvailableBiometricInteractor>(),
        getIt.get<DeletePermanentTokenInteractor>(),
        getIt.get<DisableBiometricInteractor>()
      ));
  }

  void _provideUploadRequestGroupComponent() {
    getIt.registerFactory(() => CreatedUploadRequestGroupWidget());
    getIt.registerFactory(() => ActiveClosedUploadRequestGroupWidget());
    getIt.registerFactory(() => ArchivedUploadRequestGroupWidget());
    getIt.registerFactory(() => UploadRequestGroupWidget());
		getIt.registerFactory(() => UploadRequestGroupViewModel(
				getIt.get<Store<AppState>>(),
        getIt.get<AppNavigation>()
		));
    getIt.registerFactory(() => CreatedUploadRequestGroupViewModel(
        getIt.get<Store<AppState>>(),
        getIt.get<AppNavigation>(),
        getIt.get<GetAllUploadRequestGroupsInteractor>(),
        getIt<GetSorterInteractor>(),
        getIt<SaveSorterInteractor>(),
        getIt<SortInteractor>(),
        getIt<SearchUploadRequestGroupsInteractor>(),
        getIt.get<UpdateMultipleUploadRequestGroupStateInteractor>(),
    ));
		getIt.registerFactory(() => ActiveClosedUploadRequestGroupViewModel(
        getIt.get<Store<AppState>>(),
        getIt.get<AppNavigation>(),
        getIt.get<GetAllUploadRequestGroupsInteractor>(),
        getIt<GetSorterInteractor>(),
        getIt<SaveSorterInteractor>(),
        getIt<SortInteractor>(),
        getIt<SearchUploadRequestGroupsInteractor>(),
        getIt.get<UpdateMultipleUploadRequestGroupStateInteractor>(),
    ));
		getIt.registerFactory(() => ArchivedUploadRequestGroupViewModel(
        getIt.get<Store<AppState>>(),
        getIt.get<AppNavigation>(),
        getIt.get<GetAllUploadRequestGroupsInteractor>(),
        getIt<GetSorterInteractor>(),
        getIt<SaveSorterInteractor>(),
        getIt<SortInteractor>(),
        getIt<SearchUploadRequestGroupsInteractor>(),
        getIt.get<UpdateMultipleUploadRequestGroupStateInteractor>()
    ));
  }

  void _provideUploadRequestCreationComponent() {
    getIt.registerFactory(() => UploadRequestCreationWidget());
    getIt.registerFactory(() => UploadRequestCreationViewModel(
        getIt.get<Store<AppState>>(),
        getIt.get<AppNavigation>(),
        getIt.get<AddNewUploadRequestInteractor>(),
        getIt.get<GetAllUploadRequestGroupsInteractor>(),
        getIt.get<GetAutoCompleteSharingInteractor>(),
        getIt.get<GetAutoCompleteSharingWithDeviceContactInteractor>(),
        getIt.get<AppToast>(),
    ));
  }

  void _provideEditUploadRequestComponent() {
    getIt.registerFactory(() => EditUploadRequestWidget());
    getIt.registerFactory(() => EditUploadRequestViewModel(
      getIt.get<Store<AppState>>(),
      getIt.get<AppNavigation>(),
      getIt.get<AppToast>(),
      getIt.get<EditUploadRequestGroupInteractor>(),
      getIt.get<GetUploadRequestInteractor>(),
      getIt.get<EditUploadRequestRecipientInteractor>(),
    ));
  }

  void _provideUploadRequestInsideComponent() {
    getIt.registerFactory(() =>
        PendingUploadRequestInsideViewModel(
          getIt.get<Store<AppState>>(),
          getIt.get<AppNavigation>(),
          getIt<DeviceManager>(),
          getIt<DownloadUploadRequestEntriesInteractor>(),
          getIt<UpdateMultipleUploadRequestStateInteractor>(),
          getIt<RemoveMultipleUploadRequestEntryInteractor>(),
          getIt<DownloadMultipleUploadRequestEntryIOSInteractor>(),
          getIt<CopyMultipleFilesFromUploadRequestEntriesToMySpaceInteractor>(),
          getIt<SearchUploadRequestEntriesInteractor>(),
          getIt<SearchRecipientsUploadRequestInteractor>(),
          getIt<GetSorterInteractor>(),
          getIt<SaveSorterInteractor>(),
          getIt<SortInteractor>(),
          getIt.get<GetAllUploadRequestsInteractor>(),
          getIt.get<GetAllUploadRequestEntriesInteractor>(),
        ));

    getIt.registerFactory(() =>
      ActiveCloseUploadRequestInsideViewModel(
        getIt.get<Store<AppState>>(),
        getIt.get<AppNavigation>(),
        getIt<DeviceManager>(),
        getIt<DownloadUploadRequestEntriesInteractor>(),
        getIt<UpdateMultipleUploadRequestStateInteractor>(),
        getIt<RemoveMultipleUploadRequestEntryInteractor>(),
        getIt<DownloadMultipleUploadRequestEntryIOSInteractor>(),
        getIt<CopyMultipleFilesFromUploadRequestEntriesToMySpaceInteractor>(),
        getIt<SearchUploadRequestEntriesInteractor>(),
        getIt<SearchRecipientsUploadRequestInteractor>(),
        getIt<GetSorterInteractor>(),
        getIt<SaveSorterInteractor>(),
        getIt<SortInteractor>(),
        getIt.get<GetAllUploadRequestsInteractor>(),
        getIt.get<GetAllUploadRequestEntriesInteractor>(),
      ));

    getIt.registerFactory(() =>
      ArchivedUploadRequestInsideViewModel(
        getIt.get<Store<AppState>>(),
        getIt.get<AppNavigation>(),
        getIt<DeviceManager>(),
        getIt<DownloadUploadRequestEntriesInteractor>(),
        getIt<UpdateMultipleUploadRequestStateInteractor>(),
        getIt<RemoveMultipleUploadRequestEntryInteractor>(),
        getIt<DownloadMultipleUploadRequestEntryIOSInteractor>(),
        getIt<CopyMultipleFilesFromUploadRequestEntriesToMySpaceInteractor>(),
        getIt<SearchUploadRequestEntriesInteractor>(),
        getIt<SearchRecipientsUploadRequestInteractor>(),
        getIt<GetSorterInteractor>(),
        getIt<SaveSorterInteractor>(),
        getIt<SortInteractor>(),
        getIt.get<GetAllUploadRequestsInteractor>(),
        getIt.get<GetAllUploadRequestEntriesInteractor>(),
      ));
  }

  void _provideUploadRequestFileDetailsComponent() {
    getIt.registerFactory(() => UploadRequestFileDetailsWidget());
    getIt.registerFactory(() => UploadRequestFileDetailsViewModel(
      getIt.get<Store<AppState>>(),
      getIt.get<AppNavigation>(),
      getIt.get<GetUploadRequestEntryActivitiesInteractor>(),
    ));
  }

  void _provideHomeAppBarComponent() {
    getIt.registerFactory(() => HomeAppBarWidget());
    getIt.registerFactory(() => HomeAppBarViewModel(
        getIt.get<Store<AppState>>(),
    ));
  }

  void _provideReceivedShareDetailsComponent() {
    getIt.registerFactory(() => ReceivedShareDetailsWidget());
    getIt.registerFactory(() =>
      ReceivedShareDetailsViewModel(
        getIt.get<Store<AppState>>(),
        getIt.get<AppNavigation>(),
        getIt.get<GetReceivedShareInteractor>(),
      ));
  }

  void _provideAddRecipientsUploadRequestGroupComponent() {
    getIt.registerFactory(() => AddRecipientsUploadRequestGroupWidget());
    getIt.registerFactory(() => AddRecipientsUploadRequestGroupViewModel(
        getIt.get<Store<AppState>>(),
        getIt.get<AppNavigation>(),
        getIt.get<GetAutoCompleteSharingInteractor>(),
        getIt.get<GetAutoCompleteSharingWithDeviceContactInteractor>(),
        getIt.get<AddRecipientsToUploadRequestGroupInteractor>(),
        getIt.get<GetAllUploadRequestsInteractor>()
    ));
  }

  void _provideWidgetCommonView() {
    getIt.registerFactory(() => UploadRequestGroupCommonView());
    getIt.registerFactory(() => CommonView());
  }

  void _provideAdvanceSearchWidgetComponent() {
    getIt.registerFactory(() => AdvanceSearchSettingsWidget());
    getIt.registerFactory(() => AdvanceSearchSettingsViewModel(
      getIt.get<Store<AppState>>(),
      getIt.get<AppNavigation>(),
      getIt.get<AdvanceSearchWorkgroupNodeInteractor>(),
    ));
  }

  void _provideUploadRequestGroupDetailsWidgetComponent() {
    getIt.registerFactory(() => UploadRequestGroupDetailsWidget());
    getIt.registerFactory(() => UploadRequestGroupDetailsViewModel(
      getIt.get<Store<AppState>>(),
      getIt.get<AppNavigation>(),
      getIt.get<GetUploadRequestGroupInteractor>(),
      getIt.get<GetAllUploadRequestsInteractor>(),
    ));
  }

  void _provideUploadRequestRecipientDetailsWidgetComponent() {
    getIt.registerFactory(() => UploadRequestRecipientDetailsWidget());
    getIt.registerFactory(() => UploadRequestRecipientDetailsViewModel(
      getIt.get<Store<AppState>>(),
      getIt.get<AppNavigation>(),
      getIt.get<GetUploadRequestInteractor>(),
      getIt.get<GetUploadRequestActivitiesInteractor>(),
    ));
  }
}
