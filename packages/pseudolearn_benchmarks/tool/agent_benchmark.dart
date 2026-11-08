import 'dart:convert';
import 'dart:io';

import 'package:pseudolearn_benchmarks/pseudolearn_benchmarks.dart';

import 'agent_benchmark_runner.dart';

const String defaultExercises =
    '../../apps/pseudolearn_app/assets/route/es/es/exercises';

Future<void> main(List<String> arguments) async {
  final command = arguments.isEmpty ? '' : arguments.first;
  exitCode = switch (command) {
    'plan' => _plan(arguments.skip(1).toList()),
    'summarize' => _summarize(arguments.skip(1).toList()),
    'run' => await _run(arguments.skip(1).toList()),
    _ => _usage(),
  };
}

List<AgentTask>? loadAgentTasks(String directory) {
  final folder = Directory(directory);
  if (!folder.existsSync()) return null;
  return agentTasks({
    for (final file in folder.listSync().whereType<File>())
      if (file.path.endsWith('.json'))
        file.uri.pathSegments.last: file.readAsStringSync(),
  });
}

int _plan(List<String> arguments) {
  final tasks = loadAgentTasks(
    arguments.isEmpty ? defaultExercises : arguments.first,
  );
  if (tasks == null) return _fail('agent-benchmark: unreadable exercises');
  final output = arguments.length > 1 ? File(arguments[1]) : null;
  final text = const JsonEncoder.withIndent('  ')
      .convert([for (final task in tasks) task.toJson()]);
  output == null ? stdout.writeln(text) : output.writeAsStringSync('$text\n');
  stderr.writeln('agent-benchmark: ${tasks.length} tasks');
  return 0;
}

int _summarize(List<String> arguments) {
  if (arguments.isEmpty) return _usage();
  final trials = readAgentTrials(File(arguments.first).readAsStringSync());
  if (trials == null) return _fail('agent-benchmark: unreadable trials');
  stdout.writeln(
    jsonEncode([
      for (final summary in summarizeAgentTrials(trials)) summary.toJson(),
    ]),
  );
  return 0;
}

Future<int> _run(List<String> arguments) async {
  final settings = AgentRunSettings.fromEnvironment(
    Platform.environment,
    arguments,
  );
  if (settings == null) {
    return _fail(
      'agent-benchmark: run needs --authorized, AGENT_PROXY_URL, AGENT_ACCESS_TOKEN and PSEUDO_BIN; '
      'it spends real credits with the owner key.',
    );
  }
  final tasks = loadAgentTasks(settings.exercises);
  if (tasks == null) return _fail('agent-benchmark: unreadable exercises');
  final trials = await AgentBenchmarkRunner(settings).runAll(tasks);
  File(
    settings.output,
  ).writeAsStringSync(jsonEncode([for (final trial in trials) trial.toJson()]));
  return 0;
}

List<AgentTrial>? readAgentTrials(String text) {
  try {
    final variants = {
      for (final variant in AgentVariant.all) variant.label: variant,
    };
    return [
      for (final entry
          in (jsonDecode(text) as List<dynamic>).cast<Map<String, dynamic>>())
        AgentTrial(
          taskId: entry['task'] as String,
          variant: variants[entry['variant']]!,
          compiledFirst: entry['compiled_first'] as bool,
          compiledAfterLoop: entry['compiled_after_loop'] as bool,
          passedCases: entry['passed_cases'] as bool,
          credits: entry['credits'] as int,
        ),
    ];
  } on Object {
    return null;
  }
}

int _usage() => _fail(
  'usage: dart run tool/agent_benchmark.dart plan [exercises] [out.json] | summarize <trials.json> | '
  'run --authorized [exercises] [out.json]',
);

int _fail(String message) {
  stderr.writeln(message);
  return 2;
}
