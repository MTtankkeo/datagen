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

    return [
      "\t${c.identifier} copyWith({",
      arguments.join("\n"),
      "\t}) {",
      "\t\treturn ${c.identifier}(",
      parameters.join("\n"),
      "\t\t);",
      "\t}",
    ].join("\n");
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
          ? "json['${param.name}'].map<${param.jsonType}>((e) => $resolved).toList()"
          : resolved;

      // Return the Dart code string representing this field's assignment.
      return "\t\t\t${param.name}: $value,";
    });

    return [
      "\tstatic ${c.identifier} fromJson(Map<String, dynamic> json) {",
      "\t\treturn ${c.identifier}(",
      parameters.join("\n"),
      "\t\t);",
      "\t}",
    ].join("\n");
  }
}

/// A class that generates a `fromJsonList`.
class FromJsonListGenerator extends DatagenGenerator {
  @override
  String perform(DatagenClass c) {
    return [
      "\tstatic List<${c.identifier}> fromJsonList(List list) {",
      "\t\treturn list.cast<Map<String, dynamic>>().map((json) => fromJson(json)).toList();",
      "\t}",
    ].join("\n");
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
          ? "${param.name}.map((e) => $resolved).toList()"
          : resolved;

      // Return JSON key-value pair string.
      return "\t\t\t'${param.name}': _$value,";
    });

    return [
      "\tMap<String, dynamic> toJson() {",
      "\t\treturn {",
      parameters.join("\n"),
      "\t\t};",
      "\t}",
    ].join("\n");
  }
}

/// A class that generates a override `toString`.
class ToStringGenerator extends DatagenGenerator {
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
      "\t\treturn '${c.identifier}(\"${parameters.join(", ")}\")';",
      "\t}",
    ].join("\n");
  }
}

/// A class that generates a override `toString`.
class GetterGenerator extends DatagenGenerator {
  @override
  String perform(DatagenClass c) {
    final parameters = c.parameters.map((p) {
      /// A get a => _a;
      /// B get b => _b;
      /// C get c => _c;
      return DatagenBuilder.commandWith(
        command: "\t/// Returns the value of [${c.identifier}.${p.name}]",
        content: "\t${p.type} get ${p.name} => _${p.name};",
      );
    });

    return parameters.join("\n\n");
  }
}
