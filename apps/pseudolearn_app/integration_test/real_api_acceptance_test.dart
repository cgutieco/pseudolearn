import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pseudolearn_app/application/execution/execution_cubit.dart';
import 'package:pseudolearn_app/application/execution/step_pace.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_configuration.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/rust/native_rust_transport.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_execution.dart';
import 'package:pseudolearn_app/host/local_execution_environment.dart';

const bool enabled = bool.fromEnvironment('PSEUDOLEARN_ACCEPTANCE');

const String characterProgram = '''SubProceso PrintField(document Como ValorJson, key Como Cadena)
Segun document.Campo(key) Hacer
Algo(value):
Segun value.ComoCadena() Hacer
Algo(content): Escribir content;
Nada: Escribir "invalid_type";
FinSegun
Nada: Escribir "missing_field";
FinSegun
FinSubProceso
SubProceso Fetch() Como Resultado<Entero, ErrorES>
Definir net Como RedCap <- Propagar SolicitarRed();
Definir response Como RespuestaHttp <- Propagar net.Enviar(PeticionHttp(MetodoHttp.GET, "https://rickandmortyapi.com/api/character/1"));
Escribir response.Estado();
Definir body Como Cadena <- Propagar response.CuerpoTexto();
Segun AnalizarJson(body) Hacer
Exito(document): PrintField(document, "name"); PrintField(document, "status");
Error(problem): Escribir problem.Codigo;
FinSegun
Retornar Exito(0);
FinSubProceso
Algoritmo Main
Segun Fetch() Hacer
Exito(value):
Error(problem): Escribir problem.Codigo;
FinSegun
FinAlgoritmo
''';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('acceptance program reaches the real API without configuration', (
    tester,
  ) async {
    await initializeNativeBridge();
    final root = await Directory.systemTemp.createTemp('pseudolearn_accept');
    addTearDown(() => root.delete(recursive: true));
    final execution = RustProgramExecution(
      openNativeTransport(),
      environment: LocalExecutionEnvironment(root.path),
    );
    await tester.runAsync(() async {
      await ExecutionCubit(execution: execution).advance(
        pace: StepPace.toEnd,
        sourceCode: characterProgram,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
        configuration: const ExecutionConfiguration(documentId: 'doc'),
      );
    });
    final lines = execution.outputLines.map((line) => line.text).toList();
    debugPrint('ACCEPTANCE OUTPUT $lines');
    expect(lines, ['200', 'Rick Sanchez', 'Alive']);
    execution.stop();
  }, skip: !enabled);
}
