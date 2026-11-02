import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_branch.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_focus.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_step.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_task_context.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_execution.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_view.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_view_read_result.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';
import 'package:pseudolearn_app/engine/rust/source_offset_index.dart';

import '../../fakes/fake_rust_transport.dart';

const String source = 'Algoritmo P\nEscribir 1;\nFinAlgoritmo\n';

Map<String, Object?> node(
  String id,
  String kind,
  int line, {
  List<String> children = const [],
  String? parent,
  String? syntaxKind,
}) => {
  'node_id': _revisionNodeId(id),
  'kind': kind,
  'syntax_kind':
      syntaxKind ?? (kind == 'declaration' ? 'algorithm_unit' : 'output'),
  'span': {
    'start': {'line': line, 'column': 1},
    'end': {'line': line, 'column': 5},
  },
  'child_node_ids': [for (final child in children) _revisionNodeId(child)],
  'child_roles': [
    for (final child in children)
      {'node_id': _revisionNodeId(child), 'role': 'statement'},
  ],
  'parent_node_id': parent == null ? null : _revisionNodeId(parent),
};

String _revisionNodeId(String identifier) =>
    identifier.contains('.n') ? identifier : 'rev1.$identifier';

Map<String, Object?> spanForSource(
  Map<String, Object?> span,
  String sourceCode,
) {
  final lines = sourceCode.split('\n');
  final start = Map<String, Object?>.from(span['start'] as Map);
  final end = Map<String, Object?>.from(span['end'] as Map);
  final startLine = start['line'] as int;
  final endLine = end['line'] as int;
  final startColumn = (start['column'] as int).clamp(
    1,
    lines[startLine - 1].length + 1,
  );
  final endColumn = (end['column'] as int).clamp(
    1,
    lines[endLine - 1].length + 1,
  );
  start['column'] = startColumn;
  end['column'] = endColumn;
  final startByte = _sourceByteOffset(lines, startLine, startColumn);
  final endByte = _sourceByteOffset(lines, endLine, endColumn);
  return {
    ...span,
    'start': start,
    'end': end,
    'start_byte': '$startByte',
    'end_byte': '$endByte',
  };
}

int _sourceByteOffset(List<String> lines, int line, int column) {
  final previousBytes = lines
      .take(line - 1)
      .fold<int>(0, (total, value) => total + utf8.encode(value).length + 1);
  return previousBytes +
      utf8.encode(lines[line - 1].substring(0, column - 1)).length;
}

Map<String, Object?> _nodeForSource(
  Map<String, Object?> node,
  String sourceCode,
) => {
  ...node,
  'span': spanForSource(node['span'] as Map<String, Object?>, sourceCode),
};

Map<String, Object?> _unitForSource(
  Map<String, Object?> unit,
  String sourceCode,
) => {
  ...unit,
  'node_id': _revisionNodeId(unit['node_id'] as String),
  'span': spanForSource(unit['span'] as Map<String, Object?>, sourceCode),
};

Map<String, Object?> _memberForSource(Map<String, Object?> member) => {
  ...member,
  if (member['node_id'] case final String nodeId)
    'node_id': _revisionNodeId(nodeId),
};

