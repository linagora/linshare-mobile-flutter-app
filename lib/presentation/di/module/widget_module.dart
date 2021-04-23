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
import 'package:linshare_flutter_app/presentation/manager/upload_and_share_file/upload_and_share_file_manager.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_toast.dart';
import 'package:linshare_flutter_app/presentation/util/local_file_picker.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/widget/account_details/account_details_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/account_details/account_details_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/authentication/authentication_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/authentication/authentication_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/current_uploads/current_uploads_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/current_uploads/current_uploads_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/destination_picker/destination_picker_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/destination_picker/destination_picker_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/enter_otp/enter_otp_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/enter_otp/enter_otp_widget.dart';
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
import 'package:linshare_flutter_app/presentation/widget/second_factor_authentication/second_factor_authentication_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/second_factor_authentication/second_factor_authentication_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space/shared_space_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space/shared_space_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_details/add_shared_space_member/add_shared_space_member_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_details/add_shared_space_member/add_shared_space_member_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_details/shared_space_details_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_details/shared_space_details_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_document_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_node_details/shared_space_node_details_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_node_details/shared_space_node_details_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/side_menu/side_menu_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/side_menu/side_menu_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/upload_file_manager.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/upload_file_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/upload_file_widget.dart';
import 'package:redux/redux.dart';

class WidgetModule {
  WidgetModule() {
    _provideLoginComponent();
    _provideHomeComponent();
    _provideMySpaceComponent();
    _provideUploadFileComponent();
    _provideInitializeComponent();
    _provideSideMenuComponent();
    _provideSharedSpaceComponent();
    _provideSharedSpaceDocumentComponent();
    _provideCurrentUploadsComponent();
    _provideDestinationPickerComponent();
    _provideAccountDetailsComponent();
    _provideReceivedShareWidgetComponent();
    _provideSharedSpaceDetailsWidgetComponent();
    _provideAuthenticationWidgetComponent();
    _provideEnterOTPWidgetComponent();
    _provide2FAWidgetComponent();
    _provideAddSharedSpaceMemberComponent();
    _provideDocumentDetailsComponent();
    _provideSharedSpaceNodeDetailsComponent();
  }

  void _provideLoginComponent() {
    getIt.registerFactory(() => LoginWidget());
    getIt.registerFactory(() => LoginViewModel(
      getIt.get<Store<AppState>>(),
      getIt.get<CreatePermanentTokenInteractor>(),
      getIt.get<AppNavigation>(),
      getIt.get<DynamicUrlInterceptors>()
    ));
  }

  void _provideHomeComponent() {
    getIt.registerFactory(() => HomeWidget());
    getIt.registerFactory(() => HomeViewModel(
      getIt<Store<AppState>>(),
      getIt<AppNavigation>(),
      getIt<GetAuthorizedInteractor>(),
      getIt<UploadFileManager>(),
      getIt<Connectivity>(),
      getIt<GetAllFunctionalityInteractor>()
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
      getIt<VerifyNameInteractor>()
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
      getIt.get<AppNavigation>()
    ));
  }

  void _provideAccountDetailsComponent() {
    getIt.registerFactory(() => AccountDetailsWidget());
    getIt.registerFactory(() => AccountDetailsViewModel(
      getIt.get<Store<AppState>>(),
      getIt.get<DeletePermanentTokenInteractor>(),
      getIt.get<AppNavigation>(),
      getIt.get<IsAvailableBiometricInteractor>()
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
        getIt.get<SearchReceivedSharesInteractor>()
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
        getIt.get<DeleteSharedSpaceMemberInteractor>(),
    ));
  }

  void _provideAddSharedSpaceMemberComponent() {
    getIt.registerFactory(() => AddSharedSpaceMemberWidget());
    getIt.registerFactory(() => AddSharedSpaceMemberViewModel(
          getIt.get<Store<AppState>>(),
          getIt.get<AppNavigation>(),
          getIt.get<GetAutoCompleteSharingInteractor>(),
          getIt.get<AddSharedSpaceMemberInteractor>(),
          getIt.get<UpdateSharedSpaceMemberInteractor>(),
          getIt.get<GetAllSharedSpaceMembersInteractor>(),
          getIt.get<DeleteSharedSpaceMemberInteractor>(),
        ));
  }

  void _provideDocumentDetailsComponent() {
    getIt.registerFactory(() => DocumentDetailsWidget());
    getIt.registerFactory(() => DocumentDetailsViewModel(
        getIt.get<Store<AppState>>(),
        getIt.get<AppNavigation>(),
        getIt.get<GetDocumentInteractor>(),
    ));
  }

  void _provideAuthenticationWidgetComponent() {
    getIt.registerFactory(() => AuthenticationWidget());
    getIt.registerFactory(() => AuthenticationViewModel(
        getIt<Store<AppState>>(),
        getIt<GetAuthorizedInteractor>(),
        getIt<DeletePermanentTokenInteractor>(),
        getIt<AppNavigation>()
    ));
  }

  void _provideEnterOTPWidgetComponent() {
    getIt.registerFactory(() => EnterOTPWidget());
    getIt.registerFactory(() => EnterOTPViewModel(
        getIt<Store<AppState>>(),
        getIt<AppNavigation>(),
        getIt<CreatePermanentTokenInteractor>(),
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
}
