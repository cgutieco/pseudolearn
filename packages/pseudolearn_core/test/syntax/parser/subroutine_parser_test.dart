import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

ParseResult _parse(String source, {LanguageProfile? profile}) {
  final activeProfile = profile ?? const ClassicSpanishProfile.flexible();
  final lexer = Lexer(activeProfile);
  final result = lexer.tokenize(source);
  final stream = TokenStream(result.tokens);
  return Parser(profile: activeProfile).parse(stream);
}

void main() {
  group('Subroutine Parser - Happy paths', () {
    test('parses subroutine without parameters or return type', () {
      final result = _parse('''
SubProceso Saludar()
  Escribir "Hola"
FinSubProceso

Proceso Principal
  Saludar()
FinProceso
''');
      expect(result.diagnostics, isEmpty);
      expect(result.program, isNotNull);
      final unit = result.program!;
      expect(unit.subroutines, hasLength(1));
      expect(unit.subroutines.first.name, equals('Saludar'));
      expect(unit.subroutines.first.parameters, isEmpty);
      expect(unit.subroutines.first.returnType, isNull);
      expect(unit.subroutines.first.body, hasLength(1));
      expect(unit.algorithm!.name, equals('Principal'));
    });

    test('parses subroutine with multiple typed parameters and return type',
        () {
      final result = _parse('''
SubProceso Sumar(a Como Entero, b Como Entero) Como Entero
  Retornar a + b
FinSubProceso

Proceso Principal
  Definir total Como Entero
  total <- Sumar(3, 4)
FinProceso
''');
      expect(result.diagnostics, isEmpty);
      final sub = result.program!.subroutines.first;
      expect(sub.name, equals('Sumar'));
      expect(sub.parameters, hasLength(2));
      expect(sub.parameters[0].name, equals('a'));
      expect(sub.parameters[0].type, equals(PrimitiveType.integer));
      expect(
          sub.parameters[0].passingMode, equals(ParameterPassingMode.byValue));
      expect(sub.parameters[1].name, equals('b'));
      expect(sub.returnType, equals(PrimitiveType.integer));

      final returnStmt = sub.body.first as ReturnStatementNode;
      expect(returnStmt.value, isA<BinaryExpressionNode>());
    });

    test('parses explicit By Value and By Reference parameter modifiers', () {
      final result = _parse('''
SubProceso Intercambiar(a Como Entero Por Referencia, b Como Entero Por Valor)
  Definir aux Como Entero
  aux <- a
  a <- b
  b <- aux
FinSubProceso

Proceso Principal
FinProceso
''');
      expect(result.diagnostics, isEmpty);
      final params = result.program!.subroutines.first.parameters;
      expect(params[0].passingMode, equals(ParameterPassingMode.byReference));
      expect(params[1].passingMode, equals(ParameterPassingMode.byValue));
    });

    test('parses multidimensional array parameters (1D, 2D, 3D)', () {
      final result = _parse('''
SubProceso Procesar(v[] Como Entero, m[,] Como Real, c[,,] Como Logico)
FinSubProceso

Proceso Principal
FinProceso
''');
      expect(result.diagnostics, isEmpty);
      final params = result.program!.subroutines.first.parameters;
      expect(params[0].dimensionCount, equals(1));
      expect(params[1].dimensionCount, equals(2));
      expect(params[2].dimensionCount, equals(3));
    });

    test('parses subroutines before, after and intermixed with algorithm', () {
      final result = _parse('''
SubProceso Primero()
FinSubProceso

Proceso Principal
FinProceso

SubProceso Segundo()
FinSubProceso
''');
      expect(result.diagnostics, isEmpty);
      final unit = result.program!;
      expect(unit.declarations, hasLength(3));
      expect((unit.declarations[0] as SubroutineDeclarationNode).name,
          equals('Primero'));
      expect((unit.declarations[1] as AlgorithmNode).name, equals('Principal'));
      expect((unit.declarations[2] as SubroutineDeclarationNode).name,
          equals('Segundo'));
    });

    test('parses recursive subroutine declaration', () {
      final result = _parse('''
SubProceso Factorial(n Como Entero) Como Entero
  Si n <= 1 Entonces
    Retornar 1
  Sino
    Retornar n * Factorial(n - 1)
  FinSi
FinSubProceso

Proceso Principal
FinProceso
''');
      expect(result.diagnostics, isEmpty);
    });

    test('parses call statement and requires semicolon under strict profile',
        () {
      final result = _parse('''
SubProceso Saludar()
FinSubProceso

Proceso Principal
  Saludar();
FinProceso
''', profile: const ClassicSpanishProfile.strict());
      expect(result.diagnostics, isEmpty);
      final callStmt =
          result.program!.algorithm!.body.first as CallStatementNode;
      expect(callStmt.name, equals('Saludar'));
      expect(callStmt.arguments, isEmpty);
    });

    test('reports missing semicolon on call statement under strict profile',
        () {
      final result = _parse('''
SubProceso Saludar()
FinSubProceso

Proceso Principal
  Saludar()
FinProceso
''', profile: const ClassicSpanishProfile.strict());
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.missingStatementTerminator),
      );
    });

    test('parses empty return statement', () {
      final result = _parse('''
SubProceso SalirTemprano(cond Como Logico)
  Si cond Entonces
    Retornar
  FinSi
  Escribir "Continuando"
FinSubProceso

Proceso Principal
FinProceso
''');
      expect(result.diagnostics, isEmpty);
      final sub = result.program!.subroutines.first;
      final ifStmt = sub.body.first as IfStatementNode;
      final retStmt = ifStmt.thenBody.first as ReturnStatementNode;
      expect(retStmt.value, isNull);
    });
  });

  group('Subroutine Parser - Unhappy paths and edge cases', () {
    test(
        'reports unclosedSubroutine with related span when FinSubProceso missing',
        () {
      final result = _parse('''
SubProceso Saludar()
  Escribir "Hola"

Proceso Principal
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.unclosedSubroutine),
      );
      final diag = result.diagnostics.firstWhere(
        (d) => d.code == DiagnosticCode.unclosedSubroutine,
      );
      expect(diag.relatedSpans, hasLength(1));
    });

    test('reports expectedSubroutineName when name is missing', () {
      final result = _parse('''
SubProceso ()
FinSubProceso

Proceso Principal
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.expectedSubroutineName),
      );
    });

    test(
        'reports expectedSubroutineLeftParenthesis when parentheses omitted in header',
        () {
      final result = _parse('''
SubProceso Saludar
FinSubProceso

Proceso Principal
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.expectedSubroutineLeftParenthesis),
      );
    });

    test(
        'reports unclosedParenthesis when parameter closing parenthesis missing',
        () {
      final result = _parse('''
SubProceso Saludar(x Como Entero
FinSubProceso

Proceso Principal
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.unclosedParenthesis),
      );
    });

    test(
        'reports passingModifierBeforeParameterName when modifier precedes name',
        () {
      final result = _parse('''
SubProceso Test(Por Referencia x Como Entero)
FinSubProceso

Proceso Principal
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.passingModifierBeforeParameterName),
      );
    });

    test('reports duplicatePassingModifier when both modifiers specified', () {
      final result = _parse('''
SubProceso Test(x Como Entero Por Valor Por Referencia)
FinSubProceso

Proceso Principal
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.duplicatePassingModifier),
      );
    });

    test('reports invalidArrayReturnType when return type has bracket suffix',
        () {
      final result = _parse('''
SubProceso Test() Como Entero[]
FinSubProceso

Proceso Principal
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.invalidArrayReturnType),
      );
    });

    test(
        'reports subroutineInsideAlgorithm when subroutine declared in algorithm body',
        () {
      final result = _parse('''
Proceso Principal
  SubProceso Anidado()
  FinSubProceso
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.subroutineInsideAlgorithm),
      );
    });

    test(
        'reports subroutineInsideSubroutine when subroutine declared inside another',
        () {
      final result = _parse('''
SubProceso Padre()
  SubProceso Hijo()
  FinSubProceso
FinSubProceso

Proceso Principal
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.subroutineInsideSubroutine),
      );
    });

    test('reports returnOutsideSubroutine when return used in algorithm body',
        () {
      final result = _parse('''
Proceso Principal
  Retornar 42
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.returnOutsideSubroutine),
      );
    });

    test('reports multipleAlgorithms when more than one algorithm exists', () {
      final result = _parse('''
Proceso Primero
FinProceso

Proceso Segundo
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.multipleAlgorithms),
      );
    });

    test('reports expectedAlgorithmStart when only subroutines exist', () {
      final result = _parse('''
SubProceso Solo()
FinSubProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.expectedAlgorithmStart),
      );
    });

    test('reports trailingComma when parameter list has trailing comma', () {
      final result = _parse('''
SubProceso Test(a Como Entero,)
FinSubProceso

Proceso Principal
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.trailingComma),
      );
    });

    test('parses subroutine with single letter identifier', () {
      final result = _parse('''
SubProceso f(x Como Entero) Como Entero
  Retornar x
FinSubProceso

Proceso P
  f(1)
FinProceso
''');
      expect(result.diagnostics, isEmpty);
      expect(result.program!.subroutines.first.name, equals('f'));
    });
  });
}
