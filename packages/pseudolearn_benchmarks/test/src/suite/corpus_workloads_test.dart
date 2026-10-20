import 'dart:io';

import 'package:pseudolearn_benchmarks/pseudolearn_benchmarks.dart';
import 'package:test/test.dart';

void main() {
  test('reads ten measurement cases from the exported corpus', () {
    final text = File('../pseudolearn_spec/specifications/export.json')
        .readAsStringSync();
    final workloads = corpusWorkloads(text);
    expect(workloads, hasLength(10));
    expect(workloads!.map((entry) => entry.$1.name).toSet(), hasLength(10));
    expect(workloads.every((entry) => entry.$2.length == 1), isTrue);
  });
  test('invalid and missing corpus return a failure value', () {
    expect(corpusWorkloads('{'), isNull);
    expect(corpusWorkloads('{"specifications":[]}'), isNull);
  });
}
