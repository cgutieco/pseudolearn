import { isRecord } from "../domain/credits.ts";

export type PurchaseMode = "simulated" | "disabled";

export interface AgentEnvironment {
  readonly supabaseUrl: string;
  readonly secretKey: string;
  readonly openAiKey: string | null;
  readonly model: string;
  readonly purchases: PurchaseMode;
}

export type EnvironmentReader = (name: string) => string | undefined;

export const defaultModel = "gpt-6-luna";

export function readAgentEnvironment(read: EnvironmentReader): AgentEnvironment | null {
  const supabaseUrl = nonEmpty(read("SUPABASE_URL"));
  const secretKey = secretKeyFrom(read("SUPABASE_SECRET_KEYS"));
  if (supabaseUrl === null || secretKey === null) return null;
  return {
    supabaseUrl: supabaseUrl.replace(/\/+$/, ""),
    secretKey,
    openAiKey: nonEmpty(read("OPENAI_API_KEY")),
    model: nonEmpty(read("AGENT_MODEL")) ?? defaultModel,
    purchases: read("AGENT_PURCHASES")?.trim() === "simulated" ? "simulated" : "disabled",
  };
}

function secretKeyFrom(serialized: string | undefined): string | null {
  if (serialized === undefined) return null;
  try {
    const keys: unknown = JSON.parse(serialized);
    return isRecord(keys) ? nonEmpty(keys.default) : null;
  } catch {
    return null;
  }
}

function nonEmpty(value: unknown): string | null {
  return typeof value === "string" && value.trim().length > 0 ? value.trim() : null;
}
