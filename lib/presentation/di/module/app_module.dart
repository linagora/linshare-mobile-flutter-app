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
import 'package:device_info/device_info.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/manager/offline_mode/auto_sync_offline_manager.dart';
import 'package:linshare_flutter_app/presentation/manager/upload_and_share_file/upload_and_share_file_manager.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/app_toast.dart';
import 'package:linshare_flutter_app/presentation/util/audio_recorder.dart';
import 'package:linshare_flutter_app/presentation/util/file_path_util.dart';
import 'package:linshare_flutter_app/presentation/util/generate_password_utils.dart';
import 'package:linshare_flutter_app/presentation/util/helper/file_helper.dart';
import 'package:linshare_flutter_app/presentation/util/helper/responsive_utils.dart';
import 'package:linshare_flutter_app/presentation/util/lifecycle_event_handler.dart';
import 'package:linshare_flutter_app/presentation/util/local_file_picker.dart';
import 'package:linshare_flutter_app/presentation/util/media_picker_from_camera.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/util/toast_message_handler.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/upload_file_manager.dart';
import 'package:local_auth/local_auth.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppModule {
  AppModule() {
    _provideHive();
    _provideAppAuth();
    _provideDataSourceImpl();
    _provideDataSource();
    _provideRepositoryImpl();
    _provideRepository();
    _provideInteractor();
    _provideSharePreference();
    _provideAppNavigation();
    _provideDeviceManager();
    _provideAppImagePaths();
    _provideFileManager();
    _provideResponsiveManager();
    _provideAppToast();
    _provideNetworkStateComponent();
    _provideLocalAuthentication();
    _provideBiometric();
    _provideOfflineMode();
    _provideObservers();
    _provideStopWatch();
  }

  void _provideHive() {
    getIt.registerFactory(() => AppModeCacheClient());
    getIt.registerFactory(() => CachingManager(getIt<AppModeCacheClient>()));
  }

  void _provideDataSourceImpl() {
    getIt.registerFactory(() => AuthenticationOIDCDataSourceImpl(
        getIt<LinShareHttpClient>(),
        getIt<RemoteExceptionThrower>(),
        getIt<FlutterAppAuth>(),
        getIt<DeviceManager>(),
        getIt<OIDCParser>(),
        getIt<SharedPreferences>()
    ));
    getIt.registerFactory(() => AuthenticationSaaSDataSourceImpl(
        getIt<SaaSHttpClient>(),
        getIt<RemoteExceptionThrower>(),
    ));
    getIt.registerFactory(() => AuthenticationDataSourceImpl(
        getIt<LinShareHttpClient>(),
        getIt<DeviceManager>(),
        getIt<RemoteExceptionThrower>()));
    getIt.registerLazySingleton(() => LocalAuthenticationDataSource(getIt<SharedPreferences>()));
    getIt.registerFactory(() => HiveSettingsDatasource(getIt<AppModeCacheClient>()));
    getIt.registerFactory(() => DocumentDataSourceImpl(
        getIt<LinShareHttpClient>(),
        getIt<RemoteExceptionThrower>(),
        getIt<LinShareDownloadManager>()));
    getIt.registerFactory(() => SharedSpaceDataSourceImpl(
        getIt<LinShareHttpClient>(),
        getIt<RemoteExceptionThrower>()));
    getIt.registerFactory(() => AutoCompleteDataSourceImpl(
        getIt<LinShareHttpClient>(),
        getIt<RemoteExceptionThrower>()));
    getIt.registerFactory(() => SharedSpaceDocumentDataSourceImpl(
        getIt<LinShareHttpClient>(),
        getIt<RemoteExceptionThrower>(),
        getIt<LinShareDownloadManager>()));
    getIt.registerLazySingleton(() => FileUploadDataSourceImpl(
        getIt.get<FlowUploader>())
    );
    getIt.registerFactory(() => ReceivedShareDataSourceImpl(
        getIt<LinShareHttpClient>(),
        getIt<RemoteExceptionThrower>(),
        getIt<LinShareDownloadManager>()));
    getIt.registerLazySingleton(() => QuotaDataSourceImpl(
        getIt<LinShareHttpClient>(),
        getIt<RemoteExceptionThrower>()));
    getIt.registerLazySingleton(() => LocalQuotaDataSource(getIt<SharedPreferences>()));
    getIt.registerLazySingleton(() => FunctionalityDataSourceImpl(
        getIt<LinShareHttpClient>(),
        getIt<RemoteExceptionThrower>()));
    getIt.registerFactory(() => SortDataSourceImpl(
        getIt<SharedPreferences>()));
    getIt.registerFactory(() => ContactDataSourceImpl());
    getIt.registerLazySingleton(() => SharedSpaceMemberDataSourceImpl(
        getIt<LinShareHttpClient>(),
        getIt<RemoteExceptionThrower>()));
    getIt.registerLazySingleton(() => SharedSpaceActivitiesDataSourceImpl(
        getIt<LinShareHttpClient>(),
        getIt<RemoteExceptionThrower>()));
    getIt.registerFactory(() => BiometricDataSourceImpl(
        getIt<LocalBiometricService>(),
        getIt<BiometricExceptionThrower>(),
        getIt<SharedPreferences>()));
    getIt.registerFactory(() => LocalDocumentDataSourceImpl(getIt<DocumentDatabaseManager>()));
    getIt.registerFactory(() => LocalReceivedShareDataSource(getIt<ReceivedShareDatabaseManager>()));
    getIt.registerFactory(() => UploadRequestGroupDataSourceImpl(
        getIt<LinShareHttpClient>(),
        getIt<RemoteExceptionThrower>()));
    getIt.registerFactory(() => UploadRequestDataSourceImpl(
        getIt<LinShareHttpClient>(),
        getIt<RemoteExceptionThrower>()));
    getIt.registerFactory(() => UploadRequestEntryDataSourceImpl(
        getIt<LinShareHttpClient>(),
        getIt<RemoteExceptionThrower>(),
        getIt<LinShareDownloadManager>()));
    getIt.registerFactory(() => AuditUserDataSourceImpl(
        getIt<LinShareHttpClient>(),
        getIt<RemoteExceptionThrower>()));
    getIt.registerLazySingleton(() => LocalAuditUserDataSource(getIt<SharedPreferences>()));
    getIt.registerFactory(() => SharedSpaceNodeDataSourceImpl(
        getIt<LinShareHttpClient>(),
        getIt<RemoteExceptionThrower>()));
    getIt.registerFactory(() => LocalSharedSpaceNodeDataSource(getIt<SharedSpaceDocumentDatabaseManager>()));
  }

  void _provideDataSource() {
    getIt.registerFactory<AuthenticationDataSource>(() => getIt<AuthenticationDataSourceImpl>());
    getIt.registerFactory<AuthenticationOIDCDataSource>(() => getIt<AuthenticationOIDCDataSourceImpl>());
    getIt.registerFactory<AuthenticationSaaSDataSource>(() => getIt<AuthenticationSaaSDataSourceImpl>());
    getIt.registerFactory<SettingsDatasource>(() => getIt<HiveSettingsDatasource>());
    getIt.registerFactory<DocumentDataSource>(() => getIt<DocumentDataSourceImpl>());
    getIt.registerFactory<SharedSpaceDataSource>(() => getIt<SharedSpaceDataSourceImpl>());
    getIt.registerFactory<AutoCompleteDataSource>(() => getIt<AutoCompleteDataSourceImpl>());
    getIt.registerFactory<SharedSpaceDocumentDataSource>(() => getIt<SharedSpaceDocumentDataSourceImpl>());
    getIt.registerFactory<FileUploadDataSource>(() => getIt<FileUploadDataSourceImpl>());
    getIt.registerFactory<QuotaDataSource>(() => getIt<QuotaDataSourceImpl>());
    getIt.registerFactory<ReceivedShareDataSource>(() => getIt<ReceivedShareDataSourceImpl>());
    getIt.registerFactory<FunctionalityDataSource>(() => getIt<FunctionalityDataSourceImpl>());
    getIt.registerFactory<SortDataSource>(() => getIt<SortDataSourceImpl>());
    getIt.registerFactory<ContactDataSource>(() => getIt<ContactDataSourceImpl>());
    getIt.registerFactory<SharedSpaceMemberDataSource>(() => getIt<SharedSpaceMemberDataSourceImpl>());
    getIt.registerFactory<SharedSpaceActivitiesDataSource>(() => getIt<SharedSpaceActivitiesDataSourceImpl>());
    getIt.registerFactory<BiometricDataSource>(() => getIt<BiometricDataSourceImpl>());
    getIt.registerFactory<UploadRequestGroupDataSource>(() => getIt<UploadRequestGroupDataSourceImpl>());
    getIt.registerFactory<UploadRequestDataSource>(() => getIt<UploadRequestDataSourceImpl>());
    getIt.registerFactory<UploadRequestEntryDataSource>(() => getIt<UploadRequestEntryDataSourceImpl>());
    getIt.registerFactory<AuditUserDataSource>(() => getIt<AuditUserDataSourceImpl>());
    getIt.registerFactory<SharedSpaceNodeDataSource>(() => getIt<SharedSpaceNodeDataSourceImpl>());
  }

  void _provideRepositoryImpl() {
    getIt.registerFactory(() => FlowUploaderImpl(getIt<DioClient>()));
    getIt.registerFactory(() => AuthenticationRepositoryImpl({
      DataSourceType.network : getIt<AuthenticationDataSource>(),
      DataSourceType.local : getIt<LocalAuthenticationDataSource>()
    }));
    getIt.registerFactory(() => AuthenticationOIDCRepositoryImpl(
        getIt<AuthenticationOIDCDataSource>(),
        getIt<AuthenticationSaaSDataSource>()
    ));
    getIt.registerFactory(() => TokenRepositoryImpl(getIt<SharedPreferences>()));
    getIt.registerFactory(() => CredentialRepositoryImpl(getIt<SharedPreferences>()));
    getIt.registerFactory(() => SettingsRepositoryImpl(getIt<SettingsDatasource>()));
    getIt.registerFactory(() => SaaSConsoleRepositoryImpl());
    getIt.registerFactory(() => DocumentRepositoryImpl(
      {
        DataSourceType.network : getIt<DocumentDataSource>(),
        DataSourceType.local : getIt<LocalDocumentDataSourceImpl>()
      },
      getIt<FileUploadDataSource>()));
    getIt.registerFactory(() => SharedSpaceRepositoryImpl(
        {
          DataSourceType.network : getIt<SharedSpaceDataSource>(),
          DataSourceType.local : getIt<LocalSharedSpaceDataSourceImpl>()
        }
    ));
    getIt.registerFactory(() => AutoCompleteRepositoryImpl(getIt<AutoCompleteDataSource>()));
    getIt.registerFactory(() => SharedSpaceDocumentRepositoryImpl(
      {
        DataSourceType.network : getIt<SharedSpaceDocumentDataSource>(),
        DataSourceType.local : getIt<LocalSharedSpaceDocumentDataSourceImpl>()
      },
      getIt<FileUploadDataSource>()));
    getIt.registerFactory(() => QuotaRepositoryImpl({
      DataSourceType.network : getIt<QuotaDataSource>(),
      DataSourceType.local : getIt<LocalQuotaDataSource>()
    }));
    getIt.registerFactory(() => ReceivedShareRepositoryImpl(
      {
        DataSourceType.network : getIt<ReceivedShareDataSource>(),
        DataSourceType.local : getIt<LocalReceivedShareDataSource>()
      }));
    getIt.registerFactory(() => FunctionalityRepositoryImpl(getIt<FunctionalityDataSource>()));
    getIt.registerFactory(() => SortRepositoryImpl(getIt<SortDataSource>()));
    getIt.registerFactory(() => ContactRepositoryImpl(getIt<ContactDataSource>()));
    getIt.registerFactory(() => SharedSpaceMemberRepositoryImpl(getIt<SharedSpaceMemberDataSource>()));
    getIt.registerFactory(() => SharedSpaceActivitiesRepositoryImpl(getIt<SharedSpaceActivitiesDataSource>()));
    getIt.registerFactory(() => BiometricRepositoryImpl(getIt<BiometricDataSource>()));
    getIt.registerFactory(() => LocalSharedSpaceDocumentDataSourceImpl(getIt<SharedSpaceDocumentDatabaseManager>()));
    getIt.registerFactory(() => LocalSharedSpaceDataSourceImpl(getIt<SharedSpaceDocumentDatabaseManager>()));
    getIt.registerFactory(() => UploadRequestGroupRepositoryImpl(getIt<UploadRequestGroupDataSource>()));
    getIt.registerFactory(() => UploadRequestRepositoryImpl(getIt<UploadRequestDataSource>()));
    getIt.registerFactory(() => UploadRequestEntryRepositoryImpl(getIt<UploadRequestEntryDataSource>()));
    getIt.registerFactory(() => AuditUserRepositoryImpl({
      DataSourceType.network : getIt<AuditUserDataSource>(),
      DataSourceType.local : getIt<LocalAuditUserDataSource>()
    }));
    getIt.registerFactory(() => SharedSpaceNodeRepositoryImpl({
      DataSourceType.network : getIt<SharedSpaceNodeDataSource>(),
      DataSourceType.local : getIt<LocalSharedSpaceNodeDataSource>()
    }));
    getIt.registerFactory<APIRepository>(() => APIRepositoryImp(
      getIt<SharedPreferences>()
    ));
  }

  void _provideRepository() {
    getIt.registerFactory<SettingsRepository>(() => getIt<SettingsRepositoryImpl>());
    getIt.registerFactory<FlowUploader>(() => getIt<FlowUploaderImpl>());
    getIt.registerFactory<AuthenticationRepository>(() => getIt<AuthenticationRepositoryImpl>());
    getIt.registerFactory<AuthenticationOIDCRepository>(() => getIt<AuthenticationOIDCRepositoryImpl>());
    getIt.registerFactory<TokenRepository>(() => getIt<TokenRepositoryImpl>());
    getIt.registerFactory<CredentialRepository>(() => getIt<CredentialRepositoryImpl>());
    getIt.registerFactory<SaaSConsoleRepository>(() => getIt<SaaSConsoleRepositoryImpl>());
    getIt.registerFactory<DocumentRepository>(() => getIt<DocumentRepositoryImpl>());
    getIt.registerFactory<AutoCompleteRepository>(() => getIt<AutoCompleteRepositoryImpl>());
    getIt.registerFactory<SharedSpaceRepository>(() => getIt<SharedSpaceRepositoryImpl>());
    getIt.registerFactory<SharedSpaceDocumentRepository>(() => getIt<SharedSpaceDocumentRepositoryImpl>());
    getIt.registerFactory<QuotaRepository>(() => getIt<QuotaRepositoryImpl>());
    getIt.registerFactory<ReceivedShareRepository>(() => getIt<ReceivedShareRepositoryImpl>());
    getIt.registerFactory<FunctionalityRepository>(() => getIt<FunctionalityRepositoryImpl>());
    getIt.registerFactory<SortRepository>(() => getIt<SortRepositoryImpl>());
    getIt.registerFactory<ContactRepository>(() => getIt<ContactRepositoryImpl>());
    getIt.registerFactory<SharedSpaceMemberRepository>(() => getIt<SharedSpaceMemberRepositoryImpl>());
    getIt.registerFactory<SharedSpaceActivitiesRepository>(() => getIt<SharedSpaceActivitiesRepositoryImpl>());
    getIt.registerFactory<BiometricRepository>(() => getIt<BiometricRepositoryImpl>());
    getIt.registerFactory<UploadRequestGroupRepository>(() => getIt<UploadRequestGroupRepositoryImpl>());
    getIt.registerFactory<UploadRequestRepository>(() => getIt<UploadRequestRepositoryImpl>());
    getIt.registerFactory<UploadRequestEntryRepository>(() => getIt<UploadRequestEntryRepositoryImpl>());
    getIt.registerFactory<AuditUserRepository>(() => getIt<AuditUserRepositoryImpl>());
    getIt.registerFactory<SharedSpaceNodeRepository>(() => getIt<SharedSpaceNodeRepositoryImpl>());
  }

  void _provideInteractor() {
    getIt.registerFactory(() => CreatePermanentTokenInteractor(
      getIt<AuthenticationRepository>(),
      getIt<TokenRepository>(),
      getIt<CredentialRepository>(),
      getIt<APIRepository>()
    ));
    getIt.registerFactory(() => GetOIDCConfigurationInteractor(getIt<AuthenticationOIDCRepository>()));
    getIt.registerFactory(() => GetTokenOIDCInteractor(
      getIt<AuthenticationOIDCRepository>()));
    getIt.registerFactory(() => CreatePermanentTokenOIDCInteractor(
      getIt<AuthenticationOIDCRepository>(),
      getIt<TokenRepository>(),
      getIt<CredentialRepository>(),
      getIt<APIRepository>()
    ));
    getIt.registerFactory(() => GetQuotaInteractor(getIt<QuotaRepository>()));
    getIt.registerFactory(() => GetCredentialInteractor(
      getIt<TokenRepository>(),
      getIt<CredentialRepository>(),
      getIt<APIRepository>()
    ));
    getIt.registerFactory(() => GetAppModeInteractor(
      getIt<SettingsRepository>()
    ));
    getIt.registerFactory(() => SetAppModeInteractor(
      getIt<SettingsRepository>()
    ));
    getIt.registerFactory(() => GetSaaSConfigurationInteractor(getIt<SaaSConsoleRepository>()));
    getIt.registerFactory(() => GetSecretTokenInteractor(getIt<AuthenticationOIDCRepository>()));
    getIt.registerFactory(() => SignUpForSaaSInteractor(getIt<AuthenticationOIDCRepository>()));
    getIt.registerFactory(() => FlowUploadDocumentInteractor(getIt<DocumentRepository>()));
    getIt.registerFactory(() => FlowUploadWorkGroupDocumentInteractor(getIt<SharedSpaceDocumentRepository>()));
    getIt.registerFactory(() => GetAllDocumentInteractor(getIt<DocumentRepository>()));
    getIt.registerFactory(() => DownloadFileInteractor(
        getIt<DocumentRepository>(),
        getIt<TokenRepository>(),
        getIt<CredentialRepository>(),
        getIt<APIRepository>()
    ));
    getIt.registerFactory(() => DownloadFileIOSInteractor(
        getIt<DocumentRepository>(),
        getIt<TokenRepository>(),
        getIt<CredentialRepository>()));
    getIt.registerFactory(() => ShareDocumentInteractor(getIt<DocumentRepository>()));
    getIt.registerFactory(() => DeletePermanentTokenInteractor(
      getIt<AuthenticationRepository>(),
      getIt<TokenRepository>(),
      getIt<CredentialRepository>()));
    getIt.registerFactory(() => RemovePermanentTokenInteractor(
        getIt<TokenRepository>(),
        getIt<CredentialRepository>()));
    getIt.registerFactory(() => LogoutOidcInteractor(
      getIt<AuthenticationOIDCRepository>(),
      getIt<CredentialRepository>()
    ));
    getIt.registerFactory(() => DeleteTokenOidcInteractor(getIt<AuthenticationOIDCRepository>()));
    getIt.registerFactory(() => GetAllSharedSpacesInteractor(getIt<SharedSpaceRepository>()));
    getIt.registerFactory(() => GetAutoCompleteSharingInteractor(getIt<AutoCompleteRepository>()));
    getIt.registerFactory(() => GetAllChildNodesInteractor(getIt<SharedSpaceDocumentRepository>()));
    getIt.registerFactory(() => CopyDocumentsToSharedSpaceInteractor(getIt<SharedSpaceDocumentRepository>()));
    getIt.registerFactory(() => CopyMultipleFilesToSharedSpaceInteractor(getIt<CopyDocumentsToSharedSpaceInteractor>()));
    getIt.registerFactory(() => RemoveDocumentInteractor(getIt<DocumentRepository>()));
    getIt.registerFactory(() => RemoveMultipleDocumentsInteractor(getIt<RemoveDocumentInteractor>()));
    getIt.registerFactory(() => RemoveSharedSpaceNodeInteractor(getIt<SharedSpaceDocumentRepository>()));
    getIt.registerFactory(() => RemoveMultipleSharedSpaceNodesInteractor(getIt<RemoveSharedSpaceNodeInteractor>()));
    getIt.registerFactory(() => RemoveReceivedShareInteractor(getIt<ReceivedShareRepository>()));
    getIt.registerFactory(() => RemoveMultipleReceivedSharesInteractor(getIt<RemoveReceivedShareInteractor>()));
    getIt.registerFactory(() => MoveWorkgroupNodeInteractor(getIt<SharedSpaceDocumentRepository>()));
    getIt.registerFactory(() => MoveMultipleWorkgroupNodesInteractor(getIt<MoveWorkgroupNodeInteractor>()));
    getIt.registerFactory(() => GetSharedSpacesRootNodeInfoInteractor(getIt<SharedSpaceDocumentRepository>()));
    getIt.registerFactory(() => DownloadMultipleFileIOSInteractor(getIt<DownloadFileIOSInteractor>()));
    getIt.registerFactory(() => GetAuthorizedInteractor(getIt<AuthenticationRepository>(), getIt<CredentialRepository>()));
    getIt.registerFactory(() =>
        RemoveDeletedReceivedShareFromLocalDatabaseInteractor(
            getIt<ReceivedShareRepository>()));
    getIt.registerFactory(() => GetAllReceivedSharesInteractor(
        getIt<ReceivedShareRepository>(),
        getIt<RemoveDeletedReceivedShareFromLocalDatabaseInteractor>()));
    getIt.registerFactory(() => CopyToMySpaceInteractor(getIt<DocumentRepository>()));
    getIt.registerFactory(() => CopyMultipleFilesToMySpaceInteractor(getIt<CopyToMySpaceInteractor>()));
    getIt.registerFactory(() => SearchDocumentInteractor());
    getIt.registerFactory(() => CopyMultipleFilesFromReceivedSharesToMySpaceInteractor(getIt<CopyToMySpaceInteractor>()));
    getIt.registerFactory(() => GetAllFunctionalityInteractor(getIt<FunctionalityRepository>()));
    getIt.registerFactory(() => DownloadNodeIOSInteractor(
        getIt<SharedSpaceDocumentRepository>(),
        getIt<TokenRepository>(),
        getIt<CredentialRepository>()));
    getIt.registerFactory(() => DownloadMultipleNodeIOSInteractor(getIt<DownloadNodeIOSInteractor>()));
    getIt.registerFactory(() => SearchWorkGroupNodeInteractor());
    getIt.registerFactory(() => SearchSharedSpaceNodeNestedInteractor());
    getIt.registerFactory(() => SearchWorkgroupInsideSharedSpaceNodeInteractor());
    getIt.registerFactory(() => RemoveSharedSpaceInteractor(getIt<SharedSpaceRepository>()));
    getIt.registerFactory(() => RemoveMultipleSharedSpacesInteractor(getIt<RemoveSharedSpaceInteractor>()));
    getIt.registerFactory(() => DownloadWorkGroupNodeInteractor(
        getIt<SharedSpaceDocumentRepository>(),
        getIt<TokenRepository>(),
        getIt<CredentialRepository>(),
        getIt<APIRepository>()
    ));
    getIt.registerFactory(() => DownloadReceivedSharesInteractor(
        getIt<ReceivedShareRepository>(),
        getIt<TokenRepository>(),
        getIt<CredentialRepository>(),
        getIt<APIRepository>()
    ));
    getIt.registerFactory(() => DownloadPreviewDocumentInteractor(
        getIt<DocumentRepository>(),
        getIt<TokenRepository>(),
        getIt<CredentialRepository>()
    ));
    getIt.registerFactory(() => SortInteractor(getIt<SortRepository>()));
    getIt.registerFactory(() => GetSorterInteractor(getIt<SortRepository>()));
    getIt.registerFactory(() => SaveSorterInteractor(getIt<SortRepository>()));
    getIt.registerFactory(() => CreateSharedSpaceFolderInteractor(getIt<SharedSpaceDocumentRepository>()));
    getIt.registerFactory(() => VerifyNameInteractor());
    getIt.registerFactory(() => DownloadPreviewWorkGroupDocumentInteractor(
      getIt<SharedSpaceDocumentRepository>(),
      getIt<TokenRepository>(),
      getIt<CredentialRepository>()
    ));
    getIt.registerFactory(() => GetDeviceContactSuggestionsInteractor(getIt<ContactRepository>()));
    getIt.registerFactory(() => GetAutoCompleteSharingWithDeviceContactInteractor(
        getIt<GetAutoCompleteSharingInteractor>(),
        getIt<GetDeviceContactSuggestionsInteractor>()));
    getIt.registerFactory(() => GetSharedSpaceInteractor(getIt<SharedSpaceRepository>()));
    getIt.registerFactory(() => DownloadPreviewReceivedShareInteractor(
        getIt<ReceivedShareRepository>(),
        getIt<TokenRepository>(),
        getIt<CredentialRepository>()
    ));
    getIt.registerFactory(() => GetAllSharedSpaceMembersInteractor(getIt<SharedSpaceMemberRepository>()));
    getIt.registerFactory(() => SharedSpaceActivitiesInteractor(getIt<SharedSpaceActivitiesRepository>()));
    getIt.registerFactory(() => CreateWorkGroupInteractor(getIt<SharedSpaceRepository>()));
    getIt.registerFactory(() => CreateNewDriveInteractor(getIt<SharedSpaceRepository>()));
    getIt.registerFactory(() => CreateNewWorkSpaceInteractor(getIt<SharedSpaceRepository>()));
    getIt.registerFactory(() => RenameWorkSpaceInteractor(getIt<SharedSpaceRepository>()));
    getIt.registerFactory(() => GetAllWorkgroupsInteractor(getIt<SharedSpaceNodeRepository>()));
    getIt.registerFactory(() => GetAllWorkgroupsOfflineInteractor(getIt<SharedSpaceNodeRepository>()));
    getIt.registerFactory(() => RenameSharedSpaceNodeInteractor(getIt<SharedSpaceDocumentRepository>()));
    getIt.registerFactory(() => AddSharedSpaceMemberInteractor(getIt<SharedSpaceMemberRepository>()));
    getIt.registerFactory(() => UpdateSharedSpaceMemberInteractor(getIt<SharedSpaceMemberRepository>()));
    getIt.registerFactory(() => UpdateDriveMemberInteractor(getIt<SharedSpaceMemberRepository>()));
    getIt.registerFactory(() => UpdateWorkspaceMemberInteractor(getIt<SharedSpaceMemberRepository>()));
    getIt.registerFactory(() => GetAllSharedSpaceRolesInteractor(getIt<SharedSpaceRepository>()));
    getIt.registerFactory(() => RenameDocumentInteractor(getIt<DocumentRepository>()));
    getIt.registerFactory(() => SearchReceivedSharesInteractor());
    getIt.registerFactory(() => DeleteSharedSpaceMemberInteractor(getIt<SharedSpaceMemberRepository>()));
    getIt.registerFactory(() => GetDocumentInteractor(getIt<DocumentRepository>()));
    getIt.registerFactory(() => GetSharedSpaceNodeInteractor(getIt<SharedSpaceDocumentRepository>()));
    getIt.registerFactory(() => IsAvailableBiometricInteractor(getIt<BiometricRepository>()));
    getIt.registerFactory(() => AuthenticationBiometricInteractor(getIt<BiometricRepository>()));
    getIt.registerFactory(() => EnableBiometricInteractor(getIt<BiometricRepository>()));
    getIt.registerFactory(() => GetAvailableBiometricInteractor(getIt<BiometricRepository>()));
    getIt.registerFactory(() => GetBiometricSettingInteractor(getIt<BiometricRepository>()));
    getIt.registerFactory(() => DisableBiometricInteractor(getIt<BiometricRepository>()));
    getIt.registerFactory(() => DuplicateMultipleFilesInMySpaceInteractor(getIt<CopyToMySpaceInteractor>()));
    getIt.registerFactory(() => RestoreWorkGroupDocumentVersionInteractor(getIt<SharedSpaceDocumentRepository>()));
    getIt.registerFactory(() => RenameWorkGroupInteractor(getIt<SharedSpaceRepository>()));
    getIt.registerFactory(() => RenameDriveInteractor(getIt<SharedSpaceRepository>()));
    getIt.registerFactory(() => EditDescriptionDocumentInteractor(getIt<DocumentRepository>()));
    getIt.registerFactory(() => MakeAvailableOfflineDocumentInteractor(
        getIt<DocumentRepository>(),
        getIt<TokenRepository>(),
        getIt<CredentialRepository>()
    ));
    getIt.registerFactory(() => DisableAvailableOfflineDocumentInteractor(getIt<DocumentRepository>()));
    getIt.registerFactory(() => GetAllDocumentOfflineInteractor(getIt<DocumentRepository>()));
    getIt.registerFactory(() => AutoSyncAvailableOfflineDocumentInteractor(
        getIt<DocumentRepository>(),
        getIt<TokenRepository>(),
        getIt<CredentialRepository>()));
    getIt.registerFactory(() => AutoSyncAvailableOfflineMultipleDocumentInteractor(
        getIt<AutoSyncAvailableOfflineDocumentInteractor>()));
    getIt.registerFactory(() => EnableAvailableOfflineDocumentInteractor(getIt<DocumentRepository>()));
    getIt.registerFactory(() => DeleteAllOfflineDocumentInteractor(getIt<DocumentRepository>()));
    getIt.registerFactory(() => MakeAvailableOfflineSharedSpaceDocumentInteractor(
        getIt<SharedSpaceDocumentRepository>(),
        getIt<TokenRepository>(),
        getIt<CredentialRepository>()
    ));
    getIt.registerFactory(() => DisableAvailableOfflineWorkGroupDocumentInteractor(getIt<SharedSpaceDocumentRepository>()));
    getIt.registerFactory(() => GetAllSharedSpaceOfflineInteractor(getIt<SharedSpaceRepository>()));
    getIt.registerFactory(() => GetAllSharedSpaceDocumentOfflineInteractor(getIt<SharedSpaceDocumentRepository>()));
    getIt.registerFactory(() => AutoSyncAvailableOfflineSharedSpaceDocumentInteractor(
        getIt<SharedSpaceDocumentRepository>(),
        getIt<TokenRepository>(),
        getIt<CredentialRepository>()
    ));
    getIt.registerFactory(() => AutoSyncAvailableOfflineMultipleSharedSpaceDocumentInteractor(getIt<AutoSyncAvailableOfflineSharedSpaceDocumentInteractor>()));
    getIt.registerFactory(() => EnableAvailableOfflineSharedSpaceDocumentInteractor(getIt<SharedSpaceDocumentRepository>()));
    getIt.registerFactory(() => DeleteAllSharedSpaceOfflineInteractor(getIt<SharedSpaceDocumentRepository>()));
    getIt.registerFactory(() => GetAllUploadRequestGroupsInteractor(getIt<UploadRequestGroupRepository>()));
    getIt.registerFactory(() => GetUploadRequestGroupInteractor(getIt<UploadRequestGroupRepository>()));
    getIt.registerFactory(() => AddNewUploadRequestInteractor(getIt<UploadRequestGroupRepository>()));
    getIt.registerFactory(() => EditUploadRequestGroupInteractor(getIt<UploadRequestGroupRepository>()));
    getIt.registerFactory(() => GetUploadRequestInteractor(getIt<UploadRequestRepository>()));
    getIt.registerFactory(() => EditUploadRequestRecipientInteractor(getIt<UploadRequestRepository>()));
    getIt.registerFactory(() => GetAllUploadRequestsInteractor(getIt<UploadRequestRepository>()));
    getIt.registerFactory(() => GetUploadRequestActivitiesInteractor(getIt<UploadRequestRepository>()));
    getIt.registerFactory(() => GetAllUploadRequestEntriesInteractor(getIt<UploadRequestEntryRepository>()));
    getIt.registerFactory(() => GetUploadRequestEntryActivitiesInteractor(getIt<UploadRequestEntryRepository>()));
    getIt.registerFactory(() => SearchUploadRequestGroupsInteractor());
    getIt.registerFactory(() => GetReceivedShareInteractor(getIt<ReceivedShareRepository>()));
    getIt.registerFactory(() => DownloadUploadRequestEntriesInteractor(
        getIt<UploadRequestEntryRepository>(),
        getIt<TokenRepository>(),
        getIt<CredentialRepository>(),
        getIt<APIRepository>()
    ));
    getIt.registerFactory(() => DownloadUploadRequestEntryIOSInteractor(
        getIt<UploadRequestEntryRepository>(),
        getIt<TokenRepository>(),
        getIt<CredentialRepository>()));
    getIt.registerFactory(() => DownloadMultipleUploadRequestEntryIOSInteractor(
        getIt<DownloadUploadRequestEntryIOSInteractor>()));
    getIt.registerFactory(() => AddRecipientsToUploadRequestGroupInteractor(getIt<UploadRequestGroupRepository>()));
    getIt.registerFactory(() => UpdateUploadRequestGroupStateInteractor(getIt<UploadRequestGroupRepository>()));
    getIt.registerFactory(() => UpdateMultipleUploadRequestGroupStateInteractor(getIt<UpdateUploadRequestGroupStateInteractor>()));
    getIt.registerFactory(() => SearchUploadRequestEntriesInteractor());
    getIt.registerFactory(() => CopyMultipleFilesFromUploadRequestEntriesToMySpaceInteractor(getIt<CopyToMySpaceInteractor>()));
    getIt.registerFactory(() => RemoveUploadRequestEntryInteractor(getIt<UploadRequestEntryRepository>()));
    getIt.registerFactory(() => RemoveMultipleUploadRequestEntryInteractor(getIt<RemoveUploadRequestEntryInteractor>()));
    getIt.registerFactory(() => GetLastLoginInteractor(getIt<AuditUserRepository>()));
    getIt.registerFactory(() => ExportReceivedShareInteractor(
      getIt<ReceivedShareRepository>(),
      getIt<TokenRepository>(),
      getIt<CredentialRepository>()));
    getIt.registerFactory(() => ExportMultipleReceivedSharesInteractor(getIt<ExportReceivedShareInteractor>()));
    getIt.registerFactory(() => EnableVersioningWorkgroupInteractor(getIt<SharedSpaceRepository>()));
    getIt.registerFactory(() => MakeReceivedShareOfflineInteractor(
      getIt<ReceivedShareRepository>(),
      getIt<TokenRepository>(),
      getIt<CredentialRepository>()));
    getIt.registerFactory(() => DisableOfflineReceivedShareInteractor(getIt<ReceivedShareRepository>()));
    getIt.registerFactory(() => AdvanceSearchWorkgroupNodeInteractor(getIt<SharedSpaceDocumentRepository>()));
    getIt.registerFactory(() => UpdateUploadRequestStateInteractor(getIt<UploadRequestRepository>()));
    getIt.registerFactory(() => UpdateMultipleUploadRequestStateInteractor(getIt<UpdateUploadRequestStateInteractor>()));
    getIt.registerFactory(() => SaveAuthorizedUserInteractor(getIt<AuthenticationRepository>()));
    getIt.registerFactory(() => SaveQuotaInteractor(getIt<QuotaRepository>()));
    getIt.registerFactory(() => SaveLastLoginInteractor(getIt<AuditUserRepository>()));
    getIt.registerFactory(() => SearchRecipientsUploadRequestInteractor());
    getIt.registerFactory(() => RemoveFileFromCacheInteractor());
  }

  void _provideSharePreference() {
    getIt.registerSingletonAsync(() async => SharedPreferences.getInstance());
  }

  void _provideAppNavigation() {
    getIt.registerLazySingleton(() => GlobalKey<NavigatorState>());
    getIt.registerLazySingleton(() => AppNavigation(getIt<GlobalKey<NavigatorState>>()));
  }

  void _provideDeviceManager() {
    getIt.registerLazySingleton(() => DeviceInfoPlugin());
    getIt.registerLazySingleton(() => DeviceManager(getIt<DeviceInfoPlugin>()));
  }

  void _provideAppImagePaths() {
    getIt.registerLazySingleton(() => AppImagePaths());
  }

  void _provideFileManager() {
    getIt.registerFactory(() => LocalFilePicker());
    getIt.registerFactory(() => MediaPickerFromCamera());
    getIt.registerFactory(() => AudioRecorder());
    getIt.registerLazySingleton(() => UploadFileManager());
    getIt.registerFactory(() => FilePathUtil());
    getIt.registerFactory(() => FileHelper());
    getIt.registerLazySingleton(() => UploadShareFileManager(
        getIt.get<Store<AppState>>(),
        getIt.get<FlowUploadDocumentInteractor>(),
        getIt.get<ShareDocumentInteractor>(),
        getIt.get<FlowUploadWorkGroupDocumentInteractor>(),
        getIt.get<FileHelper>(),
        getIt.get<GetQuotaInteractor>()));
  }

  void _provideResponsiveManager() {
    getIt.registerFactory(() => ResponsiveUtils());
  }

  void _provideAppToast() {
    getIt.registerLazySingleton(() => AppToast());
    getIt.registerLazySingleton(() => FToast());
    getIt.registerLazySingleton(() => ToastMessageHandler());
  }

  void _provideNetworkStateComponent() {
    getIt.registerLazySingleton(() => Connectivity());
  }

  void _provideLocalAuthentication() {
    getIt.registerLazySingleton(() => LocalAuthentication());
  }

  void _provideBiometric() {
    getIt.registerSingleton<BiometricExceptionThrower>(BiometricExceptionThrower());
    getIt.registerLazySingleton(() => LocalBiometricService(getIt<LocalAuthentication>()));
  }

  void _provideOfflineMode() {
    getIt.registerSingleton(DatabaseClient());
    getIt.registerFactory(() => DocumentDatabaseManager(getIt<DatabaseClient>()));
    getIt.registerFactory(() => ReceivedShareDatabaseManager(getIt<DatabaseClient>()));
    getIt.registerFactory(() => SharedSpaceDocumentDatabaseManager(getIt<DatabaseClient>()));
    getIt.registerLazySingleton(() => AutoSyncOfflineManager(
      getIt.get<Store<AppState>>(),
      getIt.get<AutoSyncAvailableOfflineMultipleDocumentInteractor>(),
      getIt.get<AutoSyncAvailableOfflineMultipleSharedSpaceDocumentInteractor>()));
  }

  void _provideAppAuth() {
    getIt.registerLazySingleton(() => FlutterAppAuth());
    getIt.registerLazySingleton(() => OIDCParser());
    getIt.registerLazySingleton(() => GeneratePasswordUtils());
  }

  void _provideObservers() {
    getIt.registerLazySingleton(() => LifecycleEventHandler());
  }
  
  void _provideStopWatch() {
    getIt.registerLazySingleton(() => Stopwatch());
  }
}
