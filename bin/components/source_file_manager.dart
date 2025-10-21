import 'dart:io';
import 'source_file.dart';

/// Utility class for loading source files from a directory.
class SourceFileManager {
  const SourceFileManager._();

  static SourceFile? load(File file) {
    final isDartFile = file.path.endsWith(".dart");
    final isDataFile = file.path.endsWith(".datagen.dart");

    // Skip non-Dart or generated files.
    if (!isDartFile || isDataFile) {
      return null;
    }

    // Read file content and create a SourceFile instance
    final content = file.readAsStringSync();
    return SourceFile(path: file.path, text: content);
  }

  /// Recursively loads all files under [entryDir] and
  /// returns them as a list of [SourceFile] instances.
  /// Throws an exception if [entryDir] does not exist.
  static List<SourceFile> loadAll(Directory entryDir) {
    if (!entryDir.existsSync()) {
      throw Exception("Directory '${entryDir.path}' does not exist.");
    }

    final files = <SourceFile>[];

    /// Helper function to traverse directories recursively.
    void collectFiles(Directory dir) {
      for (var entity in dir.listSync()) {
        if (entity is File) {
          final sourceFile = load(entity);

          // Read file content and create a SourceFile instance
          if (sourceFile != null) {
            files.add(sourceFile);
          }
        } else if (entity is Directory) {
          // Recursively collect files from subdirectories
          collectFiles(entity);
        }
      }
    }

    collectFiles(entryDir);
    return files;
  }
}
