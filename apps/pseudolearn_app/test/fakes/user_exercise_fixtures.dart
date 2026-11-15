import 'package:pseudolearn_app/domain/model/exercises/user_exercise.dart';
import 'package:pseudolearn_app/domain/model/exercises/user_exercise_draft.dart';
import 'package:pseudolearn_app/domain/model/knowledge/ast_construct.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_case.dart';
import 'package:pseudolearn_app/domain/model/knowledge/expected_value_kind.dart';
import 'package:pseudolearn_app/domain/model/knowledge/structural_assertion.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';

const String sumSolution =
    'Algoritmo Suma\n  Definir a Como Entero;\n  Definir b Como Entero;\n  Leer a;\n  Leer b;\n  Escribir a + b;\nFinAlgoritmo\n';

const ExerciseCase sumCase = ExerciseCase(
  inputs: ['2', '3'],
  expectedOutputs: ['5'],
  expectedValueKind: ExpectedValueKind.numeric,
);

const ExerciseCase hiddenSumCase = ExerciseCase(
  inputs: ['10', '-4'],
  expectedOutputs: ['6'],
  expectedValueKind: ExpectedValueKind.numeric,
);

UserExerciseDraft sumDraft({
  String title = 'Suma de dos números',
  String narrative = 'Una tienda suma dos precios.',
  String statement = 'Lee dos enteros y escribe su suma.',
  String solution = sumSolution,
  List<ExerciseCase> visible = const [sumCase],
  List<ExerciseCase> hidden = const [hiddenSumCase],
  List<StructuralAssertion> assertions = const [],
}) => UserExerciseDraft(
  title: title,
  narrative: narrative,
  statement: statement,
  restrictions: const ['Sin bucles'],
  hints: const ['Usa Leer dos veces', 'Suma con +'],
  visibleCases: visible,
  hiddenCases: hidden,
  assertions: assertions,
  referenceSolution: solution,
  starterCode: 'Algoritmo Suma\nFinAlgoritmo\n',
  profileId: SyntaxProfileId.classicSpanish,
);

const StructuralAssertion loopForbidden = OmitsConstructAssertion(
  requirement: 'Sin bucles',
  construct: AstConstruct.conditionalLoop,
);

const StructuralAssertion loopRequired = ContainsConstructAssertion(
  requirement: 'Con un bucle',
  construct: AstConstruct.countedLoop,
);

UserExercise sumExercise({String id = 'ux-1', int revision = 1, DateTime? at}) {
  final time = at ?? DateTime.utc(2026, 11, 8, 9);
  return UserExercise(
    id: id,
    draft: sumDraft(),
    revision: revision,
    createdAt: time,
    updatedAt: time,
  );
}
