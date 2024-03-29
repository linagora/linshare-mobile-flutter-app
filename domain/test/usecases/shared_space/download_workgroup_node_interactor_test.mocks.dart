// Mocks generated by Mockito 5.0.17 from annotations
// in domain/test/usecases/shared_space/download_workgroup_node_interactor_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i4;

import 'package:data/src/network/model/request/create_shared_space_node_folder_request.dart'
    as _i6;
import 'package:dio/dio.dart' as _i5;
import 'package:domain/domain.dart' as _i2;
import 'package:domain/src/model/authentication/token.dart' as _i3;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

class _FakeFlowFile_0 extends _i1.Fake implements _i2.FlowFile {}

class _FakeWorkGroupNode_1 extends _i1.Fake implements _i2.WorkGroupNode {}

class _FakeWorkGroupFolder_2 extends _i1.Fake implements _i2.WorkGroupFolder {}

class _FakeUri_3 extends _i1.Fake implements Uri {}

class _FakeToken_4 extends _i1.Fake implements _i3.Token {}

/// A class which mocks [SharedSpaceDocumentRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockSharedSpaceDocumentRepository extends _i1.Mock
    implements _i2.SharedSpaceDocumentRepository {
  MockSharedSpaceDocumentRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.FlowFile uploadChunks(
          _i2.FileInfo? fileInfo, _i2.SharedSpaceId? sharedSpaceId,
          {_i2.WorkGroupNodeId? parentNodeId}) =>
      (super.noSuchMethod(
          Invocation.method(#uploadChunks, [fileInfo, sharedSpaceId],
              {#parentNodeId: parentNodeId}),
          returnValue: _FakeFlowFile_0()) as _i2.FlowFile);
  @override
  _i4.Future<List<_i2.WorkGroupNode?>> getAllChildNodes(
          _i2.SharedSpaceId? sharedSpaceId,
          {_i2.WorkGroupNodeId? parentNodeId}) =>
      (super.noSuchMethod(
          Invocation.method(#getAllChildNodes, [sharedSpaceId],
              {#parentNodeId: parentNodeId}),
          returnValue: Future<List<_i2.WorkGroupNode?>>.value(
              <_i2.WorkGroupNode?>[])) as _i4.Future<List<_i2.WorkGroupNode?>>);
  @override
  _i4.Future<List<_i2.WorkGroupNode>> copyToSharedSpace(
          _i2.CopyRequest? copyRequest,
          _i2.SharedSpaceId? destinationSharedSpaceId,
          {_i2.WorkGroupNodeId? destinationParentNodeId}) =>
      (super.noSuchMethod(
              Invocation.method(
                  #copyToSharedSpace,
                  [copyRequest, destinationSharedSpaceId],
                  {#destinationParentNodeId: destinationParentNodeId}),
              returnValue:
                  Future<List<_i2.WorkGroupNode>>.value(<_i2.WorkGroupNode>[]))
          as _i4.Future<List<_i2.WorkGroupNode>>);
  @override
  _i4.Future<_i2.WorkGroupNode> removeSharedSpaceNode(
          _i2.SharedSpaceId? sharedSpaceId,
          _i2.WorkGroupNodeId? sharedSpaceNodeId) =>
      (super.noSuchMethod(
              Invocation.method(
                  #removeSharedSpaceNode, [sharedSpaceId, sharedSpaceNodeId]),
              returnValue:
                  Future<_i2.WorkGroupNode>.value(_FakeWorkGroupNode_1()))
          as _i4.Future<_i2.WorkGroupNode>);
  @override
  _i4.Future<List<_i2.DownloadTaskId>> downloadNodes(
          List<_i2.WorkGroupNode>? workgroupNodes,
          _i3.Token? token,
          Uri? baseUrl,
          _i2.APIVersionSupported? apiVersion) =>
      (super.noSuchMethod(
          Invocation.method(
              #downloadNodes, [workgroupNodes, token, baseUrl, apiVersion]),
          returnValue: Future<List<_i2.DownloadTaskId>>.value(
              <_i2.DownloadTaskId>[])) as _i4.Future<List<_i2.DownloadTaskId>>);
  @override
  _i4.Future<String> downloadNodeIOS(_i2.WorkGroupNode? workgroupNode,
          _i3.Token? token, Uri? baseUrl, _i5.CancelToken? cancelToken) =>
      (super.noSuchMethod(
          Invocation.method(
              #downloadNodeIOS, [workgroupNode, token, baseUrl, cancelToken]),
          returnValue: Future<String>.value('')) as _i4.Future<String>);
  @override
  _i4.Future<_i2.WorkGroupFolder> createSharedSpaceFolder(
          _i2.SharedSpaceId? sharedSpaceId,
          _i6.CreateSharedSpaceNodeFolderRequest?
              createSharedSpaceNodeRequest) =>
      (super.noSuchMethod(
              Invocation.method(#createSharedSpaceFolder,
                  [sharedSpaceId, createSharedSpaceNodeRequest]),
              returnValue:
                  Future<_i2.WorkGroupFolder>.value(_FakeWorkGroupFolder_2()))
          as _i4.Future<_i2.WorkGroupFolder>);
  @override
  _i4.Future<String> downloadPreviewWorkGroupDocument(
          _i2.WorkGroupDocument? workGroupDocument,
          _i2.DownloadPreviewType? downloadPreviewType,
          _i3.Token? token,
          Uri? baseUrl,
          _i5.CancelToken? cancelToken) =>
      (super.noSuchMethod(
          Invocation.method(#downloadPreviewWorkGroupDocument, [
            workGroupDocument,
            downloadPreviewType,
            token,
            baseUrl,
            cancelToken
          ]),
          returnValue: Future<String>.value('')) as _i4.Future<String>);
  @override
  _i4.Future<_i2.WorkGroupNode> renameSharedSpaceNode(
          _i2.SharedSpaceId? sharedSpaceId,
          _i2.WorkGroupNodeId? sharedSpaceNodeId,
          _i2.RenameWorkGroupNodeRequest? renameWorkGroupNodeRequest) =>
      (super.noSuchMethod(
              Invocation.method(#renameSharedSpaceNode, [
                sharedSpaceId,
                sharedSpaceNodeId,
                renameWorkGroupNodeRequest
              ]),
              returnValue:
                  Future<_i2.WorkGroupNode>.value(_FakeWorkGroupNode_1()))
          as _i4.Future<_i2.WorkGroupNode>);
  @override
  _i4.Future<_i2.WorkGroupNode?> getWorkGroupNode(
          _i2.SharedSpaceId? sharedSpaceId,
          _i2.WorkGroupNodeId? workGroupNodeId,
          {bool? hasTreePath}) =>
      (super.noSuchMethod(
              Invocation.method(
                  #getWorkGroupNode,
                  [sharedSpaceId, workGroupNodeId],
                  {#hasTreePath: hasTreePath}),
              returnValue: Future<_i2.WorkGroupNode?>.value())
          as _i4.Future<_i2.WorkGroupNode?>);
  @override
  _i4.Future<bool> makeAvailableOfflineSharedSpaceDocument(
          _i2.SharedSpaceNodeNested? drive,
          _i2.SharedSpaceNodeNested? sharedSpaceNodeNested,
          _i2.WorkGroupDocument? workGroupDocument,
          String? localPath,
          {List<_i2.TreeNode>? treeNodes}) =>
      (super.noSuchMethod(
          Invocation.method(
              #makeAvailableOfflineSharedSpaceDocument,
              [drive, sharedSpaceNodeNested, workGroupDocument, localPath],
              {#treeNodes: treeNodes}),
          returnValue: Future<bool>.value(false)) as _i4.Future<bool>);
  @override
  _i4.Future<String> downloadMakeOfflineSharedSpaceDocument(
          _i2.SharedSpaceId? sharedSpaceId,
          _i2.WorkGroupNodeId? workGroupNodeId,
          String? workGroupNodeName,
          _i2.DownloadPreviewType? downloadPreviewType,
          _i3.Token? permanentToken,
          Uri? baseUrl) =>
      (super.noSuchMethod(
          Invocation.method(#downloadMakeOfflineSharedSpaceDocument, [
            sharedSpaceId,
            workGroupNodeId,
            workGroupNodeName,
            downloadPreviewType,
            permanentToken,
            baseUrl
          ]),
          returnValue: Future<String>.value('')) as _i4.Future<String>);
  @override
  _i4.Future<_i2.WorkGroupDocument?> getSharesSpaceDocumentOffline(
          _i2.WorkGroupNodeId? workGroupNodeId) =>
      (super.noSuchMethod(
          Invocation.method(#getSharesSpaceDocumentOffline, [workGroupNodeId]),
          returnValue:
              Future<_i2.WorkGroupDocument?>.value()) as _i4
          .Future<_i2.WorkGroupDocument?>);
  @override
  _i4.Future<bool> disableAvailableOfflineSharedSpaceDocument(
          _i2.SharedSpaceId? parentId,
          _i2.SharedSpaceId? sharedSpaceId,
          _i2.WorkGroupNodeId? parentNodeId,
          _i2.WorkGroupNodeId? workGroupNodeId,
          String? localPath) =>
      (super.noSuchMethod(
          Invocation.method(#disableAvailableOfflineSharedSpaceDocument, [
            parentId,
            sharedSpaceId,
            parentNodeId,
            workGroupNodeId,
            localPath
          ]),
          returnValue: Future<bool>.value(false)) as _i4.Future<bool>);
  @override
  _i4.Future<List<_i2.WorkGroupNode>> getAllSharedSpaceDocumentOffline(
          _i2.SharedSpaceId? sharedSpaceId,
          _i2.WorkGroupNodeId? parentNodeId) =>
      (super.noSuchMethod(
          Invocation.method(
              #getAllSharedSpaceDocumentOffline, [sharedSpaceId, parentNodeId]),
          returnValue: Future<List<_i2.WorkGroupNode>>.value(
              <_i2.WorkGroupNode>[])) as _i4.Future<List<_i2.WorkGroupNode>>);
  @override
  _i4.Future<bool> updateSharedSpaceDocumentOffline(
          _i2.WorkGroupDocument? workGroupDocument, String? localPath) =>
      (super.noSuchMethod(
          Invocation.method(#updateSharedSpaceDocumentOffline,
              [workGroupDocument, localPath]),
          returnValue: Future<bool>.value(false)) as _i4.Future<bool>);
  @override
  _i4.Future<bool> deleteAllData() =>
      (super.noSuchMethod(Invocation.method(#deleteAllData, []),
          returnValue: Future<bool>.value(false)) as _i4.Future<bool>);
  @override
  _i4.Future<_i2.WorkGroupNode> getRealSharedSpaceRootNode(
          _i2.SharedSpaceId? shareSpaceId,
          {bool? hasTreePath = false}) =>
      (super.noSuchMethod(
              Invocation.method(#getRealSharedSpaceRootNode, [shareSpaceId],
                  {#hasTreePath: hasTreePath}),
              returnValue:
                  Future<_i2.WorkGroupNode>.value(_FakeWorkGroupNode_1()))
          as _i4.Future<_i2.WorkGroupNode>);
  @override
  _i4.Future<_i2.WorkGroupNode> moveWorkgroupNode(
          _i2.MoveWorkGroupNodeRequest? moveRequest,
          _i2.SharedSpaceId? sourceSharedSpaceId) =>
      (super.noSuchMethod(
              Invocation.method(
                  #moveWorkgroupNode, [moveRequest, sourceSharedSpaceId]),
              returnValue:
                  Future<_i2.WorkGroupNode>.value(_FakeWorkGroupNode_1()))
          as _i4.Future<_i2.WorkGroupNode>);
  @override
  _i4.Future<List<_i2.WorkGroupNode?>> doAdvancedSearch(
          _i2.SharedSpaceId? sharedSpaceId,
          _i2.AdvancedSearchRequest? searchRequest) =>
      (super.noSuchMethod(
          Invocation.method(#doAdvancedSearch, [sharedSpaceId, searchRequest]),
          returnValue: Future<List<_i2.WorkGroupNode?>>.value(
              <_i2.WorkGroupNode?>[])) as _i4.Future<List<_i2.WorkGroupNode?>>);
}

/// A class which mocks [CredentialRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockCredentialRepository extends _i1.Mock
    implements _i2.CredentialRepository {
  MockCredentialRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<dynamic> saveBaseUrl(Uri? baseUrl) =>
      (super.noSuchMethod(Invocation.method(#saveBaseUrl, [baseUrl]),
          returnValue: Future<dynamic>.value()) as _i4.Future<dynamic>);
  @override
  _i4.Future<dynamic> removeBaseUrl() =>
      (super.noSuchMethod(Invocation.method(#removeBaseUrl, []),
          returnValue: Future<dynamic>.value()) as _i4.Future<dynamic>);
  @override
  _i4.Future<Uri> getBaseUrl() =>
      (super.noSuchMethod(Invocation.method(#getBaseUrl, []),
          returnValue: Future<Uri>.value(_FakeUri_3())) as _i4.Future<Uri>);
}

/// A class which mocks [TokenRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockTokenRepository extends _i1.Mock implements _i2.TokenRepository {
  MockTokenRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<dynamic> persistToken(_i3.Token? token) =>
      (super.noSuchMethod(Invocation.method(#persistToken, [token]),
          returnValue: Future<dynamic>.value()) as _i4.Future<dynamic>);
  @override
  _i4.Future<dynamic> removeToken() =>
      (super.noSuchMethod(Invocation.method(#removeToken, []),
          returnValue: Future<dynamic>.value()) as _i4.Future<dynamic>);
  @override
  _i4.Future<_i3.Token> getToken() =>
      (super.noSuchMethod(Invocation.method(#getToken, []),
              returnValue: Future<_i3.Token>.value(_FakeToken_4()))
          as _i4.Future<_i3.Token>);
}

/// A class which mocks [APIRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockAPIRepository extends _i1.Mock implements _i2.APIRepository {
  MockAPIRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<void> persistAPIVersionSupported(
          _i2.APIVersionSupported? apiVersionSupported) =>
      (super.noSuchMethod(
          Invocation.method(#persistAPIVersionSupported, [apiVersionSupported]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i4.Future<void>);
  @override
  _i4.Future<_i2.APIVersionSupported> getAPIVersionSupported() =>
      (super.noSuchMethod(Invocation.method(#getAPIVersionSupported, []),
              returnValue: Future<_i2.APIVersionSupported>.value(
                  _i2.APIVersionSupported.v5))
          as _i4.Future<_i2.APIVersionSupported>);
}
