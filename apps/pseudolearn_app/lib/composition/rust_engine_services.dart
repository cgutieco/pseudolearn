import '../domain/ports/program_analyzer.dart';
import '../domain/ports/program_execution.dart';
import '../domain/ports/completion_source.dart';
import '../domain/ports/contextual_completion_source.dart';
import '../domain/ports/editor_key_source.dart';
import '../domain/ports/exercise_checker.dart';
import '../domain/ports/class_diagram_builder.dart';
import '../domain/ports/flowchart_builder.dart';
import '../domain/ports/program_construct_reader.dart';
import '../domain/ports/structogram_builder.dart';
import '../domain/ports/source_editor.dart';
import '../engine/exercise/behaviour_checker.dart';
import '../engine/rust/rust_completion_source.dart';
import '../engine/rust/rust_class_diagram_builder.dart';
import '../engine/rust/rust_flowchart_builder.dart';
import '../engine/rust/rust_analysis_api.dart';
import '../engine/rust/rust_editor_key_source.dart';
import '../engine/rust/rust_editor_vocabulary.dart';
import '../engine/rust/rust_source_editor.dart';
import '../engine/rust/rust_exercise_checker.dart';
import '../engine/rust/rust_program_construct_reader.dart';
import '../engine/rust/rust_program_analyzer.dart';
import '../engine/rust/rust_program_execution.dart';
import '../engine/rust/rust_structural_assertion_checker.dart';
import '../engine/rust/rust_structogram_builder.dart';
import '../engine/rust/rust_template_source.dart';
import '../engine/rust/rust_syntax_reference_source.dart';
import '../engine/rust/rust_transport.dart';
import '../engine/rust/export/rust_program_exporter.dart';
import '../domain/ports/program_exporter.dart';
import '../domain/ports/syntax_reference_source.dart';
import 'engine_services.dart';

final class RustEngineServices implements EngineServices {
  @override
  final ProgramAnalyzer analyzer;
  @override
  final ProgramExecution Function() createProgramExecution;
  @override
  final CompletionSource completionSource;
  @override
  final ContextualCompletionSource contextualCompletionSource;
  @override
  final SourceEditor sourceEditor;
  @override
  final EditorKeySource editorKeySource;
  @override
  final ProgramConstructReader programConstructReader;
  @override
  final ExerciseChecker exerciseChecker;
  @override
  final FlowchartBuilder flowchartBuilder;
  @override
  final StructogramBuilder structogramBuilder;
  @override
  final ClassDiagramBuilder classDiagramBuilder;
  @override
  final SyntaxReferenceSource syntaxReferenceSource;
  @override
  final ProgramExporter programExporter;

  const RustEngineServices({
    required this.analyzer,
    required this.createProgramExecution,
    required this.completionSource,
    required this.contextualCompletionSource,
    required this.sourceEditor,
    required this.editorKeySource,
    required this.programConstructReader,
    required this.exerciseChecker,
    required this.flowchartBuilder,
    required this.structogramBuilder,
    required this.classDiagramBuilder,
    required this.syntaxReferenceSource,
    required this.programExporter,
  });
}

RustEngineServices buildRustEngineServices(RustTransport transport) {
  final analysis = RustAnalysisApi(transport);
  final analyzer = RustProgramAnalyzer(analysis);
  final vocabulary = RustEditorVocabulary(transport);
  return RustEngineServices(
    analyzer: analyzer,
    createProgramExecution: () => RustProgramExecution(transport),
    completionSource: RustTemplateSource(transport),
    contextualCompletionSource: RustCompletionSource(transport),
    sourceEditor: RustSourceEditor(vocabulary),
    editorKeySource: RustEditorKeySource(vocabulary),
    programConstructReader: RustProgramConstructReader(transport),
    flowchartBuilder: RustFlowchartBuilder(transport),
    structogramBuilder: RustStructogramBuilder(transport),
    classDiagramBuilder: RustClassDiagramBuilder(transport),
    syntaxReferenceSource: RustSyntaxReferenceSource(transport),
    programExporter: RustProgramExporter(transport),
    exerciseChecker: RustExerciseChecker(
      behaviour: BehaviourChecker(
        execution: RustProgramExecution(transport),
        analyzer: analyzer,
      ),
      structure: RustStructuralAssertionChecker(transport),
    ),
  );
}
