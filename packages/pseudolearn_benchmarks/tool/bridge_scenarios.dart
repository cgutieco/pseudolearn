import 'dart:convert';
import 'dart:io';

import 'package:pseudolearn_benchmarks/pseudolearn_benchmarks.dart';

Map<String, Object?> _call(
  String operation,
  Map<String, Object?> arguments, {
  String save = 'last',
}) => {'operation': operation, 'arguments': arguments, 'save': save};

List<Map<String, Object?>> _setup(String source, List<String> inputs) => [
  _call('create_analysis', {
    'program': source,
    'profile': 'es',
    'strictness': 'flexible',
  }, save: 'analysis'),
  _call('start', {
    'analysis': r'$analysis.resource',
    'observe': 'events',
    'seed': 42,
    'inputs': inputs,
    'limits': <String, Object?>{},
  }, save: 'execution'),
];

Map<String, Object?> _advance(int size) =>
    _call('advance', {'resource': r'$execution.resource', 'batch_size': size});

Map<String, Object?> _drain() => {
  ..._advance(256),
  'until': {'last.termination.kind': 'completed'},
  'limit': 1000000,
};

Map<String, Object?> executionScenario({
  required String id,
  required String source,
  required String expected,
  List<String> inputs = const [],
  required int batchSize,
  String family = 'behavior',
}) => {
  'id': id,
  'family': family,
  'setup': _setup(source, inputs),
  'timed': [
    _advance(batchSize),
    _call('query_frame', {
      'resource': r'$execution.resource',
      'event': r'$event_index',
      'frame': 0,
    }, save: 'visible'),
  ],
  'verify': [_drain()],
  'expected': {'output': expected, 'last.termination.kind': 'completed'},
};

List<Map<String, Object?>> minimalBridgeScenarios() => [
  for (final bytes in [16, 4096, 65536])
    {
      'id': 'payload-$bytes',
      'setup': [
        _call('create_document', {
          'program': 'x' * bytes,
          'profile': 'es',
          'strictness': 'flexible',
        }, save: 'document'),
      ],
      'timed': [
        _call('document', {'resource': r'$document.resource'}),
      ],
      'expected': {'last.program': 'x' * bytes},
    },
];

String get _fibonacci => annexWorkloads
    .singleWhere((load) => load.name == 'fibonacci')
    .source
    .replaceFirst('Fib(12)', 'Fib(20)');

Map<String, Object?> visibleModelScenario() => {
  'id': 'fibonacci20-visible',
  'setup': [
    _call('model_start', {'program': _fibonacci, 'step_limit': 1000000}),
    _call('model_advance', {'pace': 'nextStatement'}),
  ],
  'timed': [
    _call('model_advance', {'pace': 'nextStatement'}),
  ],
  'verify': [
    _call('model_advance', {'pace': 'toEnd'}),
  ],
  'expected': {
    'last.finished': true,
    'last.halted': false,
    'last.output': ['6765'],
  },
};

List<Map<String, Object?>> additionalBridgeScenarios(
  Map<String, Object?> corpus,
) => [
  executionScenario(
    id: 'fibonacci20',
    source: _fibonacci,
    expected: '6765\n',
    batchSize: 16,
  ),
  for (final identity in [
    ('MEM.IDENTITY', 'C2'),
    ('MEM.IDENTITY', 'C3'),
    ('LANG.ARRAY.DIMENSION', 'C1'),
  ])
    _corpusScenario(corpus, identity.$1, identity.$2),
  _retainedScenario(),
  _inputScenario(),
  _cancelScenario(),
  _completionScenario(),
  _arrayPageScenario(),
  _abundantOutputScenario(),
];

