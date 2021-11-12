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

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:data/data.dart';
import 'package:data/src/extensions/list_extension.dart';
import 'package:data/src/network/config/endpoint.dart';
import 'package:data/src/network/dio_client.dart';
import 'package:data/src/network/model/autocomplete/mailing_list_autocomplete_result_dto.dart';
import 'package:data/src/network/model/autocomplete/simple_autocomplete_result_dto.dart';
import 'package:data/src/network/model/autocomplete/user_autocomplete_result_dto.dart';
import 'package:data/src/network/model/functionality/functionality_boolean_dto.dart';
import 'package:data/src/network/model/functionality/functionality_dto.dart';
import 'package:data/src/network/model/functionality/functionality_integer_dto.dart';
import 'package:data/src/network/model/functionality/functionality_language_dto.dart';
import 'package:data/src/network/model/functionality/functionality_simple_dto.dart';
import 'package:data/src/network/model/functionality/functionality_size_dto.dart';
import 'package:data/src/network/model/functionality/functionality_string_dto.dart';
import 'package:data/src/network/model/functionality/functionality_time_dto.dart';
import 'package:data/src/network/model/query/query_parameter.dart';
import 'package:data/src/network/model/request/create_work_group_body_request.dart';
import 'package:data/src/network/model/request/enable_versioning_work_group_body_request.dart';
import 'package:data/src/network/model/request/move_work_group_node_body_request.dart';
import 'package:data/src/network/model/request/permanent_token_body_request.dart';
import 'package:data/src/network/model/request/share_document_body_request.dart';
import 'package:data/src/network/model/response/account_quota_response.dart';
import 'package:data/src/network/model/response/authentication_audit_log_entry_user_response.dart';
import 'package:data/src/network/model/response/document_response.dart';
import 'package:data/src/network/model/response/permanent_token.dart';
import 'package:data/src/network/model/response/shared_space_member_response.dart';
import 'package:data/src/network/model/response/upload_request_entry_response.dart';
import 'package:data/src/network/model/response/upload_request_group_response.dart';
import 'package:data/src/network/model/response/user_response.dart';
import 'package:data/src/network/model/share/received_share_dto.dart';
import 'package:data/src/network/model/shared_space_activities/shared_space_member_audit_log_entry_dto.dart';
import 'package:data/src/network/model/sharedspacedocument/work_group_node_dto.dart';
import 'package:data/src/util/constant.dart';
import 'package:dio/dio.dart';
import 'package:domain/domain.dart';

import 'model/autocomplete/shared_space_member_autocomplete_result_dto.dart';
import 'model/request/add_shared_space_member_body_request.dart';
import 'model/request/add_upload_body_request.dart';
import 'model/request/copy_body_request.dart';
import 'model/request/create_shared_space_node_folder_request.dart';
import 'model/request/update_shared_space_member_body_request.dart';
import 'model/response/document_details_response.dart';
import 'model/response/upload_request_response.dart';
import 'model/response/user_response.dart';
import 'model/share/share_dto.dart';
import 'model/sharedspacedocument/work_group_document_dto.dart';
import 'model/sharedspacedocument/work_group_folder_dto.dart';

class LinShareHttpClient {
  final DioClient _dioClient;

  LinShareHttpClient(this._dioClient);

  Future<PermanentToken> createPermanentToken(
      Uri authenticateUrl,
      String userName,
      String password,
      PermanentTokenBodyRequest bodyRequest,
      {OTPCode? otpCode}) async {
    final basicAuth = 'Basic ' + base64Encode(utf8.encode('$userName:$password'));
    final resultJson = await _dioClient.post(
        Endpoint.authentication.generateAuthenticationUrl(authenticateUrl),
        options: Options(headers: _buildPermanentTokenRequestParam(basicAuth, otpCode: otpCode)),
        data: bodyRequest.toJson());
    return PermanentToken.fromJson(resultJson);
  }

