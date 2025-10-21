import 'dart:io';

import 'datagen_builder.dart';
import 'source_file_manager.dart';

import '../datagen.dart';

/// A simple queue to prevent multiple simultaneous builds of the same Dart file.
/// Uses a short delay to allow rapid successive file events to be ignored.
class DatagenQueue {
  const DatagenQueue._();

  /// Tracks which files are currently being built.
  static final Map<String, bool> _buildingFiles = {};

  /// Delay before allowing another build for the same file.
  static Duration delayDuration = Duration(milliseconds: 1);

  /// Attempts to build the given [file] if it is not already being built.
  /// Prevents duplicate builds for the same file by using [_buildingFiles] map.
  static void tryBuild(File file) async {
    if (_buildingFiles[file.path] == true) return;

    // Load the source file.
    final sourceFile = SourceFileManager.load(file);
    if (sourceFile == null) return;

    // Mark the file as building.
    _buildingFiles[file.path] = true;

    try {
      DatagenBuilder.build(sourceFile);
    } catch (error) {
      log("Error: $error", color: red);
    } finally {
      // Reset the build flag after a short delay to allow subsequent builds.
      Future.delayed(delayDuration, () {
        _buildingFiles[file.path] = false;
      });
    }
  }
}
