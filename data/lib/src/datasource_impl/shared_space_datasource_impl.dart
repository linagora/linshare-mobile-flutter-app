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
import 'package:data/src/datasource/shared_space_datasource.dart';
import 'package:data/src/network/linshare_http_client.dart';
import 'package:data/src/network/remote_exception_thrower.dart';
import 'package:dio/dio.dart';
import 'package:domain/domain.dart';
import 'package:domain/src/model/sharedspace/shared_space_node_nested.dart';

class SharedSpaceDataSourceImpl implements SharedSpaceDataSource {
  final LinShareHttpClient _linShareHttpClient;
  final RemoteExceptionThrower _remoteExceptionThrower;

  SharedSpaceDataSourceImpl(this._linShareHttpClient, this._remoteExceptionThrower);

  @override
  Future<List<SharedSpaceNodeNested>> getSharedSpaces() {
    return Future.sync(() async {
      return (await _linShareHttpClient.getSharedSpaces()).map((sharedSpaceResponse) => sharedSpaceResponse.toSharedSpaceNodeNested()).toList();
    }).catchError((error) {
      _remoteExceptionThrower.throwRemoteException(error, handler: (DioError error) {
        if (error.response?.statusCode == 404) {
          throw SharedSpaceNotFound();
        } else if (error.response?.statusCode == 403) {
          throw NotAuthorized();
        } else {
          throw UnknownError(error.response?.statusMessage!);
        }
      });
    });
  }

  @override
  Future<SharedSpaceNodeNested> deleteSharedSpace(SharedSpaceId sharedSpaceId) {
    return Future.sync(() async {
      return (await _linShareHttpClient.deleteSharedSpace(sharedSpaceId)).toSharedSpaceNodeNested();
    }).catchError((error) {
      _remoteExceptionThrower.throwRemoteException(error, handler: (DioError error) {
        if (error.response?.statusCode == 404) {
          throw SharedSpaceNotFound();
        } else if (error.response?.statusCode == 403) {
          throw NotAuthorized();
        } else {
          throw UnknownError(error.response?.statusMessage!);
        }
      });
    });
  }

  @override
  Future<SharedSpaceNodeNested> getSharedSpace(
    SharedSpaceId sharedSpaceId,
    {
      MembersParameter membersParameter = MembersParameter.withMembers,
      RolesParameter rolesParameter = RolesParameter.withRole
    }
  ) {
    return Future.sync(() async {
      return (await _linShareHttpClient.getSharedSpace(
        sharedSpaceId,
        membersParameter: membersParameter,
        rolesParameter: rolesParameter
      )).toSharedSpaceNodeNested();
    }).catchError((error) {
      _remoteExceptionThrower.throwRemoteException(error, handler: (DioError error) {
        if (error.response?.statusCode == 404) {
          throw SharedSpaceNotFound();
        } else if (error.response?.statusCode == 403) {
          throw NotAuthorized();
        } else {
          throw UnknownError(error.response?.statusMessage!);
        }
      });
    });
  }

  @override
  Future<SharedSpaceNodeNested> createSharedSpaceWorkGroup(CreateWorkGroupRequest createWorkGroupRequest) {
    return Future.sync(() async {
      return (await _linShareHttpClient.createSharedSpaceWorkGroup(createWorkGroupRequest.toCreateWorkGroupBodyRequest())).toSharedSpaceNodeNested();
    }).catchError((error) {
      _remoteExceptionThrower.throwRemoteException(error, handler: (DioError error) {
        if (error.response?.statusCode == 404) {
          throw SharedSpaceNotFound();
        } else if (error.response?.statusCode == 403) {
          throw NotAuthorized();
        } else {
          throw UnknownError(error.response?.statusMessage!);
        }
      });
    });
  }

  @override
  Future<List<SharedSpaceRole>> getSharedSpaceRoles({LinShareNodeType? type}) {
    return Future.sync(() async {
      return (await _linShareHttpClient.getSharedSpaceRoles(type: type)).map((role) => role.toSharedSpaceRole()).toList();
    }).catchError((error) {
      _remoteExceptionThrower.throwRemoteException(error, handler: (DioError error) {
        if (error.response?.statusCode == 404) {
          throw SharedSpaceRolesNotFound();
        } else if (error.response?.statusCode == 403) {
          throw NotAuthorized();
        } else {
          throw UnknownError(error.response?.statusMessage!);
        }
      });
    });
  }

  @override
  Future<SharedSpaceNodeNested> renameWorkGroup(SharedSpaceId sharedSpaceId, RenameWorkGroupRequest renameRequest) {
    return Future.sync(() async {
      return (await _linShareHttpClient.renameWorkGroup(sharedSpaceId, renameRequest.toRenameWorkGroupBodyRequest())).toSharedSpaceNodeNested();
    }).catchError((error) {
      _remoteExceptionThrower.throwRemoteException(error, handler: (DioError error) {
        if (error.response?.statusCode == 404) {
          throw SharedSpaceNotFound();
        } else if (error.response?.statusCode == 403) {
          throw NotAuthorized();
        } else {
          throw UnknownError(error.response?.statusMessage);
        }
      });
    });
  }

  @override
  Future<List<SharedSpaceNodeNested>> getAllSharedSpacesOffline() {
    throw UnimplementedError();
  }

  @override
  Future<SharedSpaceNodeNested> enableVersioningWorkGroup(
      SharedSpaceId sharedSpaceId,
      SharedSpaceRole sharedSpaceRole,
      EnableVersioningWorkGroupRequest enableVersioningRequest
  ) {
    return Future.sync(() async {
      final sharedSpaceResponse = await _linShareHttpClient.enableVersioningWorkGroup(
          sharedSpaceId,
          enableVersioningRequest.toEnableVersioningWorkGroupBodyRequest());
      return sharedSpaceResponse.toSharedSpaceNodeNestedWithRole(sharedSpaceRole);
    }).catchError((error) {
      _remoteExceptionThrower.throwRemoteException(error, handler: (DioError error) {
        if (error.response?.statusCode == 404) {
          throw SharedSpaceNotFound();
        } else if (error.response?.statusCode == 403) {
          throw NotAuthorized();
        } else {
          throw UnknownError(error.response?.statusMessage);
        }
      });
    });
  }

  @override
  Future<SharedSpaceNodeNested> renameDrive(SharedSpaceId sharedSpaceId, RenameDriveRequest renameRequest) {
    return Future.sync(() async {
      return (await _linShareHttpClient.renameDrive(sharedSpaceId, renameRequest.toRenameDriveBodyRequest())).toSharedSpaceNodeNested();
    }).catchError((error) {
      _remoteExceptionThrower.throwRemoteException(error, handler: (DioError error) {
        if (error.response?.statusCode == 404) {
          throw SharedSpaceNotFound();
        } else if (error.response?.statusCode == 403) {
          throw NotAuthorized();
        } else {
          throw UnknownError(error.response?.statusMessage);
        }
      });
    });
  }
}
