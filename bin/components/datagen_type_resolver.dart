import 'datagen_parameter.dart';

/// Defines how a specific Dart type should be resolved
/// to generate code for conversion within the Datagen generator.
abstract class DatagenTypeResolver {
  /// Determines whether this resolver can handle the given parameter type.
  bool canResolve(DatagenParameter param);

  /// Generates a code snippet that converts a JSON value into a Dart object.
  String fromJson(DatagenParameter param, String expr);

  /// Generates a code snippet that converts a Dart object into a JSON value.
  String toJson(DatagenParameter param, String expr);
}

/// Resolves primitive types like int, double, bool, String.
class PrimitiveTypeResolver implements DatagenTypeResolver {
  /// List of primitive Dart types that can be directly serialized to JSON.
  static const List<String> jsonPrimitives = [
    "int",
    "double",
    "num",
    "bool",
    "String",
    "dynamic",
  ];

  @override
  bool canResolve(DatagenParameter param) {
    return jsonPrimitives.contains(param.jsonType);
  }

  @override
  String fromJson(DatagenParameter param, String expr) {
    return "($expr as ${param.jsonType})";
  }

  @override
  String toJson(DatagenParameter param, String expr) => expr;
}

/// Resolves [DateTime] type.
class DateTimeTypeResolver implements DatagenTypeResolver {
  @override
  bool canResolve(DatagenParameter param) {
    return param.jsonType == "DateTime";
  }

  @override
  String fromJson(DatagenParameter param, String expr) {
    return param.isNullable
        ? "$expr == null ? null : DateTime.parse($expr!)"
        : "DateTime.parse($expr)";
  }

  @override
  String toJson(DatagenParameter param, String expr) {
    return "$expr${param.isNullable ? "?" : ""}.toIso8601String()";
  }
}

/// Resolves user-defined datagen models.
class ObjectTypeResolver implements DatagenTypeResolver {
  @override
  bool canResolve(DatagenParameter param) => true;

  String removeGeneric(String value) {
    return value.replaceAll(RegExp(r'<.*>'), '');
  }

  @override
  String fromJson(DatagenParameter param, String expr) {
    return "${removeGeneric(param.genType)}.fromJson($expr)";
  }

  @override
  String toJson(DatagenParameter params, String expr) {
    return "$expr.toJson()";
  }
}
