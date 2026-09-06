import 'package:pseudolearn_core/src/domain/diagnostic_code.dart';
import 'package:pseudolearn_core/src/domain/primitive_type.dart';
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
  group('StatementParser - Variable declarations', () {
    test('parses single variable declaration successfully', () {
      final result = parseProgram('''
Proceso Test
  Definir x Como Entero
FinProceso
''');
      expect(result.diagnostics, isEmpty);
      final body = result.program!.algorithm!.body;
      expect(body.length, equals(1));
      final decl = body.first as VariableDeclarationNode;
      expect(decl.type, equals(PrimitiveType.integer));
      expect(decl.variables.length, equals(1));
      expect(decl.variables.first.name, equals('x'));
    });

    test('parses multiple variable declarations in single statement', () {
      final result = parseProgram('''
Proceso Test
  Definir a, b, c Como Real
FinProceso
''');
      expect(result.diagnostics, isEmpty);
      final body = result.program!.algorithm!.body;
      final decl = body.first as VariableDeclarationNode;
      expect(decl.type, equals(PrimitiveType.real));
      expect(
          decl.variables.map((v) => v.name).toList(), equals(['a', 'b', 'c']));
    });

    test('reports trailing comma error in declaration', () {
      final result = parseProgram('''
Proceso Test
  Definir a, Como Entero
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.trailingComma),
      );
    });

    test('reports missing type connector in declaration', () {
      final result = parseProgram('''
Proceso Test
  Definir x Entero
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.expectedTypeConnector),
      );
    });

    test('reports prohibited initialization in declaration', () {
      final result = parseProgram('''
Proceso Test
  Definir x Como Entero <- 5
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.initializationInDeclarationNotAllowed),
      );
    });
  });

  group('StatementParser - Dimension declarations', () {
    test('parses single 1D array dimension statement', () {
      final result = parseProgram('''
Proceso Test
  Dimension lista[10] Como Entero
FinProceso
''');
      expect(result.diagnostics, isEmpty);
      final dim =
          result.program!.algorithm!.body.first as DimensionStatementNode;
      expect(dim.elementType, equals(PrimitiveType.integer));
      expect(dim.arrays.length, equals(1));
      expect(dim.arrays.first.name, equals('lista'));
      expect(dim.arrays.first.dimensions.length, equals(1));
    });

    test('parses multidimensional array dimension statement', () {
      final result = parseProgram('''
Proceso Test
  Dimension matriz[3, 4] Como Real
FinProceso
''');
      expect(result.diagnostics, isEmpty);
      final dim =
          result.program!.algorithm!.body.first as DimensionStatementNode;
      expect(dim.arrays.first.dimensions.length, equals(2));
    });

    test('reports empty dimension list error', () {
      final result = parseProgram('''
Proceso Test
  Dimension matriz[] Como Real
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.emptyDimensionList),
      );
    });
  });

  group('StatementParser - Assignment', () {
    test('parses simple variable assignment', () {
      final result = parseProgram('''
Proceso Test
  x <- 42 + 8
FinProceso
''');
      expect(result.diagnostics, isEmpty);
      final assign =
          result.program!.algorithm!.body.first as AssignmentStatementNode;
      expect((assign.target as VariableExpressionNode).name, equals('x'));
      expect(assign.value, isA<BinaryExpressionNode>());
    });

    test('parses array element assignment', () {
      final result = parseProgram('''
Proceso Test
  arr[1] <- 100
FinProceso
''');
      expect(result.diagnostics, isEmpty);
      final assign =
          result.program!.algorithm!.body.first as AssignmentStatementNode;
      expect(assign.target, isA<ArrayAccessExpressionNode>());
    });

    test('reports invalid assignment target when target is literal or expr',
        () {
      final result = parseProgram('''
Proceso Test
  (x + 1) <- 10
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.invalidAssignmentTarget),
      );
    });
  });

  group('StatementParser - IO Statements', () {
    test('parses read statement with multiple variables', () {
      final result = parseProgram('''
Proceso Test
  Leer a, b, c
FinProceso
''');
      expect(result.diagnostics, isEmpty);
      final read = result.program!.algorithm!.body.first as ReadStatementNode;
      expect(read.targets.length, equals(3));
    });

    test('reports invalid read target when target is an expression', () {
      final result = parseProgram('''
Proceso Test
  Leer (a + b)
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.invalidReadTarget),
      );
    });

    test('parses write statement with expressions and modifier', () {
      final result = parseProgram('''
Proceso Test
  Escribir "Total: ", x + z Sin Saltar
FinProceso
''');
      expect(result.diagnostics, isEmpty);
      final write = result.program!.algorithm!.body.first as WriteStatementNode;
      expect(write.withoutNewline, isTrue);
      expect(write.expressions.length, equals(2));
    });

    test('reports premature modifier position in write statement', () {
      final result = parseProgram('''
Proceso Test
  Escribir Sin Saltar "Hola"
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.unexpectedModifierPosition),
      );
    });
  });

  group('StatementParser - Rigor flags and unsupported constructs', () {
    test('reports missing statement terminator in strict profile', () {
      final result = parseProgram(
        '''
Proceso Test
  x <- 10
FinProceso
''',
        profile: const ClassicSpanishProfile.strict(),
      );
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.missingStatementTerminator),
      );
    });

    test('reports pedagogical diagnostic for unsupported jump construct', () {
      final result = parseProgram('''
Proceso Test
  romper
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.unsupportedStructuredConstruct),
      );
    });
  });
}
