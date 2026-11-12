import '../domain/model/route/route_kinds.dart';
import '../domain/ports/route_answer_evaluator.dart';
import 'route_evaluators.dart';
import '../domain/ports/program_analyzer.dart';
import '../engine/exercise/engine_program_batch_runner.dart';
import '../engine/rust/rust_program_formatter.dart';
import '../engine/rust/rust_program_translator.dart';
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
import '../engine/rust/rust_edit_assist_source.dart';
import '../engine/rust/rust_editor_vocabulary.dart';
import '../engine/rust/rust_source_editor.dart';
import '../engine/rust/rust_exercise_checker.dart';
import '../engine/rust/rust_program_construct_reader.dart';
import '../engine/rust/rust_program_analyzer.dart';
import '../engine/rust/rust_effect_policy.dart';
import '../engine/rust/rust_program_execution.dart';
import '../engine/rust/rust_program_execution_observer.dart';
import '../engine/rust/rust_execution_resource.dart';
import '../engine/rust/rust_structural_assertion_checker.dart';
import '../engine/rust/rust_structogram_builder.dart';
import '../engine/rust/rust_template_source.dart';
import '../engine/rust/rust_syntax_help_source.dart';
import '../engine/rust/rust_transport.dart';
import '../engine/rust/export/rust_program_exporter.dart';
import '../domain/ports/program_exporter.dart';
import '../domain/ports/syntax_help_source.dart';
import 'engine_services.dart';
import '../domain/ports/execution_environment.dart';
import 'program_execution_session.dart';
import 'program_tools.dart';

final class RustEngineServices implements EngineServices {
  @override
  final ProgramAnalyzer analyzer;
  @override
  final ProgramExecution Function() createProgramExecution;
  @override
  final ProgramExecutionSession Function() createObservableExecutionSession;
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
  final Map<RouteExerciseKind, RouteAnswerEvaluator> routeEvaluators;
  @override
  final FlowchartBuilder flowchartBuilder;
  @override
  final StructogramBuilder structogramBuilder;
  @override
  final ClassDiagramBuilder classDiagramBuilder;
  @override
  @override
  final SyntaxHelpSource syntaxHelpSource;
  @override
  final ProgramExporter programExporter;
  @override
  final ProgramTools programTools;

  const RustEngineServices({
    required this.analyzer,
    required this.createProgramExecution,
    required this.createObservableExecutionSession,
    required this.completionSource,
    required this.contextualCompletionSource,
    required this.sourceEditor,
    required this.editorKeySource,
    required this.programConstructReader,
    required this.exerciseChecker,
    required this.routeEvaluators,
    required this.flowchartBuilder,
    required this.structogramBuilder,
    required this.classDiagramBuilder,
    required this.syntaxHelpSource,
    required this.programExporter,
    required this.programTools,
  });
}

RustEngineServices buildRustEngineServices(
  RustTransport transport, {
  ExecutionEnvironment? environment,
}) {
  final analysis = RustAnalysisApi(transport);
  final analyzer = RustProgramAnalyzer(analysis);
  final vocabulary = RustEditorVocabulary(transport);
  return RustEngineServices(
    analyzer: analyzer,
    createProgramExecution: () =>
        RustProgramExecution(transport, environment: environment),
    createObservableExecutionSession: () =>
        _observableSession(transport, environment),
    completionSource: RustTemplateSource(transport),
    contextualCompletionSource: RustCompletionSource(transport),
    sourceEditor: RustSourceEditor(RustEditAssistSource(transport)),
    editorKeySource: RustEditorKeySource(vocabulary),
    programConstructReader: RustProgramConstructReader(transport),
    flowchartBuilder: RustFlowchartBuilder(transport),
    structogramBuilder: RustStructogramBuilder(transport),
    classDiagramBuilder: RustClassDiagramBuilder(transport),
    syntaxHelpSource: RustSyntaxHelpSource(transport),
    programExporter: RustProgramExporter(transport),
    exerciseChecker: RustExerciseChecker(
      behaviour: BehaviourChecker(
        execution: _containedExecution(transport),
        analyzer: analyzer,
      ),
      structure: RustStructuralAssertionChecker(transport),
    ),
    routeEvaluators: buildRouteEvaluators(
      execution: _containedExecution(transport),
      analyzer: analyzer,
    ),
    programTools: _programTools(transport, analyzer),
  );
}

RustProgramExecution _containedExecution(RustTransport transport) =>
    RustProgramExecution(
      transport,
      effectPolicy: const RustEffectPolicy.contained(),
    );

ProgramExecutionSession _observableSession(
  RustTransport transport,
  ExecutionEnvironment? environment,
) {
  final resource = RustExecutionResource();
  return ProgramExecutionSession(
    execution: RustProgramExecution(
      transport,
      observationResource: resource,
      environment: environment,
    ),
    observer: RustProgramExecutionObserver(transport, resource),
  );
}

ProgramTools _programTools(RustTransport transport, ProgramAnalyzer analyzer) =>
    ProgramTools(
      runner: EngineProgramBatchRunner(
        createExecution: () => RustProgramExecution(
          transport,
          effectPolicy: const RustEffectPolicy.contained(),
        ),
        analyzer: analyzer,
      ),
      translator: RustProgramTranslator(transport),
      formatter: RustProgramFormatter(transport),
    );
