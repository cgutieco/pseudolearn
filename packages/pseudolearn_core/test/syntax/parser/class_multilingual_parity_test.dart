import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

void main() {
  group('Class Declaration Multilingual Parity', () {
    test(
        'parses equivalent class hierarchies with fields, methods and constructor in Spanish and English',
        () {
      final spanishSource = '''
Clase Persona
  Publico Definir nombre Como Cadena
  Privado Definir edad Como Entero

  Metodo Constructor(n Como Cadena, e Como Entero)
    nombre <- n
    edad <- e
  FinMetodo

  Publico Metodo ObtenerEdad() Como Entero
    Retornar edad
  FinMetodo
FinClase

Clase Empleado Hereda De Persona
  Privado Definir salario Como Real

  Metodo Constructor(n Como Cadena, e Como Entero, s Como Real)
    salario <- s
  FinMetodo
FinClase

Proceso Principal
FinProceso
''';

      final englishSource = '''
class Persona
  public define nombre as string;
  private define edad as integer;

  method constructor(n as string, e as integer)
    nombre <- n;
    edad <- e;
  endMethod

  public method ObtenerEdad() as integer
    return edad;
  endMethod
endClass

class Empleado inherits from Persona
  private define salario as real;

  method constructor(n as string, e as integer, s as real)
    salario <- s;
  endMethod
endClass

algorithm Principal
endAlgorithm
''';

      final esLexer = Lexer(const ClassicSpanishProfile.flexible());
      final esStream = TokenStream(esLexer.tokenize(spanishSource).tokens);
      final esResult = Parser(profile: const ClassicSpanishProfile.flexible())
          .parse(esStream);

      final enLexer = Lexer(const EnglishProfile.flexible());
      final enStream = TokenStream(enLexer.tokenize(englishSource).tokens);
      final enResult =
          Parser(profile: const EnglishProfile.flexible()).parse(enStream);

      expect(esResult.diagnostics, isEmpty);
      expect(enResult.diagnostics, isEmpty);

      final esUnit = esResult.program!;
      final enUnit = enResult.program!;

      expect(esUnit.classes.length, equals(enUnit.classes.length));
      expect(esUnit.classes[0].name, equals(enUnit.classes[0].name));
      expect(esUnit.classes[0].members.length,
          equals(enUnit.classes[0].members.length));
      expect(esUnit.classes[1].name, equals(enUnit.classes[1].name));
      expect(esUnit.classes[1].superclassName,
          equals(enUnit.classes[1].superclassName));
      expect(esUnit.classes[1].members.length,
          equals(enUnit.classes[1].members.length));
    });
  });
}
