import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:supabase/supabase.dart' show SupabaseClient;
import '../data/agent/asset_agent_prompt_source.dart';
import '../data/agent/asset_knowledge_index.dart';
import '../data/agent/fake_agent_model_gateway.dart';
import '../data/agent/file_agent_consent_store.dart';
import '../data/agent/markdown_code_block_reader.dart';
import '../data/agent/proxy_agent_model_gateway.dart';
import '../data/auth/supabase_access_token_source.dart';
import '../data/credits/proxy_credits_gateway.dart';
import '../data/credits/purchase_store_simulation.dart';
import '../data/platform/platform_name_source.dart';
import '../data/progress/sqlite_assisted_progress_store.dart';
import '../domain/ports/agent_model_gateway.dart';
import '../domain/ports/credits_gateway.dart';
import '../domain/ports/identifier_generator.dart';
import 'agent_services.dart';
import '../data/credits/unconfigured_credits_gateway.dart';

const String agentBackend = String.fromEnvironment('AGENT_BACKEND', defaultValue: 'fake');
const String agentProxyUrl = String.fromEnvironment(
  'AGENT_PROXY_URL',
  defaultValue: 'https://placeholder.supabase.co/functions/v1',
);

final class AgentEndpoints {
  final String functionsUrl;
  final SupabaseAccessTokenSource tokens;

  AgentEndpoints(SupabaseClient client)
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

AgentServices buildAgentServices({
  required SupabaseClient client,
  required Directory documentsDirectory,
  required Database database,
  required IdentifierGenerator identifiers,
}) {
  final endpoints = AgentEndpoints(client);
  return AgentServices(
    modelGateway: (_modelGateways[agentBackend] ?? _modelGateways['fake']!)(endpoints),
    creditsGateway: (_creditsGateways[agentBackend] ?? _creditsGateways['fake']!)(endpoints),
    purchaseStore: SimulatedPurchaseStore(identifiers),
    knowledgeIndex: AssetKnowledgeIndex(assetLoader: rootBundle.loadString),
    consentStore: FileAgentConsentStore(documentsDirectory),
    promptSource: AssetAgentPromptSource(rootBundle.loadString),
    codeBlockReader: const MarkdownCodeBlockReader(),
    assistedProgress: SqliteAssistedProgressStore(database),
    platformName: currentPlatformName(),
  );
}
