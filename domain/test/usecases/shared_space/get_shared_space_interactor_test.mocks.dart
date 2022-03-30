// Mocks generated by Mockito 5.0.17 from annotations
// in domain/test/usecases/shared_space/get_shared_space_interactor_test.dart.
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

class _FakeSharedSpaceNodeNested_0 extends _i1.Fake
    implements _i2.SharedSpaceNodeNested {}

/// A class which mocks [SharedSpaceRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockSharedSpaceRepository extends _i1.Mock
    implements _i2.SharedSpaceRepository {
  MockSharedSpaceRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<List<_i2.SharedSpaceNodeNested>> getSharedSpaces() =>
      (super.noSuchMethod(Invocation.method(#getSharedSpaces, []),
              returnValue: Future<List<_i2.SharedSpaceNodeNested>>.value(
                  <_i2.SharedSpaceNodeNested>[]))
          as _i3.Future<List<_i2.SharedSpaceNodeNested>>);
  @override
  _i3.Future<_i2.SharedSpaceNodeNested> deleteSharedSpace(
          _i2.SharedSpaceId? sharedSpaceId) =>
      (super.noSuchMethod(
              Invocation.method(#deleteSharedSpace, [sharedSpaceId]),
              returnValue: Future<_i2.SharedSpaceNodeNested>.value(
                  _FakeSharedSpaceNodeNested_0()))
          as _i3.Future<_i2.SharedSpaceNodeNested>);
  @override
  _i3.Future<_i2.SharedSpaceNodeNested> getSharedSpace(
          _i2.SharedSpaceId? shareSpaceId,
          {_i2.MembersParameter? membersParameter =
              _i2.MembersParameter.withMembers,
          _i2.RolesParameter? rolesParameter = _i2.RolesParameter.withRole}) =>
      (super.noSuchMethod(
              Invocation.method(#getSharedSpace, [
                shareSpaceId
              ], {
                #membersParameter: membersParameter,
                #rolesParameter: rolesParameter
              }),
              returnValue: Future<_i2.SharedSpaceNodeNested>.value(
                  _FakeSharedSpaceNodeNested_0()))
          as _i3.Future<_i2.SharedSpaceNodeNested>);
  @override
  _i3.Future<_i2.SharedSpaceNodeNested> createSharedSpaceWorkGroup(
          _i2.CreateWorkGroupRequest? createWorkGroupRequest) =>
      (super.noSuchMethod(
              Invocation.method(
                  #createSharedSpaceWorkGroup, [createWorkGroupRequest]),
              returnValue: Future<_i2.SharedSpaceNodeNested>.value(
                  _FakeSharedSpaceNodeNested_0()))
          as _i3.Future<_i2.SharedSpaceNodeNested>);
  @override
  _i3.Future<List<_i2.SharedSpaceRole>> getSharedSpacesRoles(
          {_i2.LinShareNodeType? type}) =>
      (super.noSuchMethod(
              Invocation.method(#getSharedSpacesRoles, [], {#type: type}),
              returnValue: Future<List<_i2.SharedSpaceRole>>.value(
                  <_i2.SharedSpaceRole>[]))
          as _i3.Future<List<_i2.SharedSpaceRole>>);
  @override
  _i3.Future<_i2.SharedSpaceNodeNested> renameWorkGroup(
          _i2.SharedSpaceId? sharedSpaceId,
          _i2.RenameWorkGroupRequest? renameRequest) =>
      (super.noSuchMethod(
          Invocation.method(#renameWorkGroup, [sharedSpaceId, renameRequest]),
          returnValue: Future<_i2.SharedSpaceNodeNested>.value(
              _FakeSharedSpaceNodeNested_0())) as _i3
          .Future<_i2.SharedSpaceNodeNested>);
  @override
  _i3.Future<_i2.SharedSpaceNodeNested> renameDrive(
          _i2.SharedSpaceId? sharedSpaceId,
          _i2.RenameDriveRequest? renameRequest) =>
      (super.noSuchMethod(
              Invocation.method(#renameDrive, [sharedSpaceId, renameRequest]),
              returnValue: Future<_i2.SharedSpaceNodeNested>.value(
                  _FakeSharedSpaceNodeNested_0()))
          as _i3.Future<_i2.SharedSpaceNodeNested>);
  @override
  _i3.Future<_i2.SharedSpaceNodeNested> renameWorkSpace(
          _i2.SharedSpaceId? sharedSpaceId,
          _i2.RenameWorkSpaceRequest? renameRequest) =>
      (super.noSuchMethod(
          Invocation.method(#renameWorkSpace, [sharedSpaceId, renameRequest]),
          returnValue: Future<_i2.SharedSpaceNodeNested>.value(
              _FakeSharedSpaceNodeNested_0())) as _i3
          .Future<_i2.SharedSpaceNodeNested>);
  @override
  _i3.Future<_i2.SharedSpaceNodeNested> createNewDrive(
          _i2.CreateDriveRequest? createDriveRequest) =>
      (super.noSuchMethod(
              Invocation.method(#createNewDrive, [createDriveRequest]),
              returnValue: Future<_i2.SharedSpaceNodeNested>.value(
                  _FakeSharedSpaceNodeNested_0()))
          as _i3.Future<_i2.SharedSpaceNodeNested>);
  @override
  _i3.Future<_i2.SharedSpaceNodeNested> createNewWorkSpace(
          _i2.CreateWorkSpaceRequest? createWorkSpaceRequest) =>
      (super.noSuchMethod(
              Invocation.method(#createNewWorkSpace, [createWorkSpaceRequest]),
              returnValue: Future<_i2.SharedSpaceNodeNested>.value(
                  _FakeSharedSpaceNodeNested_0()))
          as _i3.Future<_i2.SharedSpaceNodeNested>);
  @override
  _i3.Future<List<_i2.SharedSpaceNodeNested>> getAllSharedSpacesOffline() =>
      (super.noSuchMethod(Invocation.method(#getAllSharedSpacesOffline, []),
              returnValue: Future<List<_i2.SharedSpaceNodeNested>>.value(
                  <_i2.SharedSpaceNodeNested>[]))
          as _i3.Future<List<_i2.SharedSpaceNodeNested>>);
  @override
  _i3.Future<_i2.SharedSpaceNodeNested> enableVersioningWorkGroup(
          _i2.SharedSpaceId? sharedSpaceId,
          _i2.SharedSpaceRole? sharedSpaceRole,
          _i2.EnableVersioningWorkGroupRequest?
              enableVersioningWorkGroupRequest) =>
      (super.noSuchMethod(
              Invocation.method(#enableVersioningWorkGroup, [
                sharedSpaceId,
                sharedSpaceRole,
                enableVersioningWorkGroupRequest
              ]),
              returnValue: Future<_i2.SharedSpaceNodeNested>.value(
                  _FakeSharedSpaceNodeNested_0()))
          as _i3.Future<_i2.SharedSpaceNodeNested>);
}