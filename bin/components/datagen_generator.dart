import 'datagen_class.dart';
import 'datagen_parameter.dart';
import 'datagen_type_resolver.dart';
import 'datagen_builder.dart';

/// A class representing the base generator that produces
/// Dart code from a [DatagenClass] instance.
abstract class DatagenGenerator {
  /// Generates Dart code for the given [instance].
  String perform(DatagenClass instance);
}

/// A generator that handles JSON serialization code generation for Datagen models.
abstract class DatagenJsonGenerator extends DatagenGenerator {
  /// List of available resolvers that determine how each type is converted.
  static final resolvers = <DatagenTypeResolver>[
    PrimitiveTypeResolver(),
    DateTimeTypeResolver(),
    ObjectTypeResolver(),
  ];

  /// Finds the first resolver that can handle the given parameter.
  /// Used to generate the appropriate fromJson/toJson code snippet.
  DatagenTypeResolver findResolver(DatagenParameter param) {
    return resolvers.firstWhere((e) => e.canResolve(param));
  }
}

/// A class that generates a `copyWith`.
class CopyWithGenerator extends DatagenGenerator {
  @override
  String perform(DatagenClass c) {
    final arguments = c.parameters.map((p) {
      // String? a,
      // String? b,
      // String? c,
      return "\t\t${p.typeName}? ${p.name},";
    });

    final parameters = c.parameters.map((p) {
      // a: a ?? this._a,
      // b: b ?? this._b,
      // c: c ?? this._c,
      return "\t\t\t${p.name}: ${p.name} ?? _${p.name},";
    });

    return DatagenBuilder.commandWith(
        command:
            "\t/// Returns a new instance of [${c.identifier}] with the given fields replaced.\n"
            "\t/// If a field is not provided, the original value is preserved.\n"
            "\t/// Useful for creating modified copies of immutable objects.",
        content: [
          "\t${c.identifier} copyWith({",
          arguments.join("\n"),
          "\t}) {",
          "\t\treturn ${c.identifier}(",
          parameters.join("\n"),
          "\t\t);",
          "\t}",
        ].join("\n"));
  }
}

/// A class that generates a `fromJson`.
class FromJsonGenerator extends DatagenJsonGenerator {
  @override
  String perform(DatagenClass c) {
    final parameters = c.parameters.map((param) {
      // Expression for transformer: 'e' if list, else param name.
      final expr = param.isList ? "e" : "json['${param.name}']";

      // Generate JSON conversion expression for this parameter.
      final resolved = findResolver(param).fromJson(param, expr);

      // Apply mapping if list, otherwise use resolved value.
      final value = param.isList
          ? "json['${param.name}']?.map<${param.jsonType}>((e) => $resolved).toList()"
          : param.isNullable
              ? "$expr == null ? null : $resolved"
              : resolved;

      // Return the Dart code string representing this field's assignment.
      return "\t\t\t${param.name}: $value,";
    });

    return DatagenBuilder.commandWith(
        command:
            "\t/// Creates an instance of [${c.identifier}] from a JSON map.",
        content: [
          "\tstatic ${c.identifier} fromJson(Map<String, dynamic> json) {",
          "\t\treturn ${c.identifier}(",
          parameters.join("\n"),
          "\t\t);",
          "\t}",
        ].join("\n"));
  }
}

/// A class that generates a `fromJsonList`.
class FromJsonListGenerator extends DatagenGenerator {
  @override
  String perform(DatagenClass c) {
    return DatagenBuilder.commandWith(
      command:
          "\t/// Creates a list of [${c.identifier}] instances from a JSON list.",
      content: [
        "\tstatic List<${c.identifier}> fromJsonList(List list) {",
        "\t\treturn list.cast<Map<String, dynamic>>().map((json) => fromJson(json)).toList();",
        "\t}",
      ].join("\n"),
    );
  }
}

