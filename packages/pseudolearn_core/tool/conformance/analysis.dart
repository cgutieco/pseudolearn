import 'package:pseudolearn_core/pseudolearn_core.dart';

import 'wire.dart';

final class ReferenceAnalysis {
  final AnalyzedProgram? program;
  final Map<String, Object?> response;

  const ReferenceAnalysis(this.program, this.response);
}

ReferenceAnalysis analyze(String source, LanguageProfile profile) {
  final lexical = Lexer(profile).tokenize(source);
  final syntax = Parser(profile: profile).parse(TokenStream(lexical.tokens));
  final diagnostics = <Map<String, Object?>>[
    ...lexical.diagnostics
        .map((diagnostic) => diagnosticWire(diagnostic, 'lexical')),
    ...syntax.diagnostics
        .map((diagnostic) => diagnosticWire(diagnostic, 'syntax')),
  ];
  final tree = syntax.program;
  final response = <String, Object?>{
    'tree': tree != null,
    'diagnostics': diagnostics
  };
  if (tree == null ||
      [...lexical.diagnostics, ...syntax.diagnostics]
          .any((diagnostic) => diagnostic.severity == Severity.error)) {
    return ReferenceAnalysis(null, response);
  }
  final resolution = NameResolver(profile: profile).resolve(tree);
  final types =
      TypeChecker(resolution: resolution, profile: profile).check(tree);
  diagnostics.addAll(resolution.diagnostics
      .map((diagnostic) => diagnosticWire(diagnostic, 'semantic')));
  diagnostics.addAll(types.diagnostics
      .map((diagnostic) => diagnosticWire(diagnostic, 'semantic')));
  final program = AnalyzedProgram(
    sourceUnit: tree,
    syntaxDiagnostics: [
      ...lexical.diagnostics,
      ...syntax.diagnostics,
      ...resolution.diagnostics
    ],
    resolution: resolution,
    typeCheck: types,
    profile: profile,
  );
  return ReferenceAnalysis(program, response);
}
