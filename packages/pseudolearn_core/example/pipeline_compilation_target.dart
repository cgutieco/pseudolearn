import 'package:pseudolearn_core/pseudolearn_core.dart';

const String _targetSource = '''
Clase Contador
  Definir valor Como Entero;

  Metodo Constructor(inicial Como Entero)
    Este.valor <- inicial;
  FinMetodo

  Metodo Incrementar(delta Como Entero)
    Este.valor <- Este.valor + delta;
  FinMetodo

  Metodo Obtener() Como Entero
    Retornar Este.valor;
  FinMetodo
FinClase

Algoritmo PipelineCompleto
  Definir c Como Contador;
  c <- Nuevo Contador(10);
  c.Incrementar(5);
  Escribir "Total: ", c.Obtener();
FinAlgoritmo
''';

void main() {
  final profile = const ClassicSpanishProfile.strict();
  final analyzedProgram = _analyzeSource(_targetSource, profile);
  _executeProgram(analyzedProgram);
}

AnalyzedProgram _analyzeSource(String source, LanguageProfile profile) {
  final lexResult = Lexer(profile).tokenize(source);
  final parseResult =
      Parser(profile: profile).parse(TokenStream(lexResult.tokens));

  if (parseResult.program == null) {
    throw StateError('Parsing failed unexpectedly in compilation target.');
  }

  final sourceUnit = parseResult.program!;
  final nodeIds = collectNodeIds(sourceUnit);
  if (nodeIds.isEmpty) {
    throw StateError('NodeId collection returned empty set.');
  }

  final resolution = NameResolver(profile: profile).resolve(sourceUnit);
  final typeCheck =
      TypeChecker(resolution: resolution, profile: profile).check(sourceUnit);

  final syntaxDiagnostics = [
    ...lexResult.diagnostics,
    ...parseResult.diagnostics,
  ];

  final analyzedProgram = AnalyzedProgram(
    sourceUnit: sourceUnit,
    syntaxDiagnostics: syntaxDiagnostics,
    resolution: resolution,
    typeCheck: typeCheck,
    profile: profile,
  );

  if (analyzedProgram.hasErrors) {
    throw StateError('Program has analysis errors.');
  }

  return analyzedProgram;
}

void _executeProgram(AnalyzedProgram analyzedProgram) {
  final observer = RecordingExecutionObserver();
  final startResult = Interpreter.start(
    program: analyzedProgram,
    observer: observer,
    random: SeededRandomSource(42),
  );

  if (startResult is! ExecutionReady) {
    throw StateError('Interpreter failed to start.');
  }

  final outcome =
      const ProgramRunner().runToCompletion(startResult.interpreter);
  if (outcome is! StepFinished) {
    throw StateError('Execution did not finish cleanly.');
  }

  final renderer = DiagnosticRenderer(
    locale: DiagnosticLocale.es,
    syntaxLexicon: analyzedProgram.profile,
  );

  for (final d in analyzedProgram.typeCheck.diagnostics) {
    renderer.render(d);
  }
}
