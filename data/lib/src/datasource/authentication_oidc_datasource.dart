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
import 'package:data/src/network/model/request/permanent_token_body_request.dart';
import 'package:data/src/network/model/response/permanent_token.dart';
import 'package:data/src/util/constant.dart';
import 'package:dio/dio.dart';
import 'package:domain/domain.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:data/src/extensions/authentication_token_extension.dart';

class AuthenticationOIDCDataSource {

  final LinShareHttpClient linShareHttpClient;
  final RemoteExceptionThrower _remoteExceptionThrower;
  final FlutterAppAuth appAuth;
  final DeviceManager deviceManager;
  final OIDCParser oidcParser;

  AuthenticationOIDCDataSource(
    this.linShareHttpClient,
    this._remoteExceptionThrower,
    this.appAuth,
    this.deviceManager,
    this.oidcParser
  );

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
            preferEphemeralSession: preferEphemeralSessionIOS,
            promptValues: promptValues,
            allowInsecureConnections: allowInsecureConnections));
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
        _remoteExceptionThrower.throwRemoteException(error, handler: (DioError dioError) {
          throw BadCredentials();
        });
      });
  }

  Future<Token> createPermanentTokenWithOIDC(Uri baseUrl, TokenOIDC tokenOIDC, {OTPCode? otpCode}) async {
    return Future.sync(() async {
      final deviceName = await deviceManager.getDeviceName();
      final permanentToken = await linShareHttpClient.createPermanentTokenWithOIDC(
          baseUrl,
          tokenOIDC.token,
          PermanentTokenBodyRequest('Token-${deviceManager.getPlatformString()}-$deviceName'),
          otpCode: otpCode);
      return permanentToken.toToken();
    }).catchError((error) {
      _remoteExceptionThrower.throwRemoteException(error, handler: (DioError error) {
        if (error.response?.statusCode == 401) {
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

  Future<OIDCConfiguration?> getOIDCConfiguration(Uri baseUrl) {
    return Future.sync(() async {
      final result = await linShareHttpClient.getOIDCConfiguration(baseUrl);
      return oidcParser.parseOIDCConfiguration(result);
    }).catchError((error) {
      _remoteExceptionThrower.throwRemoteException(error, handler: (DioError dioError) {
        throw BadCredentials();
      });
    });
  }
}