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

import 'package:data/src/network/model/query/query_parameter.dart';
import 'package:domain/domain.dart';

class Endpoint {
  static final String rootPath = '/linshare/webservice/rest/user/v2';
  static final String download = '/download';
  static final String nodes = '/nodes';
  static final String thumbnail = '/thumbnail';

  static final ServicePath authentication = ServicePath('/jwt');

  static final ServicePath authorizedUser = ServicePath('/authentication/authorized');
  static final ServicePath documents = ServicePath('/documents');

  static final ServicePath shares = ServicePath('/shares');

  static final ServicePath sharedSpaces = ServicePath('/shared_spaces');

  static final ServicePath receivedShares = ServicePath('/received_shares');

  static final ServicePath autocomplete = ServicePath('/autocomplete');

  static final ServicePath quota = ServicePath('/quota');

  static final ServicePath functionality = ServicePath('/functionalities');

  static final ServicePath workGroups = ServicePath('/work_groups');
}

extension ServicePathExtension on ServicePath {
  String generateEndpointPath() {
    return '${Endpoint.rootPath}$path';
  }

  ServicePath withQueryParameters(List<QueryParameter> queryParameters) {
    if (queryParameters.isEmpty) {
      return this;
    }
    return ServicePath('$path?${queryParameters
        .map((query) => '${query.queryName}=${query.queryValue}').join('&')}');
  }

  ServicePath withPathParameter([String pathParameter]) {
    if (pathParameter.isEmpty) {
      return this;
    }

    return ServicePath('$path/$pathParameter');
  }

  String generateAuthenticationUrl(Uri baseUrl) {
    return baseUrl.origin + generateEndpointPath();
  }

  String generateUploadUrl(Uri baseUrl) {
    return baseUrl.origin + generateEndpointPath();
  }

  ServicePath downloadServicePath(String resourceId) {
    return ServicePath('$path/$resourceId${Endpoint.download}');
  }

  String generateDownloadUrl(Uri baseUrl) {
    return baseUrl.origin + generateEndpointPath();
  }

  ServicePath append(ServicePath other) {
    return ServicePath(path + other.path);
  }
}
