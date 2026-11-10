import { describe, expect, it } from "vitest";
import { parseScreenshotStory, platePathParts } from "../../src/story/screenshot_story.ts";
import { chapterOf, shippedStory, storyDocument, TEST_STORY } from "../support/story.ts";

type Mutable = Record<string, unknown>;

function errorsAfter(change: (document: Mutable) => void): readonly string[] {
  const document = storyDocument();
  change(document);
  const parsed = parseScreenshotStory(document);
  return parsed.ok ? [] : parsed.errors.map((error) => `${error.path}: ${error.message}`);
}

function chapter(document: Mutable, index: number): Mutable {
  return (document["chapters"] as Mutable[])[index] as Mutable;
}

describe("parseScreenshotStory", () => {
  it("reads manifesto and device chapters with their optional parts", () => {
    const manifesto = chapterOf(TEST_STORY, "language");
    const nodo = chapterOf(TEST_STORY, "nodo");
    expect(manifesto.code?.es).toHaveLength(3);
    expect(manifesto.focus).toBeNull();
    expect(nodo).toMatchObject({ appTheme: "dark", palette: "deep", focus: "verified-code", pin: { x: 0.1, y: 0 } });
    expect(TEST_STORY.texture.en).toEqual(["while x > 0 do"]);
  });

  it("locates each chapter's plate by its own app theme", () => {
    expect(platePathParts(chapterOf(TEST_STORY, "nodo"), { device: "mac", language: "es" })).toEqual(["chapter-nodo", "mac", "dark", "es"]);
  });

  it("ships a story of six chapters that fits every Apple slot", () => {
    const story = shippedStory();
    expect(story.chapters.map((entry) => entry.id)).toEqual(["language", "run", "trace", "nodo", "code", "route"]);
    expect(story.chapters.filter((entry) => entry.kind === "manifesto")).toHaveLength(1);
  });

  it("accepts a one-character headline", () => {
    expect(errorsAfter((document) => {
      chapter(document, 1)["headline"] = { es: "A", en: "B" };
    })).toEqual([]);
  });
});

describe("parseScreenshotStory rejections", () => {
  it("rejects an empty story and duplicate chapters", () => {
    expect(errorsAfter((document) => {
      document["chapters"] = [];
    })).toContain("chapters: a story needs at least one chapter");
    expect(errorsAfter((document) => {
      chapter(document, 1)["id"] = "language";
    })).toContain("chapters: chapter ids must be unique");
  });

  it("rejects unpaired emphasis, five lines and a blank line", () => {
    const errors = errorsAfter((document) => {
      chapter(document, 0)["headline"] = { es: "a *b", en: "a\nb\nc\nd\ne" };
      chapter(document, 1)["headline"] = { es: "a\n\nb", en: "ok" };
    });
    expect(errors).toContain("chapters[0].headline.es: emphasis marks must come in pairs");
    expect(errors).toContain("chapters[0].headline.en: needs 1 to 4 non-empty lines");
    expect(errors).toContain("chapters[1].headline.es: needs 1 to 4 non-empty lines");
  });

  it("rejects a device chapter without its annotation and a manifesto without code", () => {
    const errors = errorsAfter((document) => {
      delete chapter(document, 0)["code"];
      delete chapter(document, 1)["pin"];
    });
    expect(errors).toContain("chapters[0].code: a manifesto chapter needs code");
    expect(errors).toContain("chapters[1].pin: a device chapter needs pin");
  });

});

describe("parseScreenshotStory value rejections", () => {
  it("rejects an unknown palette, a pin outside the focus and a missing language", () => {
    const errors = errorsAfter((document) => {
      chapter(document, 1)["palette"] = "neon";
      chapter(document, 1)["pin"] = { x: 1.5, y: 0 };
      chapter(document, 1)["note"] = { es: "solo" };
    });
    expect(errors.some((error) => error.startsWith("chapters[1].palette: expected one of"))).toBe(true);
    expect(errors).toContain("chapters[1].pin.x: expected a number between 0 and 1");
    expect(errors).toContain("chapters[1].note.en: expected a non-empty string");
  });

  it("rejects a document that is not an object", () => {
    expect(parseScreenshotStory("story").ok).toBe(false);
  });
});
