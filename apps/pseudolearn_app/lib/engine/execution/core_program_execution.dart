import 'package:pseudolearn_core/pseudolearn_core.dart';
import '../../domain/model/execution/execution_step.dart';
import '../../domain/model/execution/output_line.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/program_execution.dart';
import '../analysis/analysis_cache.dart';
import '../mapping/compound_statement_index.dart';
import '../mapping/node_span_index.dart';
import '../mapping/profile_catalog.dart';
import '../mapping/unit_membership_index.dart';
import 'projecting_observer.dart';

final class CoreProgramExecution implements ProgramExecution {
  final AnalysisCache _analyses;

  Interpreter? _interpreter;
  ProjectingObserver _observer = ProjectingObserver();
  DiagnosticRenderer? _renderer;
  String _sourceCode = '';
  int _stepCounter = 0;

  CoreProgramExecution({AnalysisCache? analyses})
      : _analyses = analyses ?? AnalysisCache();

  @override
  List<OutputLine> get outputLines => List.unmodifiable(_observer.outputLines);

  @override
  ExecutionStep startExecution({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) {
    final analysis = _analyses.of(sourceCode, profileId);
    _renderer = DiagnosticRenderer(
      locale: ProfileCatalog.toDiagnosticLocale(languageId),
      syntaxLexicon: analysis.profile,
    );

    final analyzed = analysis.executableProgram;
    if (analyzed == null) return _unstarted();

    _sourceCode = sourceCode;
    _observer = ProjectingObserver(
      spans: NodeSpanIndex.of(analyzed.sourceUnit),
      compounds: CompoundStatementIndex.of(analyzed.sourceUnit),
      units: UnitMembershipIndex.of(analyzed.sourceUnit),
    );
    _stepCounter = 0;
    final startResult = Interpreter.start(program: analyzed, observer: _observer);
    if (startResult is! ExecutionReady) return _unstarted();

    _interpreter = startResult.interpreter;
    return _observer.toExecutionStep(0);
  }

  @override
  ExecutionStep step() {
    final interpreter = _interpreter;
    if (interpreter == null) return const ExecutionStep.exhausted();

    _stepCounter++;
    return switch (interpreter.step()) {
      StepAdvanced() => _observer.toExecutionStep(_stepCounter),
      StepAwaitingInput() => _awaitingInput(),
      StepHalted(:final diagnostic) => _halted(diagnostic),
      StepFinished() => _finished(),
    };
  }

  @override
  ExecutionStep provideInput(String rawInput) {
    if (_interpreter == null) return step();
    _observer.isAwaitingInput = false;
    _interpreter!.provideInput(rawInput);
    return step();
  }

  @override
  void stop() {
    _interpreter = null;
  }

  ExecutionStep _unstarted() {
    _interpreter = null;
    return const ExecutionStep.unstarted();
  }

  ExecutionStep _awaitingInput() {
    _observer.isAwaitingInput = true;
    return _observer.toExecutionStep(_stepCounter, inputPrompt: _designatorText());
  }

  String? _designatorText() {
    final designatorId = _observer.inputDesignatorId;
    if (designatorId == null) return null;
    final span = _observer.spanOf(designatorId);
    if (span == null || span.end.offset > _sourceCode.length) return null;
    return _sourceCode.substring(span.start.offset, span.end.offset);
  }

  ExecutionStep _halted(Diagnostic diagnostic) {
    _observer.isHalted = true;
    return _observer.toExecutionStep(
      _stepCounter,
      haltReason: _renderer?.render(diagnostic),
    );
  }

  ExecutionStep _finished() {
    _observer.isFinished = true;
    return _observer.toExecutionStep(_stepCounter);
  }
}
