import '../domain/ports/class_diagram_builder.dart';
import '../domain/ports/contextual_completion_source.dart';
import '../domain/ports/completion_source.dart';
import '../domain/ports/editor_key_source.dart';
import '../domain/ports/exercise_checker.dart';
import '../domain/ports/flowchart_builder.dart';
import '../domain/ports/program_analyzer.dart';
import '../domain/ports/program_construct_reader.dart';
import '../domain/ports/program_execution.dart';
import '../domain/ports/program_exporter.dart';
import '../domain/ports/source_editor.dart';
import '../domain/ports/structogram_builder.dart';
import '../domain/ports/syntax_reference_source.dart';
import '../engine/analysis/core_program_analyzer.dart';
import '../engine/analysis/analysis_cache.dart';
import '../engine/analysis/core_program_construct_reader.dart';
import '../engine/classdiagram/core_class_diagram_builder.dart';
import '../engine/completion/profile_completion_source.dart';
import '../engine/diagram/flowchart_layout.dart';
import '../engine/editing/lexicon_source_editor.dart';
import '../engine/editing/profile_key_source.dart';
import '../engine/execution/core_program_execution.dart';
import '../engine/exercise/behaviour_checker.dart';
import '../engine/exercise/exercise_check_runner.dart';
import '../engine/exercise/structural_assertion_checker.dart';
import '../engine/export/core_program_exporter.dart';
import '../engine/knowledge/syntax_reference_generator.dart';
import '../engine/structogram/structogram_layout.dart';
import 'engine_services.dart';

final class DartEngineServices implements EngineServices {
  final AnalysisCache analyses;
  @override
  final ProgramAnalyzer analyzer;
  @override
  final ProgramExecution Function() createProgramExecution;
  @override
  final FlowchartBuilder flowchartBuilder;
  @override
  final StructogramBuilder structogramBuilder;
  @override
  final ClassDiagramBuilder classDiagramBuilder;
  @override
  final CompletionSource completionSource;
  @override
  final SourceEditor sourceEditor;
  @override
  final EditorKeySource editorKeySource;
  @override
  final SyntaxReferenceSource syntaxReferenceSource;
  @override
  final ProgramExporter programExporter;
  @override
  final ProgramConstructReader programConstructReader;
  @override
  final ExerciseChecker exerciseChecker;

  @override
  ContextualCompletionSource? get contextualCompletionSource => null;

  const DartEngineServices({
    required this.analyses,
    required this.analyzer,
    required this.createProgramExecution,
    required this.flowchartBuilder,
    required this.structogramBuilder,
    required this.classDiagramBuilder,
    required this.completionSource,
    required this.sourceEditor,
    required this.editorKeySource,
    required this.syntaxReferenceSource,
    required this.programExporter,
    required this.programConstructReader,
    required this.exerciseChecker,
  });
}

DartEngineServices buildDartEngineServices({AnalysisCache? analysisCache}) {
  final analyses = analysisCache ?? AnalysisCache();
  final analyzer = CoreProgramAnalyzer(analyses: analyses);
  final execution = CoreProgramExecution(analyses: analyses);
  return DartEngineServices(
    analyses: analyses,
    analyzer: analyzer,
    createProgramExecution: () => CoreProgramExecution(analyses: analyses),
    flowchartBuilder: FlowchartLayout(analyses: analyses),
    structogramBuilder: StructogramLayout(analyses: analyses),
    classDiagramBuilder: CoreClassDiagramBuilder(analyses: analyses),
    completionSource: const ProfileCompletionSource(),
    sourceEditor: const LexiconSourceEditor(),
    editorKeySource: const ProfileKeySource(),
    syntaxReferenceSource: const SyntaxReferenceGenerator(),
    programExporter: CoreProgramExporter(analyses: analyses),
    programConstructReader: CoreProgramConstructReader(analyses: analyses),
    exerciseChecker: ExerciseCheckRunner(
      behaviour: BehaviourChecker(execution: execution, analyzer: analyzer),
      structure: StructuralAssertionChecker(analyses: analyses),
    ),
  );
}
