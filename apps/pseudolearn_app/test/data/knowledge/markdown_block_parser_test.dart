import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/knowledge/markdown_block_parser.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_block.dart';

void main() {
  group('MarkdownBlockParser (PANT-03-F2)', () {
    const parser = MarkdownBlockParser();

    test('parses headings of multiple levels, paragraphs, quotes and lists', () {
      const markdown = '''
# Heading 1
Intro paragraph with text.

## Heading 2
> A relevant note

- Item 1
- Item 2

1. First
2. Second

```pseudo
Proceso Demo
    Escribir "Hola";
FinProceso
```
''';
      final blocks = parser.parse(markdown);

      expect(blocks.length, 7);
      expect(blocks[0], isA<HeadingBlock>().having((b) => b.level, 'level', 1).having((b) => b.text, 'text', 'Heading 1'));
      expect(blocks[1], isA<ParagraphBlock>().having((b) => b.text, 'text', 'Intro paragraph with text.'));
      expect(blocks[2], isA<HeadingBlock>().having((b) => b.level, 'level', 2).having((b) => b.text, 'text', 'Heading 2'));
      expect(blocks[3], isA<QuoteBlock>().having((b) => b.text, 'text', 'A relevant note'));
      expect(blocks[4], isA<ListBlock>().having((b) => b.isOrdered, 'isOrdered', false).having((b) => b.items.length, 'items', 2));
      expect(blocks[5], isA<ListBlock>().having((b) => b.isOrdered, 'isOrdered', true).having((b) => b.items.length, 'items', 2));
      expect(blocks[6], isA<CodeBlock>().having((b) => b.language, 'language', 'pseudo').having((b) => b.code, 'code', contains('Proceso Demo')));
    });

    test('returns empty list for empty or whitespace-only markdown', () {
      expect(parser.parse(''), isEmpty);
      expect(parser.parse('   \n\n  '), isEmpty);
    });

    test('code keeps the characters the language uses, unescaped', () {
      const markdown = '''
```pseudo
Algoritmo Demo
  n <- 5 & 3 > 2
FinAlgoritmo
```
''';
      final blocks = parser.parse(markdown);

      expect((blocks.single as CodeBlock).code, contains('n <- 5 & 3 > 2'));
    });

    test('a document with a single heading and nothing else is one block', () {
      final blocks = parser.parse('# Solo un titulo');

      expect(blocks.length, 1);
      expect(blocks.single, isA<HeadingBlock>());
    });

    test('parses a table into headers and rows', () {
      const markdown = '''
| Tipo | Valores |
|------|---------|
| entero | numeros enteros |
| real | numeros con decimales |
''';
      final blocks = parser.parse(markdown);

      expect(blocks.length, 1);
      expect(
        blocks.single,
        isA<TableBlock>()
            .having((b) => b.headers, 'headers', ['Tipo', 'Valores'])
            .having((b) => b.rows.length, 'rows', 2)
            .having((b) => b.rows.first, 'first row', ['entero', 'numeros enteros']),
      );
    });
  });
}
