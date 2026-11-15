import 'rust_program_view.dart';

String rustCaptionOf(RustViewNode? node) {
  if (node == null) return '';
  final text = node.text.replaceAll('\n', ' ').trim();
  return text.endsWith(';')
      ? text.substring(0, text.length - 1).trimRight()
      : text;
}

String rustFirstLine(String text) => text.split('\n').first.trim();
