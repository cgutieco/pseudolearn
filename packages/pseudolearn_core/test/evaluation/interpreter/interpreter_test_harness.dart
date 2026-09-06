import 'package:pseudolearn_core/pseudolearn_core.dart';

AnalyzedProgram analyzeProgram(
  String source, {
  LanguageProfile profile = const ClassicSpanishProfile.flexible(),
}) {
  final lexerResult = Lexer(profile).tokenize(source);
  final parseResult = Parser().parse(TokenStream(lexerResult.tokens));
  final sourceUnit = parseResult.program!;
  final resolution = NameResolver(profile: profile).resolve(sourceUnit);
  final typeCheck =
      TypeChecker(resolution: resolution, profile: profile).check(sourceUnit);
  return AnalyzedProgram(
    sourceUnit: sourceUnit,
    syntaxDiagnostics: [...lexerResult.diagnostics, ...parseResult.diagnostics],
    resolution: resolution,
    typeCheck: typeCheck,
    profile: profile,
  );
}

Interpreter readyInterpreter(
  String source, {
  LanguageProfile profile = const ClassicSpanishProfile.flexible(),
  RecordingExecutionObserver? observer,
  RandomSource? random,
}) {
  final program = analyzeProgram(source, profile: profile);
  final result = Interpreter.start(
    program: program,
    observer: observer,
    random: random,
  );
  if (result is ExecutionNotExecutable) {
    throw StateError(
      'Interpreter.start failed (${result.reason}):\n'
      'Syntax diags: ${program.syntaxDiagnostics}\n'
      'TypeCheck diags: ${program.typeCheck.diagnostics}',
    );
  }
  return (result as ExecutionReady).interpreter;
}

final class RunResult {
  final List<ExecutionEvent> events;
  final String output;
  final StepOutcome finalOutcome;

  const RunResult(
      {required this.events, required this.output, required this.finalOutcome});

  Diagnostic get haltDiagnostic => (finalOutcome as StepHalted).diagnostic;
}

RunResult runProgram(
  String source, {
  LanguageProfile profile = const ClassicSpanishProfile.flexible(),
  List<String> inputs = const [],
  int? seed,
}) {
  final observer = RecordingExecutionObserver();
  final interpreter = readyInterpreter(
    source,
    profile: profile,
    observer: observer,
    random: seed != null ? SeededRandomSource(seed) : null,
  );
  var inputIndex = 0;
  final outcome = const ProgramRunner().runToCompletion(
    interpreter,
    provideInput: (_) => inputs[inputIndex++],
  );
  final output = observer.events
      .whereType<OutputProducedEvent>()
      .map((e) => e.text)
      .join();
  return RunResult(
      events: observer.events, output: output, finalOutcome: outcome);
}
