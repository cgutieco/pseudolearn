import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/agent/prompt_assembler.dart';
import 'package:pseudolearn_app/application/agent/screen_context_board.dart';
import 'package:pseudolearn_app/domain/model/agent/model_item.dart';
import 'package:pseudolearn_app/domain/model/agent/screen_context_snapshot.dart';
import '../../fakes/fake_agent_ports.dart';

void main() {
  final board = ScreenContextBoard();
  final assembler = PromptAssembler(
    prompts: const FakeAgentPromptSource(),
    knowledge: const FakeKnowledgeIndex(),
    screen: board,
    ambient: () => AmbientContext(
      interfaceLanguage: 'en',
      defaultProfile: 'english',
      date: DateTime.utc(2026, 11, 8, 23),
      platform: 'macos',
    ),
  );

  test('the stable part comes first and the screen context last', () async {
    board.publish(
      const ScreenContextSnapshot(screen: 'editor', route: '/biblioteca/documento/d', fields: {'title': 'Suma'}),
      fullText: () => 'Algoritmo',
    );
    final request = await assembler.build(const [UserTextItem('hi')], const []);
    final instructions = request.instructions;
    expect(instructions.indexOf('SYSTEM-en'), lessThan(instructions.indexOf('SHEET-en')));
    expect(instructions.indexOf('SHEET-en'), lessThan(instructions.indexOf('# Current context')));
    expect(instructions, contains('"screen":"editor"'));
    expect(instructions, contains('"date":"2026-11-08"'));
    expect(instructions, isNot(contains('Algoritmo')));
    expect(request.input, hasLength(1));
  });

  test('withdrawing another screen keeps the current one and the full text is capped', () {
    board.publish(const ScreenContextSnapshot(screen: 'lesson', route: '/x'), fullText: () => 'a' * 30000);
    board.withdraw('editor');
    expect(board.snapshot().screen, 'lesson');
    expect(board.fullText(), hasLength(20000));
    board.withdraw('lesson');
    expect(board.snapshot().screen, 'unknown');
    expect(board.fullText(), isEmpty);
  });
}
