import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_case.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_check_outcome.dart';
import 'package:pseudolearn_app/domain/model/knowledge/expected_value_kind.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import '../fakes/native_test_engine.dart';

const String _networkProgram = '''
SubProceso Probe() Como Resultado<Cadena, ErrorES>
  Definir net Como RedCap <- Propagar SolicitarRed();
  Definir request Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, "http://127.0.0.1:9/").ConTiempoMaximo(1000);
  Definir response Como RespuestaHttp <- Propagar net.Enviar(request);
  Retornar response.CuerpoTexto();
FinSubProceso

Algoritmo Main
  Segun Probe() Hacer
    Exito(value): Escribir value;
    Error(problem): Escribir problem.Codigo;
  FinSegun
FinAlgoritmo
''';

const String _pureProgram = '''
Algoritmo Main
  Escribir 2 + 3;
FinAlgoritmo
''';

ExerciseCase _case(String expected) => ExerciseCase(
  inputs: const [],
  expectedOutputs: [expected],
  expectedValueKind: ExpectedValueKind.text,
);

void main() {
  tearDownAll(closeTestEngine);

  test('the exercise checker refuses network effects instead of performing them', () {
    final result = nativeTestEngine.exerciseChecker.check(
      sourceCode: _networkProgram,
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
      visibleCases: [_case('permiso_denegado')],
      hiddenCases: const [],
      assertions: const [],
    );

    expect(result.outcome, ExerciseCheckOutcome.allCasesPassed);
  });

  test('the exercise checker still judges a pure program', () {
    final result = nativeTestEngine.exerciseChecker.check(
      sourceCode: _pureProgram,
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
      visibleCases: [_case('5')],
      hiddenCases: const [],
      assertions: const [],
    );

    expect(result.outcome, ExerciseCheckOutcome.allCasesPassed);
  });

  test('a case that expects a real network answer does not pass', () {
    final result = nativeTestEngine.exerciseChecker.check(
      sourceCode: _networkProgram,
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
      visibleCases: [_case('conexion_fallida')],
      hiddenCases: const [],
      assertions: const [],
    );

    expect(result.outcome, isNot(ExerciseCheckOutcome.allCasesPassed));
  });
}
