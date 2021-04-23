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
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/manager/upload_and_share_file/upload_and_share_file_manager.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/app_toast.dart';
import 'package:linshare_flutter_app/presentation/util/file_path_util.dart';
import 'package:linshare_flutter_app/presentation/util/helper/file_helper.dart';
import 'package:linshare_flutter_app/presentation/util/local_file_picker.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/util/toast_message_handler.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/upload_file_manager.dart';
import 'package:local_auth/local_auth.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppModule {
  AppModule() {
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
    _provideFileUploader();
    _provideAppToast();
    _provideNetworkStateComponent();
    _provideLocalAuthentication();
    _provideBiometric();
  }

  void _provideDataSourceImpl() {
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
        getIt.get<FlutterUploader>()));
    getIt.registerFactory(() => ReceivedShareDataSourceImpl(
        getIt<LinShareHttpClient>(),
        getIt<RemoteExceptionThrower>(),
        getIt<LinShareDownloadManager>()));
    getIt.registerLazySingleton(() => QuotaDataSourceImpl(
        getIt<LinShareHttpClient>(),
        getIt<RemoteExceptionThrower>()));
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
        getIt<LocalAuthenticationService>(),
        getIt<BiometricExceptionThrower>(),
        getIt<SharedPreferences>()));
  }

  void _provideDataSource() {
    getIt.registerFactory(() => AuthenticationDataSource(
      getIt<LinShareHttpClient>(),
      getIt<DeviceManager>(),
      getIt<RemoteExceptionThrower>()
    ));
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
  }

  void _provideRepositoryImpl() {
    getIt.registerFactory(() => AuthenticationRepositoryImpl(getIt<AuthenticationDataSource>()));
    getIt.registerFactory(() => TokenRepositoryImpl(getIt<SharedPreferences>()));
    getIt.registerFactory(() => CredentialRepositoryImpl(getIt<SharedPreferences>()));
    getIt.registerFactory(() => DocumentRepositoryImpl(getIt<DocumentDataSource>(), getIt<FileUploadDataSource>()));
    getIt.registerFactory(() => SharedSpaceRepositoryImpl(getIt<SharedSpaceDataSource>()));
    getIt.registerFactory(() => AutoCompleteRepositoryImpl(getIt<AutoCompleteDataSource>()));
    getIt.registerFactory(() => SharedSpaceDocumentRepositoryImpl(getIt<SharedSpaceDocumentDataSource>(), getIt<FileUploadDataSource>()));
    getIt.registerFactory(() => QuotaRepositoryImpl(getIt<QuotaDataSource>()));
    getIt.registerFactory(() => ReceivedShareRepositoryImpl(getIt<ReceivedShareDataSource>()));
    getIt.registerFactory(() => FunctionalityRepositoryImpl(getIt<FunctionalityDataSource>()));
    getIt.registerFactory(() => SortRepositoryImpl(getIt<SortDataSource>()));
    getIt.registerFactory(() => ContactRepositoryImpl(getIt<ContactDataSource>()));
    getIt.registerFactory(() => SharedSpaceMemberRepositoryImpl(getIt<SharedSpaceMemberDataSource>()));
    getIt.registerFactory(() => SharedSpaceActivitiesRepositoryImpl(getIt<SharedSpaceActivitiesDataSource>()));
    getIt.registerFactory(() => BiometricRepositoryImpl(getIt<BiometricDataSource>()));
  }

  void _provideRepository() {
    getIt.registerFactory<AuthenticationRepository>(() => getIt<AuthenticationRepositoryImpl>());
    getIt.registerFactory<TokenRepository>(() => getIt<TokenRepositoryImpl>());
    getIt.registerFactory<CredentialRepository>(() => getIt<CredentialRepositoryImpl>());
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
  }

  void _provideInteractor() {
    getIt.registerFactory(() => CreatePermanentTokenInteractor(
      getIt<AuthenticationRepository>(),
      getIt<TokenRepository>(),
      getIt<CredentialRepository>()));
    getIt.registerFactory(() => GetQuotaInteractor(getIt<QuotaRepository>()));
    getIt.registerFactory(() => GetCredentialInteractor(getIt<TokenRepository>(), getIt<CredentialRepository>()));
    getIt.registerFactory(() => UploadMySpaceDocumentInteractor(
        getIt<DocumentRepository>(),
        getIt<TokenRepository>(),
        getIt<CredentialRepository>()));
    getIt.registerFactory(() => GetAllDocumentInteractor(getIt<DocumentRepository>()));
    getIt.registerFactory(() => DownloadFileInteractor(
        getIt<DocumentRepository>(),
        getIt<TokenRepository>(),
        getIt<CredentialRepository>()));
    getIt.registerFactory(() => DownloadFileIOSInteractor(
        getIt<DocumentRepository>(),
        getIt<TokenRepository>(),
        getIt<CredentialRepository>()));
    getIt.registerFactory(() => ShareDocumentInteractor(getIt<DocumentRepository>()));
    getIt.registerFactory(() => DeletePermanentTokenInteractor(
      getIt<AuthenticationRepository>(),
      getIt<TokenRepository>(),
      getIt<CredentialRepository>()));
    getIt.registerFactory(() => GetAllSharedSpacesInteractor(getIt<SharedSpaceRepository>()));
    getIt.registerFactory(() => GetAutoCompleteSharingInteractor(getIt<AutoCompleteRepository>()));
    getIt.registerFactory(() => UploadWorkGroupDocumentInteractor(
        getIt<SharedSpaceDocumentRepository>(),
        getIt<TokenRepository>(),
        getIt<CredentialRepository>()));
    getIt.registerFactory(() => GetAllChildNodesInteractor(getIt<SharedSpaceDocumentRepository>()));
    getIt.registerFactory(() => CopyDocumentsToSharedSpaceInteractor(getIt<SharedSpaceDocumentRepository>()));
    getIt.registerFactory(() => CopyMultipleFilesToSharedSpaceInteractor(getIt<CopyDocumentsToSharedSpaceInteractor>()));
    getIt.registerFactory(() => RemoveDocumentInteractor(getIt<DocumentRepository>()));
    getIt.registerFactory(() => RemoveMultipleDocumentsInteractor(getIt<RemoveDocumentInteractor>()));
    getIt.registerFactory(() => RemoveSharedSpaceNodeInteractor(getIt<SharedSpaceDocumentRepository>()));
    getIt.registerFactory(() => RemoveMultipleSharedSpaceNodesInteractor(getIt<RemoveSharedSpaceNodeInteractor>()));
    getIt.registerFactory(() => DownloadMultipleFileIOSInteractor(getIt<DownloadFileIOSInteractor>()));
    getIt.registerFactory(() => GetAuthorizedInteractor(getIt<AuthenticationRepository>()));
    getIt.registerFactory(() => GetAllReceivedSharesInteractor(getIt<ReceivedShareRepository>()));
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
    getIt.registerFactory(() => RemoveSharedSpaceInteractor(getIt<SharedSpaceRepository>()));
    getIt.registerFactory(() => RemoveMultipleSharedSpacesInteractor(getIt<RemoveSharedSpaceInteractor>()));
    getIt.registerFactory(() => DownloadWorkGroupNodeInteractor(
        getIt<SharedSpaceDocumentRepository>(),
        getIt<TokenRepository>(),
        getIt<CredentialRepository>()));
    getIt.registerFactory(() => DownloadReceivedSharesInteractor(
        getIt<ReceivedShareRepository>(),
        getIt<TokenRepository>(),
        getIt<CredentialRepository>()));
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
    getIt.registerFactory(() => RenameSharedSpaceNodeInteractor(getIt<SharedSpaceDocumentRepository>()));
    getIt.registerFactory(() => AddSharedSpaceMemberInteractor(getIt<SharedSpaceMemberRepository>()));
    getIt.registerFactory(() => UpdateSharedSpaceMemberInteractor(getIt<SharedSpaceMemberRepository>()));
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
    getIt.registerLazySingleton(() => UploadFileManager());
    getIt.registerFactory(() => FilePathUtil());
    getIt.registerFactory(() => FileHelper());
    getIt.registerLazySingleton(() => UploadShareFileManager(
        getIt.get<Store<AppState>>(),
        getIt.get<FileUploadDataSourceImpl>().uploadingFileStream,
        getIt.get<UploadMySpaceDocumentInteractor>(),
        getIt.get<ShareDocumentInteractor>(),
        getIt.get<UploadWorkGroupDocumentInteractor>(),
        getIt.get<FileHelper>(),
        getIt.get<GetQuotaInteractor>()));
  }

  void _provideFileUploader() {
    getIt.registerLazySingleton(() => FlutterUploader());
  }

  void _provideAppToast() {
    getIt.registerLazySingleton(() => AppToast());
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
    getIt.registerLazySingleton(() => LocalAuthenticationService(getIt<LocalAuthentication>()));
  }
}
