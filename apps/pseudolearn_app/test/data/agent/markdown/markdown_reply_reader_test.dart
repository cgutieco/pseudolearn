import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/agent/markdown/markdown_reply_reader.dart';
import 'package:pseudolearn_app/domain/model/agent/flowchart.dart';
import 'package:pseudolearn_app/domain/model/agent/reply_block.dart';
import 'package:pseudolearn_app/domain/model/agent/reply_run.dart';

const MarkdownReplyReader _reader = MarkdownReplyReader();

List<ReplyBlock> _blocks(String markdown) => _reader.read(markdown).blocks;

String _text(List<ReplyRun> runs) => plainTextOfRuns(runs);

void main() {
  group('blocks', () {
    test('headings keep their level and paragraphs their inline marks', () {
      final blocks = _blocks('## Título\n\nTexto **fuerte**, *cursiva*, ~~tachado~~ y `codigo`.');
      final heading = blocks.first as ReplyHeading;
      expect(heading.level, 2);
      expect(_text(heading.runs), 'Título');
      final runs = (blocks[1] as ReplyParagraph).runs;
      expect(runs.firstWhere((run) => run.text == 'fuerte').has(ReplyMark.strong), isTrue);
      expect(runs.firstWhere((run) => run.text == 'cursiva').has(ReplyMark.emphasis), isTrue);
      expect(runs.firstWhere((run) => run.text == 'tachado').has(ReplyMark.strikethrough), isTrue);
      expect(runs.firstWhere((run) => run.text == 'codigo').has(ReplyMark.code), isTrue);
    });

    test('nested marks accumulate and links carry their target', () {
      final runs = (_blocks('***ambas*** [sitio](https://example.com) https://pseudolearn.app').single as ReplyParagraph).runs;
      expect(runs.first.marks, {ReplyMark.strong, ReplyMark.emphasis});
      expect(runs.firstWhere((run) => run.text == 'sitio').target, 'https://example.com');
      expect(runs.last.target, 'https://pseudolearn.app');
    });

    test('ordered, nested and task lists are read with their items', () {
      final blocks = _blocks('3. uno\n4. dos\n   - interno\n\n- [x] hecho\n- [ ] pendiente');
      final ordered = blocks.first as ReplyList;
      expect(ordered.ordered, isTrue);
      expect(ordered.start, 3);
      expect(ordered.items, hasLength(2));
      expect(ordered.items[1].blocks.last, isA<ReplyList>());
      final tasks = blocks.last as ReplyList;
      expect(tasks.items.map((item) => item.task), [ReplyTask.done, ReplyTask.open]);
      expect(_text((tasks.items.first.blocks.single as ReplyParagraph).runs), 'hecho');
    });

    test('tables keep header, rows and alignment', () {
      final table = _blocks('| A | B | C |\n|:--|:-:|--:|\n| `x` | **y** | z |\n| 1 |').single as ReplyTable;
      expect(table.alignments, [ReplyCellAlignment.start, ReplyCellAlignment.center, ReplyCellAlignment.end]);
      expect(table.header.map(_text), ['A', 'B', 'C']);
      expect(table.rows.first.map(_text), ['x', 'y', 'z']);
      expect(table.rows.first.first.single.has(ReplyMark.code), isTrue);
      expect(table.rows.last.map(_text), ['1', '', '']);
    });

    test('quotes, alerts and rules are recognised', () {
      final blocks = _blocks('> cita\n\n---\n\n> [!WARNING]\n> cuidado');
      expect((blocks.first as ReplyQuote).kind, ReplyQuoteKind.plain);
      expect(blocks[1], isA<ReplyRule>());
      final alert = blocks.last as ReplyQuote;
      expect(alert.kind, ReplyQuoteKind.warning);
      expect(_text((alert.blocks.single as ReplyParagraph).runs), 'cuidado');
    });

    test('inline html line breaks become new lines and other tags vanish', () {
      final runs = (_blocks('uno<br/>dos <kbd>Ctrl</kbd> <span class="x">y</span>').single as ReplyParagraph).runs;
      expect(_text(runs), 'uno\ndos Ctrl y');
    });

    test('comparisons that look like markup are kept as text', () {
      final runs = (_blocks('Si a<b y c>d, o x <= y').single as ReplyParagraph).runs;
      expect(_text(runs), 'Si a<b y c>d, o x <= y');
    });

    test('images become links that show their alternative text', () {
      final run = (_blocks('![diagrama](https://x.test/a.png)').single as ReplyParagraph).runs.single;
      expect(run.text, 'diagrama');
      expect(run.target, 'https://x.test/a.png');
    });
  });

  group('code', () {
    test('fenced blocks are indexed in order, also inside lists', () {
      final document = _reader.read('a\n```pseudolearn\nx\n```\n1. paso\n\n   ```js\nlet y = 1;\n   ```\n\n```\nz\n```');
      expect(document.codeBlocks.map((block) => block.language), ['pseudolearn', 'js', '']);
      expect(document.codeBlocks.first.source, 'x');
      expect(document.codeBlocks[1].source, 'let y = 1;');
      expect((document.blocks[1] as ReplyCode).index, 0);
      final list = document.blocks[2] as ReplyList;
      expect((list.items.single.blocks.last as ReplyCode).index, 1);
    });

    test('an unterminated fence keeps the rest of the reply as code', () {
      final document = _reader.read('antes\n```python\nprint(1)');
      expect(document.codeBlocks.single.source, 'print(1)');
      expect(document.codeBlocks.single.isPseudoLearn, isFalse);
    });

    test('mermaid fences become diagrams, not code blocks', () {
      final document = _reader.read('```mermaid\nflowchart LR\n  A --> B\n```');
      expect(document.codeBlocks, isEmpty);
      final diagram = document.blocks.single as ReplyDiagram;
      expect(diagram.flowchart!.direction, FlowchartDirection.right);
      expect(diagram.source, 'flowchart LR\n  A --> B');
    });

    test('unsupported mermaid diagrams keep only their source', () {
      final diagram = _reader.read('```mermaid\nsequenceDiagram\n  A->>B: hola\n```').blocks.single as ReplyDiagram;
      expect(diagram.flowchart, isNull);
      expect(diagram.source, startsWith('sequenceDiagram'));
    });
  });

  group('edges', () {
    test('empty and blank replies have no blocks', () {
      expect(_reader.read('').blocks, isEmpty);
      expect(_reader.read('  \n\t').codeBlocks, isEmpty);
    });

    test('plain text without markdown is one paragraph with its line breaks', () {
      final paragraph = _blocks('hola\nmundo').single as ReplyParagraph;
      expect(_text(paragraph.runs), 'hola\nmundo');
    });

    test('a single character reply is kept', () {
      expect(_text((_blocks('x').single as ReplyParagraph).runs), 'x');
    });

    test('the parser used for diagrams is injected', () {
      final reader = MarkdownReplyReader(parseFlowchart: (_) => null);
      final diagram = reader.read('```mermaid\ngraph TD\nA-->B\n```').blocks.single as ReplyDiagram;
      expect(diagram.flowchart, isNull);
    });
  });
}
