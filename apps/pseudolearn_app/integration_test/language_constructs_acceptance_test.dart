import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pseudolearn_app/composition/rust_engine_services.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/rust/native_rust_transport.dart';

const String languageConstructs =
    'Registro Punto\n'
    'Definir x, z Como Entero;\n'
    'FinRegistro\n'
    'Interfaz Medible<T>\n'
    'Metodo medir() Como T;\n'
    'FinInterfaz\n'
    'Clase Caja<T> Realiza Medible<T>\n'
    'Definir dato Como T;\n'
    'Definir origen Como Punto;\n'
    'Metodo Constructor(d Como T)\n'
    'Este.dato <- d;\n'
    'Este.origen <- Punto(1, 2);\n'
    'FinMetodo\n'
    'Metodo medir() Como T\n'
    'Retornar Este.dato;\n'
    'FinMetodo\n'
    'Metodo desplazar(p Como Punto) Como Punto\n'
    'Retornar Punto(p.x + Este.origen.x, p.z + Este.origen.z);\n'
    'FinMetodo\n'
    'FinClase\n'
    'Variante Forma\n'
    'Alternativa Circulo(radio Como Entero)\n'
    'Alternativa Vacia\n'
    'FinVariante\n'
    'SubProceso mover(p Como Punto Por Referencia)\n'
    'p.x <- p.x + 10;\n'
    'FinSubProceso\n'
    'SubProceso area(f Como Forma) Como Entero\n'
    'Definir Mutable total Como Entero <- 0;\n'
    'Segun f Hacer\n'
    'Forma.Circulo(r): total <- 3 * r * r;\n'
    'Forma.Vacia: total <- 0;\n'
    'FinSegun\n'
    'Retornar total;\n'
    'FinSubProceso\n'
    'Algoritmo Aceptacion\n'
    'Dimension puntos[2] Como Punto;\n'
    'puntos[0] <- Punto(3, 4);\n'
    'puntos[1] <- Punto(5, 6);\n'
    'mover(puntos[1]);\n'
    'Escribir puntos[0].x, ":", puntos[1].x;\n'
    'Definir c Como Caja<Entero> <- Nuevo Caja<Entero>(7);\n'
    'Escribir c.medir();\n'
    'Definir q Como Punto <- c.desplazar(puntos[0]);\n'
    'Escribir q.x, ":", q.z;\n'
    'Escribir area(Forma.Circulo(2)), ":", area(Forma.Vacia);\n'
    'Definir Mutable suma Como Entero <- 0;\n'
    'Para i <- 1 Hasta 100 Con Paso 1 Hacer\n'
    'Definir b Como Caja<Entero> <- Nuevo Caja<Entero>(i);\n'
    'suma <- suma + b.medir();\n'
    'FinPara\n'
    'Escribir suma;\n'
    'FinAlgoritmo\n';

const List<String> expectedLines = ['3:15', '7', '4:6', '12:0', '5050'];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'records, generic classes, declared variants and block objects run',
    verifyLanguageConstructs,
  );
}

Future<void> verifyLanguageConstructs(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await initializeNativeBridge();
  final transport = openNativeTransport();
  try {
    final services = buildRustEngineServices(transport);
    final execution = services.createProgramExecution();
    var step = execution.startExecution(
      sourceCode: languageConstructs,
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
