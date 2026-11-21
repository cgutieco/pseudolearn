import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pseudolearn_app/application/execution/execution_cubit.dart';
import 'package:pseudolearn_app/application/execution/step_pace.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_configuration.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/rust/native_rust_transport.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_execution.dart';
import 'package:pseudolearn_app/host/local_execution_environment.dart';

const String _smokeDocument = 'platform-host-smoke';

const String _fileRoundTrip = '''SubProceso Probe() Como Resultado<Cadena, ErrorES>
Definir directory Como DirectorioCap <- Propagar SolicitarDirectorio(".");
Definir file Como ArchivoCap <- Propagar directory.Abrir("salida.txt", "escritura");
Descartar file.EscribirTexto("dato ñandú");
Descartar file.Cerrar();
Definir reader Como ArchivoCap <- Propagar directory.Abrir("salida.txt", "lectura");
Retornar reader.LeerTexto();
FinSubProceso
Algoritmo Main
Segun Probe() Hacer
Exito(value): Escribir value;
Error(problem): Escribir problem.Codigo;
FinSegun
FinAlgoritmo
''';

String _httpsStatusProgram(String url) => '''SubProceso Probe() Como Resultado<Entero, ErrorES>
Definir net Como RedCap <- Propagar SolicitarRed();
Definir response Como RespuestaHttp <- Propagar net.Enviar(PeticionHttp(MetodoHttp.GET, "$url"));
Retornar Exito(response.Estado());
FinSubProceso
Algoritmo Main
Segun Probe() Hacer
Exito(value): Escribir value;
Error(problem): Escribir problem.Codigo;
FinSegun
FinAlgoritmo
''';

const String _localClock = '''Algoritmo Main
Segun SolicitarReloj() Hacer
Exito(clock):
Segun clock.AhoraLocal() Hacer
Exito(moment): Escribir moment.FormatoIso();
Error(problem): Escribir problem.Codigo;
FinSegun
Error(problem): Escribir problem.Codigo;
FinSegun
FinAlgoritmo
''';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(initializeNativeBridge);

  testWidgets('a program writes and reads its file inside the private documents folder', (tester) async {
    final documents = await getApplicationDocumentsDirectory();
    final environment = LocalExecutionEnvironment(documents.path);
    final folder = Directory(environment.directoryFor(_smokeDocument));
    await folder.create(recursive: true);
    addTearDown(() => folder.delete(recursive: true));

    final lines = await _outputOf(_fileRoundTrip, environment: environment);

    expect(lines, ['dato ñandú']);
    expect(p.isWithin(documents.path, folder.path), isTrue);
    expect(File(p.join(folder.path, 'salida.txt')).readAsStringSync(), 'dato ñandú');
  });

  testWidgets('HTTPS reaches a public server through the system trust store', (tester) async {
    final lines = await _outputOf(_httpsStatusProgram('https://www.gstatic.com/generate_204'));

    expect(lines, ['204']);
  });

  testWidgets('an expired certificate is refused without crashing the host', (tester) async {
    final lines = await _outputOf(_httpsStatusProgram('https://expired.badssl.com/'));

    expect(lines, ['certificado_invalido']);
  });

  testWidgets('the local clock carries the same offset the device reports', (tester) async {
    final lines = await _outputOf(_localClock);

    expect(lines, hasLength(1));
    expect(lines.single, endsWith(_isoOffset(DateTime.now().timeZoneOffset)));
  });
}

Future<List<String>> _outputOf(String source, {LocalExecutionEnvironment? environment}) async {
  final transport = openNativeTransport();
  addTearDown(transport.close);
  final execution = RustProgramExecution(transport, environment: environment);
  await ExecutionCubit(execution: execution).advance(
    pace: StepPace.toEnd,
    sourceCode: source,
    profileId: SyntaxProfileId.classicSpanish,
    languageId: UiLanguageId.spanish,
    configuration: const ExecutionConfiguration(documentId: _smokeDocument),
  );
  final lines = execution.outputLines.map((line) => line.text).toList();
  execution.stop();
  return lines;
}

String _isoOffset(Duration offset) {
  if (offset == Duration.zero) return 'Z';
  final sign = offset.isNegative ? '-' : '+';
  final minutes = offset.inMinutes.abs();
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '$sign${twoDigits(minutes ~/ 60)}:${twoDigits(minutes % 60)}';
}
