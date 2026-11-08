import type { CreditsDependencies } from "./application/credits_service.ts";
import { createCreditsHandler, type CreditsSetup } from "./http/credits_handler.ts";
import { AllowlistedPurchaseVerifier } from "./infrastructure/allowlisted_purchase_verifier.ts";
import { SimulatedPurchaseVerifier } from "./infrastructure/simulated_purchase_verifier.ts";
import type { PurchaseVerifier } from "./domain/purchase.ts";
import {
  type AgentEnvironment,
  readAgentEnvironment,
} from "../agent-responses/infrastructure/environment.ts";
import type { Fetcher } from "../agent-responses/infrastructure/fetcher.ts";
import { PostgresLedger } from "../agent-responses/infrastructure/postgres_ledger.ts";
import { SupabaseUserVerifier } from "../agent-responses/infrastructure/supabase_user_verifier.ts";

const fetcher: Fetcher = (url, init) => fetch(url, init);

function purchasesFor(environment: AgentEnvironment): PurchaseVerifier | null {
  const simulated = new SimulatedPurchaseVerifier();
  if (environment.purchases === "simulated") return simulated;
  if (environment.simulatedPurchaseUsers.size === 0) return null;
  return new AllowlistedPurchaseVerifier(simulated, environment.simulatedPurchaseUsers);
}

function buildDependencies(environment: AgentEnvironment): CreditsDependencies {
  const endpoint = { ...environment, fetcher };
  return {
    users: new SupabaseUserVerifier(endpoint),
    ledger: new PostgresLedger(endpoint),
    purchases: purchasesFor(environment),
    clock: { now: () => new Date() },
  };
}

function setupFor(environment: AgentEnvironment | null): CreditsSetup {
  if (environment === null) return { kind: "unavailable", code: "misconfigured" };
  return { kind: "ready", dependencies: buildDependencies(environment) };
}

Deno.serve(createCreditsHandler(setupFor(readAgentEnvironment((name) => Deno.env.get(name)))));
