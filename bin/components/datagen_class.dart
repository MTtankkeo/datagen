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
  });

  final String identifier;
  final Datagen annotation;
  final List<DatagenParameter> parameters;

  @override
  String toString() {
    return "DatagenClass(identifier: $identifier, annotation: $annotation, parameters: $parameters)";
  }
}
