import '../../domain/diagnostic.dart';
import '../../domain/profile/language_profile.dart';
import '../../domain/severity.dart';
import '../../semantic/symbols/resolution_result.dart';
import '../../semantic/types/type_check_result.dart';
import '../../syntax/ast/ast_node.dart';

final class AnalyzedProgram {
  final SourceUnitNode sourceUnit;
  final List<Diagnostic> syntaxDiagnostics;
  final ResolutionResult resolution;
  final TypeCheckResult typeCheck;
  final LanguageProfile profile;

  const AnalyzedProgram({
    required this.sourceUnit,
    required this.syntaxDiagnostics,
    required this.resolution,
    required this.typeCheck,
    required this.profile,
  });

  bool get hasErrors =>
      syntaxDiagnostics.any((d) => d.severity == Severity.error) ||
      typeCheck.hasErrors;

  bool get declaresAnyClass => sourceUnit.classes.isNotEmpty;
}