/// A class that generates a `toJson`.
class ToJsonGenerator extends DatagenJsonGenerator {
  @override
  String perform(DatagenClass c) {
    final parameters = c.parameters.map((param) {
      // Expression for transformer: 'e' if list, else param name.
      final expr = param.isList ? "e" : param.name;

      // Generate JSON conversion expression for this parameter.
      final resolved = findResolver(param).toJson(param, expr);

      // Apply mapping if list, otherwise use resolved value.
      final value = param.isList
          ? "${param.name}${param.isNullable ? "?" : ""}.map((e) => $resolved).toList()"
          : resolved;

      // Return JSON key-value pair string.
      return "\t\t\t'${param.name}': _$value,";
    });

    return DatagenBuilder.commandWith(
      command: //
          "\t/// Converts this [B] instance into a JSON-compatible map.\n"
          "\t/// Includes all fields of [B] for serialization purposes.",
      content: [
        "\tMap<String, dynamic> toJson() {",
        "\t\treturn {",
        parameters.join("\n"),
        "\t\t};",
        "\t}",
      ].join("\n"),
    );
  }
}

/// A class that generates a override `toString`.
class StringifyGenerator extends DatagenGenerator {
  @override
  String perform(DatagenClass c) {
    final parameters = c.parameters.map((p) {
      /// a: $a
      /// b: $b
      /// c: $c
      return "${p.name}: \$_${p.name}";
    });

    return [
      "\t@override",
      "\tString toString() {",
      "\t\treturn '${c.identifier}(${parameters.join(", ")})';",
      "\t}",
    ].join("\n");
  }
}

/// A class that generates a override `hashCode` and `operator ==`.
class EqualityGenerator extends DatagenGenerator {
  @override
  String perform(DatagenClass c) {
    final hashCodeFields = c.parameters.map((p) {
      /// a.hashCode
      /// b.hashCode
      /// c.hashCode
      return "_${p.name}.hashCode";
    });

    // Combine all hashCodes into a single expression.
    final hashCodeExpr = hashCodeFields.length == 1
        ? hashCodeFields.first
        : "Object.hash(${hashCodeFields.join(", ")})";

    // Generate equality checks for each field.
    final equalityChecks = c.parameters.map((p) {
      return "other.${p.name} == ${p.name}";
    });

    final equalityCheckExpr = equalityChecks.join(" && ");

    return [
      "\t@override",
      "\tint get hashCode => $hashCodeExpr;",
      "",
      "\t@override",
      "\tbool operator ==(Object other) {",
      "\t\tif (identical(this, other)) return true;",
      "",
      "\t\treturn other is ${c.identifier} && $equalityCheckExpr;",
      "\t}",
    ].join("\n");
  }
}

/// A class that generates a override `toString`.
class GetterGenerator extends DatagenGenerator {
  /// Type conversion map: (fromType, toType) -> conversion function
  static final Map<String, Map<String, String Function(String)>>
      typeConverters = {
    "String": {
      "int": (e) => "int.parse($e)",
      "double": (e) => "double.parse($e)",
      "num": (e) => "num.parse($e)",
      "bool": (e) => "($e.toLowerCase() == 'true')",
    },
    "int": {
      "String": (e) => "$e.toString()",
      "double": (e) => "$e.toDouble()",
      "num": (e) => e,
    },
    "double": {
      "String": (e) => "$e.toString()",
      "int": (e) => "$e.toInt()",
      "num": (e) => e,
    },
    "bool": {
      "String": (e) => "$e.toString()",
    }
  };

  @override
  String perform(DatagenClass c) {
    final parameters = c.parameters.map((p) {
      String expr = "_${p.name}";

      if (p.setterType != p.getterType) {
        final convertFunc = typeConverters[p.setterType]?[p.getterType];
        if (convertFunc == null) {
          return Exception(
              "Automatic conversion from '${p.setterType}' to '${p.getterType}' is not supported. "
              "Supported conversions: ${typeConverters[p.setterType]?.keys.join(', ') ?? 'none'}");
        }

        expr = convertFunc(expr);
      }

      /// A get a => _a;
      /// B get b => _b;
      /// C get c => _c;
      return DatagenBuilder.commandWith(
        command:
            "\t/// Returns the value of [${c.identifier}.${p.name}] as [${p.getterType}]",
        content: "\t${p.getterType} get ${p.name} => $expr;",
      );
    });

    return parameters.join("\n\n");
  }
}
