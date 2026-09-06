import '../../domain/diagnostic.dart';
import '../../domain/token.dart';

final class LexerResult {
  final List<Token> tokens;
  final List<Diagnostic> diagnostics;

  const LexerResult({
    required this.tokens,
    required this.diagnostics,
  });

  bool get hasErrors => diagnostics.isNotEmpty;
}
