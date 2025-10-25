import 'datagen_generator.dart';

import '../datagen_class.dart';
import '../datagen_builder.dart';

class AugmentClassGenerator extends DatagenGenerator {
  @override
  String perform(DatagenClass c) {
    final generators = <DatagenGenerator>[_GetterGenerator()];

    if (c.annotation.copyWith) generators.add(_CopyWithGenerator());
    if (c.annotation.toJson) generators.add(_ToJsonGenerator());

    return [
      "abstract class _${c.identifier} {",
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
      /// A get a => throw UnimplementedError();
      /// B get b => throw UnimplementedError();
      /// C get c => throw UnimplementedError();
      return DatagenBuilder.commandWith(
        command:
            "\t/// Returns the value of [${c.identifier}.${p.name}] as [${p.getterType}].",
        content:
            "\t${p.getterType} get ${p.name} => throw UnimplementedError();",
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
          "\t}) => throw UnimplementedError();",
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
        "\tMap<String, dynamic> toJson() => throw UnimplementedError();",
      ].join("\n"),
    );
  }
}