Map<String, Object?> _corpusScenario(
  Map<String, Object?> corpus,
  String id,
  String caseId,
) {
  final specifications = (corpus['specifications'] as List<Object?>)
      .cast<Map<String, Object?>>();
  final specification = specifications.singleWhere(
    (entry) => (entry['metadata'] as Map<String, Object?>)['id'] == id,
  );
  final block = (specification['blocks'] as List<Object?>)
      .cast<Map<String, Object?>>()
      .singleWhere(
        (entry) =>
            entry['kind'] == 'caso' &&
            (entry['fields'] as Map<String, Object?>)['id'] == caseId,
      );
  final fields = block['fields'] as Map<String, Object?>;
  final expected = fields['espera'] as Map<String, Object?>;
  final vocabulary = jsonDecode(
    File('../pseudolearn_spec/specifications/cases/vocabulary.json')
        .readAsStringSync(),
  ) as Map<String, Object?>;
  final output = (expected['salida'] as String).replaceAllMapped(
    RegExp(r'\{\{lexema:([^}]+)\}\}'),
    (match) => (vocabulary[match[1]] as Map<String, Object?>)['es'] as String,
  );
  return executionScenario(
    id: '$id-$caseId',
    source:
        fields['programa'] as String? ??
        (fields['programas'] as Map<String, Object?>)['es'] as String,
    expected: output,
    batchSize: 16,
  );
}

Map<String, Object?> _retainedScenario() => {
  'id': 'retained-event',
  'setup': [
    ..._setup(
      'Algoritmo P\nDefinir valor Como Entero;\nvalor <- 7;\nFinAlgoritmo\n',
      [],
    ),
    _drain(),
  ],
  'timed': [
    _call('query_frame', {
      'resource': r'$execution.resource',
      'event': 0,
      'frame': 0,
    }),
  ],
  'expected': {'last.unidad': 'P'},
};

Map<String, Object?> _inputScenario() => {
  'id': 'suspended-input',
  'setup': [
    ..._setup(
      'Algoritmo P\nDefinir valor Como Entero;\nLeer valor;\nEscribir valor;\nFinAlgoritmo\n',
      [],
    ),
    _advance(256),
  ],
  'timed': [
    _call('input', {'resource': r'$execution.resource', 'text': '7'}),
    _advance(256),
  ],
  'expected': {'last.termination.kind': 'completed', 'output': '7\n'},
};

Map<String, Object?> _cancelScenario() => {
  'id': 'long-execution-cancel',
  'setup': _setup(
    'Algoritmo P\nMientras verdadero Hacer\nFinMientras\nFinAlgoritmo\n',
    [],
  ),
  'timed': [
    _advance(16),
    _call('cancel', {'resource': r'$execution.resource'}),
    _advance(16),
  ],
  'expected': {'last.termination.kind': 'cancelled'},
};

Map<String, Object?> _completionScenario() {
  final source =
      'Algoritmo P\n${List.generate(9997, (index) => 'Definir valor$index Como Entero;').join('\n')}\nEscribir valor9996;\nFinAlgoritmo\n';
  return {
    'id': 'completion-10000-lines',
    'timed': [
      _call('complete', {
        'program': source,
        'profile': 'es',
        'strictness': 'flexible',
        'revision': '1',
        'cursor_utf8': '${utf8.encode(source).length}',
      }),
    ],
    'expected': {'last.revision': '1'},
  };
}

Map<String, Object?> _arrayPageScenario() => {
  'id': 'multidimensional-visible-page',
  'setup': [
    ..._setup(
      'Algoritmo P\nDimension valores[2,3] Como Entero;\nFinAlgoritmo\n',
      [],
    ),
    _drain(),
  ],
  'timed': [
    _call('query_page', {
      'resource': r'$execution.resource',
      'event': r'$event_index',
      'query': 'array_cells',
      'target': 1,
      'page_size': 2,
    }),
  ],
  'expected': {
    'last.truncated': true,
    'last.dimensions': [2, 3],
  },
};

Map<String, Object?> _abundantOutputScenario() => executionScenario(
  id: 'abundant-output',
  source: 'Algoritmo P\nDefinir numero Como Entero;\nPara numero <- 1 Hasta 1000 Hacer\nEscribir numero;\nFinPara\nFinAlgoritmo\n',
  expected: '${List.generate(1000, (index) => index + 1).join('\n')}\n',
  batchSize: 64,
);
