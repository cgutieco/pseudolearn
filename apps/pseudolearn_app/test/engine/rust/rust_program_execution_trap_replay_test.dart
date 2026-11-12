import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/execution/execution_cubit.dart';
import 'package:pseudolearn_app/application/execution/execution_state.dart';
import 'package:pseudolearn_app/application/execution/step_pace.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_configuration.dart';
import 'package:pseudolearn_app/domain/model/execution/replay_rejection.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/rust/native_rust_transport.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_execution.dart';

const _firstArgument = '''
SubProceso First() Como Resultado<Cadena, ErrorES>
Definir arguments Como Argumentos <- Propagar SolicitarArgumentos();
Definir values Como Vector<Cadena> <- Propagar arguments.Valores();
Retornar Exito(values[0]);
FinSubProceso
Algoritmo Main
Segun First() Hacer
Exito(value): Escribir value;
Error(problem): Escribir problem.Codigo;
FinSegun
FinAlgoritmo
''';

Future<void> _run(
  ExecutionCubit cubit,
  String source, {
  bool replay = false,
  List<String> arguments = const [],
}) => cubit.advance(
  pace: StepPace.toEnd,
  sourceCode: source,
  profileId: SyntaxProfileId.classicSpanish,
  languageId: UiLanguageId.spanish,
  replay: replay,
  configuration: ExecutionConfiguration(
    documentId: 'trap',
    arguments: arguments,
  ),
);

void main() {
  setUpAll(initializeNativeBridge);

  late ExecutionCubit cubit;

  setUp(() {
    final transport = openNativeTransport();
    addTearDown(transport.close);
    cubit = ExecutionCubit(execution: RustProgramExecution(transport));
    addTearDown(cubit.close);
  });

  test('a run without arguments traps on the empty vector', () async {
    await _run(cubit, _firstArgument);

    expect(cubit.state.status, ExecutionStatus.haltedWithError);
    expect(cubit.state.currentStep.currentLine, 4);
    expect(cubit.state.haltMessage, contains('fuera de rango'));
    expect(cubit.state.recordedTape, isNotNull);
  });

  test('repeating a trapped run shows the same error at the same line', () async {
    await _run(cubit, _firstArgument);
    final recorded = cubit.state.haltMessage;

    await _run(cubit, _firstArgument, replay: true, arguments: const ['1']);

    expect(cubit.state.replayRejection, isNull);
    expect(cubit.state.status, ExecutionStatus.haltedWithError);
    expect(cubit.state.currentStep.currentLine, 4);
    expect(cubit.state.haltMessage, recorded);
  });

  test('repeating a trapped run after editing the code is rejected', () async {
    await _run(cubit, _firstArgument);

    await _run(
      cubit,
      _firstArgument.replaceFirst('values[0]', 'values[1]'),
      replay: true,
    );

    expect(cubit.state.replayRejection, ReplayRejection.identityMismatch);
  });
}
