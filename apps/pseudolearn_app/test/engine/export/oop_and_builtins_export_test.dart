import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/export/export_result.dart';
import 'package:pseudolearn_app/domain/model/export/target_language_id.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/engine/export/core_program_exporter.dart';

const String _referenceOOP = '''
Clase Vehiculo
    Publico Definir marca Como Cadena
    Publico Definir velocidad Como Entero

    Metodo Constructor(m Como Cadena)
        Este.marca <- m
        Este.velocidad <- 0
    FinMetodo

    Metodo Acelerar(delta Como Entero)
        Este.velocidad <- Este.velocidad + delta
    FinMetodo

    Metodo Describir()
        Escribir Este.marca, " a ", Este.velocidad, " km/h"
    FinMetodo
FinClase

Clase Motocicleta Hereda De Vehiculo
    Publico Definir cilindrada Como Entero

    Metodo Constructor(m Como Cadena, cc Como Entero)
        Super.Constructor(m)
        Este.cilindrada <- cc
    FinMetodo

    Metodo Describir()
        Super.Describir()
        Escribir "(", Este.cilindrada, "cc)"
    FinMetodo
FinClase

Proceso PruebaVehiculos
    Definir moto Como Motocicleta
    moto <- Nuevo Motocicleta("Honda", 250)
    moto.Acelerar(75)
    moto.Describir()
FinProceso
''';

const String _builtinsProgram = '''
Proceso PruebaBuiltins
    Definir r Como Real
    Definir e Como Entero
    Definir t Como Cadena
    r <- rc(16)
    e <- redon(r)
    t <- ATexto(e)
    Escribir r, e, t
FinProceso
''';

void main() {
  final exporter = CoreProgramExporter();

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

    test('exports OOP reference program to Rust', () {
      final result = exporter.export(
        sourceCode: _referenceOOP,
        targetLanguage: TargetLanguageId.rust,
        profileId: SyntaxProfileId.classicSpanish,
      );

      expect(result, isA<ExportSuccess>());
      final success = result as ExportSuccess;
      final code = success.program.sourceCode;

      expect(code, contains('struct Vehiculo {'));
      expect(code, contains('pub marca: String,'));
      expect(code, contains('pub velocidad: i64,'));
      expect(code, contains('struct Motocicleta {'));
      expect(code, contains('pub base: Vehiculo,'));
      expect(code, contains('pub cilindrada: i64,'));
      expect(code, contains('impl Vehiculo {'));
      expect(code, contains('pub fn new(m: String) -> Self'));
      expect(code, contains('pub fn Acelerar(&mut self, delta: i64)'));
      expect(code, contains('impl Motocicleta {'));
      expect(code, contains('Motocicleta::new('));
      expect(code, contains('moto.Acelerar(75);'));
      expect(code, contains('moto.Describir();'));
    });

    test('exports builtin functions and imports math in Python', () {
      final result = exporter.export(
        sourceCode: _builtinsProgram,
        targetLanguage: TargetLanguageId.python,
        profileId: SyntaxProfileId.classicSpanish,
      );

      expect(result, isA<ExportSuccess>());
      final success = result as ExportSuccess;
      final code = success.program.sourceCode;

      expect(code, contains('import math'));
      expect(code, contains('math.sqrt(16)'));
      expect(code, contains('round(r)'));
      expect(code, contains('str(e)'));
    });

    test('exports builtin functions in Rust', () {
      final result = exporter.export(
        sourceCode: _builtinsProgram,
        targetLanguage: TargetLanguageId.rust,
        profileId: SyntaxProfileId.classicSpanish,
      );

      expect(result, isA<ExportSuccess>());
      final success = result as ExportSuccess;
      final code = success.program.sourceCode;

      expect(code, contains('(16 as f64).sqrt()'));
      expect(code, contains('(r as f64).round()'));
      expect(code, contains('format!("{}", e)'));
    });
  });
}
