/// A data class that represents a text edit in a source file, specifying
/// the range from [start] to [end] that should be replaced with [content].
class SourceFileEdit {
  const SourceFileEdit(this.start, this.end, this.content);

  final int start;
  final int end;
  final String content;
}
