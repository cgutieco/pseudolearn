import type { AccountUser } from "../../supabase/functions/delete-account/domain/account_user.ts";
import type {
  AppleCodeExchange,
  AppleTokenClient,
  RevocableToken,
  UserDeleter,
  UserVerifier,
} from "../../supabase/functions/delete-account/domain/ports.ts";

export class CallLog {
  readonly calls: string[] = [];

  record(call: string): void {
    this.calls.push(call);
  }
}

export class FakeUserVerifier implements UserVerifier {
  constructor(private readonly log: CallLog, public user: AccountUser | null) {}

  verify(accessToken: string): Promise<AccountUser | null> {
    this.log.record(`verify:${accessToken}`);
    return Promise.resolve(this.user);
  }
}

export class FakeAppleTokenClient implements AppleTokenClient {
  exchangeResult: AppleCodeExchange = {
    kind: "exchanged",
    subject: "apple-subject",
    token: { value: "apple-refresh-token", hint: "refresh_token" },
  };
  revokeResult = true;

  constructor(private readonly log: CallLog) {}

  exchange(authorizationCode: string): Promise<AppleCodeExchange> {
    this.log.record(`exchange:${authorizationCode}`);
    return Promise.resolve(this.exchangeResult);
  }

  revoke(token: RevocableToken): Promise<boolean> {
    this.log.record(`revoke:${token.hint}:${token.value}`);
    return Promise.resolve(this.revokeResult);
  }
}

export class FakeUserDeleter implements UserDeleter {
  result = true;

  constructor(private readonly log: CallLog) {}

  delete(userId: string): Promise<boolean> {
    this.log.record(`delete:${userId}`);
    return Promise.resolve(this.result);
  }
}
