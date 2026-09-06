import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/diagram/class_model.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/engine/analysis/analysis_cache.dart';
import 'package:pseudolearn_app/engine/classdiagram/class_model_extractor.dart';
import 'package:pseudolearn_app/engine/classdiagram/member_signature_printer.dart';

const String _spanishTail =
    '\nProceso Principal\n    Definir n Como Entero\nFinProceso\n';

const String _englishTail =
    '\nalgorithm Main\n    define n as integer;\nendAlgorithm\n';

ClassModel _modelOf(String body, SyntaxProfileId profileId) {
  final tail =
      profileId == SyntaxProfileId.english ? _englishTail : _spanishTail;
  final analysis = AnalysisCache().of('$body$tail', profileId);
  return ClassModelExtractor(MemberSignaturePrinter(analysis.profile))
      .of(analysis.sourceUnit);
}

List<String> _methodsOf(String body, SyntaxProfileId profileId) =>
    [for (final row in _modelOf(body, profileId).classes.first.methods) row.text];

List<String> _attributesOf(String body, SyntaxProfileId profileId) => [
      for (final row in _modelOf(body, profileId).classes.first.attributes)
        row.text,
    ];

void main() {
  group('MemberSignaturePrinter', () {
    test('prints a method without parameters', () {
      final methods = _methodsOf(
        'Clase C\n'
        '    Publico Metodo Ejecutar()\n'
        '        Definir a Como Entero\n'
        '    FinMetodo\n'
        'FinClase\n',
        SyntaxProfileId.classicSpanish,
      );

      expect(methods.single, 'Ejecutar()');
    });

    test('prints a method with one parameter and a return type', () {
      final methods = _methodsOf(
        'Clase C\n'
        '    Publico Metodo Doble(n Como Entero) Como Entero\n'
        '        Retornar n\n'
        '    FinMetodo\n'
        'FinClase\n',
        SyntaxProfileId.classicSpanish,
      );

      expect(methods.single, 'Doble(n: Entero): Entero');
    });

    test('prints a method with several parameters', () {
      final methods = _methodsOf(
        'Clase C\n'
        '    Publico Metodo Sumar(a Como Entero, b Como Real) Como Real\n'
        '        Retornar b\n'
        '    FinMetodo\n'
        'FinClase\n',
        SyntaxProfileId.classicSpanish,
      );

      expect(methods.single, 'Sumar(a: Entero, b: Real): Real');
    });

    test('prints a procedure without a return type', () {
      final methods = _methodsOf(
        'Clase C\n'
        '    Publico Metodo Presentar(mensaje Como Cadena)\n'
        '        Escribir mensaje\n'
        '    FinMetodo\n'
        'FinClase\n',
        SyntaxProfileId.classicSpanish,
      );

      expect(methods.single, 'Presentar(mensaje: Cadena)');
    });

    test('prints a parameter without a declared type as its name alone', () {
      final methods = _methodsOf(
        'Clase C\n'
        '    Publico Metodo Presentar(algo)\n'
        '        Escribir algo\n'
        '    FinMetodo\n'
        'FinClase\n',
        SyntaxProfileId.classicSpanish,
      );

      expect(methods.single, 'Presentar(algo)');
    });

    test('names the constructor with the lexeme of the profile', () {
      final spanish = _methodsOf(
        'Clase C\n'
        '    Metodo Constructor(n Como Entero)\n'
        '        Definir a Como Entero\n'
        '    FinMetodo\n'
        'FinClase\n',
        SyntaxProfileId.classicSpanish,
      );
      final english = _methodsOf(
        'class C\n'
        '    method Constructor(n as integer)\n'
        '        define a as integer;\n'
        '    endMethod\n'
        'endClass\n',
        SyntaxProfileId.english,
      );

      expect(spanish.single, 'Constructor(n: Entero)');
      expect(english.single, 'constructor(n: integer)');
    });

    test('marks every dimension of an array attribute', () {
      final attributes = _attributesOf(
        'Clase C\n'
        '    Publico Dimension tabla[3,4] Como Entero\n'
        'FinClase\n',
        SyntaxProfileId.classicSpanish,
      );

      expect(attributes.single, 'tabla: Entero[][]');
    });

    test('prints one row per name of a multiple declaration', () {
      final attributes = _attributesOf(
        'Clase C\n'
        '    Publico Definir alto, ancho Como Entero\n'
        'FinClase\n',
        SyntaxProfileId.classicSpanish,
      );

      expect(attributes, ['alto: Entero', 'ancho: Entero']);
    });

    test('prints an attribute whose type is another declared class', () {
      final attributes = _attributesOf(
        'Clase C\n'
        '    Publico Definir motor Como Motor\n'
        'FinClase\n'
        '\n'
        'Clase Motor\n'
        '    Publico Definir potencia Como Entero\n'
        'FinClase\n',
        SyntaxProfileId.classicSpanish,
      );

      expect(attributes.single, 'motor: Motor');
    });
  });
}
