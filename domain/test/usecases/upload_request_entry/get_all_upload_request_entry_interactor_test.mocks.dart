// Mocks generated by Mockito 5.0.17 from annotations
// in domain/test/usecases/upload_request_entry/get_all_upload_request_entry_interactor_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i3;

import 'package:dio/dio.dart' as _i4;
import 'package:domain/domain.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

class _FakeUploadRequestEntry_0 extends _i1.Fake
    implements _i2.UploadRequestEntry {}

/// A class which mocks [UploadRequestEntryRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockUploadRequestEntryRepository extends _i1.Mock
    implements _i2.UploadRequestEntryRepository {
  MockUploadRequestEntryRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<List<_i2.UploadRequestEntry>> getAllUploadRequestEntries(
          _i2.UploadRequestId? uploadRequestId) =>
      (super.noSuchMethod(
              Invocation.method(#getAllUploadRequestEntries, [uploadRequestId]),
              returnValue: Future<List<_i2.UploadRequestEntry>>.value(
                  <_i2.UploadRequestEntry>[]))
          as _i3.Future<List<_i2.UploadRequestEntry>>);
  @override
  _i3.Future<List<_i2.DownloadTaskId>> downloadUploadRequestEntries(
          List<_i2.UploadRequestEntry>? uploadRequestEntry,
          _i2.Token? token,
          Uri? baseUrl,
          _i2.APIVersionSupported? apiVersion) =>
      (super.noSuchMethod(
          Invocation.method(#downloadUploadRequestEntries,
              [uploadRequestEntry, token, baseUrl, apiVersion]),
          returnValue: Future<List<_i2.DownloadTaskId>>.value(
              <_i2.DownloadTaskId>[])) as _i3.Future<List<_i2.DownloadTaskId>>);
  @override
  _i3.Future<String> downloadUploadRequestEntryIOS(
          _i2.UploadRequestEntry? uploadRequestEntry,
          _i2.Token? token,
          Uri? baseUrl,
          _i4.CancelToken? cancelToken) =>
      (super.noSuchMethod(
          Invocation.method(#downloadUploadRequestEntryIOS,
              [uploadRequestEntry, token, baseUrl, cancelToken]),
          returnValue: Future<String>.value('')) as _i3.Future<String>);
  @override
  _i3.Future<_i2.UploadRequestEntry> removeUploadRequestEntry(
          _i2.UploadRequestEntryId? entryId) =>
      (super.noSuchMethod(
              Invocation.method(#removeUploadRequestEntry, [entryId]),
              returnValue: Future<_i2.UploadRequestEntry>.value(
                  _FakeUploadRequestEntry_0()))
          as _i3.Future<_i2.UploadRequestEntry>);
  @override
  _i3.Future<List<_i2.AuditLogEntryUser?>> getUploadRequestEntryActivities(
          _i2.UploadRequestEntryId? entryId) =>
      (super.noSuchMethod(
              Invocation.method(#getUploadRequestEntryActivities, [entryId]),
              returnValue: Future<List<_i2.AuditLogEntryUser?>>.value(
                  <_i2.AuditLogEntryUser?>[]))
          as _i3.Future<List<_i2.AuditLogEntryUser?>>);
}