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
  group('Class Parser - Unhappy Paths and Error Recovery', () {
    test('reports expectedClassName when name is missing', () {
      final result = _parse('''
Clase
FinClase

Proceso Principal
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.expectedClassName),
      );
    });

    test('reports unclosedClass when FinClase is missing at EOF', () {
      final result = _parse('''
Clase Incompleta
  Definir x Como Entero
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.unclosedClass),
      );
    });

    test(
        'reports multipleInheritanceNotSupported when multiple superclasses provided',
        () {
      final result = _parse('''
Clase C Hereda De A, B
FinClase

Proceso Principal
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.multipleInheritanceNotSupported),
      );
    });

    test('reports subroutineInsideClass when SubProceso is inside class', () {
      final result = _parse('''
Clase C
  SubProceso F()
  FinSubProceso
FinClase

Proceso Principal
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.subroutineInsideClass),
      );
    });

    test('reports nestedClassNotSupported when class is inside another class',
        () {
      final result = _parse('''
Clase Externa
  Clase Interna
  FinClase
FinClase

Proceso Principal
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.nestedClassNotSupported),
      );
    });

    test('reports classInsideAlgorithm when class is inside algorithm body',
        () {
      final result = _parse('''
Proceso Principal
  Clase C
  FinClase
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.classInsideAlgorithm),
      );
    });

    test('reports classInsideSubroutine when class is inside subroutine body',
        () {
      final result = _parse('''
SubProceso S()
  Clase C
  FinClase
FinSubProceso

Proceso Principal
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.classInsideSubroutine),
      );
    });

    test('reports duplicateVisibilityModifier when multiple modifiers given',
        () {
      final result = _parse('''
Clase C
  Publico Privado Definir x Como Entero
FinClase

Proceso Principal
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.duplicateVisibilityModifier),
      );
    });

    test(
        'reports constructorVisibilityNotAllowed when constructor has visibility',
        () {
      final result = _parse('''
Clase C
  Publico Metodo Constructor()
  FinMetodo
FinClase

Proceso Principal
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.constructorVisibilityNotAllowed),
      );
    });

    test(
        'reports constructorReturnTypeNotAllowed when constructor has return type',
        () {
      final result = _parse('''
Clase C
  Metodo Constructor() Como Entero
  FinMetodo
FinClase

Proceso Principal
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.constructorReturnTypeNotAllowed),
      );
    });

    test('reports duplicateConstructor when multiple constructors declared',
        () {
      final result = _parse('''
Clase C
  Metodo Constructor()
  FinMetodo
  Metodo Constructor(x Como Entero)
  FinMetodo
FinClase

Proceso Principal
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.duplicateConstructor),
      );
    });

    test('reports methodNamedAsClass when method has same name as class', () {
      final result = _parse('''
Clase Persona
  Metodo Persona()
  FinMetodo
FinClase

Proceso Principal
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.methodNamedAsClass),
      );
    });

    test('reports unclosedMethod when FinMetodo is missing', () {
      final result = _parse('''
Clase C
  Metodo Saludar()
    Escribir "Hola"
FinClase

Proceso Principal
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.unclosedMethod),
      );
    });

    test('reports methodOutsideClass when method is declared in algorithm', () {
      final result = _parse('''
Proceso Principal
  Metodo Saludar()
  FinMetodo
FinProceso
''');
      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.methodOutsideClass),
      );
    });
  });
}
