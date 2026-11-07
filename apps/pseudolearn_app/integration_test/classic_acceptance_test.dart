import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pseudolearn_app/composition/rust_engine_services.dart';
import 'package:pseudolearn_app/domain/model/execution/output_line.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/rust/native_rust_transport.dart';

const String classicProgram =
    'Funcion r <- Mayor(a Como Real, b Como Real)\n'
    'Definir r Como Real;\n'
    'Si a > b Entonces\n'
    'r <- a;\n'
    'Sino\n'
    'r <- b;\n'
    'FinSi\n'
    'FinFuncion\n'
    'Algoritmo Integrador\n'
    'Definir nombre, resp, dato Como Cadena;\n'
    'Definir cantidad, i, opcion Como Entero;\n'
    'Definir notas Como Real;\n'
    'Definir suma, mejor Como Real;\n'
    'Dimension notas[3];\n'
    'Leer nombre;\n'
    'Escribir Concatenar("Hola, ", Mayusculas(nombre));\n'
    'Escribir "Letras: ", Longitud(nombre), " Inicio: ", Subcadena(nombre, 0, 2);\n'
    'cantidad <- 3;\n'
    'suma <- 0;\n'
    'i <- 0;\n'
    'Mientras i < cantidad Hacer\n'
    'Leer dato;\n'
    'notas[i] <- ConvertirANumero(dato);\n'
    'suma <- suma + notas[i];\n'
    'i <- i + 1;\n'
    'FinMientras\n'
    'mejor <- notas[0];\n'
    'Para k <- 1 Hasta 2 Hacer\n'
    'mejor <- Mayor(mejor, notas[k]);\n'
    'FinPara\n'
    'Escribir "Promedio: ", suma / cantidad, " Mejor: ", mejor;\n'
    'Leer opcion;\n'
    'Segun opcion Hacer\n'
    '1: Escribir "Aprobado";\n'
    '2: Escribir "Revisar";\n'
    'De Otro Modo: Escribir "Sin opcion";\n'
    'FinSegun\n'
    'Leer resp;\n'
    'Si resp = "s" Entonces\n'
    'Escribir "Fin";\n'
    'Sino\n'
    'Escribir "Continuar";\n'
    'FinSi\n'
    'FinAlgoritmo\n';

const List<String> answers = ['Lucia', '7.5', '9', '6', '2', 's'];

const List<String> expectedLines = [
  'Hola, LUCIA',
  'Letras: 5 Inicio: Luc',
  'Promedio: 7.5 Mejor: 9.0',
  'Revisar',
  'Fin',
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('a classic program pasted without changes prints the derived output',
      verifyClassicProgram);
}

Future<void> verifyClassicProgram(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await initializeNativeBridge();
  final transport = openNativeTransport();
  try {
    final services = buildRustEngineServices(transport);
    final execution = services.createProgramExecution();
    final pending = List.of(answers);
    var step = execution.startExecution(
      sourceCode: classicProgram,
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
    );
    while (!step.isTerminal) {
      final wait = step.inputWait;
      step = wait == null
          ? execution.step()
          : execution.provideInput(wait, pending.removeAt(0));
    }
    expect(step.isFinished, isTrue);
    expect(pending, isEmpty);
    expect(
      execution.outputLines
          .where((line) => line.kind == OutputLineKind.programOutput)
          .map((line) => line.text),
      expectedLines,
    );
    expect(
      execution.outputLines
          .where((line) => line.kind == OutputLineKind.userInputEcho)
          .map((line) => line.text),
      answers,
    );
    execution.stop();
  } finally {
    transport.close();
  }
}
