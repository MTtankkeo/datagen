import 'package:prepare/command/prepare_watch_command.dart';
import 'package:prepare/components/prepare_builder.dart';

import '../components/datagen_builder.dart';

/// A CLI command that triggers the datagen watch process.
class WatchCommand extends PrepareWatchCommand {
  @override
  PrepareBuilder get builder => DatagenBuilder();
}
