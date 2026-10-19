import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_branch.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_focus.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_execution.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';

import '../../fakes/fake_rust_transport.dart';

const String source = 'Algoritmo P\nEscribir 1;\nFinAlgoritmo\n';

Map<String, Object?> node(
  String id,
  String kind,
  int line, {
  List<String> children = const [],
  String? parent,
}) => {
  'node_id': id,
  'kind': kind,
  'span': {
    'start': {'line': line, 'column': 1},
    'end': {'line': line, 'column': 5},
  },
  'child_node_ids': children,
  'parent_node_id': ?parent,
};

Map<String, Object?> event(
  String name, {
  String? node,
  int depth = 1,
  Map<String, Object?>? data,
}) => {
  'class': name,
  'line': 2,
  'depth': depth,
  'data': ?data,
  'source': node == null ? null : {'node_id': node},
};

Map<String, Object?> batch(
  List<Map<String, Object?>> events,
  Map<String, Object?> termination, [
  List<Map<String, Object?>> diagnostics = const [],
]) => {
  'events': events,
  'termination': termination,
  'diagnostics': diagnostics,
};

FakeRustTransport transportWith({
  required List<Map<String, Object?>> batches,
  List<Map<String, Object?>>? nodes,
  List<Map<String, Object?>> diagnostics = const [],
  Map<String, FakeRustHandler> extra = const {},
}) {
  var next = 0;
  return FakeRustTransport({
    'create_analysis': (_) => {'resource': 2, 'document': 1},
    'analysis': (_) => {'tree': true, 'diagnostics': diagnostics},
    'program_view': (_) => {
      'revision_id': 'rev1',
      'nodes':
          nodes ??
          [
            node('n0', 'declaration', 1, children: ['n1']),
            node('n1', 'statement', 2, parent: 'n0'),
          ],
    },
    'start': (_) => {'resource': 3},
    'advance': (_) =>
        batches[next < batches.length ? next++ : batches.length - 1],
    'query_frame': (arguments) => arguments['frame'] == 0
        ? {'unidad': 'P', 'variables': <String, Object?>{}}
        : throw const RustBridgeFailure(family: 'usage', detail: 'frame'),
    'input': (_) => null,
    'cancel': (_) => null,
    'release': (_) => null,
    ...extra,
  });
}

RustProgramExecution start(FakeRustTransport transport) {
  final execution = RustProgramExecution(transport);
  execution.startExecution(
    sourceCode: source,
    profileId: SyntaxProfileId.classicSpanish,
    languageId: UiLanguageId.spanish,
  );
  return execution;
}

