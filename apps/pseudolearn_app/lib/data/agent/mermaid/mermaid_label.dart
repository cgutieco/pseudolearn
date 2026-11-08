final RegExp _lineBreakTag = RegExp(r'<br\s*/?>', caseSensitive: false);
final RegExp _anyTag = RegExp(r'</?[A-Za-z][^>]*>');
final RegExp _markdownMarks = RegExp(r'\*\*|__|`');

const Map<String, String> _entities = {
  '#quot;': '"',
  '&quot;': '"',
  '&amp;': '&',
  '&lt;': '<',
  '&gt;': '>',
  '#59;': ';',
};

String cleanMermaidLabel(String raw) {
  var label = raw.trim();
  if (label.length >= 2 && label.startsWith('"') && label.endsWith('"')) {
    label = label.substring(1, label.length - 1);
  }
  label = label.replaceAll(_lineBreakTag, '\n').replaceAll(_anyTag, '').replaceAll(_markdownMarks, '');
  for (final entry in _entities.entries) {
    label = label.replaceAll(entry.key, entry.value);
  }
  return label.split('\n').map((line) => line.trim()).join('\n').trim();
}
