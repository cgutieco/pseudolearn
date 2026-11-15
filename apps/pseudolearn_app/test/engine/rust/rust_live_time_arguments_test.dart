import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/execution/execution_cubit.dart';
import 'package:pseudolearn_app/application/execution/step_pace.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_configuration.dart';
import 'package:pseudolearn_app/domain/model/execution/effect_settlement.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/rust/native_rust_transport.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_execution.dart';

const _arguments = '''
subroutine Probe() as result<integer, IoError>
define arguments as Arguments <- propagate requestArguments();
define values as vector<string> <- propagate arguments.values();
for each value in values do
write "[" + value + "]";
endFor
return success(values.length());
endSubroutine
algorithm Main
switch Probe() do
success(value): write value;
failure(problem): write problem.code;
endSwitch
endAlgorithm
''';

const _time = '''
subroutine Probe() as result<boolean, IoError>
define clock as Clock <- propagate requestClock();
define timer as Timer <- propagate requestTimer();
define before as integer <- propagate clock.now();
define waited as integer <- propagate timer.wait(1000000000);
define after as integer <- propagate clock.now();
return success(after > before);
endSubroutine
algorithm Main
switch Probe() do
success(value): write value;
failure(problem): write problem.code;
endSwitch
endAlgorithm
''';

void main() {
  setUpAll(initializeNativeBridge);

  test('real arguments retain empty values spaces and Unicode', () async {
    final transport = openNativeTransport();
    addTearDown(transport.close);
    final execution = RustProgramExecution(transport);
    await _run(
      execution,
      _arguments,
      const ExecutionConfiguration(arguments: ['', 'two words', 'λ']),
    );
    expect(execution.outputLines.map((line) => line.text), [
      '[]',
      '[two words]',
      '[λ]',
      '3',
    ]);
    execution.stop();
  });

  test(
    'one second timer waits real time and fresh clock readings are recorded',
    () async {
      final transport = openNativeTransport();
      addTearDown(transport.close);
      final execution = RustProgramExecution(transport);
      final clock = Stopwatch()..start();
      await _run(execution, _time, const ExecutionConfiguration());
      expect(clock.elapsed, greaterThanOrEqualTo(const Duration(seconds: 1)));
      expect(execution.outputLines.map((line) => line.text), ['true']);
      expect(execution.recordedTape, isNotNull);
      execution.stop();
    },
  );

  test(
    'stopping during HTTP releases the pending host and closes the socket',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      final received = Completer<HttpRequest>();
      server.listen(received.complete);
      final transport = openNativeTransport();
      addTearDown(transport.close);
      final execution = RustProgramExecution(transport);
      final source =
          '''
subroutine Probe() as result<integer, IoError>
define net as NetworkCap <- propagate requestNetwork();
define response as HttpResponse <- propagate net.send(HttpRequest(HttpMethod.GET, "http://127.0.0.1:${server.port}/"));
return success(response.status());
endSubroutine
algorithm Main
switch Probe() do
success(value): write value;
failure(problem): write problem.code;
endSwitch
endAlgorithm
''';
      final cubit = ExecutionCubit(execution: execution);
      final running = cubit.advance(
        pace: StepPace.toEnd,
        sourceCode: source,
        profileId: SyntaxProfileId.english,
        languageId: UiLanguageId.english,
      );
      final request = await received.future.timeout(const Duration(seconds: 5));
      final cancelled = execution.settleEffect(EffectSettlement.cancel);
      cubit.stop();
      await running.timeout(const Duration(seconds: 2));
      expect(cancelled.isCancelled, isTrue);
      await request.response.close().catchError((Object _) {});
      await cubit.close();
    },
  );
}

Future<void> _run(
  RustProgramExecution execution,
  String source,
  ExecutionConfiguration configuration,
) async {
  final cubit = ExecutionCubit(execution: execution);
  await cubit.advance(
    pace: StepPace.toEnd,
    sourceCode: source,
    profileId: SyntaxProfileId.english,
    languageId: UiLanguageId.english,
    configuration: configuration,
  );
}
