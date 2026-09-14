import { isRecord } from "./jwt_payload";

export interface AppleConfiguration {
  readonly teamId: string;
  readonly keyId: string;
  readonly clientId: string;
  readonly privateKeyPem: string;
}

export interface FunctionEnvironment {
  readonly supabaseUrl: string;
  readonly secretKey: string;
  readonly apple: AppleConfiguration | null;
}

export type EnvironmentReader = (name: string) => string | undefined;

export const secretKeyName = "default";

export function readFunctionEnvironment(read: EnvironmentReader): FunctionEnvironment | null {
  const supabaseUrl = nonEmpty(read("SUPABASE_URL"));
  const secretKey = secretKeyFrom(read("SUPABASE_SECRET_KEYS"));
  if (supabaseUrl === null || secretKey === null) return null;
  return { supabaseUrl: supabaseUrl.replace(/\/+$/, ""), secretKey, apple: readApple(read) };
}

function readApple(read: EnvironmentReader): AppleConfiguration | null {
  const teamId = nonEmpty(read("APPLE_TEAM_ID"));
  const keyId = nonEmpty(read("APPLE_KEY_ID"));
  const clientId = nonEmpty(read("APPLE_CLIENT_ID"));
  const privateKeyPem = nonEmpty(read("APPLE_PRIVATE_KEY"));
  if (teamId === null || keyId === null || clientId === null || privateKeyPem === null) {
    return null;
  }
  return { teamId, keyId, clientId, privateKeyPem };
}

function secretKeyFrom(serializedKeys: string | undefined): string | null {
  if (serializedKeys === undefined) return null;
  try {
    const keys: unknown = JSON.parse(serializedKeys);
    return isRecord(keys) ? nonEmpty(keys[secretKeyName]) : null;
  } catch {
    return null;
  }
}

function nonEmpty(value: unknown): string | null {
  return typeof value === "string" && value.trim().length > 0 ? value.trim() : null;
}
