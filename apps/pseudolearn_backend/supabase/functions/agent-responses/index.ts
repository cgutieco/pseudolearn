import type { AgentDependencies } from "./application/agent_service.ts";
import type { AgentSetup } from "./http/agent_handler.ts";
import { createAgentHandler } from "./http/agent_handler.ts";
import { type AgentEnvironment, readAgentEnvironment } from "./infrastructure/environment.ts";
import type { Fetcher } from "./infrastructure/fetcher.ts";
import { OpenAiResponses } from "./infrastructure/openai_responses.ts";
import { PostgresLedger } from "./infrastructure/postgres_ledger.ts";
import { SupabaseUserVerifier } from "./infrastructure/supabase_user_verifier.ts";

const fetcher: Fetcher = (url, init) => fetch(url, init);

function buildDependencies(environment: AgentEnvironment, openAiKey: string): AgentDependencies {
  const endpoint = { ...environment, fetcher };
  return {
    users: new SupabaseUserVerifier(endpoint),
    ledger: new PostgresLedger(endpoint),
    model: new OpenAiResponses(openAiKey, fetcher),
    policy: { model: environment.model },
    clock: { now: () => new Date() },
  };
}

function setupFor(environment: AgentEnvironment | null): AgentSetup {
  if (environment === null) return { kind: "unavailable", code: "misconfigured" };
  if (environment.openAiKey === null) return { kind: "unavailable", code: "model_unconfigured" };
  return { kind: "ready", dependencies: buildDependencies(environment, environment.openAiKey) };
}

const environment = readAgentEnvironment((name) => Deno.env.get(name));

Deno.serve(
  createAgentHandler(
    setupFor(environment),
    (event) => console.log(JSON.stringify(event)),
    () => performance.now(),
  ),
);
