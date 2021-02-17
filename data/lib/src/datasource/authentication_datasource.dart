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
import 'package:data/src/network/model/response/user_response.dart';
import 'package:data/src/util/device_manager.dart';
import 'package:dio/dio.dart';
import 'package:domain/domain.dart';

class AuthenticationDataSource {

  final LinShareHttpClient linShareHttpClient;
  final DeviceManager deviceManager;
  final RemoteExceptionThrower _remoteExceptionThrower;

  AuthenticationDataSource(this.linShareHttpClient, this.deviceManager, this._remoteExceptionThrower);

  Future<Token> createPermanentToken(Uri baseUrl, UserName userName, Password password) async {
    return Future.sync(() async {
      final deviceUUID = await deviceManager.getDeviceUUID();
      final permanentToken = await linShareHttpClient.createPermanentToken(
          baseUrl,
          userName.userName,
          password.value,
          PermanentTokenBodyRequest('LinShare-${deviceManager.getPlatformString()}-$deviceUUID'));
      return permanentToken.toToken();
    }).catchError((error) {
        _remoteExceptionThrower.throwRemoteException(error, handler: (DioError error) {
          if (error.response.statusCode == 401) {
            throw BadCredentials();
          } else {
            throw UnknownError(error.response.statusMessage);
          }
        });
    });
  }

  Future<bool> deletePermanentToken(Token token) async {
    return Future.sync(() async => await linShareHttpClient.deletePermanentToken(token.toPermanentToken()))
      .catchError((error) =>
        _remoteExceptionThrower.throwRemoteException(error, handler: (DioError error) {
          if (error.response.statusCode == 404) {
            throw RequestedTokenNotFound();
          } else if (error.response.statusCode == 400) {
            throw MissingRequiredFields();
          } else {
            throw UnknownError(error.response.statusMessage);
          }
        })
      );
  }

  Future<User> getAuthorizedUser() async {
    return Future.sync(() async {
      var result = (await linShareHttpClient.getAuthorizedUser()).toUser();
      if (result == null) {
        throw NotAuthorizedUser();
      }
      return result;
    })
      .catchError((error) => 
        _remoteExceptionThrower.throwRemoteException(error, handler: (DioError error) {
          throw UnknownError(error.response.statusMessage);
        })
    );
  }
}
