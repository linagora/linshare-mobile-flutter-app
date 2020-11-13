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

import 'package:data/data.dart';
import 'package:device_info/device_info.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/app_toast.dart';
import 'package:linshare_flutter_app/presentation/util/file_path_util.dart';
import 'package:linshare_flutter_app/presentation/util/local_file_picker.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/upload_file_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppModule {
  AppModule() {
    _provideDataSourceImpl();
    _provideDataSource();
    _provideRepositoryImpl();
    _provideAuthenticationRepository();
    _provideInterActor();
    _provideSharePreference();
    _provideAppNavigation();
    _provideDeviceManager();
    _provideAppImagePaths();
    _provideFileManager();
    _provideFileUploader();
    _provideAppToast();
  }

  void _provideDataSourceImpl() {
    getIt.registerFactory(() => DocumentDataSourceImpl(
        getIt<FlutterUploader>(),
        getIt<LinShareHttpClient>(),
        getIt<RemoteExceptionThrower>()));
  }

  void _provideDataSource() {
    getIt.registerFactory(() => AuthenticationDataSource(getIt<LinShareHttpClient>(), getIt<DeviceManager>()));
    getIt.registerFactory<DocumentDataSource>(() => getIt<DocumentDataSourceImpl>());
  }

  void _provideRepositoryImpl() {
    getIt.registerFactory(() => AuthenticationRepositoryImpl(getIt<AuthenticationDataSource>()));
    getIt.registerFactory(() => TokenRepositoryImpl(getIt<SharedPreferences>()));
    getIt.registerFactory(() => CredentialRepositoryImpl(getIt<SharedPreferences>()));
    getIt.registerFactory(() => DocumentRepositoryImpl(getIt<DocumentDataSource>()));
  }

  void _provideAuthenticationRepository() {
    getIt.registerFactory<AuthenticationRepository>(() => getIt<AuthenticationRepositoryImpl>());
    getIt.registerFactory<TokenRepository>(() => getIt<TokenRepositoryImpl>());
    getIt.registerFactory<CredentialRepository>(() => getIt<CredentialRepositoryImpl>());
    getIt.registerFactory<DocumentRepository>(() => getIt<DocumentRepositoryImpl>());
  }

  void _provideInterActor() {
    getIt.registerFactory(() => CreatePermanentTokenInteractor(
      getIt<AuthenticationRepository>(),
      getIt<TokenRepository>(),
      getIt<CredentialRepository>()));
    getIt.registerFactory(() => GetCredentialInteractor(getIt<TokenRepository>(), getIt<CredentialRepository>()));
    getIt.registerFactory(() => UploadFileInteractor(
        getIt<DocumentRepository>(),
        getIt<TokenRepository>(),
        getIt<CredentialRepository>()));
    getIt.registerFactory(() => GetAllDocumentInteractor(getIt<DocumentRepository>()));
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
  }

  void _provideFileUploader() {
    getIt.registerLazySingleton(() => FlutterUploader());
  }

  void _provideAppToast() {
    getIt.registerLazySingleton(() => AppToast());
  }
}
