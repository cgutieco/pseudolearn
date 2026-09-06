import 'package:pseudolearn_core/pseudolearn_core.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../mapping/profile_catalog.dart';

final class ProgramAnalysis {
  final SyntaxProfileId profileId;
  final LanguageProfile profile;
  final LexerResult lexerResult;
  final ParseResult parseResult;
  final ResolutionResult? resolution;
  final TypeCheckResult? typeCheck;

  const ProgramAnalysis._({
    required this.profileId,
    required this.profile,
    required this.lexerResult,
    required this.parseResult,
    required this.resolution,
    required this.typeCheck,
  });

  factory ProgramAnalysis.of(String sourceCode, SyntaxProfileId profileId) {
    final profile = ProfileCatalog.toLanguageProfile(profileId);
    final lexerResult = Lexer(profile).tokenize(sourceCode);
    final parseResult = Parser(profile: profile).parse(TokenStream(lexerResult.tokens));
    final unit = parseResult.program;
    final hasSyntaxErrors = [...lexerResult.diagnostics, ...parseResult.diagnostics]
        .any((diagnostic) => diagnostic.severity == Severity.error);

    if (unit == null || hasSyntaxErrors) {
      return ProgramAnalysis._(
        profileId: profileId,
        profile: profile,
        lexerResult: lexerResult,
        parseResult: parseResult,
        resolution: null,
        typeCheck: null,
      );
    }

    final resolution = NameResolver(profile: profile).resolve(unit);
    return ProgramAnalysis._(
      profileId: profileId,
      profile: profile,
      lexerResult: lexerResult,
      parseResult: parseResult,
      resolution: resolution,
      typeCheck: TypeChecker(resolution: resolution, profile: profile).check(unit),
    );
  }

  List<Token> get tokens => lexerResult.tokens;

  List<Diagnostic> get syntaxDiagnostics =>
      [...lexerResult.diagnostics, ...parseResult.diagnostics];

  List<Diagnostic> get diagnostics => [
        ...syntaxDiagnostics,
        ...?resolution?.diagnostics,
        ...?typeCheck?.diagnostics,
      ];

  SourceUnitNode? get sourceUnit =>
      resolution == null ? null : parseResult.program;

  bool get isExecutable =>
      sourceUnit != null &&
      !diagnostics.any((diagnostic) => diagnostic.severity == Severity.error);

  AnalyzedProgram? get executableProgram => isExecutable
      ? AnalyzedProgram(
          sourceUnit: sourceUnit!,
          syntaxDiagnostics: syntaxDiagnostics,
          resolution: resolution!,
          typeCheck: typeCheck!,
          profile: profile,
        )
      : null;
}
