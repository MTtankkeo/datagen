import '../datagen_class.dart';
import '../datagen_parameter.dart';
import '../datagen_type_resolver.dart';

/// A class representing the base generator that produces
/// Dart code from a [DatagenClass] instance.
abstract class DatagenGenerator {
  /// Generates Dart code for the given [instance].
  String perform(DatagenClass instance);
}

/// A generator that handles JSON serialization code generation for Datagen models.
abstract class DatagenJsonGenerator extends DatagenGenerator {
  /// List of available resolvers that determine how each type is converted.
  static final resolvers = <DatagenTypeResolver>[
    PrimitiveTypeResolver(),
    DateTimeTypeResolver(),
    ObjectTypeResolver(),
  ];

  /// Finds the first resolver that can handle the given parameter.
  /// Used to generate the appropriate fromJson/toJson code snippet.
  DatagenTypeResolver findResolver(DatagenParameter param) {
    return resolvers.firstWhere((e) => e.canResolve(param));
  }
}
