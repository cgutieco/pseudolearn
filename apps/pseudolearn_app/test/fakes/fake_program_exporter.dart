import 'package:pseudolearn_app/domain/model/export/export_result.dart';
import 'package:pseudolearn_app/domain/model/export/exported_program.dart';
import 'package:pseudolearn_app/domain/model/export/target_language_id.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/ports/program_exporter.dart';

final class FakeProgramExporter implements ProgramExporter {
  ExportResult? nextResult;
  String? lastExportedSource;
  TargetLanguageId? lastTargetLanguage;
  SyntaxProfileId? lastProfileId;

  FakeProgramExporter({this.nextResult});

  @override
  ExportResult export({
    required String sourceCode,
    required TargetLanguageId targetLanguage,
    required SyntaxProfileId profileId,
  }) {
    lastExportedSource = sourceCode;
    lastTargetLanguage = targetLanguage;
    lastProfileId = profileId;

    if (nextResult != null) {
      return nextResult!;
    }

    if (sourceCode.contains('ERROR')) {
      return const ExportAnalysisError();
    }

    final comment = targetLanguage == TargetLanguageId.python ? '#' : '//';
    return ExportSuccess(
      ExportedProgram(
        targetLanguage: targetLanguage,
        sourceCode: '$comment Generated ${targetLanguage.displayName} code\n$sourceCode',
        notes: const [],
      ),
    );
  }
}
