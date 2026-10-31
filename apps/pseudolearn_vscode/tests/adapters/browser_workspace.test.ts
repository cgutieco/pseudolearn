import { describe, expect, it, vi } from "vitest";

const tree = vi.hoisted(() => ({
  "": [["app", 2], ["geo", 2], ["bad", 2]],
  app: [["pseudolearn.toml", 1], ["main.pseudo", 1]],
  geo: [["pseudolearn.toml", 1]],
  bad: [["notes.txt", 1], ["extra.pseudo", 1]],
} as Record<string, Array<[string, number]>>));

function fakeUri(path: string) {
  return { path, scheme: "memfs", authority: "host", toString: () => `memfs://host${path}` };
}

vi.mock("vscode", () => ({ FileType: { File: 1, Directory: 2, SymbolicLink: 64 },
  Uri: { joinPath: (base: { path: string }, name: string) => fakeUri(`${base.path.replace(/\/$/, "")}/${name}`) },
  workspace: { fs: {
    readDirectory: async (uri: { path: string }) => tree[uri.path.replace(/^\//, "")] ?? [],
    readFile: async () => new TextEncoder().encode("text"),
  } } }));

import { BrowserWorkspace } from "../../src/adapters/browser_workspace";

const resolved = { value: { configuration: { name: "x" }, manifest_errors: [] } };

function port(response: unknown) {
  return { call: vi.fn(async (_operation: string, _arguments: string) => ({ response: JSON.stringify(response), projection: response })), close: vi.fn() };
}

describe("Browser workspace snapshot", () => {
  it("reports each manifest by its containing directory", async () => {
    const api = port(resolved);
    const workspace = new BrowserWorkspace(api as never, fakeUri("/") as never);
    await workspace.read().catch(() => undefined);
    const locations = api.call.mock.calls.map((call) => JSON.parse(call[1] as string).location);
    expect(locations).toContain("app");
    expect(locations).not.toContain("app/pseudolearn.toml");
  });

  it("rejects an invalid manifest instead of snapshotting a partial project", async () => {
    const api = port({ value: { configuration: null, manifest_errors: [{}] } });
    const workspace = new BrowserWorkspace(api as never, fakeUri("/") as never);
    await expect(workspace.read()).rejects.toThrow("Invalid PseudoLearn manifest");
  });
});
