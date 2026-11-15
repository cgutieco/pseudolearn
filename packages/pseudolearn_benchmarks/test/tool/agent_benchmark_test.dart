import 'package:pseudolearn_benchmarks/pseudolearn_benchmarks.dart';
import 'package:test/test.dart';

import '../../tool/agent_benchmark.dart';
import '../../tool/agent_benchmark_runner.dart';

void main() {
  test('running needs explicit authorization and every credential', () {
    const complete = {
      'AGENT_PROXY_URL': 'https://p/functions/v1/',
      'AGENT_ACCESS_TOKEN': 't',
      'PSEUDO_BIN': 'pseudo',
    };
    expect(AgentRunSettings.fromEnvironment(complete, const []), isNull);
    expect(
      AgentRunSettings.fromEnvironment(
        const {'AGENT_PROXY_URL': 'x'},
        const ['--authorized'],
      ),
      isNull,
    );
    final settings = AgentRunSettings.fromEnvironment(complete, const [
      '--authorized',
    ]);
    expect(
      settings!.proxy.toString(),
      'https://p/functions/v1/agent-responses',
    );
  });

  test(
    'the prompt shows visible cases only and the reply program is extracted',
    () {
      const task = AgentTask(
        id: 'e',
        kind: 'resolver',
        title: 'Suma',
        statement: 'Suma dos números',
        starter: null,
        cases: [
          AgentCase(inputs: ['1', '2'], expected: '3', hidden: false),
          AgentCase(inputs: ['9', '9'], expected: '18', hidden: true),
        ],
      );
      final prompt = agentPrompt(task, context: 'FICHA');
      expect(prompt, startsWith('FICHA'));
      expect(prompt, contains('1, 2'));
      expect(prompt, isNot(contains('18')));
      expect(
        firstProgram('texto\n```pseudolearn\nAlgoritmo P\nFinAlgoritmo\n```'),
        'Algoritmo P\nFinAlgoritmo\n',
      );
      expect(firstProgram('sin código'), isNull);
    },
  );

  test('trial files round trip and malformed files are rejected', () {
    const trial = AgentTrial(
      taskId: 'e',
      variant: AgentVariant(sheet: true, retrieval: true),
      compiledFirst: true,
      compiledAfterLoop: true,
      passedCases: false,
      credits: 3,
    );
    final read = readAgentTrials(
      '[{"task":"e","variant":"sheet+retrieval","compiled_first":true,"compiled_after_loop":true,"passed_cases":false,"credits":3}]',
    );
    expect(read!.single.toJson(), trial.toJson());
    expect(readAgentTrials('nope'), isNull);
    expect(loadAgentTasks('/no/such/folder'), isNull);
  });

  test('credits spent is the drop between consecutive remaining balances', () {
    expect(creditsSpent(previousRemaining: 270, currentRemaining: 250), 20);
    expect(creditsSpent(previousRemaining: 270, currentRemaining: 270), 0);
  });

  test(
    'credits spent is zero without a baseline, a header or after a rise',
    () {
      expect(creditsSpent(previousRemaining: null, currentRemaining: 250), 0);
      expect(creditsSpent(previousRemaining: 250, currentRemaining: null), 0);
      expect(creditsSpent(previousRemaining: 250, currentRemaining: 900), 0);
    },
  );
}
