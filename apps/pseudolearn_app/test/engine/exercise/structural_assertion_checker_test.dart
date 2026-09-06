import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/knowledge/ast_construct.dart';
import 'package:pseudolearn_app/domain/model/knowledge/member_visibility.dart';
import 'package:pseudolearn_app/domain/model/knowledge/structural_assertion.dart';
import 'package:pseudolearn_app/domain/model/knowledge/structural_assertion_kind.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/engine/exercise/structural_assertion_checker.dart';
import 'package:pseudolearn_app/engine/exercise/structural_assertions.dart';

const String _countedLoop = '''
Algoritmo Suma
  Definir i Como Entero
  Definir total Como Entero
  total <- 0
  Para i <- 1 Hasta 5 Con Paso 1 Hacer
    total <- total + i
  FinPara
  Escribir total
FinAlgoritmo
''';

const String _conditionalLoop = '''
Algoritmo Suma
  Definir i Como Entero
  Definir total Como Entero
  total <- 0
  i <- 1
  Mientras i <= 5 Hacer
    total <- total + i
    i <- i + 1
  FinMientras
  Escribir total
FinAlgoritmo
''';

const String _withSubprogram = '''
SubProceso Doble(n Como Entero) Como Entero
  Retornar n * 2
FinSubProceso

Algoritmo Principal
  Definir x Como Entero
  x <- Doble(4)
  Escribir x
FinAlgoritmo
''';

const String _withClass = '''
Clase Cuenta
  Privado Definir saldo Como Real
  Publico Definir titular Como Cadena

  Metodo Constructor()
    Este.saldo <- 0
  FinMetodo

  Publico Metodo Depositar(monto Como Real)
    Este.saldo <- Este.saldo + monto
  FinMetodo
FinClase

Algoritmo Principal
  Definir c Como Cuenta
  c <- Nuevo Cuenta()
  c.Depositar(10)
FinAlgoritmo
''';

const String _threeConditionals = '''
Algoritmo Tres
  Definir n Como Entero
  n <- 1
  Si n > 0 Entonces
    Escribir 1
  FinSi
  Si n > 1 Entonces
    Escribir 2
  FinSi
  Si n > 2 Entonces
    Escribir 3
  FinSi
FinAlgoritmo
''';

const String _empty = '''
Algoritmo Vacio
FinAlgoritmo
''';

const String _oneStatement = '''
Algoritmo Uno
  Escribir 1
FinAlgoritmo
''';

const String _doesNotParse = '''
Algoritmo Roto
  Definir Como Entero
FinAlgoritmo
''';

const _usesCountedLoop = ContainsConstructAssertion(
  requirement: 'El enunciado pedia resolverlo con un bucle contado.',
  construct: AstConstruct.countedLoop,
);

List<StructuralAssertion> _unmet(
  String sourceCode,
  List<StructuralAssertion> assertions,
) {
  return StructuralAssertionChecker().unmetAssertions(
    sourceCode: sourceCode,
    profileId: SyntaxProfileId.classicSpanish,
    assertions: assertions,
  );
}

