import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

void main() {
  group('Full Language NodeId and AST Structural Coverage', () {
    late final LanguageProfile profile;

    setUpAll(() {
      profile = const ClassicSpanishProfile.flexible();
    });

    test(
        'program containing all language constructs covers 100% of parser-generated concrete AstNode types',
        () {
      const source = '''
Clase Base
  Definir codigoBase Como Entero

  Metodo Constructor(c Como Entero)
    Este.codigoBase <- c
  FinMetodo

  Metodo Identificar() Como Entero
    Retornar Este.codigoBase
  FinMetodo
FinClase

Clase Derivada Hereda De Base
  privado Definir contadorInterno Como Entero

  Metodo Constructor(c Como Entero, extra Como Entero)
    Super.Constructor(c)
    Este.contadorInterno <- extra
  FinMetodo

  Metodo Identificar() Como Entero
    Retornar Super.Identificar() + Este.contadorInterno
  FinMetodo
FinClase

SubProceso Multiplicar(a Como Entero, b Como Entero Por Referencia)
  b <- a * b
FinSubProceso

SubProceso CalcularSuma(x Como Entero, z Como Entero) Como Entero
  Retornar x + z
FinSubProceso

Algoritmo CoberturaTotal
  Definir flag Como Logico
  Definir entrada, opcion, paso, res Como Entero
  Dimension tabla[2, 2] Como Entero
  Definir d Como Derivada

  flag <- Verdadero Y NO Falso
  opcion <- 2
  paso <- 10

  d <- Nuevo Derivada(100, 20)
  d.Identificar()

  Multiplicar(5, paso)
  res <- CalcularSuma(10, (20 + 5))

  tabla[0, 0] <- 1

  Si flag Entonces
    Escribir "Bandera activa"
  SiNo
    Escribir "Bandera inactiva"
  FinSi

  Segun opcion Hacer
    1:
      Escribir "Opcion 1"
    2:
      Escribir "Opcion 2"
    De Otro Modo:
      Escribir "Otra opcion"
  FinSegun

  Mientras paso > 0 Hacer
    paso <- paso - 1
  FinMientras

  Repetir
    paso <- paso + 1
  Hasta Que paso >= 5

  Para res <- 1 Hasta 3 Con Paso 1 Hacer
    Escribir "Bucle:", res
  FinPara

  Leer entrada
  Escribir "Resultado final:", d.Identificar(), entrada, tabla[0, 0]
FinAlgoritmo
''';

      final lexResult = Lexer(profile).tokenize(source);
      final parseResult =
          Parser(profile: profile).parse(TokenStream(lexResult.tokens));

      expect(parseResult.diagnostics, isEmpty,
          reason: 'Program should parse with 0 errors');
      expect(parseResult.program, isNotNull);

      final root = parseResult.program!;
      final collectedIds = collectNodeIds(root);

      expect(collectedIds, isNotEmpty);

      final allNodes = <AstNode>[];
      void accumulateNodes(AstNode node) {
        allNodes.add(node);
        for (final child in getChildNodes(node)) {
          accumulateNodes(child);
        }
      }

      accumulateNodes(root);

      expect(allNodes.length, equals(collectedIds.length),
          reason: 'Every node in AST must have a unique NodeId');

      for (final node in allNodes) {
        expect(node.id.value, greaterThanOrEqualTo(1),
            reason: 'NodeId must be >= 1');
        expect(collectedIds.contains(node.id), isTrue);
      }

      final concreteTypesPresent = allNodes.map((n) => n.runtimeType).toSet();

      final expectedConcreteTypes = {
        SourceUnitNode,
        AlgorithmNode,
        ClassNode,
        ClassFieldNode,
        ConstructorDeclarationNode,
        MethodDeclarationNode,
        SubroutineDeclarationNode,
        ParameterNode,
        VariableDeclarationNode,
        VariableDeclaratorNode,
        DimensionStatementNode,
        ArrayDeclaratorNode,
        AssignmentStatementNode,
        WriteStatementNode,
        ReadStatementNode,
        IfStatementNode,
        SwitchStatementNode,
        SwitchCaseNode,
        SwitchDefaultNode,
        WhileStatementNode,
        RepeatUntilStatementNode,
        ForStatementNode,
        CallStatementNode,
        MethodCallStatementNode,
        ReturnStatementNode,
        VariableExpressionNode,
        LiteralExpressionNode,
        UnaryExpressionNode,
        BinaryExpressionNode,
        ParenthesizedExpressionNode,
        ArrayAccessExpressionNode,
        FunctionCallExpressionNode,
        InstantiationExpressionNode,
        MemberAccessExpressionNode,
        MethodCallExpressionNode,
        ThisExpressionNode,
        SuperExpressionNode,
      };

      for (final expectedType in expectedConcreteTypes) {
        expect(concreteTypesPresent.contains(expectedType), isTrue,
            reason: 'AST should contain an instance of $expectedType');
      }

      final firstNode = allNodes.first;
      final enclosingSpan = calculateEnclosingSpan(root);
      expect(enclosingSpan.start.offset,
          lessThanOrEqualTo(firstNode.span.start.offset));

      final innermost = findInnermostNodeAt(root, root.span.start);
      expect(innermost, isNotNull);
    });

    test('structural traversal handles synthetic type annotation nodes safely',
        () {
      final primType = PrimitiveTypeAnnotationNode(
        id: const NodeId(9998),
        span: Span.zero,
        primitiveType: PrimitiveType.integer,
      );
      final customType = CustomTypeAnnotationNode(
        id: const NodeId(9999),
        span: Span.zero,
        name: 'MiTipo',
      );

      expect(getChildNodes(primType), isEmpty);
      expect(getChildNodes(customType), isEmpty);
      expect(collectNodeIds(primType), equals({const NodeId(9998)}));
      expect(collectNodeIds(customType), equals({const NodeId(9999)}));
    });
  });
}
