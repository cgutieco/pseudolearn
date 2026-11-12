import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/completion/completion_item.dart';

CompletionItem _item(String template) => CompletionItem(
  label: 'unchanged',
  template: template,
  caretOffset: 0,
  family: CompletionFamily.structured,
);

void main() {
  test('the preview uses the offered text without changing its identity', () {
    final item = _item('area <- ');
    expect(item.insertionPreview, 'area <-');
    expect(item.label, 'unchanged');
    expect(item.template, 'area <- ');
  });

  test('a multiline insertion previews only its first line', () {
    expect(
      _item('While condition Do\n  \nEndWhile').insertionPreview,
      'While condition Do',
    );
    expect(
      _item('  Si condicion Entonces\r\n\t\nFinSi').insertionPreview,
      '  Si condicion Entonces',
    );
  });

  test('empty and whitespace insertions have an empty preview', () {
    expect(_item('').insertionPreview, isEmpty);
    expect(_item(' \t\r\nbody').insertionPreview, isEmpty);
  });
}
