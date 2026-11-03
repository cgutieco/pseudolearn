import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/execution/execution_cubit.dart';
import 'package:pseudolearn_app/application/execution/step_pace.dart';
import 'package:pseudolearn_app/domain/model/execution/effect_tape.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_configuration.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/rust/native_rust_transport.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_execution.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';
import 'package:pseudolearn_app/host/local_execution_environment.dart';

void main() {
  setUpAll(initializeNativeBridge);

  test(
    'real loopback HTTP works without configuration and replay never opens the host',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      var requests = 0;
      server.listen((request) {
        requests++;
        request.response.write('ok');
        request.response.close();
      });
      addTearDown(() => server.close(force: true));
      final transport = _CountingTransport(openNativeTransport());
      addTearDown(transport.close);
      final execution = RustProgramExecution(transport);
      final source =
          '''SubProceso Probe() Como Resultado<Entero, ErrorES>
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
''';
      await _run(execution, source);
      expect(execution.outputLines.map((line) => line.text), ['200']);
      expect(requests, 1);
      final tape = execution.recordedTape!;
      final calls = transport.hostCalls;
      await _replay(execution, source, tape);
      expect(execution.outputLines.map((line) => line.text), ['200']);
      expect(requests, 1);
      expect(transport.hostCalls, calls);
      execution.stop();
    },
  );

  test('real files are read in the document working directory', () async {
    final root = await Directory.systemTemp.createTemp('pgb-document-');
    addTearDown(() => root.delete(recursive: true));
    final environment = LocalExecutionEnvironment(root.path);
    final directory = Directory(environment.directoryFor('doc'));
    await directory.create(recursive: true);
    await File('${directory.path}/datos.txt').writeAsString('PseudoLearn');
    final transport = openNativeTransport();
    addTearDown(transport.close);
    final execution = RustProgramExecution(transport, environment: environment);
    await _run(execution, '''SubProceso Probe() Como Resultado<Cadena, ErrorES>
Definir directory Como DirectorioCap <- Propagar SolicitarDirectorio(".");
Definir file Como ArchivoCap <- Propagar directory.Abrir("datos.txt", "lectura");
Retornar file.LeerTexto();
FinSubProceso
Algoritmo Main
Segun Probe() Hacer
Exito(value): Escribir value;
Error(problem): Escribir problem.Codigo;
FinSegun
FinAlgoritmo
''', configuration: const ExecutionConfiguration(documentId: 'doc'));
    expect(execution.outputLines.map((line) => line.text), ['PseudoLearn']);
    execution.stop();
  });
}

Future<void> _run(
  RustProgramExecution execution,
  String source, {
  ExecutionConfiguration configuration = const ExecutionConfiguration(),
}) async {
  final cubit = ExecutionCubit(execution: execution);
  await cubit.advance(
    pace: StepPace.toEnd,
    sourceCode: source,
    profileId: SyntaxProfileId.classicSpanish,
    languageId: UiLanguageId.spanish,
    configuration: configuration,
  );
}

Future<void> _replay(
  RustProgramExecution execution,
  String source,
  EffectTape tape,
) async {
  execution.startExecution(
    sourceCode: source,
    profileId: SyntaxProfileId.classicSpanish,
    languageId: UiLanguageId.spanish,
    replayTape: tape,
  );
  for (var count = 0; count < 1000; count++) {
    if (execution.step().isTerminal) return;
    await Future<void>.delayed(Duration.zero);
  }
  fail('Replay did not finish');
}

final class _CountingTransport implements RustTransport {
  final RustTransport inner;
  int hostCalls = 0;
  _CountingTransport(this.inner);
  @override
  Object? call(String operation, Map<String, Object?> arguments) {
    if (operation.startsWith('host_')) hostCalls++;
    return inner.call(operation, arguments);
  }

  @override
  void close() => inner.close();
}
