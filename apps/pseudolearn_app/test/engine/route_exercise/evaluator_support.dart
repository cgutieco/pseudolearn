import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/route/route_answer.dart';
import 'package:pseudolearn_app/domain/model/route/route_evaluation.dart';
import 'package:pseudolearn_app/domain/model/route/route_kinds.dart';
import 'package:pseudolearn_app/domain/model/route/route_verdict.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/domain/ports/route_answer_evaluator.dart';
import '../../fakes/route_fixtures.dart';

RouteVerdict verdictOf(
  RouteAnswerEvaluator evaluator,
  RouteEvaluation evaluation,
  RouteAnswer answer, {
  RouteExerciseKind kind = RouteExerciseKind.predict,
}) => evaluator.evaluate(
  exercise: sampleExercise('x', evaluation, kind: kind),
  answer: answer,
  profileId: SyntaxProfileId.classicSpanish,
  languageId: UiLanguageId.spanish,
);

const String sumProgram = '''
Algoritmo Suma
  Definir a, b Como Entero;
  Leer a;
  Leer b;
  Escribir a + b;
FinAlgoritmo
''';

const String productProgram = '''
Algoritmo Suma
  Definir a, b Como Entero;
  Leer a;
  Leer b;
  Escribir a * b;
FinAlgoritmo
''';

const String doubleProgram = '''
Algoritmo Suma
  Definir a, b Como Entero;
  Leer a;
  Leer b;
  Escribir a + a;
FinAlgoritmo
''';
