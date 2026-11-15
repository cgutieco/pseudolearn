import '../model/diagram/diagram_scene.dart';
import '../model/profiles/syntax_profile_id.dart';

abstract interface class ClassDiagramBuilder {
  DiagramScene buildDiagram({
    required String sourceCode,
    required SyntaxProfileId profileId,
  });
}