Map<String, Object?> event(
  String name, {
  String? node,
  int depth = 1,
  Map<String, Object?>? data,
  String revision = 'rev1',
}) => {
  'class': name,
  'line': 2,
  'depth': depth,
  'data': ?data,
  'source': node == null
      ? null
      : {'revision_id': revision, 'node_id': _revisionNodeId(node)},
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
  List<Map<String, Object?>>? units,
  List<Map<String, Object?>>? members,
  List<Map<String, Object?>> diagnostics = const [],
  Map<String, FakeRustHandler> extra = const {},
}) {
  var next = 0;
  var activeSource = source;
  return FakeRustTransport({
    'create_analysis': (arguments) {
      activeSource = arguments['program'] as String;
      return {'resource': 2, 'document': 1};
    },
    'analysis': (_) => {'tree': true, 'diagnostics': diagnostics},
    'program_view': (_) {
      final view = <String, Object?>{
        'revision_id': 'rev1',
        'child_order': 'source',
        'units': [
          for (final unit
              in units ??
                  [
                    {
                      'kind': 'algorithm',
                      'name': 'P',
                      'order': 0,
                      'node_id': 'n0',
                      'span': {
                        'start': {'line': 1, 'column': 1},
                        'end': {'line': 3, 'column': 14},
                      },
                    },
                  ])
            _unitForSource(unit, activeSource),
        ],
        'nodes': [
          for (final item
              in nodes ??
                  [
                    node('n0', 'declaration', 1, children: ['n1']),
                    node('n1', 'statement', 2, parent: 'n0'),
                  ])
            _nodeForSource(item, activeSource),
        ],
        'members': [
          for (final member in members ?? <Map<String, Object?>>[])
            _memberForSource(member),
        ],
        'inheritance': <Object?>[],
        'methods': <Object?>[],
      };
      final result = RustProgramView.decode(
        view,
        SourceOffsetIndex(activeSource),
      );
      if (result case RustProgramViewReadFailure(:final kind, :final path)) {
        throw StateError('$kind: $path');
      }
      return view;
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

RustProgramExecution start(
  FakeRustTransport transport, {
  String sourceCode = source,
}) {
  final execution = RustProgramExecution(transport);
  execution.startExecution(
    sourceCode: sourceCode,
    profileId: SyntaxProfileId.classicSpanish,
    languageId: UiLanguageId.spanish,
  );
  return execution;
}

void main() {
  group('RustProgramExecution', () {
    test('task contexts keep independent stacks across event batches', () {
      final queryArguments = <Map<String, Object?>>[];
      final execution = start(
        transportWith(
          batches: [
            batch(
              [
                event('statement_entered', node: 'n1'),
                event('call', node: 'n1'),
                event(
                  'task_spawned',
                  data: {'task': 1, 'parent': 0, 'scope': 0},
                ),
                event('task_ready', data: {'task': 1, 'cause': 'spawn'}),
              ],
              {'kind': 'running'},
            ),
            batch(
              [
                event(
                  'task_suspended',
                  data: {'task': 0, 'cause': 'join', 'target': 0},
                ),
                event('task_resumed', data: {'task': 1}),
                event('statement_entered', node: 'n1'),
                event('call', node: 'n1'),
                event('statement_entered', node: 'n1'),
              ],
              {'kind': 'running'},
            ),
            batch(
              [
                event('return', node: 'n1'),
                event(
                  'task_completed',
                  data: {'task': 1, 'outcome': 'success'},
                ),
                event('task_ready', data: {'task': 0, 'cause': 'completion'}),
                event('task_resumed', data: {'task': 0}),
              ],
              {'kind': 'completed'},
            ),
          ],
          extra: {
            'query_frame': (arguments) {
              queryArguments.add(arguments);
              return {'unidad': 'P', 'variables': <String, Object?>{}};
            },
          },
        ),
      );
      final steps = <ExecutionStep>[];
      for (var index = 0; index < 20; index++) {
        final step = execution.step();
        steps.add(step);
        if (step.isTerminal) break;
      }

      final spawned = steps[2];
      final root = spawned.taskContexts.firstWhere((task) => task.taskId == 0);
      final child = spawned.taskContexts.firstWhere((task) => task.taskId == 1);
      expect(spawned.eventIndex, 2);
      expect(steps.first.taskId, 0);
      expect(spawned.taskId, 0);
      expect(root.frames, hasLength(2));
      expect(child.status, ExecutionTaskStatus.created);
      expect(child.frames, isEmpty);
      expect(child.focus, isNull);

      final recursive = steps[8];
      final recursiveChild = recursive.taskContexts.firstWhere(
        (task) => task.taskId == 1,
      );
      expect(recursive.taskId, 1);
      expect(recursiveChild.frames, hasLength(2));
      expect(recursiveChild.frames.last.statementNodes, [
        const ProgramNodeId(1),
      ]);

      final childSnapshot = steps[6].taskContexts.firstWhere(
        (task) => task.taskId == 1,
      );
      final suspendedRoot = steps[4].taskContexts.firstWhere(
        (task) => task.taskId == 0,
      );
      final resumedRoot = steps[12];
      final resumedRootContext = resumedRoot.taskContexts.firstWhere(
        (task) => task.taskId == 0,
      );
      final suspendedChild = resumedRoot.taskContexts.firstWhere(
        (task) => task.taskId == 1,
      );
      expect(resumedRoot.taskId, 0);
      expect(resumedRootContext.frames, hasLength(2));
      expect(suspendedRoot.status, ExecutionTaskStatus.suspended);
      expect(suspendedChild.status, ExecutionTaskStatus.completed);
      expect(suspendedChild.completionOutcome, 'success');
      expect(childSnapshot.status, ExecutionTaskStatus.running);
      expect(childSnapshot.frames, hasLength(1));
      expect(queryArguments.map((arguments) => arguments['task_id']), [
        0,
        0,
        0,
        1,
        1,
        1,
        1,
        1,
        0,
      ]);
      final finishedChild = steps.last.taskContexts.firstWhere(
        (task) => task.taskId == 1,
      );
      expect(finishedChild.status, ExecutionTaskStatus.completed);
      expect(finishedChild.completionOutcome, 'success');
    });

    test(
      'unknown tasks, foreign revisions and out-of-order events halt cleanly',
      () {
        final invalidBatches = [
          batch([event('return', node: 'n1')], {'kind': 'completed'}),
          batch(
            [
              event('task_resumed', data: {'task': 9}),
            ],
            {'kind': 'completed'},
          ),
          batch(
            [event('statement_entered', node: 'n1', revision: 'rev2')],
            {'kind': 'completed'},
          ),
          batch(
            [
              event('task_resumed', data: {'task': 1.5}),
            ],
            {'kind': 'completed'},
          ),
        ];

        for (final invalidBatch in invalidBatches) {
          final execution = start(transportWith(batches: [invalidBatch]));
          final result = execution.step();

          expect(result.isHalted, isTrue);
          expect(result.haltReason, isNotNull);
        }
      },
    );

    test('focus resolves top-level executable unit identifiers', () {
      const sourceCode =
          'Algoritmo P\nEscribir 1;\nFinAlgoritmo\n'
          'SubProceso S\nEscribir 2;\nFinSubProceso\n';
      final execution = start(
        transportWith(
          batches: [
            batch(
              [
                event('statement_entered', node: 'n1'),
                event('statement_entered', node: 'n3'),
              ],
              {'kind': 'completed'},
            ),
          ],
          nodes: [
            node('n0', 'declaration', 1, children: ['n1']),
            node('n1', 'statement', 2, parent: 'n0'),
            node(
              'n2',
              'declaration',
              4,
              children: ['n3'],
              syntaxKind: 'subroutine',
            ),
            node('n3', 'statement', 5, parent: 'n2'),
          ],
          units: [
            {
              'kind': 'algorithm',
              'name': 'P',
              'order': 0,
              'node_id': 'n0',
              'span': {
                'start': {'line': 1, 'column': 1},
                'end': {'line': 3, 'column': 14},
              },
            },
            {
              'kind': 'subprogram',
              'name': 'S',
              'order': 1,
              'node_id': 'n2',
              'span': {
                'start': {'line': 4, 'column': 1},
                'end': {'line': 6, 'column': 16},
              },
            },
          ],
        ),
        sourceCode: sourceCode,
      );

      expect(execution.step().focus?.unitId, 'alg_P');
      expect(execution.step().focus?.unitId, 'sub_S');
    });

    test('focus resolves class member identifiers', () {
      const sourceCode =
          'Clase C\nMetodo M()\nEscribir 1;\nFinMetodo\nFinClase\n'
          'Algoritmo P\nFinAlgoritmo\n';
      final execution = start(
        transportWith(
          batches: [
            batch(
              [event('statement_entered', node: 'n2')],
              {'kind': 'completed'},
            ),
          ],
          nodes: [
            node(
              'n0',
              'declaration',
              1,
              children: ['n1'],
              syntaxKind: 'class_unit',
            ),
            node(
              'n1',
              'declaration',
              2,
              children: ['n2'],
              syntaxKind: 'method',
            ),
            node('n2', 'statement', 3, parent: 'n1'),
            node('n3', 'declaration', 6, syntaxKind: 'algorithm_unit'),
          ],
          units: [
            {
              'kind': 'class',
              'name': 'C',
              'order': 0,
              'node_id': 'n0',
              'span': {
                'start': {'line': 1, 'column': 1},
                'end': {'line': 5, 'column': 9},
              },
            },
            {
              'kind': 'algorithm',
              'name': 'P',
              'order': 1,
              'node_id': 'n3',
              'span': {
                'start': {'line': 6, 'column': 1},
                'end': {'line': 7, 'column': 14},
              },
            },
          ],
          members: [
            {
              'class': 'C',
              'name': 'M',
              'kind': 'method',
              'visibility': 'public',
              'arity': 0,
              'node_id': 'n1',
            },
          ],
        ),
        sourceCode: sourceCode,
      );

      expect(execution.step().focus?.unitId, 'method_C_M');
    });

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
      expect(done.taskContexts.single.status, ExecutionTaskStatus.completed);
      expect(done.taskContexts.single.completionOutcome, 'success');
    });

    test('container statements do not change the focus', () {
      final execution = start(
        transportWith(
          nodes: [
            node('n0', 'declaration', 1, children: ['n1']),
            node(
              'n1',
              'statement',
              2,
              children: ['n2'],
              parent: 'n0',
              syntaxKind: 'conditional',
            ),
            node('n2', 'statement', 3, parent: 'n1', syntaxKind: 'output'),
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
                  ? {
                      'total': 6,
                      'dimensions': [2, 3],
                    }
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
