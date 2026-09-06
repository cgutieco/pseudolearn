import 'package:pseudolearn_core/pseudolearn_core.dart';

import '../../domain/model/diagram/diagram_program.dart';
import '../../domain/model/diagram/diagram_scene.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/structogram_builder.dart';
import '../analysis/analysis_cache.dart';
import '../diagram/diagram_vocabulary.dart';
import '../diagram/executable_units.dart';
import '../diagram/statement_caption.dart';
import '../printing/pseudocode_printer.dart';
import 'structogram_builder.dart';
import 'structogram_scene.dart';

final class StructogramLayout implements StructogramBuilder {
  final AnalysisCache _analyses;

  StructogramLayout({AnalysisCache? analyses})
      : _analyses = analyses ?? AnalysisCache();

  @override
  DiagramProgram buildDiagram({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) {
    final analysis = _analyses.of(sourceCode, profileId);
    final unit = analysis.sourceUnit;
    if (unit == null) return const DiagramProgram.empty();

    final vocabulary = DiagramVocabulary.forLanguage(languageId);
    final entries = ExecutableUnits.fromAst(unit, vocabulary: vocabulary);
    if (entries.isEmpty) return const DiagramProgram.empty();

    final scenes = <String, DiagramScene>{};
    for (final entry in entries) {
      scenes[entry.unit.id] = _composeUnitScene(entry, analysis.profile, vocabulary);
    }

    return DiagramProgram(
      units: entries.map((entry) => entry.unit).toList(),
      scenes: scenes,
    );
  }

  DiagramScene _composeUnitScene(
    ExecutableUnitEntry entry,
    LanguageProfile profile,
    DiagramVocabulary vocabulary,
  ) {
    final cells = StructogramCellBuilder(
      vocabulary: vocabulary,
      caption: StatementCaption(
        printer: PseudocodePrinter(profile),
        lexicon: profile,
        vocabulary: vocabulary,
      ),
    );
    return StructogramScene.of(cells.buildBody(entry.body));
  }
}
