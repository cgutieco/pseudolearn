import '../../domain/model/profiles/syntax_profile_id.dart';
import 'program_analysis.dart';

final class AnalysisCache {
  String? _sourceCode;
  SyntaxProfileId? _profileId;
  ProgramAnalysis? _analysis;

  ProgramAnalysis of(String sourceCode, SyntaxProfileId profileId) {
    final remembered = _analysis;
    if (remembered != null && _sourceCode == sourceCode && _profileId == profileId) {
      return remembered;
    }
    final fresh = ProgramAnalysis.of(sourceCode, profileId);
    _sourceCode = sourceCode;
    _profileId = profileId;
    _analysis = fresh;
    return fresh;
  }
}
