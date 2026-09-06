import 'package:pseudolearn_core/src/domain/diagnostic_code.dart';
import 'package:pseudolearn_core/src/domain/profile/profiles/classic_spanish_profile.dart';
import 'package:pseudolearn_core/src/domain/profile/profiles/english_profile.dart';
import 'package:pseudolearn_core/src/syntax/ast/ast_node.dart';
import 'package:pseudolearn_core/src/syntax/lexer/lexer.dart';
import 'package:pseudolearn_core/src/syntax/parser/parser.dart';
import 'package:pseudolearn_core/src/syntax/parser/token_stream.dart';
import 'package:test/test.dart';

void main() {
  group('Member Access and Method Call (Happy path)', () {
    test('parses member access expression and assignment target', () {
      const source = '''
Algoritmo Test
  p.nombre <- "Ana"
  x <- p.edad
FinAlgoritmo
''';
      final tokens =
          Lexer(const ClassicSpanishProfile.flexible()).tokenize(source).tokens;
      final result = Parser().parse(TokenStream(tokens));

      expect(result.diagnostics, isEmpty);
      final body = result.program!.algorithm!.body;
      final assign1 = body[0] as AssignmentStatementNode;
      expect(assign1.target, isA<MemberAccessExpressionNode>());
      final memberTarget = assign1.target as MemberAccessExpressionNode;
      expect(memberTarget.memberName, equals('nombre'));

      final assign2 = body[1] as AssignmentStatementNode;
      expect(assign2.value, isA<MemberAccessExpressionNode>());
    });

    test('parses method call statement and method call in expression', () {
      const source = '''
Algoritmo Test
  p.saludar()
  total <- p.calcular(10, 20)
FinAlgoritmo
''';
      final tokens =
          Lexer(const ClassicSpanishProfile.flexible()).tokenize(source).tokens;
      final result = Parser().parse(TokenStream(tokens));

      expect(result.diagnostics, isEmpty);
      final body = result.program!.algorithm!.body;
      expect(body[0], isA<MethodCallStatementNode>());
      final callStmt = body[0] as MethodCallStatementNode;
      expect(callStmt.methodName, equals('saludar'));
      expect(callStmt.arguments, isEmpty);

      final assign = body[1] as AssignmentStatementNode;
      expect(assign.value, isA<MethodCallExpressionNode>());
      final callExpr = assign.value as MethodCallExpressionNode;
      expect(callExpr.methodName, equals('calcular'));
      expect(callExpr.arguments, hasLength(2));
    });

    test('parses Este and Super expressions inside class methods', () {
      const source = '''
Clase Persona
  Publico Definir nombre Como Cadena
  Metodo Saludar()
    Escribir Este.nombre
  FinMetodo
FinClase

Clase Empleado HeredaDe Persona
  Metodo Saludar()
    Super.Saludar()
  FinMetodo
FinClase

Algoritmo Main
FinAlgoritmo
''';
      final tokens =
          Lexer(const ClassicSpanishProfile.flexible()).tokenize(source).tokens;
      final result = Parser().parse(TokenStream(tokens));

      expect(result.diagnostics, isEmpty);
      final cls1 = result.program!.classes[0];
      final m1 = cls1.members.whereType<MethodDeclarationNode>().first;
      final write = m1.body.whereType<WriteStatementNode>().first;
      expect(write.expressions.first, isA<MemberAccessExpressionNode>());
      final thisAccess = write.expressions.first as MemberAccessExpressionNode;
      expect(thisAccess.target, isA<ThisExpressionNode>());

      final cls2 = result.program!.classes[1];
      final m2 = cls2.members.whereType<MethodDeclarationNode>().first;
      final call = m2.body.whereType<MethodCallStatementNode>().first;
      expect(call.target, isA<SuperExpressionNode>());
    });

    test('parses chained member access and calls in English profile', () {
      const source = '''
algorithm Test
  this.user.profile.show();
  p.name <- "Bob";
endAlgorithm
''';
      final profile = const EnglishProfile.flexible();
      final tokens = Lexer(profile).tokenize(source).tokens;
      final result = Parser(profile: profile).parse(TokenStream(tokens));

      expect(result.diagnostics, isEmpty);
    });
  });

  group('Member Access and Method Call (Unhappy path)', () {
    test(
        'reports expectedMemberNameAfterDot when trailing dot without member name',
        () {
      const source = '''
Algoritmo Test
  x <- p.
FinAlgoritmo
''';
      final tokens =
          Lexer(const ClassicSpanishProfile.flexible()).tokenize(source).tokens;
      final result = Parser().parse(TokenStream(tokens));

      expect(
        result.diagnostics.map((d) => d.code),
        contains(DiagnosticCode.expectedMemberNameAfterDot),
      );
    });
  });
}
