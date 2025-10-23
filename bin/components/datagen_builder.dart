import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as path;

import 'source_file_parser.dart';
import 'source_file_edit.dart';
import 'source_file.dart';
import 'datagen_class.dart';
import 'datagen_generator.dart';
import 'datagen_config.dart';

import '../datagen.dart';

class DatagenBuilder {
  const DatagenBuilder._();

  /// List of characters considered as whitespace for trimming purposes.
  /// Includes space, tab, newline, and carriage return.
  static const _whitespaceChars = [' ', '\t', '\n', '\r'];

  /// Returns the start offset by removing all preceding spaces,
  /// tabs, and newlines before the given [index] in [text].
  static int getStartByRemovingLeadingWhitespace(String text, int index) {
    int start = index - 1;

    while (start >= 0 && _whitespaceChars.contains(text[start])) {
      start--;
    }

    return start + 1;
  }

  // Generates a command string if enabled, otherwise returns content only.
  static String commandWith({
    required String command,
    required String content,
    String prefix = "",
    String suffix = "",
  }) {
    final bool isEnabled = DatagenConfig.instance.useCommand;
    return prefix + (isEnabled ? "$command\n$content" : content) + suffix;
  }

  /// Builds datagen files for all Dart sources within the given [dir].
  ///
  /// Recursively scans the directory, parses Dart files, applies edits,
  /// and generates corresponding `.datagen.dart` files.
  static void build(SourceFile source) {
    final stopwatch = Stopwatch()..start();
    final result = parseString(content: source.text);
    final unit = result.unit;
    final edits = <SourceFileEdit>[];
    final classes = <DatagenClass>[];

    /// Applies all collected edits to the source text and writes it back to the file.
    void applyEdits() {
      edits.sort((a, b) => b.start.compareTo(a.start));

      for (final edit in edits) {
        source.text = source.text.replaceRange(
          edit.start,
          edit.end,
          edit.content,
        );
      }

      // Write the updated text back to the file.
      File(source.path).writeAsStringSync(source.text);
    }

    void replaceCode(int start, int end, String content) {
      edits.add(SourceFileEdit(start, end, content));
    }

    void insertCode(int index, String content) {
      replaceCode(index, index, content);
    }

    for (var declaration in unit.declarations) {
      if (declaration is ClassDeclaration) {
        final annotation = SourceFileParser.getAnnotationByClass(declaration);
        if (annotation == null) return;

        final rawClassName = declaration.name.lexeme;
        final genClassName = "\$$rawClassName";
        DatagenClass? datagen;

        if (declaration.extendsClause == null) {
          final classEnd = declaration.name.end;

          insertCode(classEnd, " extends \$$rawClassName");
        }

        ConstructorDeclaration? fromJsonConstructor;
        MethodDeclaration? fromJsonListMethod;

        for (var member in declaration.members) {
          if (member is ConstructorDeclaration) {
            final constructorName = member.name?.lexeme;
            bool shouldReplace = true;

            // Regular constructor (not a factory and unnamed)
            if (member.factoryKeyword == null && constructorName == null) {
              // Get constructor parameters.
              final params = SourceFileParser.getParametersConstructor(member);
              final newArguments = params.map((e) => e.name);
              final constructorEnd = member.parameters.end;

              // Get the first initializer, e.g., `super(a, b, c)`.
              final initializer = member.initializers.firstOrNull;

              // Checks whether the existing `super` constructor invocation needs
              // to be replaced by comparing its arguments with the new arguments.
              if (initializer is SuperConstructorInvocation) {
                final oldArguments = initializer.argumentList.arguments;
                final newNames = newArguments.toList();
                final oldNames = oldArguments.map((e) => e.toSource()).toList();

                // If the lengths are different, mark as true immediately.
                shouldReplace = newNames.length != oldNames.length;

                // If the lengths are the same, compare each argument in order.
                if (!shouldReplace) {
                  for (int i = 0; i < newNames.length; i++) {
                    if (newNames[i] != oldNames[i]) {
                      shouldReplace = true;
                      break;
                    }
                  }
                }
              }

              if (shouldReplace) {
                // Remove the existing initializer if present.
                if (initializer != null) {
                  final token = initializer.beginToken;
                  final start = token.previous!.previous!.offset + 1;
                  final end = initializer.end;

                  replaceCode(start, end, "");
                }

                // Insert super constructor call with parameters.
                insertCode(
                  constructorEnd,
                  " : super(${newArguments.join(", ")})",
                );
              }

              // Add to DatagenClass list.
              classes.add(
                datagen = DatagenClass(
                  identifier: declaration.name.lexeme,
                  annotation: annotation,
                  parameters: params,
                ),
              );
            } else {
              // A factory constructor for `fromJson`.
              if (constructorName == "fromJson") {
                fromJsonConstructor = member;
              }
            }
          }

          if (member is MethodDeclaration) {
            final methodName = member.name.lexeme;

            // A static method for `fromJsonList`.
            if (methodName == "fromJsonList") {
              fromJsonListMethod = member;
            }
          }
        }

        // Create or remove a static method for static `fromJsonList`.
        if (datagen?.annotation.fromJsonList == true &&
            datagen?.annotation.omitFactory == false) {
          if (fromJsonListMethod == null) {
            final index = declaration.endToken.offset;

            insertCode(
              index,
              commandWith(
                prefix: "\n",
                suffix: "\n",
                command:
                    "\t/// Creates a list of [$rawClassName] instances from a JSON list.",
                content:
                    "\tstatic List<$rawClassName> fromJsonList(List list) => $genClassName.fromJsonList(list);",
              ),
            );
          }
        } else {
          if (fromJsonListMethod != null) {
            final offset = fromJsonListMethod.beginToken.offset;
            final start = getStartByRemovingLeadingWhitespace(
              source.text,
              offset,
            );
            final end = fromJsonListMethod.end;

            replaceCode(start, end, "");
          }
        }

        // Create or remove a factory constructor for static `fromJson`.
        if (datagen?.annotation.fromJson == true &&
            datagen?.annotation.omitFactory == false) {
          if (fromJsonConstructor == null) {
            final index = declaration.endToken.offset;

            insertCode(
              index,
              commandWith(
                prefix: "\n",
                suffix: "\n",
                command:
                    "\t/// Creates an instance of [$rawClassName] from a JSON map.",
                content:
                    "\tfactory $rawClassName.fromJson(Map<String, dynamic> json) => $genClassName.fromJson(json);",
              ),
            );
          }
        } else {
          if (fromJsonConstructor != null) {
            final offset = fromJsonConstructor.beginToken.offset;
            final start = getStartByRemovingLeadingWhitespace(
              source.text,
              offset,
            );
            final end = fromJsonConstructor.end;

            replaceCode(start, end, "");
          }
        }
      }
    }

    if (classes.isEmpty) return;

    final fileName = path.basename(source.path);
    final genName = fileName.replaceFirst(".dart", ".datagen.dart");
    final genPath = path.join(path.dirname(source.path), genName);
    final imports = unit.directives.whereType<ImportDirective>();
    final exports = unit.directives.whereType<ExportDirective>();

    // Check if the generated datagen file is already imported,
    // and insert it at the top of the file if not.
    {
      bool isExists = false;

      // If the generated datagen file is already imported, mark it.
      for (final directive in imports) {
        if (directive.uri.stringValue == genName) {
          isExists = true;
          break;
        }
      }

      if (!isExists) {
        insertCode(0, "import '$genName';\n\n");
      }
    }

    // Check if the generated datagen file is already exported,
    // and insert it at the top of the file if not.
    {
      bool isExists = false;

      // If the generated datagen file is already exported, mark it.
      for (final directive in exports) {
        if (directive.uri.stringValue == genName) {
          isExists = true;
          break;
        }
      }

      if (!isExists) {
        insertCode(0, "export '$genName';\n");
      }
    }

    {
      // Create datagen.dart file.
      final start = imports.firstOrNull?.offset ?? 0;
      final end = imports.lastOrNull?.end ?? 0;
      final importText = source.text.substring(start, end);
      final datagenText = classes.map((e) {
        final generators = <DatagenGenerator>[GetterGenerator()];
        final constructor =
            e.parameters.map((p) => "\t\tthis._${p.name}").join(",\n");
        final fields = e.parameters
            .map((p) => "\tfinal ${p.setterType} _${p.name};")
            .join("\n");

        if (e.annotation.copyWith) generators.add(CopyWithGenerator());
        if (e.annotation.fromJson) generators.add(FromJsonGenerator());
        if (e.annotation.fromJsonList) generators.add(FromJsonListGenerator());
        if (e.annotation.toJson) generators.add(ToJsonGenerator());
        if (e.annotation.equality) generators.add(EqualityGenerator());
        if (e.annotation.stringify) generators.add(StringifyGenerator());

        return commandWith(
            command:
                "/// A class that provides an auto-completion implementation for [${e.identifier}].",
            content: [
              "class \$${e.identifier} {",
              "\tconst \$${e.identifier}(\n$constructor\n\t);",
              "",
              fields,
              "",
              generators.map((g) => g.perform(e)).join("\n\n"),
              "}\n",
            ].nonNulls.join("\n"));
      }).join("\n");

      File(genPath).writeAsStringSync(
        "// ignore_for_file: unused_import, unnecessary_question_mark\n\n"
        "import '$fileName';\n"
        "$importText\n\n"
        "$datagenText",
      );
    }

    applyEdits();

    // Stops the stopwatch and calculates the elapsed time.
    stopwatch.stop();

    // Logs the time taken to build the specified path.
    final elapsedTime = "${stopwatch.elapsedMilliseconds} ms";
    log(
      "Building the specified path: ${source.path} ($elapsedTime)",
      color: gray,
    );
  }
}
