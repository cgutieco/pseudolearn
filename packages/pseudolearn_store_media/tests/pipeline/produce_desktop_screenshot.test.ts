import { describe, expect, it } from "vitest";
import type { VideoProbe } from "../../src/audit/video_audit.ts";
import { produceDesktopScreenshotSet } from "../../src/pipeline/desktop_screenshot_set.ts";
import { isAccepted } from "../../src/pipeline/manifest.ts";
import { planJobs } from "../../src/pipeline/render_plan.ts";
import type { DesktopShot, DesktopStory } from "../../src/story/desktop_story.ts";
import { realCatalog } from "../support/catalog.ts";
import { fakeToolbox, type FakeToolbox } from "../support/fake_toolbox.ts";
import { brandFont, shippedLensStory } from "../support/lens.ts";
import { timelineBytes } from "../support/plates.ts";
import { pngBytes } from "../support/png.ts";

const catalog = realCatalog();
const PLATE = "plates/desk-run/windows-desktop/light/es";
const shot: DesktopShot = { id: "run", plate: "desk-run", appTheme: "light", palette: "mint",
  critical: { focus: "diagram", region: { x: 0.15, y: 0.3, width: 0.7, height: 0.3 } },
  caption: { es: "Código y ordinograma lado a lado.", en: "Code and flowchart side by side." } };

function record(toolbox: FakeToolbox, size = { width: 3840, height: 2160 }): void {
  toolbox.written.set(`${PLATE}/frame_000001.png`, pngBytes({ ...size, colorType: 2 }));
  toolbox.written.set(`${PLATE}/timeline.json`, timelineBytes([{ key: "diagram", x: 2067, y: 288, width: 1773, height: 1581 }]));
}

async function run(story: DesktopStory, prepare: (toolbox: FakeToolbox) => void = record) {
  const toolbox = fakeToolbox({ flattened: pngBytes({ width: 3840, height: 2160, colorType: 2 }) }, {} as VideoProbe);
  prepare(toolbox);
  const jobs = planJobs({ catalog, slotIds: ["microsoft.desktop.screenshot"], languages: ["es"] }).jobs;
  const outcome = await produceDesktopScreenshotSet({ toolbox, catalog, jobs, story, statements: shippedLensStory().statements,
    mono: brandFont("IBMPlexMono-Medium.ttf").advances, platesRoot: "plates", outputRoot: "out" });
  return { toolbox, outcome };
}

const rulesOf = (outcome: Awaited<ReturnType<typeof run>>["outcome"]) =>
  outcome.ok ? outcome.value.flatMap((result) => (result.outcome.ok ? result.outcome.value.findings.map((entry) => entry.rule) : ["ERROR"])) : ["SET"];

describe("produceDesktopScreenshotSet", () => {
  it("renders the window over its field, accepts it and writes the captions for the listing", async () => {
    const { toolbox, outcome } = await run({ id: "s", shots: [shot] });
    const manifest = outcome.ok && outcome.value[0]?.outcome.ok ? outcome.value[0].outcome.value : null;
    expect(manifest && isAccepted(manifest)).toBe(true);
    expect(manifest?.file).toBe("out/microsoft-store/microsoft.desktop.screenshot/es/01-run.png");
    const captions = JSON.parse(String(toolbox.written.get("out/microsoft-store/microsoft.desktop.screenshot/es/captions.json")));
    expect(captions).toEqual({ locales: ["es-ES"], screenshots: [{ position: 1, file: manifest?.file, caption: shot.caption.es }] });
  });
});

describe("produceDesktopScreenshotSet rejections", () => {
  it("refuses a missing plate, a plate of another size and a focus the app did not record", async () => {
    expect(rulesOf((await run({ id: "s", shots: [shot] }, () => undefined)).outcome)).toEqual(["MEDIA-PLATE", "MEDIA-PLATE"]);
    expect(rulesOf((await run({ id: "s", shots: [shot] }, (toolbox) => record(toolbox, { width: 3200, height: 1800 }))).outcome)).toEqual(["MEDIA-PLATE"]);
    expect(rulesOf((await run({ id: "s", shots: [{ ...shot, critical: { ...shot.critical, focus: "trace" } }] })).outcome)).toEqual(["MEDIA-PLATE"]);
  });

  it("refuses a caption over 200 characters and a critical region in the bottom third", async () => {
    expect(rulesOf((await run({ id: "s", shots: [{ ...shot, caption: { es: "a".repeat(201), en: "b" } }] })).outcome)).toEqual(["TEXT-LENGTH"]);
    const low = { ...shot, critical: { ...shot.critical, region: { x: 0, y: 0.6, width: 1, height: 0.4 } } };
    expect(rulesOf((await run({ id: "s", shots: [low] })).outcome)).toEqual(["MEDIA-SAFE-AREA", "MEDIA-CONTENT"]);
  });

  it("refuses more screenshots than the slot takes", async () => {
    const shots = Array.from({ length: 11 }, (_unused, index) => ({ ...shot, id: `s${index}` }));
    expect((await run({ id: "s", shots })).outcome).toEqual({ ok: false, error: "11 screenshots exceed the 10 that microsoft.desktop.screenshot takes" });
  });
});
