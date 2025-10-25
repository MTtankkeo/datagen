import 'package:analyzer/dart/ast/ast.dart';
import 'package:datagen/annotation.dart';

import 'datagen_parameter.dart';

/// A class that represents a class annotated with [Datagen]
/// for code generation, including its identifier,
/// annotation options, and constructor parameters.
class DatagenClass {
  DatagenClass({
    required this.identifier,
    required this.annotation,
    required this.parameters,
    required this.implementMembers,
  });

  final String identifier;
  final Datagen annotation;
  final List<DatagenParameter> parameters;
  final List<ClassMember> implementMembers;

  /// Removes the given [member] from the list of members to be implemented.
  /// This can be used to mark a member as already handled or excluded from
  /// code generation.
  void consumeMember(ClassMember member) {
    assert(implementMembers.contains(member));
    implementMembers.remove(member);
  }

  @override
  String toString() {
    return "DatagenClass(identifier: $identifier, annotation: $annotation, parameters: $parameters, implementMembers: $implementMembers)";
  }
}