void main() {
  group('contains a construct', () {
    test('a counted loop satisfies the assertion', () {
      expect(_unmet(_countedLoop, const [_usesCountedLoop]), isEmpty);
    });

    test('a conditional loop does not, and the requirement is what is reported', () {
      final unmet = _unmet(_conditionalLoop, const [_usesCountedLoop]);

      expect(unmet, [_usesCountedLoop]);
      expect(unmet.single.requirement, startsWith('El enunciado pedia'));
    });
  });

  group('omits a construct', () {
    const withoutLoops = OmitsConstructAssertion(
      requirement: 'El enunciado pedia resolverlo sin bucles.',
      construct: AstConstruct.countedLoop,
    );

    test('a program with no counted loop satisfies the assertion', () {
      expect(_unmet(_conditionalLoop, const [withoutLoops]), isEmpty);
    });

    test('a program with a counted loop does not', () {
      expect(_unmet(_countedLoop, const [withoutLoops]), [withoutLoops]);
    });
  });

  group('declares a subprogram', () {
    const declaresDouble = DeclaresSubprogramAssertion(
      requirement: 'El enunciado pedia definir Doble(n).',
      name: 'Doble',
      arity: 1,
    );

    test('the declared subprogram with the declared arity satisfies it', () {
      expect(_unmet(_withSubprogram, const [declaresDouble]), isEmpty);
    });

    test('the same name with another arity does not satisfy it', () {
      const withTwoParameters = DeclaresSubprogramAssertion(
        requirement: 'El enunciado pedia definir Doble(a, b).',
        name: 'Doble',
        arity: 2,
      );

      expect(_unmet(_withSubprogram, const [withTwoParameters]), [withTwoParameters]);
    });

    test('a subprogram of zero parameters is a valid signature to ask for', () {
      const noParameters = DeclaresSubprogramAssertion(
        requirement: 'El enunciado pedia definir Doble().',
        name: 'Doble',
        arity: 0,
      );

      expect(_unmet(_withSubprogram, const [noParameters]), [noParameters]);
    });
  });

  group('declares a class member with a visibility', () {
    const privateBalance = DeclaresClassMemberAssertion(
      requirement: 'El enunciado pedia que el saldo fuera privado.',
      className: 'Cuenta',
      memberName: 'saldo',
      visibility: MemberVisibility.privateMember,
    );

    test('a private attribute satisfies the assertion', () {
      expect(_unmet(_withClass, const [privateBalance]), isEmpty);
    });

    test('the same attribute made public does not', () {
      const publicBalance = DeclaresClassMemberAssertion(
        requirement: 'El enunciado pedia que el saldo fuera publico.',
        className: 'Cuenta',
        memberName: 'saldo',
        visibility: MemberVisibility.publicMember,
      );

      expect(_unmet(_withClass, const [publicBalance]), [publicBalance]);
    });

    test('a public method is found with its declared visibility', () {
      const publicMethod = DeclaresClassMemberAssertion(
        requirement: 'El enunciado pedia un metodo Depositar publico.',
        className: 'Cuenta',
        memberName: 'Depositar',
        visibility: MemberVisibility.publicMember,
      );

      expect(_unmet(_withClass, const [publicMethod]), isEmpty);
    });

    test('a class with no members satisfies nothing', () {
      const anyMember = DeclaresClassMemberAssertion(
        requirement: 'El enunciado pedia un atributo saldo.',
        className: 'Cuenta',
        memberName: 'saldo',
        visibility: MemberVisibility.privateMember,
      );

      expect(_unmet(_oneStatement, const [anyMember]), [anyMember]);
    });
  });

  group('does not repeat a block more than N times', () {
    test('exactly N occurrences satisfies the assertion, N plus one does not', () {
      const atMostThree = RepeatsAtMostAssertion(
        requirement: 'El enunciado pedia no repetir el condicional.',
        construct: AstConstruct.conditional,
        maxOccurrences: 3,
      );
      const atMostTwo = RepeatsAtMostAssertion(
        requirement: 'El enunciado pedia no repetir el condicional.',
        construct: AstConstruct.conditional,
        maxOccurrences: 2,
      );

      expect(_unmet(_threeConditionals, const [atMostThree]), isEmpty);
      expect(_unmet(_threeConditionals, const [atMostTwo]), [atMostTwo]);
    });
  });

  group('behaviour and structure are independent', () {
    test('a program that satisfies the behaviour can fail the assertion', () {
      expect(_unmet(_conditionalLoop, const [_usesCountedLoop]), [_usesCountedLoop]);
    });

    test('a program that satisfies the assertion can compute the wrong thing', () {
      const wrongTotal = '''
Algoritmo Suma
  Definir i Como Entero
  Definir total Como Entero
  total <- 0
  Para i <- 1 Hasta 5 Con Paso 1 Hacer
    total <- total - i
  FinPara
  Escribir total
FinAlgoritmo
''';

      expect(_unmet(wrongTotal, const [_usesCountedLoop]), isEmpty);
    });
  });

  group('edge cases', () {
    test('no assertions means nothing unmet, whatever the program', () {
      expect(_unmet(_doesNotParse, const []), isEmpty);
    });

    test('an empty program satisfies an omission and fails a requirement', () {
      const withoutLoops = OmitsConstructAssertion(
        requirement: 'El enunciado pedia resolverlo sin bucles.',
        construct: AstConstruct.countedLoop,
      );

      expect(_unmet(_empty, const [withoutLoops]), isEmpty);
      expect(_unmet(_empty, const [_usesCountedLoop]), [_usesCountedLoop]);
    });

    test('a program of one statement is analysed like any other', () {
      expect(_unmet(_oneStatement, const [_usesCountedLoop]), [_usesCountedLoop]);
    });

    test('a program that does not parse leaves every assertion unverified', () {
      expect(_unmet(_doesNotParse, const [_usesCountedLoop]), [_usesCountedLoop]);
    });
  });

  group('the catalog is closed and complete', () {
    test('every declared assertion kind has an evaluator', () {
      for (final kind in StructuralAssertionKind.values) {
        expect(structuralAssertionCatalog[kind], isNotNull, reason: kind.name);
      }
    });

    test('the catalog holds exactly the declared kinds', () {
      expect(
        structuralAssertionCatalog.keys.toSet(),
        StructuralAssertionKind.values.toSet(),
      );
    });
  });
}
