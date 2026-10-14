import 'package:pseudolearn_core/pseudolearn_core.dart';

AnalyzedProgram? analyze(String source) {
  const profile = ClassicSpanishProfile.flexible();
  final lexical = Lexer(profile).tokenize(source);
  final parsed = Parser(profile: profile).parse(TokenStream(lexical.tokens));
  final program = parsed.program;
  if (program == null) return null;
  final resolution = NameResolver(profile: profile).resolve(program);
  final types = TypeChecker(
    resolution: resolution,
    profile: profile,
  ).check(program);
  final analyzed = AnalyzedProgram(
    sourceUnit: program,
    syntaxDiagnostics: [...lexical.diagnostics, ...parsed.diagnostics],
    resolution: resolution,
    typeCheck: types,
    profile: profile,
  );
  return analyzed.hasErrors ? null : analyzed;
}
