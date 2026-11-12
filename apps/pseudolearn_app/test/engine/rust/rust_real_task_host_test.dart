import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/execution/execution_cubit.dart';
import 'package:pseudolearn_app/application/execution/step_pace.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/rust/native_rust_transport.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_execution.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';

const _concurrentScenes = {'live_http', 'live_order'};

void main() {
  setUpAll(initializeNativeBridge);
  for (final (suffix, profile) in [
    ('es', SyntaxProfileId.classicSpanish),
    ('en', SyntaxProfileId.english),
  ]) {
    for (final (scene, expected, requestsExpected) in [
      ('live_timer', ['sibling', 'timer', 'done'], 0),
      ('live_fetch', ['sibling', '200', 'done'], 1),
      ('live_order', ['fast', 'slow', 'done'], 2),
      ('live_http', ['sibling', 'timer', '200', 'done'], 1),
    ]) {
      test(
        '$scene leaves the sibling runnable in $suffix and replay never touches the host',
        () async {
          final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
          addTearDown(() => server.close(force: true));
          var requests = 0;
          server.listen((request) async {
            requests++;
            final slow = request.uri.path == '/slow';
            await Future<void>.delayed(Duration(milliseconds: slow ? 150 : 100));
            request.response.write('ok');
            await request.response.close();
          });
          final source = File('test/fixtures/task_scenes/${scene}_$suffix.pseudo')
              .readAsStringSync()
              .replaceAll('__ORIGIN__', 'http://127.0.0.1:${server.port}');
          final transport = _HostCounter(openNativeTransport());
          addTearDown(transport.close);
          final execution = RustProgramExecution(transport);
          final cubit = ExecutionCubit(execution: execution);
          await cubit.advance(
            pace: StepPace.toEnd,
            sourceCode: source,
            profileId: profile,
            languageId: UiLanguageId.english,
          );
          final output = execution.outputLines.map((line) => line.text).toList();
          expect(output, containsAll(expected));
          expect(output.first, scene == 'live_order' ? 'fast' : 'sibling');
          expect(output.last, 'done');
          expect(
            cubit.state.currentStep.taskContexts.every(
              (task) => task.status.isTerminal,
            ),
            isTrue,
          );
          final projection = execution.projection;
          final calls = transport.calls;
          expect(requests, requestsExpected);
          await cubit.advance(
            pace: StepPace.toEnd,
            sourceCode: source,
            profileId: profile,
            languageId: UiLanguageId.english,
            replay: true,
          );
          final replayed = execution.projection;
          if (_concurrentScenes.contains(scene)) {
            expect(replayed.output, projection.output);
            expect(replayed.termination, projection.termination);
            expect(replayed.failure, projection.failure);
          } else {
            expect(replayed.firstDivergence(projection), isNull);
          }
          expect(transport.calls, calls);
          expect(requests, requestsExpected);
          await cubit.close();
        },
      );
    }
  }
}

final class _HostCounter implements RustTransport {
  final RustTransport inner;
  int calls = 0;
  _HostCounter(this.inner);
  @override
  Object? call(String operation, Map<String, Object?> arguments) {
    if (operation.startsWith('host_')) calls++;
    return inner.call(operation, arguments);
  }

  @override
  void close() => inner.close();
}
