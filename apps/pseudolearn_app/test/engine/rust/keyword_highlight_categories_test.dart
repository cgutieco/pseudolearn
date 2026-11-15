import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/highlight_span.dart';
import 'package:pseudolearn_app/engine/rust/keyword_highlight_categories.dart';
import 'package:pseudolearn_app/engine/rust/rust_syntax_highlighter.dart';
import 'package:pseudolearn_app/engine/rust/source_offset_index.dart';

Map<String, Object?> _json(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>;

Set<String> _reservedIdentities() {
  final export = _json(
    '../../packages/pseudolearn_spec/specifications/export.json',
  );
  final resources = export['resources'] as Map<String, Object?>;
  return (resources['vocabulary'] as Map<String, Object?>).keys.toSet();
}

Map<String, Object?> _keywordToken(String identity) => {
  'kind': 'keyword',
  'keyword': identity,
  'span': {
    'start': {'line': 1, 'column': 1},
    'end': {'line': 1, 'column': 2},
  },
};

List<HighlightSpan> _project(String identity) => RustSyntaxHighlighter(
  SourceOffsetIndex('x'),
).project([_keywordToken(identity)]);

void main() {
  test('every reserved identity has the category the book uses', () {
    final book = _json('../../packages/pseudolearn_reference/categories.json');
    final reserved = _reservedIdentities();
    expect(keywordHighlightCategories.keys.toSet(), reserved);
    for (final identity in reserved) {
      expect(
        keywordHighlightCategories[identity]?.name,
        book[identity],
        reason: identity,
      );
    }
  });

  test('a function opening and its closing are highlighted as procedures', () {
    expect(
      _project('function').single.category,
      HighlightCategory.keywordProcedural,
    );
    expect(
      _project('endFunction').single.category,
      HighlightCategory.keywordProcedural,
    );
    expect(_project('tasksKeyword').single.category, isNotNull);
  });

  test('an unknown keyword identity is left unhighlighted', () {
    expect(_project('notAnIdentity'), isEmpty);
    expect(_project(''), isEmpty);
  });
}
