import '../domain/ports/agent_consent_store.dart';
import '../domain/ports/agent_model_gateway.dart';
import '../domain/ports/agent_prompt_source.dart';
import '../domain/ports/assisted_progress_store.dart';
import '../domain/ports/credits_gateway.dart';
import '../domain/ports/knowledge_index.dart';
import '../domain/ports/purchase_store.dart';
import '../domain/ports/reply_markdown_reader.dart';

final class AgentServices {
  final AgentModelGateway modelGateway;
  final CreditsGateway creditsGateway;
  final PurchaseStore purchaseStore;
  final KnowledgeIndex knowledgeIndex;
  final AgentConsentStore consentStore;
  final AgentPromptSource promptSource;
  final ReplyMarkdownReader replyReader;
  final AssistedProgressStore assistedProgress;
  final String platformName;

  const AgentServices({
    required this.modelGateway,
    required this.creditsGateway,
    required this.purchaseStore,
    required this.knowledgeIndex,
    required this.consentStore,
    required this.promptSource,
    required this.replyReader,
    required this.assistedProgress,
    required this.platformName,
  });
}
