import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/composition/rust_engine_services.dart';
import 'package:pseudolearn_app/domain/model/program/program_run_request.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/rust/native_rust_transport.dart';

void main() {
  setUpAll(initializeNativeBridge);

  List<String> runForAgent(String source) {
    final transport = openNativeTransport();
    addTearDown(transport.close);
    final runner = buildRustEngineServices(transport).programTools.runner;
    final report = runner.run(
      ProgramRunRequest(
        sourceCode: source,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      ),
    );
    return report.outputs;
  }

  test('the agent runner refuses network effects', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    var requests = 0;
    server.listen((request) {
      requests++;
      request.response.write('ok');
      request.response.close();
    });
    addTearDown(() => server.close(force: true));
    final outputs = runForAgent('''SubProceso Probe() Como Resultado<Entero, ErrorES>
Definir net Como RedCap <- Propagar SolicitarRed();
Definir response Como RespuestaHttp <- Propagar net.Enviar(PeticionHttp(MetodoHttp.GET, "http://127.0.0.1:${server.port}/"));
Retornar Exito(response.Estado());
FinSubProceso
Algoritmo Main
Segun Probe() Hacer
Exito(value): Escribir value;
Error(problem): Escribir problem.Codigo;
FinSegun
FinAlgoritmo
''');
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(requests, 0);
    expect(outputs, ['permiso_denegado']);
  });

  test('the agent runner refuses to open a directory outside the program', () async {
    final root = await Directory.systemTemp.createTemp('pgb-agent-');
    addTearDown(() => root.delete(recursive: true));
    final outputs = runForAgent('''SubProceso Probe() Como Resultado<Entero, ErrorES>
Definir directory Como DirectorioCap <- Propagar SolicitarDirectorio("${root.path}");
Definir file Como ArchivoCap <- Propagar directory.Abrir("marca.txt", "escritura");
Retornar Exito(1);
FinSubProceso
Algoritmo Main
Segun Probe() Hacer
Exito(value): Escribir value;
Error(problem): Escribir problem.Codigo;
FinSegun
FinAlgoritmo
''');
    expect(File('${root.path}/marca.txt').existsSync(), isFalse);
    expect(outputs, ['permiso_denegado']);
  });

  test('the agent runner still writes to the console', () {
    final outputs = runForAgent('''Algoritmo Main
Escribir "hola";
FinAlgoritmo
''');
    expect(outputs, ['hola']);
  });
}
