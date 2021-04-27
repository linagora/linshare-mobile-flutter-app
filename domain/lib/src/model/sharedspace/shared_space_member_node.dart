import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';

class SharedSpaceMemberNode extends Equatable {
  final String name;
  final SharedSpaceId sharedSpaceId;
  final LinShareNodeType? nodeType;
  final DateTime creationDate;
  final DateTime modificationDate;

  SharedSpaceMemberNode(
    this.sharedSpaceId,
    this.name,
    this.nodeType,
    this.creationDate,
    this.modificationDate
  );

  @override
  List<Object?> get props => [
    sharedSpaceId,
    name,
    nodeType,
    creationDate,
    modificationDate
  ];
}
