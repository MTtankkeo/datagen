import 'package:analyzer/dart/ast/ast.dart';
import 'package:datagen/annotation.dart';

import 'datagen_parameter.dart';
import 'datagen_config.dart';

/// Utility class for parsing Dart source files and extracting metadata,
/// parameters, and annotations for code generation purposes.
class DatagenSourceParser {
  const DatagenSourceParser._();

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

  /// Extracts the type argument from an annotation on a [FormalParameter].
  static String? getAnnotationType(String identifier, FormalParameter p) {
    for (final meta in p.metadata) {
      // An annotation identifier of the given parameter.
      final metaName = meta.name.name;

      // Check if the annotation is a given identifier.
      if (metaName == identifier) {
        final arguments = meta.arguments?.arguments;
        if (arguments != null && arguments.isNotEmpty) {
          return arguments.first.toSource(); // int, double, etc.
        }
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
      String? setterType;
      String? getterType;
      bool isRequired = false;
      dynamic expression;

      if (param is SimpleFormalParameter) {
        name = param.name?.lexeme;
        setterType = param.type?.toSource();
        isRequired = param.requiredKeyword != null;
        expression = param.toSource();
        getterType = getAnnotationType("Get", param);
      } else if (param is DefaultFormalParameter) {
        final inner = param.parameter;

        if (inner is SimpleFormalParameter) {
          name = inner.name?.lexeme;
          setterType = inner.type?.toSource();
          isRequired = inner.requiredKeyword != null;
          expression = inner.toSource();
          getterType = getAnnotationType("Get", inner);
        }
      }

      return DatagenParameter(
        name: name!,
        setterType: setterType!,
        getterType: getterType ?? setterType,
        isRequired: isRequired,
        expression: expression,
      );
    }).toList();

    return parameters;
  }
}
