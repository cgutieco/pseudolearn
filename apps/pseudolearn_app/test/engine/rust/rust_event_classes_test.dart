import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/engine/rust/rust_event_classes.dart';
import 'package:pseudolearn_app/engine/rust/rust_wire_models.dart';

Map<String, Object?> eventJson(
  String eventClass, [
  Map<String, Object?>? data,
]) => {'class': eventClass, 'line': 3, 'depth': 1, 'data': ?data};

Map<String, Object?> taskData(String eventClass) => switch (eventClass) {
  'task_spawned' => {'task': 1, 'parent': 0, 'scope': 0},
  'task_suspended' => {'task': 1, 'cause': 'join', 'target': 0},
  'task_ready' => {'task': 1, 'cause': 'spawn'},
  'task_resumed' => {'task': 1},
  'task_completed' => {'task': 1, 'outcome': 'success'},
  'task_cancel_requested' => {
    'task': 1,
    'reason': 'parent_cancelled',
    'origin': 0,
  },
  'scope_joined' => {'task': 0, 'outcome': 'success'},
  'channel_created' => {'channel': 1, 'capacity': 1},
  'channel_sent' => {'channel': 1},
  'channel_received' => {'channel': 1, 'present': true},
  'channel_closed' => {'channel': 1},
  'effect_delivered' => {'effect_seq': 1, 'delivery_seq': 1, 'task': 1},
  _ => const <String, Object?>{},
};

void main() {
  group('event classes', () {
    test('ordinary and task classes are all recognised', () {
      for (final eventClass in rustOrdinaryEventClasses) {
        expect(
          RustEvent.fromJson(eventJson(eventClass)).eventClass,
          eventClass,
        );
      }
      for (final eventClass in rustTaskEventClasses) {
        expect(
          RustEvent.fromJson(
            eventJson(eventClass, taskData(eventClass)),
          ).eventClass,
          eventClass,
        );
      }
      expect(rustTaskEventClasses, hasLength(12));
    });

    test('an unknown class is rejected', () {
      expect(
        () => RustEvent.fromJson(eventJson('task_teleported')),
        throwsFormatException,
      );
    });

    test(
      'task events expose typed fields and ordinary events are not task events',
      () {
        final spawned = RustEvent.fromJson(
          eventJson('task_spawned', {'task': 2, 'parent': 0, 'scope': 1}),
        );
        final task = RustTaskEvent.tryFrom(spawned)!;
        expect(task.task, 2);
        expect(task.intOf('parent'), 0);
        expect(task.intOf('absent'), isNull);
        final received = RustTaskEvent.tryFrom(
          RustEvent.fromJson(
            eventJson('channel_received', {'channel': 1, 'present': true}),
          ),
        )!;
        expect(received.channel, 1);
        expect(received.flagOf('present'), isTrue);
        expect(
          RustTaskEvent.tryFrom(
            RustEvent.fromJson(eventJson('output', {'texto': 'x'})),
          ),
          isNull,
        );
      },
    );

    test('malformed task fields and source revisions are rejected', () {
      expect(
        () => RustEvent.fromJson(eventJson('task_resumed', {'task': 1.5})),
        throwsFormatException,
      );
      expect(
        () => RustEvent.fromJson({
          ...eventJson('statement_entered'),
          'source': {'revision_id': 1, 'node_id': 'n1'},
        }),
        throwsFormatException,
      );
    });

    test('event source keeps revision and project identity', () {
      final event = RustEvent.fromJson({
        ...eventJson('statement_entered'),
        'source': {
          'revision_id': 'r1',
          'node_id': 'r1.n1',
          'identity': {'project_id': '2', 'revision_id': '3', 'source_id': 4},
        },
      });
      expect(event.sourceRevisionId, 'r1');
      expect(event.sourceIdentity?.projectId, '2');
      expect(event.sourceIdentity?.revisionId, '3');
      expect(event.sourceIdentity?.sourceId, 4);
      expect(event.nodeId, 'r1.n1');
    });
  });

  group('pending effects', () {
    Map<String, Object?> batch(List<Map<String, Object?>> pendings) => {
      'events': <Object?>[],
      'diagnostics': <Object?>[],
      'termination': {
        'kind': 'awaiting_effect',
        'effect_seq': 1,
        'capability_kind': 'timer',
        'operation': 'request_timer',
        'arguments_summary': '',
      },
      if (pendings.isNotEmpty) 'pending_effects': pendings,
    };

    test('a batch without concurrent effects has an empty pending list', () {
      expect(RustBatch.fromJson(batch(const [])).pendingEffects, isEmpty);
    });

    test('concurrent pending effects keep their task identity and order', () {
      final parsed = RustBatch.fromJson(
        batch([
          {'effect_seq': 1, 'task_id': 1, 'operation': 'request_timer'},
          {'effect_seq': 2, 'task_id': 2, 'operation': 'request_timer'},
        ]),
      );
      expect(parsed.pendingEffects.map((pending) => pending.taskId), [1, 2]);
      expect(parsed.pendingEffects.map((pending) => pending.effectSeq), [1, 2]);
    });
  });
}
