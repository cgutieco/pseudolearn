import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/agent/highlight/code_language.dart';
import 'package:pseudolearn_app/application/agent/highlight/code_language_catalog.dart';
import 'package:pseudolearn_app/application/agent/highlight/lexical_highlighter.dart';
import 'package:pseudolearn_app/domain/model/analysis/highlight_span.dart';

Map<String, HighlightCategory> _categories(String source, String language) => {
  for (final span in highlightLexically(source, codeLanguageNamed(language)))
    source.substring(span.range.startOffset, span.range.endOffset): span.category,
};

void main() {
  test('javascript keywords, strings, numbers, calls and comments are told apart', () {
    final categories = _categories('const n = 42; // fin\nconsole.log(`x \${n}`, "a\\"b", true);', 'javascript');
    expect(categories['const'], HighlightCategory.keywordStructured);
    expect(categories['42'], HighlightCategory.literalNumber);
    expect(categories['// fin'], HighlightCategory.comment);
    expect(categories['log'], HighlightCategory.keywordProcedural);
    expect(categories['`x \${n}`'], HighlightCategory.literalString);
    expect(categories['"a\\"b"'], HighlightCategory.literalString);
    expect(categories['true'], HighlightCategory.literalBoolean);
    expect(categories['n'], HighlightCategory.identifier);
  });

  test('aliases resolve to the same language and case does not matter', () {
    expect(codeLanguageNamed('JS'), same(codeLanguageNamed('typescript')));
    expect(_categories('def f():\n    return None', 'Py')['def'], HighlightCategory.keywordStructured);
  });

  test('python triple quotes span lines and go types are recognised', () {
    expect(_categories('x = """a\nb"""', 'python')['"""a\nb"""'], HighlightCategory.literalString);
    expect(_categories('var n int = 0', 'go')['int'], HighlightCategory.type);
  });

  test('sql is case insensitive and block comments close', () {
    final categories = _categories('SELECT * /* todo */ FROM t', 'sql');
    expect(categories['SELECT'], HighlightCategory.keywordStructured);
    expect(categories['/* todo */'], HighlightCategory.comment);
  });

  test('markup tag names are keywords', () {
    final categories = _categories('<div class="a">x</div><!-- c -->', 'html');
    expect(categories['div'], HighlightCategory.keywordStructured);
    expect(categories['"a"'], HighlightCategory.literalString);
    expect(categories['<!-- c -->'], HighlightCategory.comment);
  });

  test('unterminated strings and comments end with the line or the source', () {
    final string = highlightLexically('"abierta\nsiguiente', codeLanguageNamed('js')).first;
    expect(string.range.endOffset, 8);
    final comment = highlightLexically('/* sin cerrar', codeLanguageNamed('c')).single;
    expect(comment.range.endOffset, 13);
    final escaped = highlightLexically(r'"\', codeLanguageNamed('js')).single;
    expect(escaped.range.endOffset, 2);
  });

  test('unknown languages and empty sources still highlight words and numbers only', () {
    expect(highlightLexically('', CodeLanguage.plain), isEmpty);
    final plain = _categories('hola "no es cadena" 3', 'brainfuck');
    expect(plain['hola'], HighlightCategory.identifier);
    expect(plain['3'], HighlightCategory.literalNumber);
    expect(plain.containsKey('"no es cadena"'), isFalse);
  });

  test('identifiers with digits are not numbers and ranges carry lines and columns', () {
    final spans = highlightLexically('a\nx1 = 2', codeLanguageNamed('js'));
    final identifier = spans.firstWhere((span) => span.range.startOffset == 2);
    expect(identifier.category, HighlightCategory.identifier);
    expect(identifier.range.endOffset, 4);
    expect(identifier.range.startLine, 2);
    expect(identifier.range.startColumn, 1);
  });
}
