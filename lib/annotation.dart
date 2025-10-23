/// Default [Datagen] annotation with all options enabled.
const datagen = Datagen();

/// Annotation class used to configure code generation options for a Dart data class.
///
/// Applying [Datagen] to a class controls which utility methods and factories
/// are automatically generated in the companion `.datagen.dart` file.
///
/// Example:
/// ```dart
/// @Datagen(
///   copyWith: true,
///   fromJson: true,
///   toJson: true,
///   stringify: true,
/// )
/// class MyModel { ... }
/// ```
class Datagen {
  /// Creates a [Datagen] annotation with optional flags.
  /// All options default to `true`.
  const Datagen({
    this.copyWith = true,
    this.fromJson = true,
    this.fromJsonList = true,
    this.toJson = true,
    this.stringify = true,
    this.omitFactory = false,
  }) : assert(fromJsonList ? fromJson : true);

  /// Enables generating a `copyWith` method for the annotated class.
  final bool copyWith;

  /// Enables generating a `fromJson` factory constructor.
  final bool fromJson;

  /// Enables generating a `fromJsonList` factory constructor.
  final bool fromJsonList;

  /// Enables generating a `toJson` method.
  final bool toJson;

  /// Enables generating a `toString` override method.
  final bool stringify;

  /// Controls whether a `fromJson` factory is generated in the public class.
  /// The factory in the generated `.datagen.dart` class is always created.
  final bool omitFactory;

  @override
  String toString() {
    return "Datagen(copyWith: $copyWith, fromJson: $fromJson, toJson: $toJson)";
  }
}

/// Annotation to indicate that a parameter or field should be
/// automatically converted to the specified type.
///
/// Example:
/// ```dart
/// const MyModel({
///   @Get(int) required String age,
/// });
/// ```
///
/// Here, `age` is stored as a [String], but getters can automatically
/// convert it to [int].
class Get {
  /// Creates a [Get] annotation to specify the target type.
  const Get(this.type);

  /// The target type for automatic conversion
  final Type type;
}
