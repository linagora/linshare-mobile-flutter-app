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
// e-mails sent with the Program, (ii) retain all hyper& links between LinShare and
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

import 'dart:async';

import 'package:data/src/datasource/upload_request_entry_datasource.dart';
import 'package:data/src/network/linshare_http_client.dart';
import 'package:data/src/network/remote_exception_thrower.dart';
import 'package:dio/dio.dart';
import 'package:domain/domain.dart';
import 'package:data/src/network/model/response/upload_request_entry_response.dart';

class UploadRequestEntryDataSourceImpl implements UploadRequestEntryDataSource {
  final LinShareHttpClient _linShareHttpClient;
  final RemoteExceptionThrower _remoteExceptionThrower;

  UploadRequestEntryDataSourceImpl(this._linShareHttpClient, this._remoteExceptionThrower);

  @override
  Future<List<UploadRequestEntry>> getAllUploadRequestEntries(UploadRequestId uploadRequestId) async {
    return Future.sync(() async {
      final entryResponse = await _linShareHttpClient.getAllUploadRequestEntries(uploadRequestId);
      return entryResponse.map((entry) => entry.toUploadRequestEntry()).toList();
    }).catchError((error) {
      _remoteExceptionThrower.throwRemoteException(error, handler: (DioError error) {
        if (error.response?.statusCode == 404) {
          throw UploadRequestGroupsNotFound();
        } else {
          throw UnknownError(error.response?.statusMessage);
        }
      });
    });
  }
}