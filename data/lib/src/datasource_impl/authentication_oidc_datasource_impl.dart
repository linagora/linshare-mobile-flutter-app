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

import 'dart:developer' as developer;

import 'package:data/data.dart';
import 'package:data/src/extensions/share_preferences_extension.dart';
import 'package:data/src/local/model/token_oidc_cache.dart';
import 'package:dio/dio.dart';
import 'package:domain/domain.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationOIDCDataSourceImpl implements AuthenticationOIDCDataSource {

  static const _keyTokenOIDC = 'TOKEN-OIDC';

  final LinShareHttpClient linShareHttpClient;
  final RemoteExceptionThrower remoteExceptionThrower;
  final FlutterAppAuth appAuth;
  final DeviceManager deviceManager;
  final OIDCParser oidcParser;
  final SharedPreferences sharedPreferences;

  AuthenticationOIDCDataSourceImpl(
    this.linShareHttpClient,
    this.remoteExceptionThrower,
    this.appAuth,
    this.deviceManager,
    this.oidcParser,
    this.sharedPreferences
  );

  @override
  Future<TokenOIDC?> getTokenOIDC(
    String clientId,
    String redirectUrl,
    String discoveryUrl,
    List<String> scopes,
    bool preferEphemeralSessionIOS,
    List<String>? promptValues,
    bool allowInsecureConnections) async {
      return Future.sync(() async {
        final result = await appAuth.authorizeAndExchangeCode(AuthorizationTokenRequest(
            clientId,
            redirectUrl,
            discoveryUrl: discoveryUrl,
            scopes: scopes,
            preferEphemeralSession: true,
            promptValues: ['consent'],
            responseMode: 'query'));

        developer.log('getTokenOIDC(): ${result?.idToken.toString()}', name: 'AuthenticationOIDCDataSourceImpl');

        if(result != null) {
          final tokenOIDC = result.toTokenOIDC();
          if (tokenOIDC.isTokenValid()) {
              return tokenOIDC;
          } else {
            throw BadCredentials();
          }
        } else {
          throw BadCredentials();
        }
      }).catchError((error) {
        remoteExceptionThrower.throwRemoteException(error, handler: (DioError dioError) {
          throw BadCredentials();
        });
      });
  }

  @override
  Future<Token> createPermanentTokenWithOIDC(Uri baseUrl, APIVersionSupported apiVersion, TokenOIDC tokenOIDC, {OTPCode? otpCode}) async {
    return Future.sync(() async {
      final deviceName = await deviceManager.getDeviceName();
      final permanentToken = await linShareHttpClient.createPermanentTokenWithOIDC(
          baseUrl,
          apiVersion,
          tokenOIDC.token,
          PermanentTokenBodyRequest('Token-${deviceManager.getPlatformString()}-$deviceName'),
          otpCode: otpCode);
      return permanentToken.toToken();
    }).catchError((error) {
      remoteExceptionThrower.throwRemoteException(error, handler: (DioError error) {
        if (error.response?.statusCode == 404) {
          developer.log('createPermanentTokenWithOIDC(): $error', name: 'AuthenticationOIDCDataSourceImpl');
          throw UnsupportedAPIVersion();
        } else if (error.response?.statusCode == 401) {
          final errorCode = error.response?.headers.value(Constant.linShareAuthErrorCode) ?? '1';
          final authErrorCode = LinShareErrorCode(int.tryParse(errorCode) ?? 1);
          if (authErrorCode.isAuthenticateWithOTPError()) {
            throw NeedAuthenticateWithOTP();
          } else if (authErrorCode.isAuthenticateErrorUserLocked()) {
            throw UserLocked();
          }
          throw BadCredentials();
        } else {
          throw UnknownError(error.response?.statusMessage!);
        }
      });
    });
  }

  @override
  Future<OIDCConfiguration?> getOIDCConfiguration(Uri baseUrl) {
    return Future.sync(() async {
      final result = await linShareHttpClient.getOIDCConfiguration(baseUrl);
      return oidcParser.parseOIDCConfiguration(result);
    }).catchError((error) {
      remoteExceptionThrower.throwRemoteException(error, handler: (DioError dioError) {
        throw UnknownError(error.response?.statusMessage!);
      });
    });
  }

  @override
  Future<TokenOIDC?> getStoredTokenOIDC() async {
    final storedToken = await sharedPreferences.getObject(_keyTokenOIDC);
    return Future.sync(() {
      if (storedToken != null) {
        final tokenOIDCCache = TokenOIDCCache.fromJson(storedToken);
        return tokenOIDCCache.toTokenOIDC();
      }
      return null;
    });
  }

  @override
  Future<void> logout(Uri baseUrl) async {
    final tokenOIDC = await getStoredTokenOIDC();
    if (tokenOIDC != null) {
      final oidcConfiguration = await getOIDCConfiguration(baseUrl);
      if (oidcConfiguration != null) {
        return Future.sync(() async {
          await appAuth.endSession(EndSessionRequest(
              idTokenHint: tokenOIDC.tokenId.uuid,
              postLogoutRedirectUrl: OIDCConfiguration.redirectOidc,
              discoveryUrl: oidcConfiguration.discoveryUrl
          ));
        }).catchError((error) {
          remoteExceptionThrower.throwRemoteException(error, handler: (DioError dioError) {
            throw UnknownError(error.response?.statusMessage!);
          });
        });
      }
    }
  }

  @override
  Future<void> persistTokenOIDC(TokenOIDC tokenOidc) async {
    await sharedPreferences.setObject(_keyTokenOIDC, tokenOidc.toTokenOIDCCache().toJson());
  }

  @override
  Future<void> deleteStoredTokenOIDC() async {
    await sharedPreferences.remove(_keyTokenOIDC);
  }
}