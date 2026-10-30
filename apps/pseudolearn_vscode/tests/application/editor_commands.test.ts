import { describe, expect, it } from "vitest";
import { listProjectEntries } from "../../src/application/entry_choice";
import { hasUnsavedChanges } from "../../src/application/saved_snapshot_guard";
import { translateDocument } from "../../src/application/translate_document";
import type { CommandRunnerPort, TranslationEditPort } from "../../src/contracts/editor_documents";
import type { RunSettings } from "../../src/contracts/editor_run";

const settings: RunSettings = { executable: "pseudo", language: "es", profile: "es", strictness: "strict" };

describe("hasUnsavedChanges", () => {
  it("detects unsaved files inside the project directory only", () => {
    const documents = { unsavedPaths: () => ["/p/app/main.pseudo"] };
    expect(hasUnsavedChanges(documents, { kind: "project", directory: "/p", entry: "a" })).toBe(true);
    expect(hasUnsavedChanges(documents, { kind: "project", directory: "/p2", entry: "a" })).toBe(false);
    expect(hasUnsavedChanges(documents, { kind: "file", path: "/p/app/main.pseudo" })).toBe(true);
    expect(hasUnsavedChanges({ unsavedPaths: () => [] }, { kind: "file", path: "/x" })).toBe(false);
  });
});

describe("translateDocument", () => {
  const edits = (version: number | undefined, applies: boolean): TranslationEditPort & { replaced: string[] } => {
    const replaced: string[] = [];
    return {
      replaced,
      currentVersion: () => version,
      replaceWhole: async (_path, _version, text) => {
        replaced.push(text);
        return applies;
      },
    };
  };
  const runner = (code: number | null, stdout: string): CommandRunnerPort => ({
    run: async () => ({ code, stdout }),
  });
  const request = { path: "/a.pseudo", targetProfile: "en", unsaved: false, settings } as const;

  it("applies the translation as one edit", async () => {
    const port = edits(3, true);
    expect(await translateDocument({ runner: runner(0, "out"), edits: port }, request)).toBe("applied");
    expect(port.replaced).toEqual(["out"]);
  });

  it("writes nothing on a collision or an unsaved document", async () => {
    const port = edits(3, true);
    expect(await translateDocument({ runner: runner(1, ""), edits: port }, request)).toBe("collision");
    expect(await translateDocument({ runner: runner(0, "x"), edits: port }, { ...request, unsaved: true })).toBe("unsaved");
    expect(port.replaced).toEqual([]);
  });

  it("reports a closed document and a document that changed meanwhile", async () => {
    expect(await translateDocument({ runner: runner(0, "x"), edits: edits(undefined, true) }, request)).toBe("notOpen");
    expect(await translateDocument({ runner: runner(0, "x"), edits: edits(1, false) }, request)).toBe("documentChanged");
  });
});

describe("listProjectEntries", () => {
  it("returns module paths from the check output", async () => {
    const runner: CommandRunnerPort = { run: async () => ({ code: 0, stdout: '{"modules":[{"path":"app/main"},{"x":1}]}' }) };
    expect(await listProjectEntries(runner, { directory: "/p", settings })).toEqual(["app/main"]);
  });

  it("returns an empty list for unusable output", async () => {
    const runner: CommandRunnerPort = { run: async () => ({ code: 1, stdout: "garbage" }) };
    expect(await listProjectEntries(runner, { directory: "/p", settings })).toEqual([]);
  });
});
