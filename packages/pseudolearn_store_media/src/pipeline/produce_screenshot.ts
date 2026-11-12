import type { Catalog, Device } from "../catalog/catalog_types.ts";
import type { Finding } from "../audit/finding.ts";
import { auditImage } from "../audit/image_audit.ts";
import { auditSafeArea } from "../audit/safe_area_audit.ts";
import { auditFocus, auditHeadlineFit, auditPlate } from "../audit/screenshot_audit.ts";
import { auditContrast, auditLexicon } from "../audit/text_audit.ts";
import { MONO_FONT_FILE, SANS_FONT_FILE } from "../compose/editorial_markup.ts";
import { buildEditorialScreenshot, PLATE_FILE, type ScreenshotComposition } from "../compose/editorial_screenshot.ts";
import { textWidth, type GlyphAdvances } from "../layout/glyph_advances.ts";
import type { Chapter, ScreenshotStory } from "../story/screenshot_story.ts";
import { manifestOf, type Manifest } from "./manifest.ts";
import { readPlate, type RecordedPlate } from "./plate_source.ts";
import type { Outcome, Toolbox } from "./ports.ts";
import type { Job } from "./render_plan.ts";

export type LoadedFont = { readonly bytes: Uint8Array; readonly advances: GlyphAdvances };

export type ScreenshotJob = {
  readonly toolbox: Toolbox;
  readonly catalog: Catalog;
  readonly job: Job;
  readonly story: ScreenshotStory;
  readonly chapter: Chapter;
  readonly position: number;
  readonly fonts: { readonly sans: LoadedFont; readonly mono: LoadedFont };
  readonly platesRoot: string;
  readonly outputRoot: string;
  readonly guides: boolean;
};

const STILL_FPS = 1;

export async function produceScreenshot(request: ScreenshotJob): Promise<Outcome<Manifest>> {
  const { toolbox, job, chapter } = request;
  const device = job.slot.device;
  if (!device) {
    return { ok: false, error: `${job.slot.id} declares no device to frame the plate in` };
  }
  const { files } = toolbox;
  const name = `${String(request.position).padStart(2, "0")}-${chapter.id}`;
  const directory = files.join(request.outputRoot, job.directory);
  const plate = await readPlate(files, request.platesRoot, { chapter, device: device.id, language: job.language });
  const composition = compose(request, device, plate);
  const early = [...plateFindings(name, { device, chapter, plate }), ...compositionFindings(request, composition)];
  if (early.length > 0 || plate.image === null) {
    return writeManifest(request, { directory, name, file: null, findings: early });
  }
  const projectDirectory = files.join(directory, "projects", name);
  await files.writeText(files.join(projectDirectory, "index.html"), composition.html);
  await files.copyTimelineLibrary(projectDirectory);
  await files.writeBytes(files.join(projectDirectory, PLATE_FILE), plate.image);
  await files.writeBytes(files.join(projectDirectory, SANS_FONT_FILE), request.fonts.sans.bytes);
  await files.writeBytes(files.join(projectDirectory, MONO_FONT_FILE), request.fonts.mono.bytes);
  const rendered = await toolbox.frames.renderFrames({ projectDirectory, framesDirectory: files.join(directory, "frames", name), fps: STILL_FPS });
  if (!rendered.ok) {
    return rendered;
  }
  const outputPath = files.join(directory, `${name}.png`);
  const firstFrame = rendered.value.framePattern.replace("%06d", String(rendered.value.startNumber).padStart(6, "0"));
  const flattened = await toolbox.media.flattenImage(firstFrame, outputPath);
  if (!flattened.ok) {
    return flattened;
  }
  const findings = auditImage({ slot: job.slot, target: name, bytes: await files.readBytes(outputPath) });
  return writeManifest(request, { directory, name, file: outputPath, findings });
}

function compose(request: ScreenshotJob, device: Device, plate: RecordedPlate): ScreenshotComposition {
  const { job, chapter, fonts } = request;
  return buildEditorialScreenshot({
    slot: job.slot, device, chapter, position: request.position, language: job.language,
    texture: request.story.texture[job.language],
    focus: chapter.focus ? plate.focus?.get(chapter.focus) ?? null : null,
    plate: { width: device.logicalWidth * device.plateScale, height: device.logicalHeight * device.plateScale },
    measures: { sans: (text, size) => textWidth(fonts.sans.advances, text, size), mono: (text, size) => textWidth(fonts.mono.advances, text, size) },
    guides: request.guides,
  });
}

function plateFindings(name: string, context: { device: Device; chapter: Chapter; plate: RecordedPlate }): readonly Finding[] {
  const { device, chapter, plate } = context;
  const imageFindings = auditPlate(name, device, plate.image);
  return imageFindings.length > 0 ? imageFindings : auditFocus(name, chapter.focus, plate.focus ? [...plate.focus.keys()] : null);
}

function compositionFindings(request: ScreenshotJob, composition: ScreenshotComposition): readonly Finding[] {
  const { catalog, job } = request;
  return [
    ...auditSafeArea(composition.id, { slot: job.slot, frames: composition.layout, profiles: [] }),
    ...auditLexicon(catalog, job.slot.store, composition.texts),
    ...auditContrast(composition.contrast),
    ...composition.fits.flatMap((entry) => auditHeadlineFit(`${composition.id} ${entry.role}`, entry.fit)),
  ];
}

type ManifestBody = { readonly directory: string; readonly name: string; readonly file: string | null; readonly findings: readonly Finding[] };

async function writeManifest(request: ScreenshotJob, body: ManifestBody): Promise<Outcome<Manifest>> {
  const { files } = request.toolbox;
  const sha256 = body.file ? await files.sha256(body.file) : null;
  const manifest = manifestOf({ piece: body.name, job: request.job, sha256, file: body.file, checkedFrames: body.file ? 1 : 0, findings: body.findings });
  await files.writeText(files.join(body.directory, `${body.name}.audit.json`), `${JSON.stringify(manifest, null, 2)}\n`);
  return { ok: true, value: manifest };
}
