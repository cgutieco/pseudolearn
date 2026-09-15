export type Fetcher = (url: string, init: RequestInit) => Promise<Response>;

export const remoteRequestTimeoutMilliseconds = 10_000;
