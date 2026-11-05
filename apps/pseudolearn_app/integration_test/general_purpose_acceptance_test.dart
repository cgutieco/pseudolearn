import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pseudolearn_app/composition/rust_engine_services.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/rust/native_rust_transport.dart';

const String pureLibrary =
    'Algoritmo Main\n'
    'Escribir AMayusculas("straße"), ":", AMinusculas("ÉCOLE");\n'
    'Escribir min(3, 4), ":", max(2, 2.5), ":", piso(-0.5), ":", techo(-0.5);\n'
    'Escribir tan(0), ":", asen(0), ":", acos(1), ":", atan2(0, 1), ":", log10(1000), ":", log2(0.5);\n'
    'Escribir Decimales(0.125, 2), ":", Decimales(7, 2), ":", Decimales(-2.5, 0);\n'
    'Escribir RellenarIzquierda("7", 3, "0"), ":", RellenarDerecha("ab", 4, ".");\n'
    'Definir values Como Vector<Entero> <- Vector();\n'
    'values.Agregar(3); values.Agregar(-1); values.Agregar(2);\n'
    'values.Ordenar(); Escribir values[0], ":", values[1], ":", values[2];\n'
    'values.Invertir(); Escribir values[0], ":", values[2];\n'
    'Escribir values.Contiene(2);\n'
    'Segun values.PosicionDe(3) Hacer\n'
    'Nada: Escribir "none";\n'
    'Algo(index): Escribir index;\n'
    'FinSegun\n'
    'Definir dictionary Como Diccionario<Cadena,Entero> <- Diccionario();\n'
    'dictionary["bb"] <- 1; dictionary["aa"] <- 2;\n'
    'Definir names Como Vector<Cadena> <- dictionary.Claves();\n'
    'Escribir names[0], ":", names[1];\n'
    'Escribir FechaHoraUtc(0).FormatoIso();\n'
    'FinAlgoritmo\n';

const List<String> expectedLines = [
  'STRASSE:école',
  '3:2.5:-1:0',
  '0.0:0.0:0.0:0.0:3.0:-1.0',
  '0.13:7.00:-3',
  '007:ab..',
  '-1:2:3',
  '3:-1',
  'Verdadero',
  '0',
  'bb:aa',
  '1970-01-01T00:00:00Z',
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('general purpose library prints the values derived from the rules',
      verifyPureLibrary);
}

Future<void> verifyPureLibrary(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await initializeNativeBridge();
  final transport = openNativeTransport();
  try {
    final services = buildRustEngineServices(transport);
    final execution = services.createProgramExecution();
    var step = execution.startExecution(
      sourceCode: pureLibrary,
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
    );
    while (!step.isTerminal) {
      step = execution.step();
    }
    expect(step.isFinished, isTrue);
    expect(execution.outputLines.map((line) => line.text), expectedLines);
    execution.stop();
  } finally {
    transport.close();
  }
}
