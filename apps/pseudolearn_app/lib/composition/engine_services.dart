import '../domain/ports/class_diagram_builder.dart';
import '../domain/ports/completion_source.dart';
import '../domain/ports/contextual_completion_source.dart';
import '../domain/ports/editor_key_source.dart';
import '../domain/ports/exercise_checker.dart';
import '../domain/ports/flowchart_builder.dart';
import '../domain/ports/program_analyzer.dart';
import '../domain/ports/program_construct_reader.dart';
import '../domain/ports/program_execution.dart';
import '../domain/ports/program_exporter.dart';
import '../domain/ports/source_editor.dart';
import '../domain/ports/structogram_builder.dart';
import '../domain/ports/syntax_help_source.dart';
import '../domain/ports/syntax_reference_source.dart';

abstract interface class EngineServices {
  ProgramAnalyzer get analyzer;

  ProgramExecution Function() get createProgramExecution;

  FlowchartBuilder get flowchartBuilder;

  StructogramBuilder get structogramBuilder;

  ClassDiagramBuilder get classDiagramBuilder;

  CompletionSource get completionSource;

  ContextualCompletionSource? get contextualCompletionSource;

  SourceEditor get sourceEditor;

  EditorKeySource get editorKeySource;

  SyntaxReferenceSource get syntaxReferenceSource;

  SyntaxHelpSource get syntaxHelpSource;

  ProgramExporter get programExporter;

  ProgramConstructReader get programConstructReader;

  ExerciseChecker get exerciseChecker;
}
