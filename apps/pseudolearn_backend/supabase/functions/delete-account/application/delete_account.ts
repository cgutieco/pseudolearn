import type { AccountUser } from "../domain/account_user.ts";
import {
  accountDeleted,
  deletionFailed,
  type DeletionOutcome,
} from "../domain/deletion_outcome";
import type { AppleTokenClient, UserDeleter, UserVerifier } from "../domain/ports.ts";

export interface DeleteAccountCommand {
  readonly accessToken: string;
  readonly appleAuthorizationCode: string | null;
}

export interface DeleteAccountDependencies {
  readonly userVerifier: UserVerifier;
  readonly appleTokenClient: AppleTokenClient | null;
  readonly userDeleter: UserDeleter;
}

export async function deleteAccount(
  command: DeleteAccountCommand,
  dependencies: DeleteAccountDependencies,
): Promise<DeletionOutcome> {
  const user = await dependencies.userVerifier.verify(command.accessToken);
  if (user === null) return deletionFailed("unauthorized");
  const appleFailure = await revokeAppleAuthorization(user, command, dependencies.appleTokenClient);
  if (appleFailure !== null) return appleFailure;
  const deleted = await dependencies.userDeleter.delete(user.id);
  return deleted ? accountDeleted : deletionFailed("delete_failed");
}

async function revokeAppleAuthorization(
  user: AccountUser,
  command: DeleteAccountCommand,
  appleTokenClient: AppleTokenClient | null,
): Promise<DeletionOutcome | null> {
  if (user.appleSubject === null) return null;
  if (appleTokenClient === null) return deletionFailed("misconfigured");
  if (command.appleAuthorizationCode === null) {
    return deletionFailed("apple_reauthentication_required");
  }
  const exchange = await appleTokenClient.exchange(command.appleAuthorizationCode);
  if (exchange.kind === "failed") return deletionFailed("apple_token_exchange_failed");
  if (exchange.subject !== user.appleSubject) return deletionFailed("apple_identity_mismatch");
  const revoked = await appleTokenClient.revoke(exchange.token);
  return revoked ? null : deletionFailed("apple_revoke_failed");
}
