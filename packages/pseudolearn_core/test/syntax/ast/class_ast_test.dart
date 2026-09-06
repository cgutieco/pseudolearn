import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

void main() {
  group('Class AST Nodes and Structural Traversal', () {
    final generator = NodeIdGenerator();
    final span = Span(
      start: const Position(offset: 0, line: 1, column: 1),
      end: const Position(offset: 20, line: 1, column: 21),
    );

    test('constructs ClassNode with properties and inheritance', () {
      final cls = ClassNode(
        id: generator.next(),
        span: span,
        name: 'Estudiante',
        nameSpan: span,
        superclassName: 'Persona',
        superclassSpan: span,
        members: const [],
      );

      expect(cls.name, equals('Estudiante'));
      expect(cls.superclassName, equals('Persona'));
      expect(cls.members, isEmpty);
      expect(getChildNodes(cls), isEmpty);
    });

    test('constructs ClassFieldNode with visibility', () {
      final varDecl = VariableDeclarationNode(
        id: generator.next(),
        span: span,
        variables: [
          VariableDeclaratorNode(
              id: generator.next(), span: span, name: 'edad'),
        ],
        type: PrimitiveType.integer,
        typeSpan: span,
      );

      final field = ClassFieldNode(
        id: generator.next(),
        span: span,
        visibility: Visibility.private,
        declaration: varDecl,
      );

      expect(field.visibility, equals(Visibility.private));
      expect(field.declaration, equals(varDecl));
      expect(getChildNodes(field), equals([varDecl]));
    });

    test(
        'constructs MethodDeclarationNode with parameters, return type and body',
        () {
      final param = ParameterNode(
        id: generator.next(),
        span: span,
        name: 'x',
        nameSpan: span,
        type: PrimitiveType.integer,
      );
      final retStmt = ReturnStatementNode(id: generator.next(), span: span);

      final method = MethodDeclarationNode(
        id: generator.next(),
        span: span,
        visibility: Visibility.public,
        name: 'Calcular',
        nameSpan: span,
        parameters: [param],
        returnType: PrimitiveType.integer,
        returnTypeSpan: span,
        body: [retStmt],
      );

      expect(method.name, equals('Calcular'));
      expect(method.visibility, equals(Visibility.public));
      expect(method.returnType, equals(PrimitiveType.integer));
      expect(getChildNodes(method), equals([param, retStmt]));
    });

    test(
        'constructs ConstructorDeclarationNode and traverses children in order',
        () {
      final param = ParameterNode(
        id: generator.next(),
        span: span,
        name: 'nombre',
        nameSpan: span,
      );
      final retStmt = ReturnStatementNode(id: generator.next(), span: span);

      final constructor = ConstructorDeclarationNode(
        id: generator.next(),
        span: span,
        parameters: [param],
        body: [retStmt],
      );

      expect(constructor.parameters, equals([param]));
      expect(getChildNodes(constructor), equals([param, retStmt]));
    });

    test('collectNodeIds collects all ids across source unit with classes', () {
      final fieldVar = VariableDeclarationNode(
        id: generator.next(),
        span: span,
        variables: [
          VariableDeclaratorNode(id: generator.next(), span: span, name: 'x'),
        ],
        type: PrimitiveType.integer,
        typeSpan: span,
      );
      final field = ClassFieldNode(
        id: generator.next(),
        span: span,
        declaration: fieldVar,
      );
      final cls = ClassNode(
        id: generator.next(),
        span: span,
        name: 'Punto',
        nameSpan: span,
        members: [field],
      );
      final alg = AlgorithmNode(
        id: generator.next(),
        span: span,
        name: 'Principal',
        nameSpan: span,
        body: const [],
      );
      final unit = SourceUnitNode(
        id: generator.next(),
        span: span,
        algorithm: alg,
        subroutines: const [],
        classes: [cls],
        declarations: [cls, alg],
      );

      final ids = collectNodeIds(unit);
      expect(
          ids, containsAll([unit.id, cls.id, field.id, fieldVar.id, alg.id]));
      expect(ids.length, equals(6));
    });
  });
}
