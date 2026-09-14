export type DeletionFailureCode =
  | "method_not_allowed"
  | "invalid_body"
  | "unauthorized"
  | "apple_reauthentication_required"
  | "apple_token_exchange_failed"
  | "apple_identity_mismatch"
  | "apple_revoke_failed"
  | "delete_failed"
  | "misconfigured"
  | "unexpected_failure";

export type DeletionOutcome =
  | { readonly kind: "deleted" }
  | { readonly kind: "failed"; readonly code: DeletionFailureCode };

export const accountDeleted: DeletionOutcome = { kind: "deleted" };

export function deletionFailed(code: DeletionFailureCode): DeletionOutcome {
  return { kind: "failed", code };
}
