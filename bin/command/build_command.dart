import 'dart:async';
import 'dart:io';
import 'package:args/command_runner.dart';

import '../components/source_file_manager.dart';
import '../components/datagen_builder.dart';
import '../components/datagen_queue.dart';
import '../datagen.dart';

/// A CLI command that triggers the datagen build process.
class BuildCommand extends Command {
  @override
  String get name => "build";

  @override
  String get description =>
      "Generates datagen files for annotated Dart classes";

  BuildCommand() {
    argParser.addFlag(
      "watch",
      abbr: 'w',
      help: "Automatically rebuild on file changes",
      defaultsTo: false,
    );
  }

  /// Attempts to build all Dart source files in the given [dir].
  void tryBuildAll(Directory dir) async {
    // Start the build process on the given directory.
    final files = SourceFileManager.loadAll(dir);

    for (final file in files) {
      DatagenBuilder.build(file);
    }
  }

  @override
  Future<void> run() async {
    final isWatchMode = argResults?["watch"] ?? false;
    final dir = Directory("./");

    if (isWatchMode) {
      log("Starting datagen build in watch mode...", color: yellow);

      // Watch for changes.
      await for (final event in dir.watch(recursive: true)) {
        if (event.type == FileSystemEvent.modify) {
          // Skip if a build is already running.
          DatagenQueue.tryBuild(File(event.path));
        }
      }
    } else {
      // Start the build process on the current directory.
      tryBuildAll(dir);
    }

    log("Datagen build completed successfully!", color: green);
  }
}
