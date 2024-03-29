// Mocks generated by Mockito 5.0.17 from annotations
// in domain/test/usecases/shared_space/get_all_shared_space_members_interactor_test.dart.
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

class _FakeSharedSpaceMember_0 extends _i1.Fake
    implements _i2.SharedSpaceMember {}

/// A class which mocks [SharedSpaceMemberRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockSharedSpaceMemberRepository extends _i1.Mock
    implements _i2.SharedSpaceMemberRepository {
  MockSharedSpaceMemberRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<List<_i2.SharedSpaceMember>> getMembers(
          _i2.SharedSpaceId? sharedSpaceId) =>
      (super.noSuchMethod(Invocation.method(#getMembers, [sharedSpaceId]),
              returnValue: Future<List<_i2.SharedSpaceMember>>.value(
                  <_i2.SharedSpaceMember>[]))
          as _i3.Future<List<_i2.SharedSpaceMember>>);
  @override
  _i3.Future<_i2.SharedSpaceMember> addMember(_i2.SharedSpaceId? sharedSpaceId,
          _i2.AddSharedSpaceMemberRequest? request) =>
      (super.noSuchMethod(
              Invocation.method(#addMember, [sharedSpaceId, request]),
              returnValue: Future<_i2.SharedSpaceMember>.value(
                  _FakeSharedSpaceMember_0()))
          as _i3.Future<_i2.SharedSpaceMember>);
  @override
  _i3.Future<_i2.SharedSpaceMember> updateMemberRole(
          _i2.SharedSpaceId? sharedSpaceId,
          _i2.UpdateSharedSpaceMemberRequest? request) =>
      (super.noSuchMethod(
              Invocation.method(#updateMemberRole, [sharedSpaceId, request]),
              returnValue: Future<_i2.SharedSpaceMember>.value(
                  _FakeSharedSpaceMember_0()))
          as _i3.Future<_i2.SharedSpaceMember>);
  @override
  _i3.Future<_i2.SharedSpaceMember> updateDriveMemberRole(
          _i2.SharedSpaceId? sharedSpaceId,
          _i2.UpdateDriveMemberRequest? request,
          {bool? isOverrideRoleForAll}) =>
      (super.noSuchMethod(
              Invocation.method(#updateDriveMemberRole, [
                sharedSpaceId,
                request
              ], {
                #isOverrideRoleForAll: isOverrideRoleForAll
              }),
              returnValue: Future<_i2.SharedSpaceMember>.value(
                  _FakeSharedSpaceMember_0()))
          as _i3.Future<_i2.SharedSpaceMember>);
  @override
  _i3.Future<_i2.SharedSpaceMember> updateWorkspaceMemberRole(
          _i2.SharedSpaceId? sharedSpaceId,
          _i2.UpdateWorkspaceMemberRequest? request,
          {bool? isOverrideRoleForAll}) =>
      (super.noSuchMethod(
              Invocation.method(
                  #updateWorkspaceMemberRole,
                  [sharedSpaceId, request],
                  {#isOverrideRoleForAll: isOverrideRoleForAll}),
              returnValue: Future<_i2.SharedSpaceMember>.value(
                  _FakeSharedSpaceMember_0()))
          as _i3.Future<_i2.SharedSpaceMember>);
  @override
  _i3.Future<_i2.SharedSpaceMember> deleteMember(
          _i2.SharedSpaceId? sharedSpaceId,
          _i2.SharedSpaceMemberId? sharedSpaceMemberId) =>
      (super.noSuchMethod(
              Invocation.method(
                  #deleteMember, [sharedSpaceId, sharedSpaceMemberId]),
              returnValue: Future<_i2.SharedSpaceMember>.value(
                  _FakeSharedSpaceMember_0()))
          as _i3.Future<_i2.SharedSpaceMember>);
}
