/// Represents a source file with its path and content.
/// This class is used to store and manipulate file
/// data when formatting or adding comments via the AI.
class SourceFile {
  // Constructs a [SourceFile] instance with the given [path] and [text].
  SourceFile({required this.path, required this.text});

  /// The file path of the source file.
  String path;

  /// The full text content of the source file.
  String text;
}
