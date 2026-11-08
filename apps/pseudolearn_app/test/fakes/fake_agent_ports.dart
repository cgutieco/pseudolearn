import 'package:pseudolearn_app/domain/model/agent/knowledge_hit.dart';
import 'package:pseudolearn_app/domain/model/credits/agent_product.dart';
import 'package:pseudolearn_app/domain/model/credits/credit_balance.dart';
import 'package:pseudolearn_app/domain/model/credits/credits_outcome.dart';
import 'package:pseudolearn_app/domain/ports/agent_consent_store.dart';
import 'package:pseudolearn_app/domain/ports/agent_prompt_source.dart';
import 'package:pseudolearn_app/domain/ports/assisted_progress_store.dart';
import 'package:pseudolearn_app/domain/ports/credits_gateway.dart';
import 'package:pseudolearn_app/domain/ports/knowledge_index.dart';

final class InMemoryAgentConsentStore implements AgentConsentStore {
  bool consented;

  InMemoryAgentConsentStore({this.consented = false});

  @override
  Future<void> grant() async => consented = true;

  @override
  Future<bool> hasConsented() async => consented;

  @override
  Future<void> withdraw() async => consented = false;
}

final class InMemoryAssistedProgressStore implements AssistedProgressStore {
  final Set<String> ids = {};

  @override
  Future<Set<String>> assistedIds() async => {...ids};

  @override
  Future<void> markAssisted(String progressId) async => ids.add(progressId);
}

final class FakeKnowledgeIndex implements KnowledgeIndex {
  const FakeKnowledgeIndex();

  @override
  Future<String> manualSummary(String languageCode) async => '- library (/biblioteca): Library';

  @override
  Future<List<KnowledgeHit>> search({
    required String query,
    required String languageCode,
    int limit = 5,
  }) async => [
    KnowledgeHit(
      source: KnowledgeSource.manual,
      id: 'execution-options',
      title: 'Run options',
      excerpt: 'Arguments for $query',
      languageCode: languageCode,
      score: 1,
    ),
  ];
}

final class FakeAgentPromptSource implements AgentPromptSource {
  const FakeAgentPromptSource();

  @override
  Future<String> languageSheet(String languageCode) async => 'SHEET-$languageCode';

  @override
  Future<String> systemPrompt(String languageCode) async => 'SYSTEM-$languageCode';
}

final class FakeCreditsGateway implements CreditsGateway {
  CreditsOutcome next;
  final List<PurchaseReceipt> redeemed = [];

  FakeCreditsGateway([CreditsOutcome? next])
    : next = next ?? const CreditsKnown(CreditBalance(remaining: 40, allowance: 40, topUp: 0, trial: true), periodActive: true);

  @override
  Future<CreditsOutcome> balance() async => next;

  @override
  Future<CreditsOutcome> redeem(PurchaseReceipt receipt) async {
    redeemed.add(receipt);
    return next;
  }
}
