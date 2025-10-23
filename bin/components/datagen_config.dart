import 'dart:convert';
import 'dart:io';

import 'package:datagen/annotation.dart';

/// A class that manages configuration for the datagen.
class DatagenConfig {
  DatagenConfig._({
    required this.options,
    required this.useCommand,
  });

  /// The parsed [Datagen] options currently in use.
  final Datagen options;
  final bool useCommand;

  static DatagenConfig? _instance;

  /// Returns a singleton instance of [DatagenConfig].
  static DatagenConfig get instance {
    if (_instance != null) return _instance!;

    final configFile = File("datagen.json");
    Map config = {};

    // Reads and decodes config file if the file exists.
    if (configFile.existsSync()) {
      final source = configFile.readAsStringSync();
      config = jsonDecode(source);
    }

    final option = config["options"];

    return _instance = DatagenConfig._(
      options: Datagen(
        copyWith: option?["copyWith"] ?? datagen.copyWith,
        fromJson: option?["fromJson"] ?? datagen.fromJson,
        fromJsonList: option?["fromJsonList"] ?? datagen.fromJsonList,
        toJson: option?["toJson"] ?? datagen.toJson,
        stringify: option?["stringify"] ?? datagen.stringify,
        equality: option?["equality"] ?? datagen.equality,
        omitFactory: option?["omitFactory"] ?? datagen.omitFactory,
      ),
      useCommand: config["useCommand"] ?? true,
    );
  }
}