  Future<PermanentToken> createPermanentTokenWithOIDC(
      Uri authenticateUrl,
      String oidcToken,
      PermanentTokenBodyRequest bodyRequest,
      {OTPCode? otpCode}) async {
    final bearerAuth = 'Bearer $oidcToken';
    final resultJson = await _dioClient.post(
        Endpoint.authentication.generateAuthenticationUrl(authenticateUrl),
        options: Options(headers: _buildPermanentTokenRequestParam(bearerAuth, otpCode: otpCode)),
        data: bodyRequest.toJson());
    return PermanentToken.fromJson(resultJson);
  }

  Map<String, dynamic> _buildPermanentTokenRequestParam(String authorizationHeader, {OTPCode? otpCode}) {
    final headerParam = _dioClient.getHeaders();
    headerParam[HttpHeaders.authorizationHeader] = authorizationHeader;
    if (otpCode != null && otpCode.value.isNotEmpty) {
      headerParam[Constant.linShare2FAPin] = otpCode.value;
    }
    return headerParam;
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

  Future<UserResponse?> getAuthorizedUser() async {
    final resultJson = await _dioClient.get(Endpoint.authorizedUser.generateEndpointPath());
    return UserResponse.fromJson(resultJson);
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

  Future<ResponseBody> downloadFile(
      String url,
      CancelToken? cancelToken,
      Token permanentToken
  ) async {
    final headerParam = _dioClient.getHeaders();
    headerParam[HttpHeaders.authorizationHeader] = 'Bearer ${permanentToken.token}';
    final responseBody = await _dioClient.get(
        url,
        options: Options(headers: headerParam, responseType: ResponseType.stream),
        cancelToken: cancelToken);
    return (responseBody as ResponseBody);
  }

  Future<List<SharedSpaceNodeNestedResponse>> getSharedSpaces() async {
    final List resultJson = await _dioClient.get(
        Endpoint.sharedSpaces
            .generateEndpointPath(),
        queryParameters: [BooleanQueryParameter('withRole', true)].toMap());
    return resultJson.map((data) => SharedSpaceNodeNestedResponse.fromJson(data)).toList();
  }

  Future<List<AuditLogEntryUserDto?>> getSharedSpaceActivities(SharedSpaceId sharedSpaceId) async {
    final List membersJson = await _dioClient.get(
        Endpoint.sharedSpaces
                .withPathParameter(sharedSpaceId.uuid)
                .withPathParameter('audit')
                .generateEndpointPath());
    return membersJson
        .map((data) => _convertToAuditLogEntryNodeChild(data))
        .toList();
  }

  AuditLogEntryUserDto? _convertToAuditLogEntryNodeChild(Map<String, dynamic> nodeChildJson) {
    if (nodeChildJson['type'] == AuditLogEntryType.WORKGROUP.value) {
      return SharedSpaceNodeAuditLogEntryDto.fromJson(nodeChildJson);
    } else if (nodeChildJson['type'] == AuditLogEntryType.WORKGROUP_MEMBER.value) {
      return SharedSpaceMemberAuditLogEntryDto.fromJson(nodeChildJson);
    } else if (nodeChildJson['type'] == AuditLogEntryType.WORKGROUP_DOCUMENT.value) {
      return WorkGroupDocumentAuditLogEntryDto.fromJson(nodeChildJson);
    } else if (nodeChildJson['type'] == AuditLogEntryType.WORKGROUP_DOCUMENT_REVISION.value) {
      return WorkGroupDocumentRevisionAuditLogEntryDto.fromJson(nodeChildJson);
    } else if (nodeChildJson['type'] == AuditLogEntryType.WORKGROUP_FOLDER.value) {
      return WorkGroupFolderAuditLogEntryDto.fromJson(nodeChildJson);
    } else {
      return null;
    }
  }

  Future<List<AutoCompleteResult>> getSharingAutoComplete(
      AutoCompletePattern autoCompletePattern,
      AutoCompleteType autoCompleteType,
      { ThreadId? threadId }
  ) async {
    final List resultJson = await _dioClient.get(
        Endpoint.autocomplete
            .withPathParameter(autoCompletePattern.value)
            .generateEndpointPath(),
        queryParameters: [
          threadId != null ? StringQueryParameter('threadUuid', threadId.uuid) : null,
          StringQueryParameter('type', autoCompleteType.toString().split('.').last)
        ].toMap());
    return resultJson.map((data) => _getDynamicAutoCompleteResult(data)).toList();
  }

  Future<List<WorkGroupNodeDto>> getWorkGroupChildNodes(
      SharedSpaceId sharedSpaceId,
      {WorkGroupNodeId? parentId}
  ) async {
    final endpointPath = Endpoint.sharedSpaces
        .withPathParameter(sharedSpaceId.uuid)
        .withPathParameter(Endpoint.nodes)
        .generateEndpointPath();

    final queryParameters = parentId != null
        ? [StringQueryParameter('parent', parentId.uuid)]
        : <QueryParameter>[];

    final List nodesJsonResult = await _dioClient.get(
      endpointPath,
      queryParameters: queryParameters.toMap(),
    );

    return nodesJsonResult
        .map((data) => _convertToWorkGroupNodeChild(data))
        .toList();
  }

  Future<List<ReceivedShare>> getReceivedShares() async {
    final endpointPath = Endpoint.receivedShares.generateEndpointPath();

    final List receivedSharesJson = await _dioClient.get(endpointPath);

    return receivedSharesJson
        .map((data) => ReceivedShareDto.fromJson(data))
        .map((dto) => dto.toReceivedShare())
        .toList();
  }

  AutoCompleteResult _getDynamicAutoCompleteResult(Map<String, dynamic> map) {
    final type = map['type'] as String?;
    if (type == AutoCompleteResultType.simple.value) {
      return SimpleAutoCompleteResultDto.fromJson(map);
    } else if (type == AutoCompleteResultType.user.value) {
      return UserAutoCompleteResultDto.fromJson(map);
    } else if (type == AutoCompleteResultType.threadmember.value) {
      return SharedSpaceMemberAutoCompleteResultDto.fromJson(map);
    } else {
      return MailingListAutoCompleteResultDto.fromJson(map);
    }
  }

  WorkGroupNodeDto _convertToWorkGroupNodeChild(Map<String, dynamic> nodeChildJson) {
    if (nodeChildJson['type'] == WorkGroupNodeType.FOLDER.value) {
      return WorkGroupNodeFolderDto.fromJson(nodeChildJson);
    }

    return WorkGroupDocumentDto.fromJson(nodeChildJson);
  }

  Future<List<WorkGroupNodeDto>> copyWorkGroupNodeToSharedSpaceDestination(
    CopyBodyRequest copyRequest,
    SharedSpaceId destinationSharedSpaceId,
    {WorkGroupNodeId? destinationParentNodeId}) async {
      final copyEndpointPath = Endpoint.sharedSpaces
        .withPathParameter(destinationSharedSpaceId.uuid)
        .withPathParameter('nodes')
        .withPathParameter(destinationParentNodeId != null ? destinationParentNodeId.uuid : '')
        .withPathParameter('copy')
        .generateEndpointPath();

        final List resultJson = await _dioClient.post(
          copyEndpointPath,
          data: copyRequest.toJson().toString(),
        );

        return resultJson.map((node) => _convertToWorkGroupNodeChild(node)).toList();
    }

  Future<DocumentResponse> removeDocument(DocumentId documentId) async {
    final resultJson = await _dioClient.delete(Endpoint.documents
        .withPathParameter(documentId.uuid)
        .generateEndpointPath());
    return DocumentResponse.fromJson(resultJson);
  }

  Future<DocumentResponse> renameDocument(DocumentId documentId, RenameDocumentRequest renameDocumentRequest) async {
    final resultJson = await _dioClient.put(
        Endpoint.documents
            .withPathParameter(documentId.uuid)
            .generateEndpointPath(),
        data: renameDocumentRequest.toJson().toString(),
        options: Options(headers: {
          'Content-Type': 'application/json'
        })
    );
    return DocumentResponse.fromJson(resultJson);
  }

  Future<WorkGroupNodeDto> removeSharedSpaceNode(
    SharedSpaceId sharedSpaceId,
    WorkGroupNodeId sharedSpaceNodeId
  ) async {
    final workGroupNode = await _dioClient.delete(
      Endpoint.sharedSpaces
        .withPathParameter(sharedSpaceId.uuid)
        .withPathParameter('nodes')
        .withPathParameter(sharedSpaceNodeId.uuid)
        .generateEndpointPath(),
      options: Options(headers: {
        'Content-Type': 'application/json'
      })
    );

    return _convertToWorkGroupNodeChild(workGroupNode);
  }

  Future<AccountQuotaResponse> findQuota(QuotaId? quotaUuid) async {
    final resultJson = await _dioClient.get(Endpoint.quota.withPathParameter(quotaUuid?.uuid)
        .generateEndpointPath());
    return AccountQuotaResponse.fromJson(resultJson);
  }

  Future<List<DocumentResponse>> copyToMySpace(
    CopyBodyRequest copyRequest
  ) async {
      final copyEndpointPath = Endpoint.documents
        .withPathParameter('copy')
        .generateEndpointPath();

        final List resultJson = await _dioClient.post(
          copyEndpointPath,
          data: copyRequest.toJson().toString(),
        );

        return resultJson.map((data) => DocumentResponse.fromJson(data)).toList();
    }

  Future<List<FunctionalityDto>> getAllFunctionality() async {
    final List resultJson = await _dioClient.get(Endpoint.functionality.generateEndpointPath());
    return resultJson.map((data) => _convertToActualFunctionality(data)).toList();
  }

  FunctionalityDto _convertToActualFunctionality(Map<String, dynamic> jsonData) {
    String? type = jsonData['type'];
    switch (type) {
      case 'boolean': return FunctionalityBooleanDto.fromJson(jsonData);
      case 'integer': return FunctionalityIntegerDto.fromJson(jsonData);
      case 'language': return FunctionalityLanguageDto.fromJson(jsonData);
      case 'simple': return FunctionalitySimpleDto.fromJson(jsonData);
      case 'size': return FunctionalitySizeDto.fromJson(jsonData);
      case 'string': return FunctionalityStringDto.fromJson(jsonData);
      case 'time': return FunctionalityTimeDto.fromJson(jsonData);
      default: return FunctionalitySimpleDto.fromJson(jsonData);
    }
  }

  Future<SharedSpaceNodeNestedResponse> deleteSharedSpace(SharedSpaceId sharedSpaceId) async {
    final deletedSharedSpace = await _dioClient.delete(
      Endpoint.sharedSpaces.withPathParameter(sharedSpaceId.uuid).generateEndpointPath(),
      options: Options(headers: {
        'Content-Type': 'application/json'
      })
    );

    return SharedSpaceNodeNestedResponse.fromJson(deletedSharedSpace);
  }

  Future<WorkGroupNodeFolderDto> createSharedSpaceNodeFolder(SharedSpaceId sharedSpaceId, CreateSharedSpaceNodeFolderRequest createSharedSpaceNodeRequest) async {
    final resultJson = await _dioClient.post(
      Endpoint.sharedSpaces
        .withPathParameter(sharedSpaceId.uuid)
        .withPathParameter('nodes')
        .generateEndpointPath(),
        data: createSharedSpaceNodeRequest.toJson().toString());
    return WorkGroupNodeFolderDto.fromJson(resultJson);
  }

  Future<SharedSpaceNodeNestedResponse> getSharedSpace(
    SharedSpaceId sharedSpaceId,
    {
      MembersParameter membersParameter = MembersParameter.withoutMembers,
      RolesParameter rolesParameter = RolesParameter.withRole
    }
  ) async {
    final resultJson = await _dioClient.get(
        Endpoint.sharedSpaces
            .withPathParameter(sharedSpaceId.uuid)
            .generateEndpointPath(),
        queryParameters: [
          BooleanQueryParameter('members', membersParameter == MembersParameter.withMembers),
          BooleanQueryParameter('withRole', rolesParameter == RolesParameter.withRole),
        ].toMap());
    return SharedSpaceNodeNestedResponse.fromJson(resultJson);
  }

  Future<List<SharedSpaceMemberResponse>> getSharedSpaceMembers(SharedSpaceId sharedSpaceId) async {
    final sharedSpaceMemberPath = Endpoint.sharedSpaces.withPathParameter(sharedSpaceId.uuid).withPathParameter('members').generateEndpointPath();

    final List membersJson = await _dioClient.get(sharedSpaceMemberPath);

    return membersJson
      .map((data) => SharedSpaceMemberResponse.fromJson(data))
      .toList();
  }

  Future<SharedSpaceNodeNestedResponse> createSharedSpaceWorkGroup(CreateWorkGroupBodyRequest createWorkGroupBodyRequest) async {
    final resultJson = await _dioClient.post(
        Endpoint.sharedSpaces.generateEndpointPath(),
        data: createWorkGroupBodyRequest.toJson().toString());
    return SharedSpaceNodeNestedResponse.fromJson(resultJson);
  }

  Future<WorkGroupNodeDto> renameSharedSpaceNode(
      SharedSpaceId sharedSpaceId,
      WorkGroupNodeId sharedSpaceNodeId,
      RenameWorkGroupNodeBodyRequest renameWorkGroupNodeBodyRequest
  ) async {
    final workGroupNode = await _dioClient.put(
        Endpoint.sharedSpaces
            .withPathParameter(sharedSpaceId.uuid)
            .withPathParameter('nodes')
            .withPathParameter(sharedSpaceNodeId.uuid)
            .generateEndpointPath(),
        data: renameWorkGroupNodeBodyRequest.toJson().toString(),
        options: Options(headers: {
          'Content-Type': 'application/json'
        })
    );

    return _convertToWorkGroupNodeChild(workGroupNode);
  }

  Future<SharedSpaceMemberResponse> addSharedSpaceMember(SharedSpaceId sharedSpaceId, AddSharedSpaceMemberRequest request) async {
    final resultJson = await _dioClient.post(
      Endpoint.sharedSpaces
        .withPathParameter(sharedSpaceId.uuid)
        .withPathParameter('members')
        .generateEndpointPath(),
        data: request.toBodyRequest().toJson().toString());
    return SharedSpaceMemberResponse.fromJson(resultJson);
  }

  Future<List<SharedSpaceRoleDto>> getSharedSpaceRoles() async {
    final sharedSpaceRolesPath = Endpoint.sharedSpaceRoles.generateEndpointPath();
    final List rolesJson = await _dioClient.get(sharedSpaceRolesPath);

    return rolesJson
      .map((data) => SharedSpaceRoleDto.fromJson(data))
      .toList();
  }

  Future<SharedSpaceMemberResponse> updateRoleSharedSpaceMember(SharedSpaceId sharedSpaceId, UpdateSharedSpaceMemberRequest request) async {
    final resultJson = await _dioClient.put(
        Endpoint.sharedSpaces
            .withPathParameter(sharedSpaceId.uuid)
            .withPathParameter('members')
            .withPathParameter(request.account.uuid)
            .generateEndpointPath(),
        data: request.toBodyRequest().toJson().toString());
    return SharedSpaceMemberResponse.fromJson(resultJson);
  }

  Future<SharedSpaceMemberResponse> deleteSharedSpaceMember(
      SharedSpaceId sharedSpaceId,
      SharedSpaceMemberId sharedSpaceMemberId) async {
    final resultJson = await _dioClient.delete(
        Endpoint.sharedSpaces
            .withPathParameter(sharedSpaceId.uuid)
            .withPathParameter('members')
            .withPathParameter(sharedSpaceMemberId.uuid)
            .generateEndpointPath(),
        data: json.encode(null));

    return SharedSpaceMemberResponse.fromJson(resultJson);
  }

  Future<DocumentDetailsResponse> getDocument(DocumentId documentId) async {
    final resultJson = await _dioClient.get(Endpoint.documents
        .withPathParameter(documentId.uuid)
        .withQueryParameters([BooleanQueryParameter('withShares', true)]).generateEndpointPath());

    return DocumentDetailsResponse.fromJson(resultJson);
  }

  Future<WorkGroupNodeDto> getWorkGroupNode(
      SharedSpaceId sharedSpaceId,
      WorkGroupNodeId workGroupNodeId,
      {bool hasTreePath = false}
  ) async {
    final endpointPath = hasTreePath
      ? Endpoint.sharedSpaces
          .withPathParameter(sharedSpaceId.uuid)
          .withPathParameter(Endpoint.nodes)
          .withPathParameter(workGroupNodeId.uuid)
          .withQueryParameters([BooleanQueryParameter('tree', true)])
          .generateEndpointPath()
      : Endpoint.sharedSpaces
          .withPathParameter(sharedSpaceId.uuid)
          .withPathParameter(Endpoint.nodes)
          .withPathParameter(workGroupNodeId.uuid)
          .generateEndpointPath();

    final nodeJsonResult = await _dioClient.get(endpointPath);

    return _convertToWorkGroupNodeChild(nodeJsonResult);
  }

  Future<SharedSpaceNodeNestedResponse> renameWorkGroup(
      SharedSpaceId sharedSpaceId,
      RenameWorkGroupBodyRequest renameWorkGroupBodyRequest
  ) async {
    final resultJson = await _dioClient.put(
      Endpoint.sharedSpaces.withPathParameter(sharedSpaceId.uuid).generateEndpointPath(),
      data: renameWorkGroupBodyRequest.toJson().toString(),
    );

    return SharedSpaceNodeNestedResponse.fromJson(resultJson);
  }

  Future<DocumentResponse> editDescriptionDocument(DocumentId documentId, EditDescriptionDocumentRequest request) async {
    final resultJson = await _dioClient.put(
        Endpoint.documents
            .withPathParameter(documentId.uuid)
            .generateEndpointPath(),
        data: request.toJson().toString(),
        options: Options(headers: {
          'Content-Type': 'application/json'
        })
    );
    return DocumentResponse.fromJson(resultJson);
  }

  Future<List<UploadRequestGroupResponse>> getAllUploadRequestGroups(
      List<UploadRequestStatus> status) async {
    final List resultJson = await _dioClient.get(Endpoint.uploadRequestGroups
        .withQueryParameters(
            status.map((element) => StringQueryParameter('status', element.value)).toList())
        .generateEndpointPath());

    return resultJson.map((data) => UploadRequestGroupResponse.fromJson(data)).toList();
  }

  Future<UploadRequestGroupResponse> addNewUploadRequest(UploadRequestCreationType creationType, AddUploadRequest addUploadRequest) async {
    final resultJson = await _dioClient.post(
        Endpoint.uploadRequestGroups
            .withQueryParameters([BooleanQueryParameter('collective',
                (creationType == UploadRequestCreationType.COLLECTIVE))])
            .generateEndpointPath(),
        data: addUploadRequest.toAddUploadBodyRequest().toJson().toString());
    return UploadRequestGroupResponse.fromJson(resultJson);
  }

  Future<List<UploadRequestResponse>> getAllUploadRequests(UploadRequestGroupId uploadRequestGroupId) async {
    final List resultJson = await _dioClient.get(Endpoint.uploadRequestGroups
        .withPathParameter(uploadRequestGroupId.uuid)
        .withPathParameter(Endpoint.uploadRequests)
        .generateEndpointPath());
    return resultJson.map((data) => UploadRequestResponse.fromJson(data)).toList();
  }

  Future<List<UploadRequestEntryResponse>> getAllUploadRequestEntries(UploadRequestId uploadRequestId) async {
    final List resultJson = await _dioClient.get(Endpoint.uploadRequestsRoute
        .withPathParameter(uploadRequestId.uuid)
        .withPathParameter(Endpoint.entries)
        .generateEndpointPath());
    return resultJson.map((data) => UploadRequestEntryResponse.fromJson(data)).toList();
  }

  Future<UploadRequestResponse> updateUploadRequestStatus(
    UploadRequestId uploadRequestId,
    UploadRequestStatus newStatus,
    {bool? copyToMySpace}
  ) async {
    if (copyToMySpace != null) {
      final resultJson = await _dioClient.put(
        Endpoint.uploadRequestsRoute.withPathParameter(uploadRequestId.uuid)
          .withPathParameter(Endpoint.status)
          .withPathParameter(newStatus.value)
          .withQueryParameters([BooleanQueryParameter('copy', copyToMySpace)])
          .generateEndpointPath());
      return UploadRequestResponse.fromJson(resultJson);
    } else {
      final resultJson = await _dioClient.put(
        Endpoint.uploadRequestsRoute.withPathParameter(uploadRequestId.uuid)
          .withPathParameter(Endpoint.status)
          .withPathParameter(newStatus.value)
          .generateEndpointPath());
      return UploadRequestResponse.fromJson(resultJson);
    }
  }

  Future<ReceivedShareDto> getReceivedShare(ShareId receivedShareId) async {
    final endpointPath =
        Endpoint.receivedShares.withPathParameter(receivedShareId.uuid).generateEndpointPath();

    final receivedShareJson = await _dioClient.get(endpointPath);

    return ReceivedShareDto.fromJson(receivedShareJson);
  }

  Future<UploadRequestGroupResponse> addRecipientsToUploadRequestGroup(UploadRequestGroupId uploadRequestGroupId, List<GenericUser> recipients) async {
    final resultJson = await _dioClient.post(
        Endpoint.uploadRequestGroups
            .withPathParameter(uploadRequestGroupId.uuid)
            .withPathParameter(Endpoint.recipents)
            .generateEndpointPath(),
        data: recipients.map((data) => GenericUserDto(data.mail, lastName: data.lastName, firstName: data.firstName).toJson()).toList().toString());
    return UploadRequestGroupResponse.fromJson(resultJson);
  }

  Future<UploadRequestGroupResponse> updateUploadRequestGroupStatus(
      UploadRequestGroupId uploadRequestGroupId,
      UploadRequestStatus status,
      {bool? copyToMySpace}) async {
    if(copyToMySpace != null) {
      final resultJson = await _dioClient.put(Endpoint.uploadRequestGroups
          .withPathParameter(uploadRequestGroupId.uuid)
          .withPathParameter(Endpoint.status)
          .withPathParameter(status.value)
          .withQueryParameters([BooleanQueryParameter('copy', copyToMySpace)])
          .generateEndpointPath());
      return UploadRequestGroupResponse.fromJson(resultJson);
    } else {
      final resultJson = await _dioClient.put(
          Endpoint.uploadRequestGroups
              .withPathParameter(uploadRequestGroupId.uuid)
              .withPathParameter(Endpoint.status)
              .withPathParameter(status.value)
              .generateEndpointPath());
      return UploadRequestGroupResponse.fromJson(resultJson);
    }
  }

  Future<List<AuthenticationAuditLogEntryUserResponse>> getAuditAuthenticationEntryUser() async {
    final List resultJson = await _dioClient.get(
        Endpoint.audit.generateEndpointPath(),
        queryParameters: [StringQueryParameter('type', 'AUTHENTICATION'), StringQueryParameter('action', 'SUCCESS')].toMap());
    return resultJson.map((data) => AuthenticationAuditLogEntryUserResponse.fromJson(data)).toList();
  }

  Future<WorkGroupNodeDto> moveWorkgroupNode(MoveWorkGroupNodeBodyRequest moveRequest, SharedSpaceId sourceSharedSpaceId) async {
    final workGroupNode = await _dioClient.put(
        Endpoint.sharedSpaces
            .withPathParameter(sourceSharedSpaceId.uuid)
            .withPathParameter('nodes')
            .withPathParameter(moveRequest.workGroupNodeId.uuid)
            .generateEndpointPath(),
        options: Options(headers: {
          'Content-Type': 'application/json'
        }),
        data: moveRequest.toJson().toString(),
    );
    return _convertToWorkGroupNodeChild(workGroupNode);
  }

  Future<ReceivedShareDto> removeReceivedShare(ShareId shareId) async {
    final resultJson = await _dioClient.delete(Endpoint.receivedShares
      .withPathParameter(shareId.uuid)
      .generateEndpointPath());
    return ReceivedShareDto.fromJson(resultJson);
  }

  Future<SharedSpaceNodeNestedResponse> enableVersioningWorkGroup(
      SharedSpaceId sharedSpaceId,
      EnableVersioningWorkGroupBodyRequest enableVersioningBodyRequest
  ) async {
    final resultJson = await _dioClient.put(
      Endpoint.sharedSpaces.withPathParameter(sharedSpaceId.uuid).generateEndpointPath(),
      data: enableVersioningBodyRequest.toJson().toString(),
    );

    return SharedSpaceNodeNestedResponse.fromJson(resultJson);
  }

  Future<List<WorkGroupNodeDto>> advanceSearchWorkGroupNodes(SharedSpaceId sharedSpaceId, AdvancedSearchRequest searchRequest) async {

    final queryParameters = <QueryParameter>[];
    if(searchRequest.kinds != null && searchRequest.kinds!.isNotEmpty) {
      queryParameters.addAll(searchRequest.kinds!.map((kind) => StringQueryParameter('kinds', kind.name)).toList());
    }
    if(searchRequest.modificationDateAfter != null) {
      queryParameters.add(StringQueryParameter('modificationDateAfter', searchRequest.modificationDateAfter!));
    }
    if(searchRequest.modificationDateBefore != null) {
      queryParameters.add(StringQueryParameter('modificationDateBefore', searchRequest.modificationDateBefore!));
    }
    if(searchRequest.pattern != null && searchRequest.pattern!.isNotEmpty) {
      queryParameters.add(StringQueryParameter('pattern', searchRequest.pattern!));
    }
    if(searchRequest.sortField != null) {
      queryParameters.add(StringQueryParameter('sortField', searchRequest.sortField!.value));
    }
    if(searchRequest.sortOrder != null) {
      queryParameters.add(StringQueryParameter('sortOrder', searchRequest.sortOrder!.value));
    }
    if(searchRequest.tree != null) {
      queryParameters.add(BooleanQueryParameter('tree', searchRequest.tree!));
    }
    if(searchRequest.types != null && searchRequest.types!.isNotEmpty) {
      queryParameters.addAll(searchRequest.types!.map((type) => StringQueryParameter('types', type.name)).toList());
    }

    final endpointPath = Endpoint.sharedSpaces
        .withPathParameter(sharedSpaceId.uuid)
        .withPathParameter(Endpoint.nodes)
        .withPathParameter(Endpoint.search)
        .withQueryParameters(queryParameters)
        .generateEndpointPath();

    final List nodesJsonResult = await _dioClient.get(endpointPath);

    return nodesJsonResult
      .where((element) => validateSearchResult(element))
      .map((data) => _convertToWorkGroupNodeChild(data))
      .toList();
  }

  bool validateSearchResult(Map<String, dynamic> jsonResult) {
    return (jsonResult['type'] == WorkGroupNodeType.FOLDER.value)
      || (jsonResult['type'] == WorkGroupNodeType.DOCUMENT.value);
  }

  Future<String> getOIDCConfiguration(Uri baseUrl) async {
    final result = await _dioClient.get(
        Endpoint.oidcConfiguration.generateOIDCConfigurationUrl(baseUrl));
    return result;
  }

  Future<UploadRequestEntryResponse> removeUploadRequestEntry(UploadRequestEntryId entryId) async {
    final resultJson = await _dioClient.delete(Endpoint.uploadRequestsEntriesRoute
      .withPathParameter(entryId.uuid)
      .generateEndpointPath());
    return UploadRequestEntryResponse.fromJson(resultJson);
  }

  Future<UploadRequestGroupResponse> editUploadRequest(UploadRequestGroupId uploadRequestGroupId, EditUploadRequest request) async {
    final resultJson = await _dioClient.put(
      Endpoint.uploadRequestGroups
        .withPathParameter(uploadRequestGroupId.uuid)
        .generateEndpointPath(),
      data: request.toBodyRequest().toJson().toString());
    return UploadRequestGroupResponse.fromJson(resultJson);
  }

  Future<List<SharedSpaceNodeNestedResponse>> getAllWorkgroups(DriveId driveId) async {
    final List resultJson = await _dioClient.get(
      Endpoint.sharedSpaces
        .withQueryParameters([
            StringQueryParameter('parent', driveId.uuid),
            BooleanQueryParameter('withRole', true)
          ])
        .generateEndpointPath());
    return resultJson.map((data) => SharedSpaceNodeNestedResponse.fromJson(data)).toList();
  }
}
