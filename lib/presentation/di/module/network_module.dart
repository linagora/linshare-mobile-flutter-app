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

import 'dart:io';

import 'package:data/data.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';

class NetworkModule {
  NetworkModule() {
    _provideBaseOption();
    _provideDio();
    _provideRemoteExceptionThrower();
    _provideHttpClient();
  }

  void _provideBaseOption() {
    final headers = <String, dynamic>{
      HttpHeaders.acceptHeader: 'application/json',
      HttpHeaders.contentTypeHeader: 'application/json'
    };
    getIt.registerSingleton<BaseOptions>(BaseOptions(headers: headers));
  }

  void _provideInterceptors() {
    getIt.registerSingleton<DynamicUrlInterceptors>(DynamicUrlInterceptors());
    getIt.registerSingleton<CookieInterceptors>(CookieInterceptors());
    getIt.registerSingleton<RetryAuthenticationInterceptors>(RetryAuthenticationInterceptors(getIt<Dio>()));
    getIt.registerSingleton<SSOAuthenticationInterceptors>(SSOAuthenticationInterceptors(getIt<Dio>()));
    getIt.registerSingleton<DynamicAPIVersionSupportInterceptor>(DynamicAPIVersionSupportInterceptor());
  }

  void _provideDio() {
    getIt.registerSingleton(Dio(getIt<BaseOptions>()));
    _provideInterceptors();
    getIt<Dio>().interceptors.add(getIt<DynamicUrlInterceptors>());
    getIt<Dio>().interceptors.add(getIt<DynamicAPIVersionSupportInterceptor>());
    getIt<Dio>().interceptors.add(getIt<CookieInterceptors>());
    getIt<Dio>().interceptors.add(getIt<RetryAuthenticationInterceptors>());
    getIt<Dio>().interceptors.add(getIt<SSOAuthenticationInterceptors>());
    if (kDebugMode) {
      getIt<Dio>().interceptors.add(LogInterceptor(requestBody: true, responseBody: true, requestHeader: true));
    };
  }

  void _provideRemoteExceptionThrower() {
    getIt.registerSingleton<RemoteExceptionThrower>(RemoteExceptionThrower());
  }

  void _provideHttpClient() {
    getIt.registerSingleton(DioClient(getIt<Dio>()));
    getIt.registerSingleton(LinShareHttpClient(getIt<DioClient>()));
    getIt.registerSingleton(SaaSHttpClient(getIt<DioClient>()));
    getIt.registerFactory(() => LinShareDownloadManager(
        getIt<RemoteExceptionThrower>(),
        getIt<LinShareHttpClient>()));
  }
}
