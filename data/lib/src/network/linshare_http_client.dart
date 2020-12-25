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

import 'dart:convert';
import 'dart:io';

import 'package:data/data.dart';
import 'package:data/src/network/config/endpoint.dart';
import 'package:data/src/network/dio_client.dart';
import 'package:data/src/network/model/autocomplete/mailing_list_autocomplete_result_dto.dart';
import 'package:data/src/network/model/autocomplete/simple_autocomplete_result_dto.dart';
import 'package:data/src/network/model/autocomplete/user_autocomplete_result_dto.dart';
import 'package:data/src/network/model/query/query_parameter.dart';
import 'package:data/src/network/model/request/permanent_token_body_request.dart';
import 'package:data/src/network/model/request/share_document_body_request.dart';
import 'package:data/src/network/model/response/document_response.dart';
import 'package:data/src/network/model/response/permanent_token.dart';
import 'package:data/src/network/model/response/user.dart';
import 'package:dio/dio.dart';
import 'package:domain/domain.dart';
import 'package:data/src/extensions/list_extension.dart';

import 'model/share/share_dto.dart';

class LinShareHttpClient {
  final DioClient _dioClient;

  LinShareHttpClient(this._dioClient);

  Future<PermanentToken> createPermanentToken(
      Uri authenticateUrl,
      String userName,
      String password,
      PermanentTokenBodyRequest bodyRequest) async {
    final basicAuth = 'Basic ' + base64Encode(utf8.encode('$userName:$password'));

    final headerParam = _dioClient.getHeaders();
    headerParam[HttpHeaders.authorizationHeader] = basicAuth;

    final resultJson = await _dioClient.post(
        Endpoint.authentication.generateAuthenticationUrl(authenticateUrl),
        options: Options(headers: headerParam),
        data: bodyRequest.toJson());
    return PermanentToken.fromJson(resultJson);
  }

  Future<bool> deletePermanentToken(PermanentToken token) async {
    final deletedToken = await _dioClient.delete(
      Endpoint.authentication.withPathParameter(token.tokenId.uuid).generateEndpointPath(),
      options: Options(headers: {
        'Content-Type': 'application/json'
      })
    );
    return deletedToken != null;
  }

  Future<User> getAuthorizedUser() async {
    final resultJson = await _dioClient.get(Endpoint.authorizedUser.generateEndpointPath());
    return User.fromJson(resultJson);
  }

  Future<List<DocumentResponse>> getAllDocument() async {
    final List resultJson = await _dioClient.get(Endpoint.documents.generateEndpointPath());
    return resultJson.map((data) => DocumentResponse.fromJson(data)).toList();
  }

  Future<List<ShareDto>> shareDocument(ShareDocumentBodyRequest bodyRequest) async {
    final List resultJson = await _dioClient.post(
        Endpoint.shares.generateEndpointPath(),
        data: bodyRequest.toJson().toString());
    return resultJson.map((data) => ShareDto.fromJson(data)).toList();
  }

  Future<ResponseBody> downloadDocumentIOS(
      String url,
      CancelToken cancelToken,
      Token permanentToken) async {
    final headerParam = _dioClient.getHeaders();
    headerParam[HttpHeaders.authorizationHeader] = 'Bearer ${permanentToken.token}';
    final responseBody = await _dioClient.get(url,
        options: Options(headers: headerParam, responseType: ResponseType.stream));
    return (responseBody as ResponseBody);
  }

  Future<List<SharedSpaceNodeNestedResponse>> getSharedSpaces() async {
    final List resultJson = await _dioClient.get(
        Endpoint.sharedSpaces
            .generateEndpointPath(),
        queryParameters: [BooleanQueryParameter('withRole', true)].toMap());
    return resultJson.map((data) => SharedSpaceNodeNestedResponse.fromJson(data)).toList();
  }

  Future<List<AutoCompleteResult>> getSharingAutoComplete(
      AutoCompletePattern autoCompletePattern) async {
    final List resultJson = await _dioClient.get(
        Endpoint.autocomplete
            .withPathParameter(autoCompletePattern.value)
            .generateEndpointPath(),
        queryParameters: [StringQueryParameter('type', 'SHARING')].toMap());
    return resultJson.map((data) => _getDynamicAutoCompleteResult(data)).toList();
  }

  AutoCompleteResult _getDynamicAutoCompleteResult(Map<String, dynamic> map) {
    final type = map['type'] as String;
    if (type == AutoCompleteResultType.simple.value) {
      return SimpleAutoCompleteResultDto.fromJson(map);
    } else if (type == AutoCompleteResultType.user.value) {
      return UserAutoCompleteResultDto.fromJson(map);
    } else {
      return MailingListAutoCompleteResultDto.fromJson(map);
    }
  }
}
