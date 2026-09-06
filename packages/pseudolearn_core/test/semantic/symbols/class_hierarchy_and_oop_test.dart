import 'package:pseudolearn_core/src/domain/diagnostic_code.dart';
import 'package:pseudolearn_core/src/domain/profile/profiles/classic_spanish_profile.dart';
import 'package:pseudolearn_core/src/semantic/symbols/name_resolver.dart';
import 'package:pseudolearn_core/src/syntax/ast/ast_node.dart';
import 'package:pseudolearn_core/src/syntax/lexer/lexer.dart';
import 'package:pseudolearn_core/src/syntax/parser/parser.dart';
import 'package:pseudolearn_core/src/syntax/parser/token_stream.dart';
import 'package:test/test.dart';

void main() {
  const profile = ClassicSpanishProfile.strict();

  SourceUnitNode parseSource(String source) {
    final tokens = Lexer(profile).tokenize(source).tokens;
    final parseResult = Parser().parse(TokenStream(tokens));
    return parseResult.program!;
  }

  group('Circular inheritance and superclass resolution', () {
    test('reports circularInheritance on direct cycle A -> B -> A', () {
      const source = '''
Clase A HeredaDe B
FinClase

Clase B HeredaDe A
FinClase

Algoritmo Principal
FinAlgoritmo
''';
      final ast = parseSource(source);
      final result = const NameResolver(profile: profile).resolve(ast);

      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.circularInheritance),
      );
    });

    test('reports circularInheritance on indirect cycle A -> B -> C -> A', () {
      const source = '''
Clase A HeredaDe B
FinClase

Clase B HeredaDe C
FinClase

Clase C HeredaDe A
FinClase

Algoritmo Principal
FinAlgoritmo
''';
      final ast = parseSource(source);
      final result = const NameResolver(profile: profile).resolve(ast);

      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.circularInheritance),
      );
    });

    test('reports undeclaredSuperclass when superclass is missing', () {
      const source = '''
Clase Hijo HeredaDe PadreInexistente
FinClase

Algoritmo Principal
FinAlgoritmo
''';
      final ast = parseSource(source);
      final result = const NameResolver(profile: profile).resolve(ast);

      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.undeclaredSuperclass),
      );
    });
  });

  group('Member shadowing and override validation', () {
    test(
        'reports inheritedAttributeShadowed when field has same name as superclass field',
        () {
      const source = '''
Clase Padre
  Publico:
    Definir x Como Entero
FinClase

Clase Hijo HeredaDe Padre
  Publico:
    Definir x Como Entero
FinClase

Algoritmo Principal
FinAlgoritmo
''';
      final ast = parseSource(source);
      final result = const NameResolver(profile: profile).resolve(ast);

      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.inheritedAttributeShadowed),
      );
    });

    test('reports incompatibleMethodOverride when parameter counts differ', () {
      const source = '''
Clase Base
  Metodo Operar(a Como Entero)
  FinMetodo
FinClase

Clase Derivada HeredaDe Base
  Metodo Operar(a Como Entero, b Como Entero)
  FinMetodo
FinClase

Algoritmo Principal
FinAlgoritmo
''';
      final ast = parseSource(source);
      final result = const NameResolver(profile: profile).resolve(ast);

      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.incompatibleMethodOverride),
      );
    });

    test('accepts compatible method override with identical signature', () {
      const source = '''
Clase Base
  Metodo Operar(a Como Entero) Como Entero
    Retornar a
  FinMetodo
FinClase

Clase Derivada HeredaDe Base
  Metodo Operar(a Como Entero) Como Entero
    Retornar a * 2
  FinMetodo
FinClase

Algoritmo Principal
FinAlgoritmo
''';
      final ast = parseSource(source);
      final result = const NameResolver(profile: profile).resolve(ast);

      expect(
        result.diagnostics
            .where((d) => d.code == DiagnosticCode.incompatibleMethodOverride),
        isEmpty,
      );
    });
  });

  group('Constructor and Superconstructor checks', () {
    test(
        'reports missingSuperConstructorCall when superclass has parameters and call is missing',
        () {
      const source = '''
Clase Base
  Metodo Constructor(id Como Entero)
  FinMetodo
FinClase

Clase Derivada HeredaDe Base
  Metodo Constructor()
  FinMetodo
FinClase

Algoritmo Principal
FinAlgoritmo
''';
      final ast = parseSource(source);
      final result = const NameResolver(profile: profile).resolve(ast);

      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.missingSuperConstructorCall),
      );
    });

    test(
        'reports invalidSuperConstructorCallPosition when super call is not first statement',
        () {
      const source = '''
Clase Base
  Metodo Constructor(id Como Entero)
  FinMetodo
FinClase

Clase Derivada HeredaDe Base
  Metodo Constructor(id Como Entero)
    Definir x Como Entero
    x <- 1
    Super.Constructor(id)
  FinMetodo
FinClase

Algoritmo Principal
FinAlgoritmo
''';
      final ast = parseSource(source);
      final result = const NameResolver(profile: profile).resolve(ast);

      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.invalidSuperConstructorCallPosition),
      );
    });

    test(
        'reports returnWithValueInConstructor when constructor returns expression',
        () {
      const source = '''
Clase Caja
  Metodo Constructor()
    Retornar 10
  FinMetodo
FinClase

Algoritmo Principal
FinAlgoritmo
''';
      final ast = parseSource(source);
      final result = const NameResolver(profile: profile).resolve(ast);

      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.returnWithValueInConstructor),
      );
    });
  });

  group('Mandatory Este. Field Access (11.6)', () {
    test(
        'reports identifierMatchesFieldWithoutThis when accessing field without Este.',
        () {
      const source = '''
Clase Cuenta
  Publico:
    Definir saldo Como Entero

  Metodo Consultar()
    Escribir saldo
  FinMetodo
FinClase

Algoritmo Principal
FinAlgoritmo
''';
      final ast = parseSource(source);
      final result = const NameResolver(profile: profile).resolve(ast);

      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.identifierMatchesFieldWithoutThis),
      );
    });

    test('accepts explicit Este.saldo access', () {
      const source = '''
Clase Cuenta
  Publico:
    Definir saldo Como Entero

  Metodo Consultar()
    Escribir Este.saldo
  FinMetodo
FinClase

Algoritmo Principal
FinAlgoritmo
''';
      final ast = parseSource(source);
      final result = const NameResolver(profile: profile).resolve(ast);

      expect(
        result.diagnostics.where(
            (d) => d.code == DiagnosticCode.identifierMatchesFieldWithoutThis),
        isEmpty,
      );
    });

    test('reports undefinedMember on non-existent Este member access', () {
      const source = '''
Clase Cuenta
  Metodo Consultar()
    Escribir Este.noExiste
  FinMetodo
FinClase

Algoritmo Principal
FinAlgoritmo
''';
      final ast = parseSource(source);
      final result = const NameResolver(profile: profile).resolve(ast);

      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.undefinedMember),
      );
    });
  });
}
