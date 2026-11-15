import 'dart:convert';

import '../model/agent_task.dart';

const Set<String> agentTaskKinds = {
  'resolver',
  'modificar',
  'encontrar-error',
  'romperlo',
};

List<AgentTask>? agentTasks(Map<String, String> exercisesByFile) {
  try {
    final tasks = <AgentTask>[];
    for (final name in exercisesByFile.keys.toList()..sort()) {
      final task = _task(
        jsonDecode(exercisesByFile[name]!) as Map<String, dynamic>,
      );
      if (task != null) tasks.add(task);
    }
    return tasks;
  } on Object {
    return null;
  }
}

AgentTask? _task(Map<String, dynamic> exercise) {
  final kind = exercise['kind'] as String;
  final evaluation = exercise['evaluation'] as Map<String, dynamic>;
  final cases = evaluation['cases'] as List<dynamic>?;
  if (!agentTaskKinds.contains(kind) || cases == null || cases.isEmpty) {
    return null;
  }
  final program = exercise['program'];
  return AgentTask(
    id: exercise['id'] as String,
    kind: kind,
    title: _plain(exercise['title'] as List<dynamic>),
    statement: _blocks(exercise['statement'] as List<dynamic>),
    starter: program is Map<String, dynamic>
        ? program['source'] as String?
        : null,
    cases: [
      for (final entry in cases.cast<Map<String, dynamic>>())
        AgentCase(
          inputs: (entry['inputs'] as List<dynamic>).cast<String>(),
          expected: entry['expected'] as String,
          hidden: entry['hidden'] as bool? ?? false,
        ),
    ],
  );
}

String _blocks(List<dynamic> blocks) => [
  for (final block in blocks.cast<Map<String, dynamic>>())
    if (block['runs'] is List<dynamic>) _plain(block['runs'] as List<dynamic>),
].join('\n\n');

String _plain(List<dynamic> runs) => [
  for (final run in runs.cast<Map<String, dynamic>>())
    run['text'] as String? ?? '',
].join();
