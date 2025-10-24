import 'datagen_generator.dart';

import '../datagen_class.dart';
import '../datagen_builder.dart';

class AugmentClassGenerator extends DatagenGenerator {
  @override
  String perform(DatagenClass c) {
    final generators = <DatagenGenerator>[_GetterGenerator()];

    if (c.annotation.copyWith) generators.add(_CopyWithGenerator());
    if (c.annotation.toJson) generators.add(_ToJsonGenerator());
    if (c.annotation.fromJson) generators.add(_FromJsonGenerator());
    if (c.annotation.fromJsonList) generators.add(_FromJsonListGenerator());

    return [
      "augment class ${c.identifier} {",
      generators.map((g) => g.perform(c)).join("\n\n"),
      "}\n",
    ].nonNulls.join("\n");
  }
}

/// A class that generates getters.
class _GetterGenerator extends DatagenGenerator {
  @override
  String perform(DatagenClass c) {
    final parameters = c.parameters.map((p) {
      /// A get a;
      /// B get b;
      /// C get c;
      return DatagenBuilder.commandWith(
        command:
            "\t/// Returns the value of [${c.identifier}.${p.name}] as [${p.getterType}].",
        content: "\t${p.getterType} get ${p.name};",
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

    return DatagenBuilder.commandWith(
        command:
            "\t/// Returns a new instance of [${c.identifier}] with the given fields replaced.\n"
            "\t/// If a field is not provided, the original value is preserved.\n"
            "\t/// Useful for creating modified copies of immutable objects.",
        content: [
          "\t${c.identifier} copyWith({",
          arguments.join("\n"),
          "\t});",
        ].join("\n"));
  }
}

/// A class that generates a `toJson`.
class _ToJsonGenerator extends DatagenJsonGenerator {
  @override
  String perform(DatagenClass c) {
    return DatagenBuilder.commandWith(
      command: //
          "\t/// Converts this [B] instance into a JSON-compatible map.\n"
          "\t/// Includes all fields of [B] for serialization purposes.",
      content: [
        "\tMap<String, dynamic> toJson();",
      ].join("\n"),
    );
  }
}

/// A class that generates a `fromJson`.
class _FromJsonGenerator extends DatagenJsonGenerator {
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
class _FromJsonListGenerator extends DatagenGenerator {
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
