import 'dart:convert';

import '../model/workload.dart';

List<(Workload, List<String>)>? corpusWorkloads(String exported) {
  try {
    return _parse(exported);
  } on Object {
    return null;
  }
}

List<(Workload, List<String>)> _parse(String exported) {
  final corpus = jsonDecode(exported) as Map<String, dynamic>;
  final specifications = corpus['specifications'] as List<dynamic>;
  final suite = specifications.cast<Map<String, dynamic>>().singleWhere(
    (specification) =>
        specification['metadata']['id'] == 'PERF.SUITE.AWFY-CORE',
  );
  final workloads = (suite['blocks'] as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .where((block) => block['kind'] == 'caso')
      .map((block) => block['fields'] as Map<String, dynamic>)
      .where(
        (fields) => (fields['etiquetas'] as List<dynamic>).contains('medicion'),
      )
      .map(_workload)
      .toList();
  if (workloads.length != 10) {
    throw const FormatException('Expected ten workloads');
  }
  return workloads;
}

(Workload, List<String>) _workload(Map<String, dynamic> fields) {
  final tags = (fields['etiquetas'] as List<dynamic>).cast<String>();
  final name = tags.last;
  final family = switch (name) {
    'sieve' || 'queens' => 'arrays',
    'permute' => 'recursive',
    'mandelbrot' || 'nbody' => 'numeric',
    _ => 'objects',
  };
  final inputs = (fields['entradas'] as List<dynamic>).cast<String>();
  return (
    Workload(
      name: name,
      family: family,
      source: fields['programa'] as String,
      expectedOutput: (fields['espera']['salida'] as String).trim(),
      operations: int.parse(inputs.single),
    ),
    inputs,
  );
}