void main() {
  group('RustProgramExecution', () {
    test('projects statement focus, output and completion', () {
      final execution = start(
        transportWith(
          batches: [
            batch(
              [
                event('statement_entered', node: 'n1'),
                event('output', node: 'n1', data: {'texto': '1\n'}),
                event('statement_exited', node: 'n1'),
              ],
              {'kind': 'completed'},
            ),
          ],
        ),
      );
      final entered = execution.step();
      expect(entered.focus?.startLine, 2);
      expect(entered.focus?.kind, ExecutionFocusKind.statement);
      expect(entered.blockPosition.depth, 1);
      final output = execution.step();
      expect(output.focusRevision, entered.focusRevision);
      expect(execution.outputLines.map((line) => line.text), ['1']);
      execution.step();
      final done = execution.step();
      expect(done.isFinished, isTrue);
      expect(done.isTerminal, isTrue);
    });

    test('container statements do not change the focus', () {
      final execution = start(
        transportWith(
          nodes: [
            node('n0', 'declaration', 1, children: ['n1']),
            node('n1', 'statement', 2, children: ['n2'], parent: 'n0'),
            node('n2', 'statement', 3, parent: 'n1'),
          ],
          batches: [
            batch(
              [
                event('statement_entered', node: 'n1'),
                event('statement_entered', node: 'n2', depth: 1),
              ],
              {'kind': 'completed'},
            ),
          ],
        ),
      );
      final container = execution.step();
      expect(container.focus, isNull);
      expect(container.focusRevision, 0);
      expect(container.blockPosition.depth, 1);
      final inner = execution.step();
      expect(inner.focus?.startLine, 3);
      expect(inner.blockPosition.enclosingNodeId, isNotNull);
    });

    test('decisions carry their branch', () {
      final execution = start(
        transportWith(
          batches: [
            batch(
              [
                event(
                  'decision',
                  node: 'n1',
                  data: {'rama': 'caso', 'indice': 2},
                ),
              ],
              {'kind': 'completed'},
            ),
          ],
        ),
      );
      final step = execution.step();
      expect(step.focus?.kind, ExecutionFocusKind.decision);
      expect(step.focus?.branch?.kind, ExecutionBranchKind.selectedCase);
      expect(step.focus?.branch?.caseIndex, 2);
    });

    test('awaits input with a prompt and resumes after it', () {
      final execution = start(
        transportWith(
          batches: [
            batch(
              [event('input_requested', node: 'n1')],
              {'kind': 'awaiting_input'},
            ),
            batch(
              [
                event('input_received', node: 'n1', data: {'texto': '5'}),
              ],
              {'kind': 'completed'},
            ),
          ],
        ),
      );
      expect(execution.step().isAwaitingInput, isFalse);
      final waiting = execution.step();
      expect(waiting.isAwaitingInput, isTrue);
      expect(waiting.inputPrompt, 'Escr');
      execution.provideInput('5');
      expect(execution.outputLines.map((line) => line.text), ['5']);
      expect(execution.step().isFinished, isTrue);
    });

    test('failures halt with the rendered message', () {
      final execution = start(
        transportWith(
          batches: [
            batch(
              [],
              {'kind': 'failed', 'code': 'divisionByZero'},
              [
                {'message': 'División entre cero'},
              ],
            ),
          ],
        ),
      );
      final halted = execution.step();
      expect(halted.isHalted, isTrue);
      expect(halted.haltReason, 'División entre cero');
    });

    test('a failure without diagnostics falls back to the code', () {
      final execution = start(
        transportWith(
          batches: [
            batch([], {'kind': 'failed', 'code': 'boom'}),
          ],
        ),
      );
      expect(execution.step().haltReason, 'boom');
    });

    test('host limits surface as step limit reached', () {
      final execution = start(
        transportWith(
          batches: [
            batch([], {'kind': 'limit_reached', 'limit': 'statements'}),
          ],
        ),
      );
      expect(execution.step().isStepLimitReached, isTrue);
    });

    test('programs with errors are not started and release resources', () {
      final transport = transportWith(
        batches: const [],
        diagnostics: [
          {'severity': 'error'},
        ],
      );
      final execution = RustProgramExecution(transport);
      final first = execution.startExecution(
        sourceCode: source,
        profileId: SyntaxProfileId.english,
        languageId: UiLanguageId.english,
      );
      expect(first.isHalted, isTrue);
      expect(transport.calls, contains('release'));
      expect(execution.step().isFinished, isTrue);
    });

    test('stop cancels, releases once and exhausts later steps', () {
      final transport = transportWith(
        batches: [
          batch([event('statement_entered', node: 'n1')], {'kind': 'running'}),
        ],
      );
      final execution = start(transport);
      execution.step();
      execution.stop();
      execution.stop();
      expect(transport.calls.where((call) => call == 'cancel'), hasLength(1));
      expect(transport.calls.where((call) => call == 'release'), hasLength(1));
      expect(execution.step().isFinished, isTrue);
      expect(execution.outputLines, isEmpty);
    });

    test(
      'watch rows describe values, arrays, objects, absent values and aliases',
      () {
        final execution = start(
          transportWith(
            batches: [
              batch(
                [event('statement_entered', node: 'n1')],
                {'kind': 'completed'},
              ),
            ],
            extra: {
              'query_frame': (arguments) => arguments['frame'] == 0
                  ? {
                      'unidad': 'P',
                      'variables': {
                        'n': {'valor': '4', 'tipo': 'entero'},
                    's': {'valor': 'hi', 'tipo': 'texto'},
                    'c': {'valor': 'x', 'tipo': 'caracter'},
                        'v': {'ref': 1},
                        'o': {'ref': 2},
                        'x': {'sin_valor': true},
                        'z': {'nulo': true},
                        'p': {
                          'alias': {'marco': 0, 'variable': 'n'},
                        },
                      },
                    }
                  : throw const RustBridgeFailure(
                      family: 'usage',
                      detail: 'frame',
                    ),
              'query_page': (arguments) => arguments['target'] == 1
                  ? {'total': 6, 'dimensions': [2, 3]}
                  : throw const RustBridgeFailure(
                      family: 'usage',
                      detail: 'array',
                    ),
              'query_object': (_) => {
                'clase': 'Vehiculo',
                'campos': <String, Object?>{},
              },
            },
          ),
        );
        final rows = {
          for (final row in execution.step().variables) row.name: row,
        };
        expect(rows['n']?.formattedValue, '4');
      expect(rows['s']?.formattedValue, '"hi"');
      expect(rows['c']?.formattedValue, "'x'");
        expect(rows['v']?.formattedValue, '[2x3]');
        expect(rows['v']?.identityBadge, 1);
        expect(rows['o']?.formattedValue, 'Vehiculo#2');
        expect(rows['x']?.isAbsent, isTrue);
        expect(rows['z']?.isAbsent, isTrue);
        expect(rows['p']?.formattedValue, '4');
      },
    );

    test('unexpected bridge failures propagate', () {
      final transport = transportWith(
        batches: const [],
        extra: {
          'advance': (_) =>
              throw const RustBridgeFailure(family: 'internal', detail: 'x'),
        },
      );
      final execution = start(transport);
      expect(execution.step, throwsA(isA<RustBridgeFailure>()));
    });
  });
}
