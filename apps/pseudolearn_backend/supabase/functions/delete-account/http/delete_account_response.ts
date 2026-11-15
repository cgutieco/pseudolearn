import type { DeletionFailureCode, DeletionOutcome } from "../domain/deletion_outcome.ts";

export const statusByFailureCode: Readonly<Record<DeletionFailureCode, number>> = {
  method_not_allowed: 405,
  invalid_body: 400,
  unauthorized: 401,
  apple_reauthentication_required: 409,
  apple_identity_mismatch: 403,
  apple_token_exchange_failed: 502,
  apple_revoke_failed: 502,
  delete_failed: 500,
  misconfigured: 500,
  unexpected_failure: 500,
};

export function responseFor(outcome: DeletionOutcome): Response {
  if (outcome.kind === "deleted") return Response.json({ status: "deleted" }, { status: 200 });
  return Response.json(
    { code: outcome.code },
    { status: statusByFailureCode[outcome.code] },
  );
}
