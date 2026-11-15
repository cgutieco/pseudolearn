import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/agent/tools/tool_arguments.dart';
import 'package:pseudolearn_app/application/agent/tools/tutor_tools.dart';
import 'package:pseudolearn_app/domain/model/exercises/active_exercise.dart';
import 'package:pseudolearn_app/domain/model/exercises/exercise_reference.dart';
import 'package:pseudolearn_app/domain/ports/active_exercise_source.dart';
import '../../../fakes/fake_agent_ports.dart';

final class _Active implements ActiveExerciseSource {
  @override
  ActiveExercise? activeExercise;
}

ActiveExercise _exercise({int failed = 0, List<String> hints = const ['Piensa', 'Usa +'], String? solution = 'S'}) =>
    ActiveExercise(
      reference: const ExerciseReference.user('ux-1'),
      title: 'Suma',
      hints: hints,
      solution: solution,
      failedAttempts: failed,
      solved: false,
    );

void main() {
  late _Active active;
  late InMemoryAssistedProgressStore assisted;

  setUp(() {
    active = _Active();
    assisted = InMemoryAssistedProgressStore();
  });

  test('hints need an open exercise with hints', () async {
    final tool = GiveHintTool(active, assisted);
    expect((await tool.run(const ToolArguments({'level': 1}))).output['error'], 'no_exercise_open');
    active.activeExercise = _exercise(hints: const []);
    expect((await tool.run(const ToolArguments({'level': 1}))).output['error'], 'no_hints');
  });

  test('hints are graded, clamped and mark the progress as assisted', () async {
    active.activeExercise = _exercise();
    final tool = GiveHintTool(active, assisted);
    expect((await tool.run(const ToolArguments({'level': 1}))).output['hint'], 'Piensa');
    expect((await tool.run(const ToolArguments({'level': 9}))).output['level'], 2);
    expect((await tool.run(const ToolArguments({'level': -3}))).output['level'], 1);
    expect(assisted.ids, {'usuario.ejercicio:ux-1'});
  });

  test('the solution needs an explicit request and three failed attempts', () async {
    final tool = RevealSolutionTool(active, assisted);
    expect(tool.needsConfirmation(const ToolArguments({})), isTrue);
    active.activeExercise = _exercise(failed: 2);
    expect((await tool.run(const ToolArguments({'explicit_request': true}))).output['error'], 'too_early');
    active.activeExercise = _exercise(failed: 3);
    expect((await tool.run(const ToolArguments({'explicit_request': false}))).output['error'], 'not_requested');
    expect(assisted.ids, isEmpty);
    expect((await tool.run(const ToolArguments({'explicit_request': true}))).output['solution'], 'S');
    expect(assisted.ids, hasLength(1));
  });

  test('a route exercise without a solution cannot be revealed', () async {
    active.activeExercise = ActiveExercise(
      reference: const ExerciseReference.route('r1'),
      title: 'R',
      hints: const ['h'],
      solution: null,
      failedAttempts: 5,
      solved: false,
    );
    final result = await RevealSolutionTool(active, assisted).run(const ToolArguments({'explicit_request': true}));
    expect(result.output['error'], 'no_solution');
  });
}
