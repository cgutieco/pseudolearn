import '../../../fakes/native_test_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/export/export_result.dart';
import 'package:pseudolearn_app/domain/model/export/target_language_id.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';

const String _referenceOOP = '''
Clase Vehiculo
    Publico Definir marca Como Cadena;
    Publico Definir velocidad Como Entero;

    Metodo Constructor(m Como Cadena)
        Este.marca <- m;
        Este.velocidad <- 0;
    FinMetodo

    Metodo Acelerar(delta Como Entero)
        Este.velocidad <- Este.velocidad + delta;
    FinMetodo

    Metodo Describir()
        Escribir Este.marca, " a ", Este.velocidad, " km/h";
    FinMetodo
FinClase

Clase Motocicleta Hereda De Vehiculo
    Publico Definir cilindrada Como Entero;

    Metodo Constructor(m Como Cadena, cc Como Entero)
        Super.Constructor(m);
        Este.cilindrada <- cc;
    FinMetodo

    Metodo Describir()
        Super.Describir();
        Escribir "(", Este.cilindrada, "cc)";
    FinMetodo
FinClase

Proceso PruebaVehiculos
    Definir moto Como Motocicleta <- Nuevo Motocicleta("Honda", 250);

    moto.Acelerar(75);
    moto.Describir();
FinProceso
''';

const String _builtinsProgram = '''
Proceso PruebaBuiltins
    Definir r Como Real <- 0.0;
    Definir e Como Entero <- 0;
    Definir t Como Cadena <- "";
    r <- rc(16);
    e <- redon(r);
    t <- ATexto(e);
    Escribir r, e, t;
FinProceso
''';

void main() {
  final exporter = nativeTestEngine.programExporter;

  group('OOP and Builtins Export Tests', () {
    test('exports OOP reference program to Python', () {
      final result = exporter.export(
        sourceCode: _referenceOOP,
        targetLanguage: TargetLanguageId.python,
        profileId: SyntaxProfileId.classicSpanish,
      );

      expect(result, isA<ExportSuccess>());
      final success = result as ExportSuccess;
      final code = success.program.sourceCode;

      expect(code, contains('class Vehiculo:'));
      expect(code, contains('def __init__(self, m):'));
      expect(code, contains('def Acelerar(self, delta):'));
      expect(code, contains('def Describir(self):'));
      expect(code, contains('class Motocicleta(Vehiculo):'));
      expect(code, contains('super().__init__(m)'));
      expect(code, contains('super().Describir()'));
      expect(code, contains('moto = Motocicleta("Honda", 250)'));
      expect(code, contains('moto.Acelerar(75)'));
      expect(code, contains('moto.Describir()'));
    });

    test('withholds the OOP reference program from Rust', () {
      final result = exporter.export(
        sourceCode: _referenceOOP,
        targetLanguage: TargetLanguageId.rust,
        profileId: SyntaxProfileId.classicSpanish,
      );

      expect(result, isA<ExportUnavailable>());
      final constructs = (result as ExportUnavailable).blockers.map(
        (blocker) => blocker.construct,
      );
      expect(constructs, containsAll(['class_unit', 'constructor_member']));
    });

    test('withholds a builtin without a proven equivalent from Python', () {
      final result = exporter.export(
        sourceCode: _builtinsProgram,
        targetLanguage: TargetLanguageId.python,
        profileId: SyntaxProfileId.classicSpanish,
      );

      expect(result, isA<ExportUnavailable>());
      final constructs = (result as ExportUnavailable).blockers.map(
        (blocker) => blocker.construct,
      );
      expect(constructs, contains('builtin:round'));
      expect(constructs, isNot(contains('builtin:squareRoot')));
    });

    test('exports the proven builtins in Python', () {
      const source = '''
Proceso PruebaBuiltins
    Definir r Como Real <- 0.0;
    Definir t Como Cadena <- "";
    r <- rc(16);
    t <- ATexto(3);
    Escribir r, t;
FinProceso
''';
      final result = exporter.export(
        sourceCode: source,
        targetLanguage: TargetLanguageId.python,
        profileId: SyntaxProfileId.classicSpanish,
      );

      expect(result, isA<ExportSuccess>());
      final code = (result as ExportSuccess).program.sourceCode;
      expect(code, contains('import math'));
      expect(code, contains('math.sqrt(16)'));
      expect(code, contains('str(3)'));
    });

    test('withholds real arithmetic and builtins from Rust', () {
      final result = exporter.export(
        sourceCode: _builtinsProgram,
        targetLanguage: TargetLanguageId.rust,
        profileId: SyntaxProfileId.classicSpanish,
      );

      expect(result, isA<ExportUnavailable>());
      final constructs = (result as ExportUnavailable).blockers.map(
        (blocker) => blocker.construct,
      );
      expect(
        constructs,
        containsAll(['type:real', 'literal:real', 'builtin:squareRoot']),
      );
    });
  });
}
