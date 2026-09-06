import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/engine/printing/pseudocode_printer.dart';
import 'package:pseudolearn_core/pseudolearn_core.dart';

ParseResult _parse(String source, LanguageProfile profile) {
  final lexer = Lexer(profile);
  final lexerResult = lexer.tokenize(source);
  final stream = TokenStream(lexerResult.tokens);
  final parser = Parser(profile: profile);
  return parser.parse(stream);
}

void main() {
  const spanishProfile = ClassicSpanishProfile.flexible();
  const englishProfile = EnglishProfile.flexible();

  group('PseudocodePrinter - Expressions', () {
    final spanishPrinter = PseudocodePrinter(spanishProfile);
    final englishPrinter = PseudocodePrinter(englishProfile);

    test('prints literals and booleans in both profiles', () {
      final boolTrueNode = LiteralExpressionNode(
        id: const NodeId(1),
        span: Span.zero,
        type: PrimitiveType.boolean,
        value: true,
      );
      expect(spanishPrinter.expressionText(boolTrueNode), equals('Verdadero'));
      expect(englishPrinter.expressionText(boolTrueNode), equals('true'));

      final stringNode = LiteralExpressionNode(
        id: const NodeId(2),
        span: Span.zero,
        type: PrimitiveType.string,
        value: 'Hola',
      );
      expect(spanishPrinter.expressionText(stringNode), equals('"Hola"'));
    });

    test('prints OOP expressions', () {
      final thisNode = ThisExpressionNode(id: const NodeId(1), span: Span.zero);
      final superNode = SuperExpressionNode(id: const NodeId(2), span: Span.zero);
      expect(spanishPrinter.expressionText(thisNode), equals('Este'));
      expect(englishPrinter.expressionText(thisNode), equals('this'));
      expect(spanishPrinter.expressionText(superNode), equals('Super'));
      expect(englishPrinter.expressionText(superNode), equals('super'));
    });
  });

  group('PseudocodePrinter - Statements and Structure', () {
    final printer = PseudocodePrinter(spanishProfile);

    test('prints variable declarations and dimension statements', () {
      final parseResult = _parse('''
Algoritmo Test
  Definir a, b Como Entero
  Dimension matriz[10, 20] Como Real
FinAlgoritmo
''', spanishProfile);

      expect(parseResult.diagnostics, isEmpty);
      final unit = parseResult.program!;
      final printed = printer.printUnit(unit);

      expect(printed, contains('Proceso Test'));
      expect(printed, contains('  Definir a, b Como Entero'));
      expect(printed, contains('  Dimension matriz[10, 20] Como Real'));
      expect(printed, contains('FinProceso'));
    });

    test('prints control structures: if, while, repeat, for, switch', () {
      final parseResult = _parse('''
Algoritmo Control
  Si x > 0 Entonces
    Escribir "Positivo" Sin Saltar
  SiNo
    Escribir "Cero o Negativo"
  FinSi
  Mientras x > 0 Hacer
    x <- x - 1
  FinMientras
  Repetir
    x <- x + 1
  Hasta Que x = 10
  Para i <- 1 Hasta 5 Con Paso 1 Hacer
    Escribir i
  FinPara
  Segun x Hacer
    1, 2:
      Escribir "Uno o Dos"
    De Otro Modo:
      Escribir "Otro"
  FinSegun
FinAlgoritmo
''', spanishProfile);

      expect(parseResult.diagnostics, isEmpty);
      final printed = printer.printUnit(parseResult.program!);
      expect(printed, contains('Si x > 0 Entonces'));
      expect(printed, contains('SiNo'));
      expect(printed, contains('FinSi'));
      expect(printed, contains('Sin Saltar'));
      expect(printed, contains('Mientras x > 0 Hacer'));
      expect(printed, contains('FinMientras'));
      expect(printed, contains('Repetir'));
      expect(printed, contains('Hasta Que x = 10'));
      expect(printed, contains('Para i <- 1 Hasta 5 Con Paso 1 Hacer'));
      expect(printed, contains('FinPara'));
      expect(printed, contains('Segun x Hacer'));
      expect(printed, contains('  1, 2:'));
      expect(printed, contains('  De Otro Modo:'));
      expect(printed, contains('FinSegun'));
    });

    test('prints subroutines with parameter passing modes and array dimensions', () {
      final parseResult = _parse('''
SubProceso Modificar(v[] Como Entero, m[,] Como Real, n Como Entero Por Referencia) Como Entero
  n <- n + 1
  Retornar n
FinSubProceso

Algoritmo Main
FinAlgoritmo
''', spanishProfile);

      expect(parseResult.diagnostics, isEmpty);
      final printed = printer.printUnit(parseResult.program!);
      expect(
        printed,
        contains('SubProceso Modificar(v[] Como Entero, m[,] Como Real, n Como Entero Por Referencia) Como Entero'),
      );
      expect(printed, contains('  n <- n + 1'));
      expect(printed, contains('  Retornar n'));
      expect(printed, contains('FinSubProceso'));
    });

    test('prints classes with inheritance, visibility, fields, methods and constructor', () {
      final parseResult = _parse('''
Clase Persona
  Publico Definir nombre Como Cadena
  Privado Definir edad Como Entero

  Metodo Constructor(n Como Cadena, e Como Entero)
    Este.nombre <- n
    Este.edad <- e
  FinMetodo

  Publico Metodo ObtenerEdad() Como Entero
    Retornar Este.edad
  FinMetodo
FinClase

Clase Estudiante Hereda De Persona
FinClase

Algoritmo Main
FinAlgoritmo
''', spanishProfile);

      expect(parseResult.diagnostics, isEmpty);
      final printed = printer.printUnit(parseResult.program!);
      expect(printed, contains('Clase Persona'));
      expect(printed, contains('  Definir nombre Como Cadena'));
      expect(printed, contains('  Privado Definir edad Como Entero'));
      expect(printed, contains('  Metodo Constructor(n Como Cadena, e Como Entero)'));
      expect(printed, contains('  Metodo ObtenerEdad() Como Entero'));
      expect(printed, contains('FinClase'));
      expect(printed, contains('Clase Estudiante Hereda De Persona'));
    });
  });

  group('PseudocodePrinter - Roundtrip & Cross-profile', () {
    const spanishSource = '''
Clase Contador
  Definir valor Como Entero

  Metodo Constructor(inicio Como Entero)
    Este.valor <- inicio
  FinMetodo

  Metodo Incrementar(paso Como Entero)
    Este.valor <- Este.valor + paso
  FinMetodo

  Metodo Obtener() Como Entero
    Retornar Este.valor
  FinMetodo
FinClase

SubProceso Factorial(n Como Entero) Como Entero
  Si n <= 1 Entonces
    Retornar 1
  SiNo
    Retornar n * Factorial(n - 1)
  FinSi
FinSubProceso

Algoritmo Principal
  Definir c Como Contador
  c <- Nuevo Contador(10)
  c.Incrementar(5)
  Definir f Como Entero
  f <- Factorial(5)
  Dimension arr[3] Como Entero
  Definir i Como Entero
  Para i <- 0 Hasta 2 Con Paso 1 Hacer
    arr[i] <- (i + 1) * 10
  FinPara
  Escribir "Contador: ", c.Obtener()
  Escribir "Factorial: ", f
FinAlgoritmo
''';

    test('same-profile roundtrip (Spanish -> Spanish)', () {
      final r1 = _parse(spanishSource, spanishProfile);
      expect(r1.diagnostics, isEmpty);
      final unit1 = r1.program!;

      final spanishPrinter = PseudocodePrinter(spanishProfile);
      final printedSpanish = spanishPrinter.printUnit(unit1);

      final r2 = _parse(printedSpanish, spanishProfile);
      expect(r2.diagnostics, isEmpty);
      final unit2 = r2.program!;

      expect(unit2.classes.length, equals(unit1.classes.length));
      expect(unit2.classes.first.name, equals(unit1.classes.first.name));
      expect(unit2.classes.first.members.length, equals(unit1.classes.first.members.length));
      expect(unit2.subroutines.length, equals(unit1.subroutines.length));
      expect(unit2.subroutines.first.name, equals(unit1.subroutines.first.name));
      expect(unit2.algorithm!.name, equals(unit1.algorithm!.name));
      expect(unit2.algorithm!.body.length, equals(unit1.algorithm!.body.length));
    });

    test('cross-profile roundtrip (Spanish -> English -> Spanish)', () {
      final rSpanish = _parse(spanishSource, spanishProfile);
      expect(rSpanish.diagnostics, isEmpty);

      final englishPrinter = PseudocodePrinter(englishProfile);
      final printedEnglish = englishPrinter.printUnit(rSpanish.program!);

      expect(printedEnglish, contains('class Contador'));
      expect(printedEnglish, contains('define valor as integer'));
      expect(printedEnglish, contains('subroutine Factorial(n as integer) as integer'));
      expect(printedEnglish, contains('algorithm Principal'));
      expect(printedEnglish, contains('endAlgorithm'));

      final rEnglish = _parse(printedEnglish, englishProfile);
      expect(rEnglish.diagnostics, isEmpty);
      final unitEng = rEnglish.program!;

      expect(unitEng.classes.length, equals(1));
      expect(unitEng.classes.first.name, equals('Contador'));
      expect(unitEng.subroutines.length, equals(1));
      expect(unitEng.subroutines.first.name, equals('Factorial'));
      expect(unitEng.algorithm!.name, equals('Principal'));

      final spanishPrinter = PseudocodePrinter(spanishProfile);
      final printedBack = spanishPrinter.printUnit(unitEng);
      final rBack = _parse(printedBack, spanishProfile);
      expect(rBack.diagnostics, isEmpty);
    });

    test('edge cases: empty program and 0-parameter subroutine', () {
      final emptyResult = _parse('Algoritmo Vacio\nFinAlgoritmo', spanishProfile);
      expect(emptyResult.diagnostics, isEmpty);

      final spanishPrinter = PseudocodePrinter(spanishProfile);
      final printedEmpty = spanishPrinter.printUnit(emptyResult.program!);
      expect(printedEmpty.trim(), equals('Proceso Vacio\nFinProceso'));

      final subResult = _parse('SubProceso Saludar()\nFinSubProceso\n\nAlgoritmo Main\nFinAlgoritmo', spanishProfile);
      expect(subResult.diagnostics, isEmpty);
      final printedSub = spanishPrinter.printUnit(subResult.program!);
      expect(printedSub, contains('SubProceso Saludar()\nFinSubProceso'));
    });
  });
}
