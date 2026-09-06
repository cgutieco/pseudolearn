import '../model/export/export_result.dart';
import '../model/export/target_language_id.dart';
import '../model/profiles/syntax_profile_id.dart';

abstract interface class ProgramExporter {
  ExportResult export({
    required String sourceCode,
    required TargetLanguageId targetLanguage,
    required SyntaxProfileId profileId,
  });
}
