import { deleteAccount, type DeleteAccountDependencies } from "../application/delete_account";
import { deletionFailed, type DeletionOutcome } from "../domain/deletion_outcome";
import { parseDeleteAccountRequest } from "./delete_account_request";
import { responseFor } from "./delete_account_response";

export type OutcomeRecorder = (outcome: DeletionOutcome) => void;

export function createDeleteAccountHandler(
  dependencies: DeleteAccountDependencies | null,
  recordOutcome: OutcomeRecorder,
): (request: Request) => Promise<Response> {
  return async (request) => {
    const outcome = await resolveOutcome(request, dependencies);
    recordOutcome(outcome);
    return responseFor(outcome);
  };
}

async function resolveOutcome(
  request: Request,
  dependencies: DeleteAccountDependencies | null,
): Promise<DeletionOutcome> {
  try {
    const parsed = await parseDeleteAccountRequest(request);
    if (parsed.kind === "rejected") return deletionFailed(parsed.code);
    if (dependencies === null) return deletionFailed("misconfigured");
    return await deleteAccount(parsed.command, dependencies);
  } catch {
    return deletionFailed("unexpected_failure");
  }
}
