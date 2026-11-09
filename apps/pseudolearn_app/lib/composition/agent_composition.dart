import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:supabase/supabase.dart' show SupabaseClient;
import '../data/agent/asset_agent_prompt_source.dart';
import '../data/agent/asset_knowledge_index.dart';
import '../data/agent/fake_agent_model_gateway.dart';
import '../data/agent/file_agent_consent_store.dart';
import '../data/agent/markdown/markdown_reply_reader.dart';
import '../data/agent/proxy_agent_model_gateway.dart';
import '../data/auth/supabase_access_token_source.dart';
import '../data/credits/proxy_credits_gateway.dart';
import '../data/credits/in_app_purchase_storekit_client.dart';
import '../data/credits/no_pending_purchases.dart';
import '../data/credits/paddle_purchase_store.dart';
import '../data/credits/proxy_checkout_gateway.dart';
import '../data/credits/purchase_store_simulation.dart';
import '../data/credits/storekit_purchase_store.dart';
import '../data/credits/storekit_transaction_queue.dart';
import '../data/platform/platform_external_url_launcher.dart';
import '../data/platform/platform_name_source.dart';
import '../data/progress/sqlite_assisted_progress_store.dart';
import '../domain/ports/agent_model_gateway.dart';
import '../domain/ports/credits_gateway.dart';
import '../domain/ports/identifier_generator.dart';
import '../domain/ports/pending_purchases.dart';
import '../domain/ports/purchase_store.dart';
import 'agent_services.dart';
import '../data/credits/unconfigured_credits_gateway.dart';

const String agentBackend = String.fromEnvironment('AGENT_BACKEND', defaultValue: 'fake');
const String agentPurchases = String.fromEnvironment('AGENT_PURCHASES', defaultValue: 'simulated');
const String agentProxyUrl = String.fromEnvironment(
  'AGENT_PROXY_URL',
  defaultValue: 'https://placeholder.supabase.co/functions/v1',
);

final class AgentEndpoints {
  final String functionsUrl;
  final SupabaseAccessTokenSource tokens;
  final SupabaseClient client;

  AgentEndpoints(this.client)
    : functionsUrl = agentProxyUrl,
      tokens = SupabaseAccessTokenSource(client);
}

final Map<String, AgentModelGateway Function(AgentEndpoints endpoints)> _modelGateways = {
  'fake': (_) => FakeAgentModelGateway(),
  'proxy': (endpoints) => ProxyAgentModelGateway(
    functionsUrl: endpoints.functionsUrl,
    tokens: endpoints.tokens,
  ),
};

final Map<String, CreditsGateway Function(AgentEndpoints endpoints)> _creditsGateways = {
  'fake': (_) => const UnconfiguredCreditsGateway(),
  'proxy': (endpoints) => ProxyCreditsGateway(
    functionsUrl: endpoints.functionsUrl,
    tokens: endpoints.tokens,
  ),
};

typedef PurchaseAdapters = ({PurchaseStore store, PendingPurchases pending});

final Map<String, PurchaseAdapters Function(AgentEndpoints endpoints, IdentifierGenerator identifiers)>
_purchaseAdapters = {
  'simulated': (_, identifiers) => (store: SimulatedPurchaseStore(identifiers), pending: const NoPendingPurchases()),
  'storekit': (endpoints, _) => _storeKitAdapters(() => endpoints.client.auth.currentUser?.id),
  'paddle': (endpoints, _) => (
    store: PaddlePurchaseStore(
      checkouts: ProxyCheckoutGateway(functionsUrl: endpoints.functionsUrl, tokens: endpoints.tokens),
      launcher: const PlatformExternalUrlLauncher(),
    ),
    pending: const NoPendingPurchases(),
  ),
};

PurchaseAdapters _storeKitAdapters(String? Function() accountToken) {
  final client = InAppPurchaseStoreKitClient();
  final queue = StoreKitTransactionQueue(client: client, accountToken: accountToken);
  return (
    store: StoreKitPurchaseStore(
      client: client,
      queue: queue,
      accountToken: accountToken,
      launcher: const PlatformExternalUrlLauncher(),
    ),
    pending: queue,
  );
}

AgentServices buildAgentServices({
  required SupabaseClient client,
  required Directory documentsDirectory,
  required Database database,
  required IdentifierGenerator identifiers,
}) {
  final endpoints = AgentEndpoints(client);
  final purchases = (_purchaseAdapters[agentPurchases] ?? _purchaseAdapters['simulated']!)(endpoints, identifiers);
  return AgentServices(
    modelGateway: (_modelGateways[agentBackend] ?? _modelGateways['fake']!)(endpoints),
    creditsGateway: (_creditsGateways[agentBackend] ?? _creditsGateways['fake']!)(endpoints),
    purchaseStore: purchases.store,
    pendingPurchases: purchases.pending,
    externalLinks: const PlatformExternalUrlLauncher(),
    knowledgeIndex: AssetKnowledgeIndex(assetLoader: rootBundle.loadString),
    consentStore: FileAgentConsentStore(documentsDirectory),
    promptSource: AssetAgentPromptSource(rootBundle.loadString),
    replyReader: const MarkdownReplyReader(),
    assistedProgress: SqliteAssistedProgressStore(database),
    platformName: currentPlatformName(),
  );
}
