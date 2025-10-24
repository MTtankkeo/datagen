import 'datagen_generator.dart';

import '../datagen_class.dart';
import '../datagen_builder.dart';

class FactoryClassGenerator extends DatagenGenerator {
  @override
  String perform(DatagenClass c) {
    final generators = <DatagenGenerator>[_GetterGenerator()];
    final constructor =
        c.parameters.map((p) => "\t\t${p.expression},\n").join("");
    final initializer =
        c.parameters.map((p) => "_${p.name} = ${p.name}").join(", ");

    final fields = c.parameters
        .map((p) => "\tfinal ${p.setterType} _${p.name};")
        .join("\n");

    if (c.annotation.copyWith) generators.add(_CopyWithGenerator());
    if (c.annotation.toJson) generators.add(_ToJsonGenerator());
    if (c.annotation.equality) generators.add(_EqualityGenerator());
    if (c.annotation.stringify) generators.add(_StringifyGenerator());

    return DatagenBuilder.commandWith(
      command:
          "/// A class that provides an auto-completion implementation for [${c.identifier}].",
      content: [
        "class \$${c.identifier} implements ${c.identifier} {",
        "\tconst \$${c.identifier}({\n$constructor\t}) : $initializer;",
        "",
        fields,
        "",
        generators.map((g) => g.perform(c)).join("\n\n"),
        "}\n",
      ].nonNulls.join("\n"),
    );
  }
}

/// A class that generates getters.
class _GetterGenerator extends DatagenGenerator {
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
            "\t/// Returns the value of [${c.identifier}.${p.name}] as [${p.getterType}].",
        content: //
            "\t@override\n"
            "\t${p.getterType} get ${p.name} => $expr;",
      );
    });

    return parameters.join("\n\n");
  }
}

/// A class that generates a `copyWith`.
class _CopyWithGenerator extends DatagenGenerator {
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
          "\t@override",
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

/// A class that generates a `toJson`.
class _ToJsonGenerator extends DatagenJsonGenerator {
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
          "\t/// Converts this [${c.identifier}] instance into a JSON-compatible map.\n"
          "\t/// Includes all fields of [${c.identifier}] for serialization purposes.",
      content: [
        "\t@override",
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
class _StringifyGenerator extends DatagenGenerator {
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
class _EqualityGenerator extends DatagenGenerator {
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
      return "other._${p.name} == _${p.name}";
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
      "\t\treturn other is \$${c.identifier} && $equalityCheckExpr;",
      "\t}",
    ].join("\n");
  }
}
