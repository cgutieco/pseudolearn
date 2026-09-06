import '../../domain/model/knowledge/ast_construct.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/ports/program_construct_reader.dart';
import '../exercise/program_structure.dart';
import 'analysis_cache.dart';

final class CoreProgramConstructReader implements ProgramConstructReader {
  final AnalysisCache _analyses;

  CoreProgramConstructReader({AnalysisCache? analyses})
      : _analyses = analyses ?? AnalysisCache();

  @override
  Set<AstConstruct> constructsOf({
    required String sourceCode,
    required SyntaxProfileId profileId,
  }) {
    final unit = _analyses.of(sourceCode, profileId).sourceUnit;
    if (unit == null) return const <AstConstruct>{};
    return ProgramStructure.of(unit).usedConstructs;
  }
}
