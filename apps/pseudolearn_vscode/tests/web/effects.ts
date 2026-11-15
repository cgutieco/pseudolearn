export const directoryToken = { slot: "1", generation: "1", rights: "3", kind: "2" };
export const fileToken = { slot: "2", generation: "1", rights: "3", kind: "3" };

let sequence = 0;
const next = (): string => String(++sequence);

export function networkEffect(url: string, overrides: Record<string, unknown> = {}) {
  return { effect_seq: next(), operation: "network_send", arguments: [{ kind: "http_request", value: {
    method: "GET", url, headers: [], body: null, effective_response_limit: "1024",
    effective_timeout_nanos: "5000000000", ...overrides } }] };
}

export const directoryEffect = () => ({ effect_seq: next(), operation: "request_directory", result_capability: directoryToken,
  arguments: [{ kind: "text", value: "." }] });

export const openEffect = (relative: string, mode: string) => ({ effect_seq: next(), operation: "file_open", receiver: directoryToken,
  result_capability: fileToken, arguments: [{ kind: "text", value: relative }, { kind: "text", value: mode }] });

export const writeEffect = (value: string) => ({ effect_seq: next(), operation: "file_write_text", receiver: fileToken,
  arguments: [{ kind: "text", value }] });

export const readEffect = () => ({ effect_seq: next(), operation: "file_read_text", receiver: fileToken });

export interface Resolution { outcome: string; value: { code?: string; uncertain?: boolean; kind?: string; value?: { status?: string | number; body?: number[] } } }
