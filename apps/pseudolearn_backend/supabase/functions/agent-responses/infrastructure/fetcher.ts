export type Fetcher = (url: string, init: RequestInit) => Promise<Response>;

export const supabaseTimeoutMilliseconds = 10_000;
export const modelTimeoutMilliseconds = 120_000;
