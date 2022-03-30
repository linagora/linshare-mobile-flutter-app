// Mocks generated by Mockito 5.0.17 from annotations
// in domain/test/usecases/upload_request/get_all_upload_request_interactor_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i3;

import 'package:domain/domain.dart' as _i2;
import 'package:domain/src/model/upload_request/edit_upload_request_recipient.dart'
    as _i4;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

class _FakeUploadRequest_0 extends _i1.Fake implements _i2.UploadRequest {}

/// A class which mocks [UploadRequestRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockUploadRequestRepository extends _i1.Mock
    implements _i2.UploadRequestRepository {
  MockUploadRequestRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<List<_i2.UploadRequest>> getAllUploadRequests(
          _i2.UploadRequestGroupId? uploadRequestGroupId) =>
      (super.noSuchMethod(
              Invocation.method(#getAllUploadRequests, [uploadRequestGroupId]),
              returnValue:
                  Future<List<_i2.UploadRequest>>.value(<_i2.UploadRequest>[]))
          as _i3.Future<List<_i2.UploadRequest>>);
  @override
  _i3.Future<_i2.UploadRequest> updateUploadRequestState(
          _i2.UploadRequestId? uploadRequestId, _i2.UploadRequestStatus? status,
          {bool? copyToMySpace}) =>
      (super.noSuchMethod(
              Invocation.method(#updateUploadRequestState,
                  [uploadRequestId, status], {#copyToMySpace: copyToMySpace}),
              returnValue:
                  Future<_i2.UploadRequest>.value(_FakeUploadRequest_0()))
          as _i3.Future<_i2.UploadRequest>);
  @override
  _i3.Future<_i2.UploadRequest> getUploadRequest(
          _i2.UploadRequestId? uploadRequestId) =>
      (super.noSuchMethod(
              Invocation.method(#getUploadRequest, [uploadRequestId]),
              returnValue:
                  Future<_i2.UploadRequest>.value(_FakeUploadRequest_0()))
          as _i3.Future<_i2.UploadRequest>);
  @override
  _i3.Future<_i2.UploadRequest> editUploadRequest(
          _i2.UploadRequestId? uploadRequestId,
          _i4.EditUploadRequestRecipient? request) =>
      (super.noSuchMethod(
              Invocation.method(#editUploadRequest, [uploadRequestId, request]),
              returnValue:
                  Future<_i2.UploadRequest>.value(_FakeUploadRequest_0()))
          as _i3.Future<_i2.UploadRequest>);
  @override
  _i3.Future<List<_i2.AuditLogEntryUser?>> getUploadRequestActivities(
          _i2.UploadRequestId? uploadRequestId) =>
      (super.noSuchMethod(
              Invocation.method(#getUploadRequestActivities, [uploadRequestId]),
              returnValue: Future<List<_i2.AuditLogEntryUser?>>.value(
                  <_i2.AuditLogEntryUser?>[]))
          as _i3.Future<List<_i2.AuditLogEntryUser?>>);
}