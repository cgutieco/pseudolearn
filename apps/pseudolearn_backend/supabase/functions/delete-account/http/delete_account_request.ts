import type { DeleteAccountCommand } from "../application/delete_account.ts";
import type { DeletionFailureCode } from "../domain/deletion_outcome.ts";

export type ParsedDeleteAccountRequest =
  | { readonly kind: "accepted"; readonly command: DeleteAccountCommand }
  | { readonly kind: "rejected"; readonly code: DeletionFailureCode };

export async function parseDeleteAccountRequest(
  request: Request,
): Promise<ParsedDeleteAccountRequest> {
  if (request.method !== "POST") return { kind: "rejected", code: "method_not_allowed" };
  const accessToken = bearerTokenOf(request.headers.get("authorization"));
  if (accessToken === null) return { kind: "rejected", code: "unauthorized" };
  const body = await readBody(request);
  if (body === undefined) return { kind: "rejected", code: "invalid_body" };
  const appleAuthorizationCode = appleAuthorizationCodeOf(body);
  if (appleAuthorizationCode === undefined) return { kind: "rejected", code: "invalid_body" };
  return { kind: "accepted", command: { accessToken, appleAuthorizationCode } };
}

function bearerTokenOf(header: string | null): string | null {
  if (header === null) return null;
  const [scheme, token, ...rest] = header.trim().split(" ");
  if (scheme.toLowerCase() !== "bearer" || rest.length > 0) return null;
  return token !== undefined && token.length > 0 ? token : null;
}

async function readBody(request: Request): Promise<unknown> {
  const text = await request.text();
  if (text.trim().length === 0) return {};
  try {
    return JSON.parse(text);
  } catch {
    return undefined;
  }
}

function appleAuthorizationCodeOf(body: unknown): string | null | undefined {
  if (typeof body !== "object" || body === null || Array.isArray(body)) return undefined;
  const code = (body as Record<string, unknown>).apple_authorization_code;
  if (code === undefined || code === null) return null;
  if (typeof code !== "string" || code.trim().length === 0) return undefined;
  return code.trim();
}
