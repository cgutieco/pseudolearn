import { decodeBase64UrlText } from "./base64url.ts";

export function decodeJwtPayload(token: string): Record<string, unknown> | null {
  const segments = token.split(".");
  if (segments.length !== 3) return null;
  const json = decodeBase64UrlText(segments[1]);
  if (json === null) return null;
  try {
    const payload: unknown = JSON.parse(json);
    return isRecord(payload) ? payload : null;
  } catch {
    return null;
  }
}

export function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
