import 'package:pseudolearn_core/src/domain/diagnostic_code.dart';
import 'package:pseudolearn_core/src/domain/profile/language_profile.dart';
import 'package:pseudolearn_core/src/domain/profile/profiles/classic_spanish_profile.dart';
import 'package:pseudolearn_core/src/syntax/ast/ast_node.dart';
import 'package:pseudolearn_core/src/syntax/lexer/lexer.dart';
import 'package:pseudolearn_core/src/syntax/parser/parse_result.dart';
import 'package:pseudolearn_core/src/syntax/parser/parser.dart';
import 'package:pseudolearn_core/src/syntax/parser/token_stream.dart';
import 'package:test/test.dart';

ParseResult parseProgram(
  String source, {
  LanguageProfile profile = const ClassicSpanishProfile.flexible(),
}) {
  final lexer = Lexer(profile);
  final lexerResult = lexer.tokenize(source);
  final stream = TokenStream(lexerResult.tokens);
  final parser = Parser(profile: profile);
  return parser.parse(stream);
}

void main() {
  group('ControlStatementParser - If statements', () {
    test('parses simple if statement', () {
      final result = parseProgram('''
Proceso Test
  Si x > 0 Entonces
    Escribir "Positivo"
  FinSi
FinProceso
''');
      expect(result.diagnostics, isEmpty);
      final ifStmt = result.program!.algorithm!.body.first as IfStatementNode;
      expect(ifStmt.condition, isA<BinaryExpressionNode>());
      expect(ifStmt.thenBody.length, equals(1));
      expect(ifStmt.elseBody, isNull);
    });

    test('parses if-else statement', () {
      final result = parseProgram('''
Proceso Test
  Si x > 0 Entonces
    Escribir "Positivo"
  Sino
    Escribir "No positivo"
  FinSi
FinProceso
''');
      expect(result.diagnostics, isEmpty);
      final ifStmt = result.program!.algorithm!.body.first as IfStatementNode;
      expect(ifStmt.thenBody.length, equals(1));
      expect(ifStmt.elseBody?.length, equals(1));
    });

    test('reports missing then keyword', () {
      final result = parseProgram('''
Proceso Test
  Si x > 0
    Escribir "Positivo"
  FinSi
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.expectedThenKeyword),
      );
    });

    test('reports duplicate else clause', () {
      final result = parseProgram('''
Proceso Test
  Si x > 0 Entonces
    Escribir "A"
  Sino
    Escribir "B"
  Sino
    Escribir "C"
  FinSi
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.duplicateElseClause),
      );
    });

    test('reports unclosed if statement at EOF with relatedSpan', () {
      final result = parseProgram('''
Proceso Test
  Si x > 0 Entonces
    Escribir "A"
FinProceso
''');
      final diag = result.diagnostics.firstWhere(
        (d) => d.code == DiagnosticCode.unclosedIfStatement,
      );
      expect(diag.relatedSpans, isNotEmpty);
    });
  });

  group('ControlStatementParser - Switch statements', () {
    test('parses switch statement with literal labels and default case', () {
      final result = parseProgram('''
Proceso Test
  Segun opct Hacer
    1:
      Escribir "Uno"
    2, 3:
      Escribir "Dos o Tres"
    De Otro Modo:
      Escribir "Otro"
  FinSegun
FinProceso
''');
      expect(result.diagnostics, isEmpty);
      final switchStmt =
          result.program!.algorithm!.body.first as SwitchStatementNode;
      expect(switchStmt.cases.length, equals(2));
      expect(switchStmt.defaultCase, isNotNull);
    });

    test('parses switch with signed integer labels', () {
      final result = parseProgram('''
Proceso Test
  Segun valor Hacer
    -1:
      Escribir "Negativo"
    +1:
      Escribir "Positivo"
  FinSegun
FinProceso
''');
      expect(result.diagnostics, isEmpty);
    });

    test('reports non-literal switch case label', () {
      final result = parseProgram('''
Proceso Test
  Segun valor Hacer
    x + 1:
      Escribir "Variable"
  FinSegun
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.nonLiteralSwitchCaseLabel),
      );
    });

    test('reports duplicate switch case label with relatedSpan', () {
      final result = parseProgram('''
Proceso Test
  Segun valor Hacer
    1:
      Escribir "Uno"
    1:
      Escribir "Uno repetido"
  FinSegun
FinProceso
''');
      final diag = result.diagnostics.firstWhere(
        (d) => d.code == DiagnosticCode.duplicateSwitchCaseLabel,
      );
      expect(diag.relatedSpans, isNotEmpty);
    });

    test('reports misplaced default case when not at the end', () {
      final result = parseProgram('''
Proceso Test
  Segun valor Hacer
    De Otro Modo:
      Escribir "Primero"
    1:
      Escribir "Uno"
  FinSegun
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.invalidDefaultCasePosition),
      );
    });

    test('reports missing branch separator', () {
      final result = parseProgram('''
Proceso Test
  Segun valor Hacer
    1
      Escribir "Uno"
  FinSegun
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.expectedBranchSeparator),
      );
    });
  });

  group('ControlStatementParser - While loops', () {
    test('parses while loop successfully', () {
      final result = parseProgram('''
Proceso Test
  Mientras x > 0 Hacer
    x <- x - 1
  FinMientras
FinProceso
''');
      expect(result.diagnostics, isEmpty);
      final whileStmt =
          result.program!.algorithm!.body.first as WhileStatementNode;
      expect(whileStmt.body.length, equals(1));
    });

    test('reports missing do keyword in while loop', () {
      final result = parseProgram('''
Proceso Test
  Mientras x > 0
    x <- x - 1
  FinMientras
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.expectedDoKeyword),
      );
    });
  });

  group('ControlStatementParser - Repeat loops', () {
    test('parses repeat until loop successfully', () {
      final result = parseProgram('''
Proceso Test
  Repetir
    x <- x + 1
  Hasta Que x = 10
FinProceso
''');
      expect(result.diagnostics, isEmpty);
      final repeatStmt =
          result.program!.algorithm!.body.first as RepeatUntilStatementNode;
      expect(repeatStmt.body.length, equals(1));
      expect(repeatStmt.condition, isA<BinaryExpressionNode>());
    });

    test('reports unclosed repeat statement when until is missing', () {
      final result = parseProgram('''
Proceso Test
  Repetir
    x <- x + 1
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.unclosedRepeatStatement),
      );
    });
  });

  group('ControlStatementParser - For loops', () {
    test('parses for loop with step clause', () {
      final result = parseProgram('''
Proceso Test
  Para i <- 1 Hasta 10 Con Paso 2 Hacer
    Escribir i
  FinPara
FinProceso
''');
      expect(result.diagnostics, isEmpty);
      final forStmt = result.program!.algorithm!.body.first as ForStatementNode;
      expect(forStmt.variable.name, equals('i'));
      expect(forStmt.step, isNotNull);
    });

    test('parses for loop without step clause in flexible profile', () {
      final result = parseProgram('''
Proceso Test
  Para i <- 1 Hasta 10 Hacer
    Escribir i
  FinPara
FinProceso
''');
      expect(result.diagnostics, isEmpty);
      final forStmt = result.program!.algorithm!.body.first as ForStatementNode;
      expect(forStmt.step, isNull);
    });

    test('reports missing step clause in strict profile', () {
      final result = parseProgram(
        '''
Proceso Test
  Para i <- 1 Hasta 10 Hacer;
    Escribir i;
  FinPara;
FinProceso
''',
        profile: const ClassicSpanishProfile.strict(),
      );
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.missingStepClause),
      );
    });

    test('reports expected loop variable error', () {
      final result = parseProgram('''
Proceso Test
  Para 10 <- 1 Hasta 10 Hacer
    Escribir "Error"
  FinPara
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.expectedForLoopVariable),
      );
    });
  });
}
