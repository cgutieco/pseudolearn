import { describe, expect, it } from "vitest";
import { parseLensStory } from "../../src/story/lens_story.ts";
import { lensDocument, shippedLensStory } from "../support/lens.ts";

type Mutable = Record<string, unknown>;

function errorsAfter(change: (document: Mutable) => void): readonly string[] {
  const document = lensDocument();
  change(document);
  const parsed = parseLensStory(document);
  return parsed.ok ? [] : parsed.errors.map((error) => `${error.path}: ${error.message}`);
}

function statements(document: Mutable, language: string): Mutable[] {
  return (document["statements"] as Mutable)[language] as Mutable[];
}

describe("parseLensStory", () => {
  it("reads the shipped story with the same program in both languages", () => {
    const story = shippedLensStory();
    expect(story.durationSeconds).toBe(20);
    expect(story.statements.es).toHaveLength(10);
    expect(story.statements.en.map((item) => item.kind)).toEqual(story.statements.es.map((item) => item.kind));
  });

  it("rejects a translation whose kinds drift", () => {
    expect(errorsAfter((document) => {
      statements(document, "en")[1] = { text: "define temperature as integer <- 30;", kind: "io" };
    })).toEqual(["statements.en: must translate every statement with the same kind and order"]);
  });

  it("rejects an unknown kind and an unknown key", () => {
    expect(errorsAfter((document) => {
      statements(document, "es")[0] = { text: "Proceso X", kind: "loop", color: "red" };
    })).toContain("statements.es[0].kind: expected one of terminal, io, process, decision, join");
  });

  it("rejects an empty program and more statements per row than the program has", () => {
    expect(errorsAfter((document) => {
      (document["statements"] as Mutable)["es"] = [];
      (document["statements"] as Mutable)["en"] = [];
    })).toEqual(["statements: the lens needs at least one statement"]);
    expect(errorsAfter((document) => {
      (document["rows"] as Mutable)["statementsPerRow"] = 11;
    })).toEqual(["rows.statementsPerRow: cannot exceed the number of statements"]);
  });

  it("rejects a loop outside 5–30 s and a poster past the end", () => {
    expect(errorsAfter((document) => {
      document["durationSeconds"] = 40;
    })).toContain("durationSeconds: expected a number between 5 and 30");
    expect(errorsAfter((document) => {
      document["posterSeconds"] = 25;
    })).toEqual(["posterSeconds: expected a number between 0 and 20"]);
  });
});
