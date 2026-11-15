import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/execution/effect_settlement.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_task_context.dart';

import 'task_scene_runner.dart';

void main() {
  for (final language in SceneLanguage.values) {
    group('task scenes · ${language.suffix}', () {
      test(
        'identities: one subprogram, one task waits and the other runs',
        () async {
          final run = TaskSceneRun.open();
          final step = run.until(
            run.start(sceneSource('identities', language), language),
            (step) => step.isAwaitingEffect,
          );

          expect(step.pendingEffect?.operation, 'request_timer');
          expect(taskOf(step, 1).status.isTerminal, isFalse);
          expect(taskOf(step, 2).status, ExecutionTaskStatus.completed);
          expect(taskOf(step, 0).status, ExecutionTaskStatus.suspended);
          expect(run.lines, ['2']);
          expect(taskOf(step, 1).scopeName, contains('Worker'));
          expect(taskOf(step, 2).scopeName, contains('Worker'));
          expect(taskOf(step, 1).frames, isNotEmpty);

          final end = await run.untilSettled(
            run.execution.settleEffect(EffectSettlement.resolve),
            (step) => step.isFinished,
          );
          expect(end.isFinished, isTrue);
          expect(run.lines, ['2', '1']);
          expect(taskOf(end, 1).status, ExecutionTaskStatus.completed);
          run.execution.stop();
        },
      );

      test('failure: a recoverable error cancels the sibling only', () {
        final run = TaskSceneRun.open();
        final end = run.until(
          run.start(sceneSource('failure', language), language),
          (step) => step.isFinished,
        );

        expect(end.isFinished, isTrue);
        expect(taskOf(end, 0).status, ExecutionTaskStatus.completed);
        expect(taskOf(end, 1).status, ExecutionTaskStatus.cancelled);
        expect(taskOf(end, 2).status, ExecutionTaskStatus.completed);
        expect(taskOf(end, 2).completionOutcome, 'error');
        expect(run.lines, isEmpty);
        run.execution.stop();
      });

      test('channel: a full channel makes the sender wait and keeps order', () {
        final run = TaskSceneRun.open();
        final end = run.until(
          run.start(sceneSource('channel', language), language),
          (step) => step.isFinished,
        );

        expect(end.isFinished, isTrue);
        expect(run.lines, ['81', '82', '83']);
        final blocked = eventsOf(run.events, 'task_suspended', 1);
        expect(blocked.map((event) => event.data['cause']), ['channel_send']);
        expect(taskOf(end, 1).status, ExecutionTaskStatus.completed);
        run.execution.stop();
      });

      test('select: two ready branches choose the first textual one', () {
        final run = TaskSceneRun.open();
        final end = run.until(
          run.start(sceneSource('select', language), language),
          (step) => step.isFinished,
        );

        expect(end.isFinished, isTrue);
        expect(run.lines, ['81']);
        run.execution.stop();
      });

      test('cancellation: the host cut keeps cleanups unexecuted', () {
        final run = TaskSceneRun.open();
        final waiting = run.until(
          run.start(sceneSource('cancellation', language), language),
          (step) => step.isAwaitingEffect,
        );
        expect(waiting.isAwaitingEffect, isTrue);

        final cut = run.execution.settleEffect(EffectSettlement.cancel);

        expect(cut.isCancelled, isTrue);
        expect(taskOf(cut, 0).status, ExecutionTaskStatus.cancelledByHost);
        expect(taskOf(cut, 1).status, ExecutionTaskStatus.interruptedByHost);
        expect(taskOf(cut, 2).status, ExecutionTaskStatus.interruptedByHost);
        expect(run.lines, ['before']);
        run.execution.stop();
      });

      test(
        'revision: a new run gets another revision and drops the old one',
        () {
          final first = sceneSource('identities', language);
          final second = first.replaceFirst('Worker(2)', 'Worker(5)');
          final run = TaskSceneRun.open();
          run.until(
            run.start(first, language),
            (step) => step.isAwaitingEffect,
          );
          final firstRevision = run.resource.revisionId;
          final firstResource = run.resource.identifier;

          final step = run.until(
            run.start(second, language),
            (step) => step.isAwaitingEffect,
          );

          expect(run.resource.revisionId, isNot(firstRevision));
          expect(run.resource.identifier, isNot(firstResource));
          expect(run.lines, ['5']);
          expect(run.events.map((event) => event.revisionId).toSet(), {
            run.resource.revisionId,
          });
          expect(step.isAwaitingEffect, isTrue);
          run.execution.stop();
        },
      );
    });
  }
}
