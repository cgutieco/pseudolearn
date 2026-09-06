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
  group('Class Parser - Happy Paths', () {
    test('parses empty class', () {
      final result = _parse('''
Clase Vacia
FinClase

Proceso Principal
FinProceso
''');
      expect(result.diagnostics, isEmpty);
      expect(result.program, isNotNull);
      final unit = result.program!;
      expect(unit.classes, hasLength(1));
      expect(unit.classes.first.name, equals('Vacia'));
      expect(unit.classes.first.superclassName, isNull);
      expect(unit.classes.first.members, isEmpty);
    });

    test('parses class with single inheritance', () {
      final result = _parse('''
Clase Estudiante Hereda De Persona
FinClase

Proceso Principal
FinProceso
''');
      expect(result.diagnostics, isEmpty);
      final cls = result.program!.classes.first;
      expect(cls.name, equals('Estudiante'));
      expect(cls.superclassName, equals('Persona'));
    });

    test('parses class with fields having public and private visibility', () {
      final result = _parse('''
Clase Cuenta
  Publico Definir titular Como Cadena
  Privado Definir saldo Como Real
  Dimension transacciones[100] Como Real
FinClase

Proceso Principal
FinProceso
''');
      expect(result.diagnostics, isEmpty);
      final cls = result.program!.classes.first;
      expect(cls.members, hasLength(3));

      final f1 = cls.members[0] as ClassFieldNode;
      expect(f1.visibility, equals(Visibility.public));
      expect(f1.declaration, isA<VariableDeclarationNode>());

      final f2 = cls.members[1] as ClassFieldNode;
      expect(f2.visibility, equals(Visibility.private));

      final f3 = cls.members[2] as ClassFieldNode;
      expect(f3.visibility, equals(Visibility.public));
      expect(f3.declaration, isA<DimensionStatementNode>());
    });

    test('parses class with methods and constructor', () {
      final result = _parse('''
Clase Calculadora
  Privado Definir memoria Como Real

  Metodo Constructor()
    memoria <- 0.0
  FinMetodo

  Publico Metodo Sumar(a Como Real, b Como Real) Como Real
    Retornar a + b
  FinMetodo

  Metodo Limpiar()
    memoria <- 0.0
  FinMetodo
FinClase

Proceso Principal
FinProceso
''');
      expect(result.diagnostics, isEmpty);
      final cls = result.program!.classes.first;
      expect(cls.members, hasLength(4));

      final constructor = cls.members[1] as ConstructorDeclarationNode;
      expect(constructor.parameters, isEmpty);
      expect(constructor.body, hasLength(1));

      final method1 = cls.members[2] as MethodDeclarationNode;
      expect(method1.name, equals('Sumar'));
      expect(method1.visibility, equals(Visibility.public));
      expect(method1.parameters, hasLength(2));
      expect(method1.returnType, equals(PrimitiveType.real));

      final method2 = cls.members[3] as MethodDeclarationNode;
      expect(method2.name, equals('Limpiar'));
      expect(method2.visibility, equals(Visibility.public));
      expect(method2.returnType, isNull);
    });

    test('preserves source order across classes, subroutines and algorithm',
        () {
      final result = _parse('''
Clase A
FinClase

SubProceso Helper()
FinSubProceso

Proceso Principal
FinProceso

Clase B Hereda De A
FinClase
''');
      expect(result.diagnostics, isEmpty);
      final unit = result.program!;
      expect(unit.declarations, hasLength(4));
      expect(unit.declarations[0], isA<ClassNode>());
      expect(unit.declarations[1], isA<SubroutineDeclarationNode>());
      expect(unit.declarations[2], isA<AlgorithmNode>());
      expect(unit.declarations[3], isA<ClassNode>());
    });
  });
}
