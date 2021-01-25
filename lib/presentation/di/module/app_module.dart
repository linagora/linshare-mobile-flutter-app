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
import 'package:linshare_flutter_app/presentation/widget/upload_file/upload_file_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:redux/redux.dart';

class AppModule {
  AppModule() {
    _provideDataSourceImpl();
    _provideDataSource();
    _provideRepositoryImpl();
    _provideRepository();
    _provideInterActor();
    _provideSharePreference();
    _provideAppNavigation();
    _provideDeviceManager();
    _provideAppImagePaths();
    _provideFileManager();
    _provideFileUploader();
    _provideAppToast();
    _provideNetworkStateComponent();
  }

  void _provideDataSourceImpl() {
    getIt.registerFactory(() => DocumentDataSourceImpl(
        getIt<LinShareHttpClient>(),
        getIt<RemoteExceptionThrower>()));
    getIt.registerFactory(() => SharedSpaceDataSourceImpl(
        getIt<LinShareHttpClient>(),
        getIt<RemoteExceptionThrower>()));
    getIt.registerFactory(() => AutoCompleteDataSourceImpl(
        getIt<LinShareHttpClient>(),
        getIt<RemoteExceptionThrower>()));
    getIt.registerFactory(() => SharedSpaceDocumentDataSourceImpl(
        getIt<LinShareHttpClient>(),
        getIt<RemoteExceptionThrower>()));
    getIt.registerLazySingleton(() => FileUploadDataSourceImpl(
        getIt.get<FlutterUploader>()));
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
  }

  void _provideRepositoryImpl() {
    getIt.registerFactory(() => AuthenticationRepositoryImpl(getIt<AuthenticationDataSource>()));
    getIt.registerFactory(() => TokenRepositoryImpl(getIt<SharedPreferences>()));
    getIt.registerFactory(() => CredentialRepositoryImpl(getIt<SharedPreferences>()));
    getIt.registerFactory(() => DocumentRepositoryImpl(getIt<DocumentDataSource>(), getIt<FileUploadDataSource>()));
    getIt.registerFactory(() => SharedSpaceRepositoryImpl(getIt<SharedSpaceDataSource>()));
    getIt.registerFactory(() => AutoCompleteRepositoryImpl(getIt<AutoCompleteDataSource>()));
    getIt.registerFactory(() => SharedSpaceDocumentRepositoryImpl(getIt<SharedSpaceDocumentDataSource>(), getIt<FileUploadDataSource>()));
  }

  void _provideRepository() {
    getIt.registerFactory<AuthenticationRepository>(() => getIt<AuthenticationRepositoryImpl>());
    getIt.registerFactory<TokenRepository>(() => getIt<TokenRepositoryImpl>());
    getIt.registerFactory<CredentialRepository>(() => getIt<CredentialRepositoryImpl>());
    getIt.registerFactory<DocumentRepository>(() => getIt<DocumentRepositoryImpl>());
    getIt.registerFactory<AutoCompleteRepository>(() => getIt<AutoCompleteRepositoryImpl>());
    getIt.registerFactory<SharedSpaceRepository>(() => getIt<SharedSpaceRepositoryImpl>());
    getIt.registerFactory<SharedSpaceDocumentRepository>(() => getIt<SharedSpaceDocumentRepositoryImpl>());
  }

  void _provideInterActor() {
    getIt.registerFactory(() => CreatePermanentTokenInteractor(
      getIt<AuthenticationRepository>(),
      getIt<TokenRepository>(),
      getIt<CredentialRepository>()));
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
        getIt.get<FileHelper>()));
  }

  void _provideFileUploader() {
    getIt.registerLazySingleton(() => FlutterUploader());
  }

  void _provideAppToast() {
    getIt.registerLazySingleton(() => AppToast());
  }

  void _provideNetworkStateComponent() {
    getIt.registerLazySingleton(() => Connectivity());
  }
}
