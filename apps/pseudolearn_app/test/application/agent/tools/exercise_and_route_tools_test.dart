import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/agent/tools/exercise_writing_tools.dart';
import 'package:pseudolearn_app/application/agent/tools/route_reading_tools.dart';
import 'package:pseudolearn_app/application/agent/tools/screen_context_tool.dart';
import 'package:pseudolearn_app/application/agent/tools/search_knowledge_tool.dart';
import 'package:pseudolearn_app/application/agent/tools/tool_arguments.dart';
import 'package:pseudolearn_app/application/agent/screen_context_board.dart';
import 'package:pseudolearn_app/application/exercises/use_cases/create_user_exercise.dart';
import 'package:pseudolearn_app/application/exercises/use_cases/delete_user_exercise.dart';
import 'package:pseudolearn_app/application/exercises/use_cases/validate_user_exercise.dart';
import 'package:pseudolearn_app/domain/model/agent/screen_context_snapshot.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_edition.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import '../../../fakes/fake_agent_ports.dart';
import '../../../fakes/fake_clock.dart';
import '../../../fakes/fake_identifier_generator.dart';
import '../../../fakes/fake_route_repository.dart';
import '../../../fakes/in_memory_local_progress_store.dart';
import '../../../fakes/in_memory_user_exercise_repository.dart';
import '../../../fakes/native_test_engine.dart';
import '../../../fakes/user_exercise_fixtures.dart';

const Map<String, Object?> _draft = {
  'title': 'Suma',
  'statement': 'Suma dos enteros',
  'visible_cases': [
    {'inputs': ['2', '3'], 'expected': ['5']},
  ],
  'hidden_cases': [
    {'inputs': ['1', '1'], 'expected': ['2']},
  ],
  'hints': ['Lee dos números'],
  'assertions': ['no-contiene: bucle-condicional'],
  'reference_solution': sumSolution,
  'profile': 'classicSpanish',
};

ReferenceEdition _edition() =>
    const ReferenceEdition(language: UiLanguageId.spanish, profile: SyntaxProfileId.classicSpanish);

void main() {
  late InMemoryUserExerciseRepository repository;

  setUp(() => repository = InMemoryUserExerciseRepository());

  CreateUserExerciseTool create() => CreateUserExerciseTool(CreateUserExercise(
    repository: repository,
    validate: ValidateUserExercise(analyzer: nativeTestEngine.analyzer, checker: nativeTestEngine.exerciseChecker),
    identifiers: FakeIdentifierGenerator(['ux-9']),
    clock: FakeClock(),
  ));

  test('creating an exercise confirms first and publishes a valid draft', () async {
    final tool = create();
    expect(tool.needsConfirmation(const ToolArguments(_draft)), isTrue);
    final result = await tool.run(const ToolArguments(_draft));
    expect(result.output['exercise_id'], 'user:ux-9');
    expect(repository.exercises['ux-9']!.assertions, hasLength(1));
  });

  test('an exercise whose solution fails a case is not published', () async {
    final wrong = {..._draft, 'visible_cases': [{'inputs': ['2', '3'], 'expected': ['6']}]};
    final result = await create().run(ToolArguments(wrong));
    expect(result.output['error'], 'not_publishable');
    expect(result.output['detail'], contains('referenceFailsCase'));
    expect(repository.exercises, isEmpty);
  });

  test('malformed assertions and missing fields are invalid arguments', () async {
    final bad = await create().run(ToolArguments({..._draft, 'assertions': ['magia']}));
    expect(bad.output['error'], 'invalid_arguments');
    final missing = await create().run(const ToolArguments({'title': 'x'}));
    expect(missing.output['error'], 'invalid_arguments');
  });

  test('deleting accepts the user prefix', () async {
    repository.exercises['ux-1'] = sumExercise();
    final result = await DeleteUserExerciseTool(DeleteUserExercise(repository: repository))
        .run(const ToolArguments({'exercise_id': 'user:ux-1'}));
    expect(result.succeeded, isTrue);
    expect(repository.exercises, isEmpty);
  });

  test('get exercise never returns hidden cases or the solution', () async {
    repository.exercises['ux-1'] = sumExercise();
    final tool = GetExerciseTool(FakeRouteRepository(), repository, _edition);
    final result = await tool.run(const ToolArguments({'exercise_id': 'user:ux-1'}));
    expect(result.output['hidden_case_count'], 1);
    expect(result.output.toString(), isNot(contains('10')));
    expect(result.output.toString(), isNot(contains('Leer a')));
    expect((await tool.run(const ToolArguments({'exercise_id': 'route:none'}))).output['error'], 'not_found');
  });

  test('route progress fails cleanly without a table of contents', () async {
    final tool = RouteProgressTool(FakeRouteRepository(failToc: true), InMemoryLocalProgressStore(), _edition);
    expect((await tool.run(const ToolArguments({}))).output['error'], 'route_unavailable');
  });

  test('screen context and knowledge search expose their sources', () async {
    final board = ScreenContextBoard()
      ..publish(const ScreenContextSnapshot(screen: 'editor', route: '/r'), fullText: () => 'fuente');
    final screen = await ScreenContextTool(board).run(const ToolArguments({}));
    expect(screen.output['full_text'], 'fuente');
    final search = SearchKnowledgeTool(const FakeKnowledgeIndex(), () => 'es');
    final found = await search.run(const ToolArguments({'query': 'argumentos', 'limit': 99}));
    expect((found.output['results'] as List).single, containsPair('citation', 'manual:execution-options'));
    expect((await search.run(const ToolArguments({}))).output['error'], 'invalid_arguments');
  });
}
