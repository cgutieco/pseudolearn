import '../../domain/model/diagram/diagram_scene.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/ports/class_diagram_builder.dart';
import '../analysis/analysis_cache.dart';
import 'class_diagram_layout.dart';
import 'class_model_extractor.dart';
import 'member_signature_printer.dart';

final class CoreClassDiagramBuilder implements ClassDiagramBuilder {
  final AnalysisCache _analyses;
  final ClassDiagramLayout _layout;

  CoreClassDiagramBuilder({
    AnalysisCache? analyses,
    ClassDiagramLayout layout = const ClassDiagramLayout(),
  })  : _analyses = analyses ?? AnalysisCache(),
        _layout = layout;

  @override
  DiagramScene buildDiagram({
    required String sourceCode,
    required SyntaxProfileId profileId,
  }) {
    final analysis = _analyses.of(sourceCode, profileId);
    final unit = analysis.sourceUnit;
    if (unit == null) return const DiagramScene.empty();
    final model =
        ClassModelExtractor(MemberSignaturePrinter(analysis.profile)).of(unit);
    return _layout.of(model);
  }
}
