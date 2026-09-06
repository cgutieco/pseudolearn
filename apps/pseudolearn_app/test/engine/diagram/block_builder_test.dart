import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/diagram/block_builder.dart';
import 'package:pseudolearn_app/engine/diagram/diagram_vocabulary.dart';
import 'package:pseudolearn_app/engine/diagram/node_factory.dart';
import 'package:pseudolearn_app/engine/diagram/node_sizing.dart';
import 'package:pseudolearn_app/engine/diagram/statement_caption.dart';
import 'package:pseudolearn_app/engine/diagram/text_metrics.dart';
import 'package:pseudolearn_app/engine/printing/pseudocode_printer.dart';
import 'package:pseudolearn_core/pseudolearn_core.dart';

const ClassicSpanishProfile _profile = ClassicSpanishProfile.flexible();

BlockBuilder _builder() {
  final vocabulary = DiagramVocabulary.forLanguage(UiLanguageId.spanish);
  return BlockBuilder(
    nodes: NodeFactory(const NodeSizing(TextMetrics())),
    vocabulary: vocabulary,
    caption: StatementCaption(
      printer: PseudocodePrinter(_profile),
      lexicon: _profile,
      vocabulary: vocabulary,
    ),
  );
}

List<StatementNode> _statements(String source) {
  final tokens = Lexer(_profile).tokenize(source);
  final parsed = Parser(profile: _profile).parse(TokenStream(tokens.tokens));
  return parsed.program!.algorithm!.body;
}

void main() {
  group('buildStatement', () {
    test('a return leaves the block without an exit', () {
      final statement = _statements('Proceso P\nRetornar;\nFinProceso\n').first;
      final block = _builder().buildStatement(statement);
      expect(block.hasExit, isFalse);
      expect(block.exitId, isNull);
    });

    test('an assignment leaves the block with an exit', () {
      final statement = _statements('Proceso P\na <- 1;\nFinProceso\n').first;
      final block = _builder().buildStatement(statement);
      expect(block.hasExit, isTrue);
      expect(block.exitId, isNotNull);
    });

    test('a statement after a return receives no incoming edge', () {
      final statements = _statements('Proceso P\nRetornar;\na <- 1;\nFinProceso\n');
      final block = _builder().buildSequence(statements);
      expect(block.nodes, hasLength(2));
      expect(block.edges, isEmpty);
    });
  });

  group('buildSequence', () {
    test('an empty body still produces a passing node', () {
      final block = _builder().buildSequence(const []);
      expect(block.nodes, hasLength(1));
      expect(block.entryId, isNotNull);
    });

    test('consecutive statements are joined in order', () {
      final statements = _statements('Proceso P\na <- 1;\nb <- 2;\nc <- 3;\nFinProceso\n');
      final block = _builder().buildSequence(statements);
      expect(block.nodes, hasLength(3));
      expect(block.edges, hasLength(2));
      expect(block.edges.first.fromId, block.nodes.first.id);
    });

    test('every node of a sequence shares the spine', () {
      final statements = _statements('Proceso P\na <- 1;\nb <- 2;\nFinProceso\n');
      final block = _builder().buildSequence(statements);
      for (final node in block.nodes) {
        expect(node.x + node.width / 2, closeTo(block.spineX, 0.001));
      }
    });
  });
}
