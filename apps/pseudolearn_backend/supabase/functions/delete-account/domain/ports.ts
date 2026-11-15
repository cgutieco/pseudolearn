import type { AccountUser } from "./account_user.ts";

export interface UserVerifier {
  verify(accessToken: string): Promise<AccountUser | null>;
}

export type RevocableTokenHint = "refresh_token" | "access_token";

export interface RevocableToken {
  readonly value: string;
  readonly hint: RevocableTokenHint;
}

export type AppleCodeExchange =
  | { readonly kind: "exchanged"; readonly subject: string; readonly token: RevocableToken }
  | { readonly kind: "failed" };

export interface AppleTokenClient {
  exchange(authorizationCode: string): Promise<AppleCodeExchange>;
  revoke(token: RevocableToken): Promise<boolean>;
}

export interface UserDeleter {
  delete(userId: string): Promise<boolean>;
}
