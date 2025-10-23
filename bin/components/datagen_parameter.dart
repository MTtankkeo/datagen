/// A data class that represents a constructor parameter info
/// for code generation purposes, including its name, type,
/// whether it is required, and any default value.
class DatagenParameter {
  const DatagenParameter({
    required this.name,
    required this.setterType,
    required this.getterType,
    required this.isRequired,
    required this.defaultValue,
  });

  final String name;
  final String setterType;
  final String getterType;
  final bool isRequired;
  final dynamic defaultValue;

  bool get isNullable => setterType.endsWith("?");

  /// Nullable types (ending with `?`) are normalized before the check.
  String get typeName => setterType.replaceFirst("?", "");

  /// Returns the class name or, for a List, its element type.
  /// This is the type that has a JSON serialization function.
  String get jsonType {
    if (isList) {
      final value = typeName
          .replaceFirst("List", "")
          .replaceFirst("<", "")
          .replaceFirst(">", "")
          .trim();

      return value.isEmpty ? "dynamic" : value;
    }

    return typeName;
  }

  /// Returns the generated class name corresponding to [jsonType].
  /// The $ prefix indicates that this is the auto-generated class.
  String get genType => "\$$jsonType";

  /// Returns true if the type represents a List.
  bool get isList {
    return typeName == "List" || typeName.startsWith("List<");
  }

  @override
  String toString() {
    return "DatagenParameter(name: $name, setterType: $setterType, isRequired: $isRequired, defaultValue: $defaultValue)";
  }
}
