import 'dart:io';

import 'package:path/path.dart' as p;

final class AndroidCommentViolation {
  final String path;
  final int line;
  final String text;

  const AndroidCommentViolation({required this.path, required this.line, required this.text});

  @override
  String toString() => '$path:$line forbidden comment: $text';
}

final RegExp _quotedText = RegExp(r'"(?:[^"\\]|\\.)*"');
final RegExp _slashComment = RegExp(r'//|/\*|^\s*\*');
final RegExp _markupComment = RegExp('<!--');
final RegExp _hashComment = RegExp(r'^\s*#');

const Set<String> _generatedOrLocalNames = {'local.properties', 'GeneratedPluginRegistrant.java'};
const Set<String> _generatedFolders = {'.gradle', 'build', '.cxx'};

final Map<String, RegExp> _commentSyntaxByExtension = {
  '.kt': _slashComment,
  '.kts': _slashComment,
  '.java': _slashComment,
  '.xml': _markupComment,
  '.pro': _hashComment,
  '.properties': _hashComment,
};

List<AndroidCommentViolation> checkAndroidComments(String androidRoot) {
  final root = Directory(androidRoot);
  if (!root.existsSync()) return const [];
  return [
    for (final file in root.listSync(recursive: true).whereType<File>())
      if (_isHandWritten(file.path, androidRoot)) ...checkAndroidFile(file),
  ];
}

List<AndroidCommentViolation> checkAndroidFile(File file) {
  final syntax = _commentSyntaxByExtension[p.extension(file.path)];
  if (syntax == null) return const [];
  final lines = file.readAsLinesSync();
  return [
    for (var index = 0; index < lines.length; index++)
      if (syntax.hasMatch(lines[index].replaceAll(_quotedText, '""')))
        AndroidCommentViolation(path: file.path, line: index + 1, text: lines[index].trim()),
  ];
}

bool _isHandWritten(String path, String androidRoot) {
  final segments = p.split(p.relative(path, from: androidRoot));
  return !_generatedOrLocalNames.contains(segments.last) && !segments.any(_generatedFolders.contains);
}

void main() {
  final violations = checkAndroidComments(p.join(Directory.current.path, 'android'));
  if (violations.isEmpty) {
    stdout.writeln('Android sources carry no comments.');
    exit(0);
  }
  stderr.writeln('Android comment violations found (${violations.length}):');
  violations.forEach(stderr.writeln);
  exit(1);
}
