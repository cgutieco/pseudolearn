import '../../domain/model/diagram/diagram_program.dart';
import '../../domain/model/diagram/diagram_scene.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/structogram_builder.dart';
import '../diagram/diagram_vocabulary.dart';
import '../structogram/structogram_scene.dart';
import 'rust_diagram_captions.dart';
import 'rust_editor_vocabulary.dart';
import 'rust_executable_unit_reader.dart';
import 'rust_program_view.dart';
import 'rust_program_view_source.dart';
import 'rust_structogram_cell_builder.dart';
import 'rust_transport.dart';

final class RustStructogramBuilder implements StructogramBuilder {
  final RustProgramViewSource _views;
  final RustExecutableUnitReader _units;
  final RustEditorVocabulary _words;

  RustStructogramBuilder(RustTransport transport)
    : _views = RustProgramViewSource(transport),
      _units = const RustExecutableUnitReader(),
      _words = RustEditorVocabulary(transport);

  @override
  DiagramProgram buildDiagram({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) {
    final captions = RustDiagramCaptions.load(_words, profileId);
    final view = _views.loadStructure(
      sourceCode: sourceCode,
      profileId: profileId,
      languageId: languageId,
    );
    if (view == null) return const DiagramProgram.empty();
    final vocabulary = DiagramVocabulary.forLanguage(languageId);
    final entries = _units.read(view, vocabulary: vocabulary);
    return DiagramProgram(
      units: entries.map((entry) => entry.unit).toList(),
      scenes: {
        for (final entry in entries)
          entry.unit.id: _scene(entry.body, view, (vocabulary, captions)),
      },
    );
  }

  DiagramScene _scene(
    RustViewNode body,
    RustProgramView view,
    (DiagramVocabulary, RustDiagramCaptions) words,
  ) {
    final (vocabulary, captions) = words;
    final cells = RustStructogramCellBuilder(
      view: view,
      vocabulary: vocabulary,
      captions: captions,
    );
    return StructogramScene.of(cells.buildBody(body));
  }
}
