import { describe, expect, it, vi } from "vitest";

const fake = vi.hoisted(() => ({ writes: vi.fn(), reads: vi.fn(async () => new Uint8Array([111, 107])),
  stat: vi.fn(async () => ({ type: 1, size: 2 })) }));

vi.mock("vscode", () => ({ FileType: { File: 1, Directory: 2, SymbolicLink: 64 },
  Uri: { parse: (value: string) => ({ toString: () => value }),
    joinPath: (base: { toString(): string }, path: string) => ({ toString: () => `${base.toString()}/${path}` }) },
  workspace: { fs: { readFile: fake.reads, writeFile: fake.writes, stat: fake.stat } } }));

import { BrowserFileHost } from "../../src/adapters/browser_file_host";

const directory = { slot: "1", generation: "1", rights: "3", kind: "2" };
const file = { slot: "2", generation: "1", rights: "3", kind: "3" };

describe("Browser file host", () => {
  it("reports an unavailable provider without writing", async () => {
    const host = new BrowserFileHost(undefined);
    expect(await host.perform({ operation: "request_directory", result_capability: directory })).toMatchObject({ outcome: "failed" });
    expect(fake.writes).not.toHaveBeenCalled();
  });
  it("writes system paths and retains provider uncertainty", async () => {
    fake.stat.mockResolvedValueOnce({ type: 2, size: 0 });
    const host = new BrowserFileHost("memfs://host/root");
    await host.perform({ operation: "request_directory", result_capability: directory, arguments: [{ kind: "text", value: "." }] });
    const open = { operation: "file_open", receiver: directory, result_capability: file,
      arguments: [{ kind: "text", value: "a" }, { kind: "text", value: "write" }] };
    expect(await host.perform(open)).toMatchObject({ outcome: "committed" });
    const write = { operation: "file_write_text", receiver: file, arguments: [{ kind: "text", value: "ok" }] };
    expect(await host.perform(write)).toEqual({ outcome: "committed", value: { kind: "integer", value: 2 } });
    fake.writes.mockRejectedValueOnce(new Error("provider disconnected"));
    expect(await host.perform(write)).toMatchObject({ outcome: "uncertain", value: { uncertain: true } });
    expect(await host.perform({ ...open, arguments: [{ kind: "text", value: "../escape" }, { kind: "text", value: "write" }] }))
      .toMatchObject({ outcome: "committed" });
  });

});

describe("Browser file host aliases", () => {
  it("allows a provider link under full root authority", async () => {
    fake.stat.mockResolvedValueOnce({ type: 2, size: 0 });
    const host = new BrowserFileHost("memfs://host/root");
    await host.perform({ operation: "request_directory", result_capability: directory, arguments: [{ kind: "text", value: "." }] });
    fake.stat.mockResolvedValueOnce({ type: 64, size: 1 });
    const open = { operation: "file_open", receiver: directory, result_capability: file,
      arguments: [{ kind: "text", value: "link" }, { kind: "text", value: "read" }] };
    expect(await host.perform(open)).toMatchObject({ outcome: "committed" });
    const read = { operation: "file_read_text", receiver: file };
    expect(await host.perform(read)).toMatchObject({ outcome: "committed" });
  });
});
