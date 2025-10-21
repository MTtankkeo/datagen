import 'package:analyzer/dart/ast/ast.dart';
import 'package:datagen/annotation.dart';

import 'datagen_parameter.dart';
import 'datagen_config.dart';

/// Utility class for parsing Dart source files and extracting metadata,
/// parameters, and annotations for code generation purposes.
class SourceFileParser {
  const SourceFileParser._();

  /// Returns the [Datagen] annotation for a class, or null if none exists.
  static Datagen? getAnnotationByClass(ClassDeclaration declaration) {
    dynamic getOptionValue(Expression arg, String name) {
      if (arg is NamedExpression && arg.name.label.name == name) {
        final value = arg.expression;

        if (value is BooleanLiteral) return value.value;
        if (value is IntegerLiteral) return value.value;
        if (value is DoubleLiteral) return value.value;
        if (value is StringLiteral) return value.stringValue;
      }

      return null;
    }

    for (var meta in declaration.metadata) {
      final options = DatagenConfig.instance.options;

      if (meta.name.name == "datagen") return options;
      if (meta.name.name.contains("Datagen")) {
        bool? copyWithEnabled;
        bool? fromJsonEnabled;
        bool? fromJsonListEnabled;
        bool? toJsonEnabled;
        bool? stringifyEnabled;
        bool? omitFactoryEnabled;

        final arguments = meta.arguments?.arguments;

        // When arguments exist, extract their values.
        if (arguments != null) {
          for (var arg in arguments) {
            final name = (arg is NamedExpression) ? arg.name.label.name : null;
            if (name == null) continue;

            switch (name) {
              case "copyWith":
                copyWithEnabled = getOptionValue(arg, name);
                break;
              case "fromJson":
                fromJsonEnabled = getOptionValue(arg, name);
                break;
              case "fromJsonList":
                fromJsonListEnabled = getOptionValue(arg, name);
                break;
              case "toJson":
                toJsonEnabled = getOptionValue(arg, name);
                break;
              case "stringify":
                stringifyEnabled = getOptionValue(arg, name);
                break;
              case "omitFactory":
                omitFactoryEnabled = getOptionValue(arg, name);
                break;
            }
          }
        }

        return Datagen(
          copyWith: copyWithEnabled ?? options.copyWith,
          fromJson: fromJsonEnabled ?? options.fromJson,
          fromJsonList: fromJsonListEnabled ?? options.fromJsonList,
          toJson: toJsonEnabled ?? options.toJson,
          stringify: stringifyEnabled ?? options.stringify,
          omitFactory: omitFactoryEnabled ?? options.omitFactory,
        );
      }
    }

    return null;
  }

  /// Extracts constructor parameters from [declaration] and converts them
  /// into a list of [DatagenParameter] objects, including name, type,
  /// whether it's required, and any default value.
  static List<DatagenParameter> getParametersConstructor(
    ConstructorDeclaration declaration,
  ) {
    final parameters = declaration.parameters.parameters.map((param) {
      String? name;
      String? type;
      bool isRequired = false;
      dynamic defaultValue;

      if (param is SimpleFormalParameter) {
        name = param.name?.lexeme;
        type = param.type?.toSource();
        isRequired = param.requiredKeyword != null;
      } else if (param is DefaultFormalParameter) {
        final inner = param.parameter;

        if (inner is SimpleFormalParameter) {
          name = inner.name?.lexeme;
          type = inner.type?.toSource();
          isRequired = inner.requiredKeyword != null;
          defaultValue = param.defaultValue?.toSource();
        }
      }

      return DatagenParameter(
        name: name!,
        type: type!,
        isRequired: isRequired,
        defaultValue: defaultValue,
      );
    }).toList();

    return parameters;
  }
}
