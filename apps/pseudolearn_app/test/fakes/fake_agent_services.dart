import 'package:pseudolearn_app/composition/agent_services.dart';
import 'package:pseudolearn_app/data/agent/fake_agent_model_gateway.dart';
import 'package:pseudolearn_app/data/agent/markdown/markdown_reply_reader.dart';
import 'package:pseudolearn_app/data/credits/no_pending_purchases.dart';
import 'package:pseudolearn_app/data/credits/purchase_store_simulation.dart';
import 'fake_agent_ports.dart';
import 'fake_identifier_generator.dart';
import 'fake_purchase_ports.dart';

AgentServices buildFakeAgentServices({
  FakeAgentModelGateway? modelGateway,
  FakeCreditsGateway? creditsGateway,
  InMemoryAgentConsentStore? consentStore,
  InMemoryAssistedProgressStore? assistedProgress,
}) => AgentServices(
  modelGateway: modelGateway ?? FakeAgentModelGateway(),
  creditsGateway: creditsGateway ?? FakeCreditsGateway(),
  purchaseStore: SimulatedPurchaseStore(FakeIdentifierGenerator(['tx-1', 'tx-2', 'tx-3'])),
  pendingPurchases: const NoPendingPurchases(),
  externalLinks: RecordingUrlLauncher(),
  knowledgeIndex: const FakeKnowledgeIndex(),
  consentStore: consentStore ?? InMemoryAgentConsentStore(),
  promptSource: const FakeAgentPromptSource(),
  replyReader: const MarkdownReplyReader(),
  assistedProgress: assistedProgress ?? InMemoryAssistedProgressStore(),
  platformName: 'test',
);
