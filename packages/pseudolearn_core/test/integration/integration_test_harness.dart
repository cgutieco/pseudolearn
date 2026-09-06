import 'package:pseudolearn_core/pseudolearn_core.dart';

final class IntegrationPipelineResult {
  final LexerResult lexerResult;
  final ParseResult parseResult;
  final ResolutionResult? resolutionResult;
  final TypeCheckResult? typeCheckResult;
  final AnalyzedProgram? analyzedProgram;
  final ExecutionStartResult? executionResult;
  final RunResult? runResult;

  const IntegrationPipelineResult({
    required this.lexerResult,
    required this.parseResult,
    this.resolutionResult,
    this.typeCheckResult,
    this.analyzedProgram,
    this.executionResult,
    this.runResult,
  });

  List<Diagnostic> get allDiagnostics {
    final list = <Diagnostic>[
      ...lexerResult.diagnostics,
      ...parseResult.diagnostics,
      if (resolutionResult != null) ...resolutionResult!.diagnostics,
      if (typeCheckResult != null) ...typeCheckResult!.diagnostics,
      if (runResult?.finalOutcome is StepHalted)
        (runResult!.finalOutcome as StepHalted).diagnostic,
    ];
    return list;
  }

  bool get hasErrors => allDiagnostics.any((d) => d.severity == Severity.error);

  String get output => runResult?.output ?? '';

  List<ExecutionEvent> get events => runResult?.events ?? const [];

  StepOutcome? get finalOutcome => runResult?.finalOutcome;
}

final class RunResult {
  final List<ExecutionEvent> events;
  final String output;
  final StepOutcome finalOutcome;

  const RunResult({
    required this.events,
    required this.output,
    required this.finalOutcome,
  });

  Diagnostic get haltDiagnostic => (finalOutcome as StepHalted).diagnostic;
}

IntegrationPipelineResult runPipeline(
  String source, {
  LanguageProfile profile = const ClassicSpanishProfile.flexible(),
  List<String> inputs = const [],
  int? seed,
  RecordingExecutionObserver? observer,
}) {
  final lexerResult = Lexer(profile).tokenize(source);
  final parseResult = Parser(profile: profile).parse(TokenStream(lexerResult.tokens));

  final syntaxDiagnostics = [
    ...lexerResult.diagnostics,
    ...parseResult.diagnostics,
  ];
  final hasSyntaxErrors =
      syntaxDiagnostics.any((d) => d.severity == Severity.error);

  if (parseResult.program == null || hasSyntaxErrors) {
    return IntegrationPipelineResult(
      lexerResult: lexerResult,
      parseResult: parseResult,
    );
  }

  final sourceUnit = parseResult.program!;
  final resolution = NameResolver(profile: profile).resolve(sourceUnit);

  if (resolution.hasErrors) {
    return IntegrationPipelineResult(
      lexerResult: lexerResult,
      parseResult: parseResult,
      resolutionResult: resolution,
    );
  }

  final typeCheck =
      TypeChecker(resolution: resolution, profile: profile).check(sourceUnit);

  final analyzedProgram = AnalyzedProgram(
    sourceUnit: sourceUnit,
    syntaxDiagnostics: syntaxDiagnostics,
    resolution: resolution,
    typeCheck: typeCheck,
    profile: profile,
  );

  final effectiveObserver = observer ?? RecordingExecutionObserver();
  final executionResult = Interpreter.start(
    program: analyzedProgram,
    observer: effectiveObserver,
    random: seed != null ? SeededRandomSource(seed) : null,
  );

  if (executionResult is! ExecutionReady) {
    return IntegrationPipelineResult(
      lexerResult: lexerResult,
      parseResult: parseResult,
      resolutionResult: resolution,
      typeCheckResult: typeCheck,
      analyzedProgram: analyzedProgram,
      executionResult: executionResult,
    );
  }

  final interpreter = executionResult.interpreter;
  var inputIndex = 0;
  final outcome = const ProgramRunner().runToCompletion(
    interpreter,
    provideInput: (_) => inputs[inputIndex++],
  );

  final output = effectiveObserver.events
      .whereType<OutputProducedEvent>()
      .map((e) => e.text)
      .join();

  return IntegrationPipelineResult(
    lexerResult: lexerResult,
    parseResult: parseResult,
    resolutionResult: resolution,
    typeCheckResult: typeCheck,
    analyzedProgram: analyzedProgram,
    executionResult: executionResult,
    runResult: RunResult(
      events: effectiveObserver.events,
      output: output,
      finalOutcome: outcome,
    ),
  );
}
