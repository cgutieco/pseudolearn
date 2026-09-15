import type { UserDeleter } from "../domain/ports.ts";
import { remoteRequestTimeoutMilliseconds } from "./fetcher.ts";
import type { SupabaseAuthEndpoint } from "./supabase_user_verifier.ts";

export class SupabaseUserDeleter implements UserDeleter {
  constructor(private readonly endpoint: SupabaseAuthEndpoint) {}

  async delete(userId: string): Promise<boolean> {
    try {
      const response = await this.endpoint.fetcher(
        `${this.endpoint.supabaseUrl}/auth/v1/admin/users/${encodeURIComponent(userId)}`,
        {
          method: "DELETE",
          headers: { apikey: this.endpoint.secretKey, "content-type": "application/json" },
          body: JSON.stringify({ should_soft_delete: false }),
          signal: AbortSignal.timeout(remoteRequestTimeoutMilliseconds),
        },
      );
      await response.body?.cancel();
      return response.ok;
    } catch {
      return false;
    }
  }
}
