import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as path;
import 'package:prepare/components/prepare_builder.dart';
import 'package:prepare/components/source_file.dart';
import 'package:prepare/components/source_file_edit.dart';

import 'datagen_class.dart';
import 'generator/datagen_generator.dart';
import 'datagen_source_parser.dart';
import 'datagen_config.dart';
import 'generator/factory_class_generator.dart';
import 'generator/abstract_class_generator.dart';

class DatagenBuilder extends PrepareBuilder {
  @override
  String get name => "Datagen";

  @override
  List<String> get extensions => [".dart"];

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
  @override
  Future<bool> build(SourceFile source) async {
    if (source.path.endsWith(".datagen.dart")) {
      return false;
    }

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
        final annotation =
            DatagenSourceParser.getAnnotationByClass(declaration);
        if (annotation == null) continue;

        final rawClassName = declaration.name.lexeme;
        final genClassName = "\$$rawClassName";
        DatagenClass? datagen;

        ConstructorDeclaration? fromJsonConstructor;
        MethodDeclaration? fromJsonListMethod;

        // If the class does not already extend another class, inserts an `extends`
        // clause to make it extend the generated base class `_rawClassName`
        if (declaration.extendsClause == null) {
          final classEnd = declaration.name.end;
          insertCode(classEnd, " extends _$rawClassName");
        }

        for (var member in declaration.members) {
          if (member is ConstructorDeclaration) {
            final constructorName = member.name?.lexeme;

            // Regular constructor (not a factory and unnamed)
            if (constructorName == null) {
              // Get constructor parameters.
              final params =
                  DatagenSourceParser.getParametersConstructor(member);

              if (member.factoryKeyword != null) {
                // Already a factory, check if const needs to be added
                if (member.constKeyword == null) {
                  insertCode(member.offset, "const ");
                }
              } else if (member.constKeyword != null) {
                // Const constructor, add factory after const
                insertCode(member.constKeyword!.end, " factory");
              } else {
                // Regular constructor, add const factory at the start
                insertCode(member.offset, "const factory ");
              }

              // Insert redirected constructor if missing
              if (member.redirectedConstructor == null) {
                insertCode(member.endToken.previous!.end, " = $genClassName");
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
          } else {
            if (member is MethodDeclaration) {
              final methodName = member.name.lexeme;

              // A static method for `fromJsonList`.
              if (methodName == "fromJsonList") {
                fromJsonListMethod = member;
              }
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

    if (classes.isEmpty) return false;

    final fileName = path.basename(source.path);
    final genName = fileName.replaceFirst(".dart", ".datagen.dart");
    final genPath = path.join(path.dirname(source.path), genName);
    final parts = unit.directives.whereType<Directive>();

    // Check if the generated datagen file is already imported,
    // and insert it at the top of the file if not.
    {
      bool isExists = false;

      // If the generated datagen file is already imported, mark it.
      for (final directive in parts) {
        if (directive is PartDirective) {
          if (directive.uri.stringValue == genName) {
            isExists = true;
            break;
          }
        }
      }

      if (!isExists) {
        final index = parts.lastOrNull?.end ?? 0;
        insertCode(index, "\n\npart '$genName';");
      }
    }

    {
      // Create datagen.dart file.
      final generatedText = classes.map((c) {
        final generators = <DatagenGenerator>[
          AugmentClassGenerator(),
          FactoryClassGenerator(),
        ];

        return generators.map((g) => g.perform(c)).join("\n");
      }).join("\n");

      File(genPath).writeAsStringSync([
        "// ignore_for_file: unused_import, unnecessary_question_mark",
        "part of '$fileName';",
        generatedText,
      ].join("\n\n"));
    }

    applyEdits();
    return true;
  }
}
