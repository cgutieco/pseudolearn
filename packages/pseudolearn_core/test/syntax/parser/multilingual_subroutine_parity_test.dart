import 'package:pseudolearn_core/src/domain/profile/language_profile.dart';
import 'package:pseudolearn_core/src/domain/profile/profiles/classic_spanish_profile.dart';
import 'package:pseudolearn_core/src/domain/profile/profiles/english_profile.dart';
import 'package:pseudolearn_core/src/syntax/ast/ast_node.dart';
import 'package:pseudolearn_core/src/syntax/lexer/lexer.dart';
import 'package:pseudolearn_core/src/syntax/parser/parse_result.dart';
import 'package:pseudolearn_core/src/syntax/parser/parser.dart';
import 'package:pseudolearn_core/src/syntax/parser/token_stream.dart';
import 'package:test/test.dart';

ParseResult _parse(String source, LanguageProfile profile) {
  final lexer = Lexer(profile);
  final result = lexer.tokenize(source);
  final stream = TokenStream(result.tokens);
  return Parser(profile: profile).parse(stream);
}

void main() {
  group('Multilingual Subroutine Parity', () {
    test(
        'subroutine declaration with parameters and return produces equivalent AST in both profiles',
        () {
      final spanish = _parse('''
SubProceso Maximo(a Como Entero, b Como Entero) Como Entero
  Si a > b Entonces
    Retornar a
  Sino
    Retornar b
  FinSi
FinSubProceso

Proceso Test
  Definir res Como Entero
  res <- Maximo(10, 20)
FinProceso
''', const ClassicSpanishProfile.flexible());

      final english = _parse('''
subroutine Maximo(a as integer, b as integer) as integer
  if a > b then
    return a;
  else
    return b;
  endIf
endSubroutine

algorithm Test
  define res as integer;
  res <- Maximo(10, 20);
endAlgorithm
''', const EnglishProfile.flexible());

      expect(spanish.diagnostics, isEmpty);
      expect(english.diagnostics, isEmpty);

      final spSub = spanish.program!.subroutines.first;
      final enSub = english.program!.subroutines.first;

      expect(spSub.name, equals(enSub.name));
      expect(spSub.returnType, equals(enSub.returnType));
      expect(spSub.parameters.length, equals(enSub.parameters.length));
      expect(spSub.parameters[0].name, equals(enSub.parameters[0].name));
      expect(spSub.parameters[0].type, equals(enSub.parameters[0].type));
      expect(spSub.body.length, equals(enSub.body.length));

      final spAlg = spanish.program!.algorithm!;
      final enAlg = english.program!.algorithm!;
      expect(spAlg.name, equals(enAlg.name));
      expect(spAlg.body.length, equals(enAlg.body.length));
    });

    test(
        'array parameter passing mode and call statement produce equivalent AST',
        () {
      final spanish = _parse('''
SubProceso Modificar(v[] Como Entero Por Referencia)
  v[0] <- 42
FinSubProceso

Proceso Test
  Dimension v[5] Como Entero
  Modificar(v)
FinProceso
''', const ClassicSpanishProfile.flexible());

      final english = _parse('''
subroutine Modificar(v[] as integer by reference)
  v[0] <- 42;
endSubroutine

algorithm Test
  dimension v[5] as integer;
  Modificar(v);
endAlgorithm
''', const EnglishProfile.flexible());

      expect(spanish.diagnostics, isEmpty);
      expect(english.diagnostics, isEmpty);

      final spParam = spanish.program!.subroutines.first.parameters.first;
      final enParam = english.program!.subroutines.first.parameters.first;

      expect(spParam.dimensionCount, equals(enParam.dimensionCount));
      expect(spParam.passingMode, equals(enParam.passingMode));

      final spCall = spanish.program!.algorithm!.body[1] as CallStatementNode;
      final enCall = english.program!.algorithm!.body[1] as CallStatementNode;
      expect(spCall.name, equals(enCall.name));
      expect(spCall.arguments.length, equals(enCall.arguments.length));
    });
  });
}
