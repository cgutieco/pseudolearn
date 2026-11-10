import { describe, expect, it } from "vitest";
import { parsePreviewStory, previewPlatePathParts } from "../../src/story/preview_story.ts";
import { previewDocument, previewStory } from "../support/preview.ts";

type Mutable = Record<string, unknown>;

function errorsAfter(change: (document: Mutable, scenes: Mutable[]) => void): readonly string[] {
  const document = previewDocument();
  const preview = (document["previews"] as Mutable[])[0] as Mutable;
  change(document, preview["scenes"] as Mutable[]);
  const parsed = parsePreviewStory(document);
  return parsed.ok ? [] : parsed.errors.map((error) => `${error.path}: ${error.message}`);
}

describe("parsePreviewStory", () => {
  it("reads previews, trimmed scenes, dissolves and overlays", () => {
    const [preview] = previewStory().previews;
    expect(preview?.posterSeconds).toBe(5);
    expect(preview?.scenes.map((scene) => [scene.plate, scene.fromSeconds, scene.toSeconds, scene.transition?.seconds ?? null]))
      .toEqual([["preview-run", 0, 9, null], ["preview-nodo", 1, 9, 0.6]]);
    expect(preview?.scenes[0]?.touches).toBe(true);
    expect(preview?.scenes[1]?.touches).toBe(false);
    expect(preview?.scenes[1]?.captions[0]?.role).toBe("disclosure");
  });

  it("finds a scene's plates by plate, device, theme and language", () => {
    const scene = previewStory().previews[0]!.scenes[1]!;
    expect(previewPlatePathParts(scene, { device: "iphone-preview", language: "en" })).toEqual(["preview-nodo", "iphone-preview", "dark", "en"]);
  });

  it("rejects a first scene with a transition and a later scene without one", () => {
    const errors = errorsAfter((_document, scenes) => {
      scenes[0]!["transition"] = { kind: "dissolve", seconds: 0.6 };
      delete scenes[1]!["transition"];
    });
    expect(errors.filter((error) => error.endsWith("every scene but the first enters with a transition, and only those"))).toHaveLength(2);
  });

  it("rejects transitions other than a dissolve, so no wipe or push can imply a feature", () => {
    const errors = errorsAfter((_document, scenes) => {
      scenes[1]!["transition"] = { kind: "push", seconds: 0.6 };
    });
    expect(errors).toContain("previews[0].scenes[1].transition.kind: expected one of dissolve");
  });

});

describe("parsePreviewStory rejections", () => {
  it("rejects a scene that ends before it starts and an empty preview", () => {
    expect(errorsAfter((_document, scenes) => {
      scenes[0]!["to"] = 0;
    })).toContain("previews[0].scenes[0].to: a scene must end after it starts");
    expect(errorsAfter((_document, scenes) => {
      scenes.length = 0;
    })).toContain("previews[0].scenes: a preview needs at least one scene");
  });

  it("rejects more than three previews, repeated ids and no previews at all", () => {
    const tooMany = errorsAfter((document) => {
      const [first] = document["previews"] as Mutable[];
      document["previews"] = [first, { ...first, id: "b" }, { ...first, id: "c" }, { ...first, id: "d" }];
    });
    expect(tooMany).toContain("previews: a story holds 1 to 3 previews per device and language");
    expect(errorsAfter((document) => {
      const [first] = document["previews"] as Mutable[];
      document["previews"] = [first, first];
    })).toContain("previews: preview ids must be unique");
    expect(errorsAfter((document) => {
      document["previews"] = [];
    })).toContain("previews: a story holds 1 to 3 previews per device and language");
  });
});
