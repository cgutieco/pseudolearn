import 'dart:convert';
import 'dart:io';

import 'package:pseudolearn_benchmarks/pseudolearn_benchmarks.dart';
import 'package:test/test.dart';

void main() {
  test('about one hundred tasks come from the route exercises with cases', () {
    final folder = Directory(
      '../../apps/pseudolearn_app/assets/route/es/es/exercises',
    );
    final tasks = agentTasks({
      for (final file in folder.listSync().whereType<File>())
        file.uri.pathSegments.last: file.readAsStringSync(),
    })!;
    expect(tasks.length, inInclusiveRange(90, 110));
    expect(tasks.every((task) => task.cases.isNotEmpty), isTrue);
    expect(tasks.map((task) => task.kind).toSet(), agentTaskKinds);
    expect(tasks.first.statement, isNotEmpty);
  });

  test('exercises without cases are skipped and malformed input fails', () {
    final predict = jsonEncode({
      'id': 'p',
      'kind': 'predecir',
      'evaluation': {'type': 'predict'},
      'title': <Object>[],
      'statement': <Object>[],
    });
    expect(agentTasks({'p.json': predict}), isEmpty);
    expect(agentTasks({'x.json': '{'}), isNull);
    expect(agentTasks({}), isEmpty);
  });
}
