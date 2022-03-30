// Mocks generated by Mockito 5.0.17 from annotations
// in domain/test/usecases/shared_space_activities/shared_space_activities_interactor_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i3;

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

/// A class which mocks [SharedSpaceActivitiesRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockSharedSpaceActivitiesRepository extends _i1.Mock
    implements _i2.SharedSpaceActivitiesRepository {
  MockSharedSpaceActivitiesRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<List<_i2.AuditLogEntryUser?>> getSharedSpaceActivities(
          _i2.SharedSpaceId? sharedSpaceId) =>
      (super.noSuchMethod(
              Invocation.method(#getSharedSpaceActivities, [sharedSpaceId]),
              returnValue: Future<List<_i2.AuditLogEntryUser?>>.value(
                  <_i2.AuditLogEntryUser?>[]))
          as _i3.Future<List<_i2.AuditLogEntryUser?>>);
}
