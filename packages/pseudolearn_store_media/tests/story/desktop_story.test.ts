import { readFileSync } from "node:fs";
import { describe, expect, it } from "vitest";
import { parseDesktopStory } from "../../src/story/desktop_story.ts";
import { characterCount } from "../../src/audit/label_audit.ts";

const shipped = JSON.parse(readFileSync(new URL("../../stories/microsoft-store-screenshots.json", import.meta.url), "utf8")) as Record<string, unknown>;

function errorsOf(change: (shot: Record<string, unknown>) => void): readonly string[] {
  const document = structuredClone(shipped);
  change((document["shots"] as Record<string, unknown>[])[0]!);
  const parsed = parseDesktopStory(document);
  return parsed.ok ? [] : parsed.errors.map((error) => `${error.path}: ${error.message}`);
}

describe("parseDesktopStory", () => {
  it("reads the shipped Microsoft Store story with captions inside 200 characters", () => {
    const parsed = parseDesktopStory(shipped);
    expect(parsed.ok).toBe(true);
    const shots = parsed.ok ? parsed.value.shots : [];
    expect(shots.map((shot) => shot.plate)).toEqual(["desk-run", "desk-trace", "chapter-nodo", "desk-code", "chapter-route"]);
    expect(shots.every((shot) => characterCount(shot.caption.es) <= 200 && characterCount(shot.caption.en) <= 200)).toBe(true);
  });

  it("marks Nodo as AI and discloses the subscription in both languages", () => {
    const parsed = parseDesktopStory(shipped);
    const nodo = parsed.ok ? parsed.value.shots.find((shot) => shot.plate === "chapter-nodo") : undefined;
    expect(nodo?.caption.es).toContain("IA");
    expect(nodo?.caption.es).toContain("suscripción");
    expect(nodo?.caption.en).toContain("AI");
    expect(nodo?.caption.en).toContain("subscription");
  });

  it("rejects a region outside its focus, an empty one and a missing translation", () => {
    expect(errorsOf((shot) => {
      (shot["critical"] as Record<string, unknown>)["region"] = { x: 0.5, y: 0, width: 0.6, height: 1 };
    })).toEqual(["shots[0].critical.region: must be a non-empty region inside its focus rectangle"]);
    expect(errorsOf((shot) => {
      (shot["critical"] as Record<string, unknown>)["region"] = { x: 0, y: 0, width: 0, height: 1 };
    })).toEqual(["shots[0].critical.region: must be a non-empty region inside its focus rectangle"]);
    expect(errorsOf((shot) => {
      shot["caption"] = { es: "Hola" };
    }).some((error) => error.startsWith("shots[0].caption.en"))).toBe(true);
  });

  it("rejects an empty story, duplicate ids and an unknown palette", () => {
    expect(parseDesktopStory({ id: "x", shots: [] })).toEqual({ ok: false, errors: [{ path: "shots", message: "a story needs at least one screenshot" }] });
    const twice = { ...shipped, shots: [(shipped["shots"] as unknown[])[0], (shipped["shots"] as unknown[])[0]] };
    expect(parseDesktopStory(twice).ok).toBe(false);
    expect(errorsOf((shot) => {
      shot["palette"] = "neon";
    }).some((error) => error.startsWith("shots[0].palette"))).toBe(true);
  });
});
