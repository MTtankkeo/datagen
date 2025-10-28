import 'package:args/command_runner.dart';
import 'command/build_command.dart';
import 'command/watch_command.dart';

void main(List<String> arguments) {
  final runner = CommandRunner("datagen", "A data class generator");

  // Setup command runner with the 'build' and 'watch' command.
  runner.addCommand(BuildCommand());
  runner.addCommand(WatchCommand());
  runner.run(arguments);
}
