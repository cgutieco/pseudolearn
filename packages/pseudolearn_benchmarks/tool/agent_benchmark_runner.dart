import 'dart:convert';
import 'dart:io';

import 'package:pseudolearn_benchmarks/pseudolearn_benchmarks.dart';

const int repairAttempts = 3;
final RegExp _fence = RegExp(r'```(?:pseudolearn|pseudo)?\n([\s\S]*?)```');

final class AgentRunSettings {
  final Uri proxy;
  final String token;
  final String pseudo;
  final String exercises;
  final String output;
  final String sheet;

  const AgentRunSettings({
    required this.proxy,
    required this.token,
    required this.pseudo,
    required this.exercises,
    required this.output,
    required this.sheet,
  });

  static AgentRunSettings? fromEnvironment(
    Map<String, String> environment,
    List<String> arguments,
  ) {
    final proxy = environment['AGENT_PROXY_URL'];
    final token = environment['AGENT_ACCESS_TOKEN'];
    final pseudo = environment['PSEUDO_BIN'];
    if (!arguments.contains('--authorized') ||
        proxy == null ||
        token == null ||
        pseudo == null) {
      return null;
    }
    final positional = arguments
        .where((argument) => !argument.startsWith('--'))
        .toList();
    return AgentRunSettings(
      proxy: Uri.parse(
        '${proxy.replaceAll(RegExp(r'/+$'), '')}/agent-responses',
      ),
      token: token,
      pseudo: pseudo,
      exercises: positional.isNotEmpty
          ? positional.first
          : '../../apps/pseudolearn_app/assets/route/es/es/exercises',
      output: positional.length > 1
          ? positional[1]
          : 'results/agent-trials.json',
      sheet: File('../../apps/pseudolearn_cli/generated/language-sheet.es.md')
          .readAsStringSync(),
    );
  }
}

String? firstProgram(String reply) => _fence.firstMatch(reply)?.group(1);

String agentPrompt(AgentTask task, {required String context}) => [
  if (context.isNotEmpty) context,
  'Escribe un programa PseudoLearn completo en un bloque ```pseudolearn que resuelva:',
  '# ${task.title}',
  task.statement,
  if (task.starter != null)
    'Parte de este programa:\n```pseudolearn\n${task.starter}```',
  for (final item in task.cases.where((item) => !item.hidden))
    'Con entradas ${item.inputs.join(', ')} la salida es:\n${item.expected}',
].join('\n\n');

final class AgentBenchmarkRunner {
  final AgentRunSettings settings;
  final HttpClient _http = HttpClient();

  AgentBenchmarkRunner(this.settings);

  Future<List<AgentTrial>> runAll(List<AgentTask> tasks) async {
    final trials = <AgentTrial>[];
    for (final task in tasks) {
      for (final variant in AgentVariant.all) {
        trials.add(await _trial(task, variant));
      }
    }
    _http.close();
    return trials;
  }

  Future<AgentTrial> _trial(AgentTask task, AgentVariant variant) async {
    final context = [
      if (variant.sheet) settings.sheet,
      if (variant.retrieval) await _retrieve(task.title),
    ].join('\n\n');
    var reply = await _ask(agentPrompt(task, context: context), task.id);
    var program = firstProgram(reply.$1) ?? '';
    var diagnostics = await _check(program);
    final compiledFirst = diagnostics == null;
    var credits = reply.$2;
    for (
      var attempt = 0;
      attempt < repairAttempts && diagnostics != null;
      attempt++
    ) {
      reply = await _ask(
        '$program\n\nEste programa tiene errores:\n$diagnostics\nCorrígelo.',
        task.id,
      );
      credits += reply.$2;
      program = firstProgram(reply.$1) ?? program;
      diagnostics = await _check(program);
    }
    return AgentTrial(
      taskId: task.id,
      variant: variant,
      compiledFirst: compiledFirst,
      compiledAfterLoop: diagnostics == null,
      passedCases: diagnostics == null && await _passes(program, task.cases),
      credits: credits,
    );
  }

  Future<(String, int)> _ask(String prompt, String turn) async {
    final request = await _http.postUrl(settings.proxy);
    request.headers
      ..set('authorization', 'Bearer ${settings.token}')
      ..set('x-request-id', '$turn-${DateTime.now().microsecondsSinceEpoch}')
      ..set('x-pseudolearn-turn-id', turn)
      ..contentType = ContentType.json;
    request.write(
      jsonEncode({
        'instructions': 'Responde solo con el programa.',
        'input': [
          {'role': 'user', 'content': prompt},
        ],
        'tools': <Object>[],
      }),
    );
    final response = await request.close();
    final body = jsonDecode(await response.transform(utf8.decoder).join());
    final spent =
        int.tryParse(
          response.headers.value('x-pseudolearn-credits-remaining') ?? '',
        ) ??
        0;
    return (_text(body), spent);
  }

  Future<String> _retrieve(String query) async {
    final process = await Process.start(settings.pseudo, ['mcp']);
    process.stdin.writeln(
      jsonEncode({
        'jsonrpc': '2.0',
        'id': 1,
        'method': 'tools/call',
        'params': {
          'name': 'search_reference',
          'arguments': {'query': query},
        },
      }),
    );
    await process.stdin.close();
    return (await process.stdout.transform(utf8.decoder).join()).trim();
  }

  Future<String?> _check(String program) async {
    final file = File(
      '${Directory.systemTemp.createTempSync('agent_bench_').path}/p.pseudo',
    )..writeAsStringSync(program);
    final result = await Process.run(settings.pseudo, ['comprobar', file.path]);
    return result.exitCode == 0 ? null : '${result.stdout}${result.stderr}';
  }

  Future<bool> _passes(String program, List<AgentCase> cases) async {
    final file = File(
      '${Directory.systemTemp.createTempSync('agent_bench_').path}/p.pseudo',
    )..writeAsStringSync(program);
    for (final item in cases) {
      final process = await Process.start(settings.pseudo, [
        'ejecutar',
        file.path,
      ]);
      process.stdin.write('${item.inputs.join('\n')}\n');
      await process.stdin.close();
      final output = await process.stdout.transform(utf8.decoder).join();
      if (output.trim() != item.expected.trim()) return false;
    }
    return true;
  }

  String _text(Object? body) {
    final output = body is Map<String, dynamic> ? body['output'] : null;
    return [
      for (final item in output is List<dynamic> ? output : const <dynamic>[])
        if (item is Map<String, dynamic> && item['type'] == 'message')
          for (final part in (item['content'] as List<dynamic>? ?? const []))
            if (part is Map<String, dynamic>) part['text'] as String? ?? '',
    ].join();
  }
}
