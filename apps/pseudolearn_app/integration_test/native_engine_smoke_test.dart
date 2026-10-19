import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pseudolearn_app/composition/rust_engine_services.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_step.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/rust/native_rust_transport.dart';

const String program =
    'Algoritmo P\nDefinir amount Como Entero;\n'
    'Dimension values[2] Como Entero;\nLeer amount;\n'
    'values[0] <- amount;\nEscribir amount;\nFinAlgoritmo\n';

const String incompleteProgram = 'Algoritmo P\nEscri';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'native engine supports app language and execution flows',
    verifyNativeEngineFlows,
  );
}

Future<void> verifyNativeEngineFlows(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await initializeNativeBridge();
  final transport = openNativeTransport();
  try {
    final services = buildRustEngineServices(transport);
    verifyAnalysisAndCompletion(services);
    verifyExecutionInputAndArray(services);
  } finally {
    transport.close();
  }
}

void verifyAnalysisAndCompletion(RustEngineServices services) {
  final analysis = services.analyzer.analyze(
    sourceCode: program,
    profileId: SyntaxProfileId.classicSpanish,
    languageId: UiLanguageId.spanish,
  );
  expect(analysis.isExecutable, isTrue);
  final completion = services.contextualCompletionSource.complete(
    sourceCode: incompleteProgram,
    profileId: SyntaxProfileId.classicSpanish,
    cursorUtf16: incompleteProgram.length,
    revision: 1,
  );
  expect(completion.isSuccessful, isTrue);
  expect(completion.candidates, isNotEmpty);
}

void verifyExecutionInputAndArray(RustEngineServices services) {
  final execution = services.createProgramExecution();
  var step = execution.startExecution(
    sourceCode: program,
    profileId: SyntaxProfileId.classicSpanish,
    languageId: UiLanguageId.spanish,
  );
  var arrayVisible = false;
  while (!step.isAwaitingInput && !step.isTerminal) {
    arrayVisible = arrayVisible || hasArray(step);
    step = execution.step();
  }
  expect(step.isAwaitingInput, isTrue);
  expect(step.inputPrompt, 'amount');
  step = execution.provideInput('7');
  while (!step.isTerminal) {
    arrayVisible = arrayVisible || hasArray(step);
    step = execution.step();
  }
  arrayVisible = arrayVisible || hasArray(step);
  expect(step.isFinished, isTrue);
  expect(arrayVisible, isTrue);
  expect(execution.outputLines.map((line) => line.text), ['7', '7']);
  execution.stop();
}

bool hasArray(ExecutionStep step) => step.variables.any(
  (row) => row.name == 'values' && row.formattedValue == '[2]',
);
