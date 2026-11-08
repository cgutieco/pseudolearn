import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/agent/agent_session_cubit.dart';
import 'package:pseudolearn_app/application/agent/agent_session_state.dart';
import 'package:pseudolearn_app/application/agent/code_block_checker.dart';
import 'package:pseudolearn_app/data/agent/fake_agent_model_gateway.dart';
import 'package:pseudolearn_app/data/agent/markdown/markdown_reply_reader.dart';
import 'package:pseudolearn_app/domain/model/agent/code_block.dart';
import 'package:pseudolearn_app/domain/model/agent/reply_block.dart';
import 'package:pseudolearn_app/domain/model/analysis/highlight_span.dart';
import 'package:pseudolearn_app/domain/model/agent/model_outcome.dart';
import 'package:pseudolearn_app/domain/model/agent/tool_definition.dart';
import 'package:pseudolearn_app/domain/model/credits/credit_failure.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import '../../fakes/agent_scripts.dart';
import '../../fakes/fake_agent_ports.dart';
import '../../fakes/native_test_engine.dart';

AgentSessionCubit _cubit(FakeAgentModelGateway gateway, InMemoryAgentConsentStore consent, {List<RecordingTool> tools = const []}) =>
    AgentSessionCubit(
      loop: testLoop(gateway, tools),
      consent: consent,
      checker: CodeBlockChecker(reader: const MarkdownReplyReader(), analyzer: nativeTestEngine.analyzer),
      editorial: AgentEditorial(
        profile: () => SyntaxProfileId.classicSpanish,
        language: () => UiLanguageId.spanish,
      ),
    );

void main() {
  test('without consent the message waits and is sent after consenting', () async {
    final consent = InMemoryAgentConsentStore();
    final gateway = FakeAgentModelGateway([textReply('Hola')]);
    final cubit = _cubit(gateway, consent);
    await cubit.send('hola');
    expect(cubit.state.status, AgentSessionStatus.needsConsent);
    expect(gateway.requests, isEmpty);
    await consent.grant();
    await cubit.resumeAfterConsent();
    expect(cubit.state.messages.map((message) => message.text), ['hola', 'Hola']);
    await cubit.close();
  });

  test('an empty message is ignored', () async {
    final gateway = FakeAgentModelGateway();
    final cubit = _cubit(gateway, InMemoryAgentConsentStore(consented: true));
    await cubit.send('   ');
    expect(cubit.state.messages, isEmpty);
    await cubit.close();
  });

  test('code in a reply is verified with the engine', () async {
    const reply = 'Prueba:\n```pseudolearn\nAlgoritmo P\n  Escribir 1;\nFinAlgoritmo\n```\n'
        'Y esta no:\n```pseudolearn\nAlgoritmo P\n  Si x >\nFinAlgoritmo\n```\n```python\nprint(1)\n```';
    final cubit = _cubit(FakeAgentModelGateway([textReply(reply)]), InMemoryAgentConsentStore(consented: true));
    await cubit.send('ejemplo');
    final blocks = cubit.state.messages.last.codeBlocks;
    expect(blocks.map((block) => block.verdict), [
      CodeBlockVerdict.verified,
      CodeBlockVerdict.withErrors,
      CodeBlockVerdict.notPseudoLearn,
    ]);
    expect(blocks.first.canInsert, isTrue);
    expect(blocks[1].canInsert, isFalse);
    expect(blocks.first.highlightSpans, isNotEmpty);
    expect(blocks.last.highlightSpans.first.category, HighlightCategory.keywordStructured);
    expect(cubit.state.messages.last.blocks.whereType<ReplyCode>().map((block) => block.index), [0, 1, 2]);
    await cubit.close();
  });

  test('a confirmation is shown, answered and the spend recorded', () async {
    final tool = RecordingTool('delete_document', risk: ToolRisk.destructive);
    final gateway = FakeAgentModelGateway([
      toolReply('delete_document', '{"document_id":"d"}', remaining: 38),
      textReply('Hecho', remaining: 36),
    ]);
    final cubit = _cubit(gateway, InMemoryAgentConsentStore(consented: true), tools: [tool]);
    await cubit.send('borra');
    expect(cubit.state.status, AgentSessionStatus.awaitingConfirmation);
    expect(cubit.state.confirmation!.arguments, {'document_id': 'd'});
    await cubit.send('otra cosa');
    expect(gateway.requests, hasLength(1));
    await cubit.answerConfirmation(approved: true);
    expect(tool.calls, hasLength(1));
    expect(cubit.state.status, AgentSessionStatus.idle);
    expect(cubit.state.messages.last.steps.single.toolName, 'delete_document');
    expect(cubit.state.balance!.remaining, 36);
    await cubit.close();
  });

  test('a failure is kept in the state and exhausted credits block the composer', () async {
    final cubit = _cubit(
      FakeAgentModelGateway([const ModelFailed(CreditFailure.creditsExhausted)]),
      InMemoryAgentConsentStore(consented: true),
    );
    await cubit.send('hola');
    expect(cubit.state.status, AgentSessionStatus.failed);
    expect(cubit.state.blocksComposer, isTrue);
    cubit.startOver();
    expect(cubit.state.messages, isEmpty);
    expect(cubit.state.failure, isNull);
    await cubit.close();
  });

  test('answering without a pending confirmation does nothing', () async {
    final cubit = _cubit(FakeAgentModelGateway(), InMemoryAgentConsentStore(consented: true));
    await cubit.answerConfirmation(approved: true);
    expect(cubit.state.status, AgentSessionStatus.idle);
    await cubit.close();
  });
}
