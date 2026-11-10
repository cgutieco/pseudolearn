import type { Catalog } from "../catalog/catalog_types.ts";
import type { Voice } from "../audio/score.ts";
import { auditDelivery } from "../audit/delivery_audit.ts";
import type { Finding } from "../audit/finding.ts";
import { POSTER_PREVIEW_LONG_SIDE } from "../audit/poster_audit.ts";
import { auditVideo } from "../audit/video_audit.ts";
import { SANS_FONT_FILE } from "../compose/editorial_markup.ts";
import { buildPreviewComposition, type PreviewComposition } from "../compose/preview_composition.ts";
import { textWidth } from "../layout/glyph_advances.ts";
import { pixelInsets } from "../layout/preview_layout.ts";
import { planPreview, previewStoryboard, type PreviewFrame, type PreviewPlan } from "../story/preview_plan.ts";
import type { Preview } from "../story/preview_story.ts";
import { manifestOf, type Manifest } from "./manifest.ts";
import type { Outcome, Toolbox } from "./ports.ts";
import { previewFindings } from "./preview_findings.ts";
import { readPreviewPlates, type PreviewPlates } from "./preview_source.ts";
import type { LoadedFont } from "./produce_screenshot.ts";
import type { Job } from "./render_plan.ts";
import { produceSoundtrack } from "./soundtrack.ts";

export type PreviewJob = {
  readonly toolbox: Toolbox;
  readonly catalog: Catalog;
  readonly job: Job;
  readonly preview: Preview;
  readonly frame: PreviewFrame;
  readonly position: number;
  readonly font: LoadedFont;
  readonly voice: Voice;
  readonly platesRoot: string;
  readonly outputRoot: string;
};

type Staged = { readonly plan: PreviewPlan; readonly composition: PreviewComposition; readonly plates: PreviewPlates; readonly directory: string };

export async function producePreview(request: PreviewJob): Promise<Outcome<Manifest>> {
  const { toolbox, job } = request;
  const device = job.slot.device;
  if (!job.slot.video || !device) {
    return { ok: false, error: `${job.slot.id} is not an app-preview slot with a device` };
  }
  const name = `${String(request.position).padStart(2, "0")}-${request.preview.id}`;
  const directory = toolbox.files.join(request.outputRoot, job.directory, name);
  const plates = await readPreviewPlates(toolbox.files, request.platesRoot, { preview: request.preview, device: device.id, language: job.language });
  if (plates.problems.length > 0) {
    return { ok: false, error: plates.problems.join("; ") };
  }
  const plan = planPreview(request.preview, plates.timelines, request.frame);
  const composition = buildPreviewComposition({
    id: name, plan, canvas: { width: job.slot.width, height: job.slot.height }, language: job.language,
    insets: pixelInsets(device.insets, device.plateScale), measure: (text, size) => textWidth(request.font.advances, text, size),
  });
  const early = previewFindings({ catalog: request.catalog, slot: job.slot, plan, composition });
  if (early.length > 0) {
    return writeManifest(request, { directory, name, file: null, checkedFrames: 0, findings: early });
  }
  return renderPreview(request, { plan, composition, plates, directory });
}

async function renderPreview(request: PreviewJob, staged: Staged): Promise<Outcome<Manifest>> {
  const { toolbox, job } = request;
  const { files, media } = toolbox;
  const video = job.slot.video!;
  const project = files.join(staged.directory, "project");
  const prepared = await prepareProject(request, staged, project);
  if (!prepared.ok) {
    return prepared;
  }
  const frames = await toolbox.frames.renderFrames({ projectDirectory: project, framesDirectory: files.join(staged.directory, "frames"), fps: video.fps });
  if (!frames.ok) {
    return frames;
  }
  const soundtrack = await produceSoundtrack({ toolbox, storyboard: previewStoryboard(staged.plan), voice: request.voice,
    sampleRate: video.codecProfile.audio.sampleRate, loudness: request.catalog.loudness, directory: staged.directory });
  if (!soundtrack.ok) {
    return soundtrack;
  }
  const name = staged.composition.id;
  const outputPath = files.join(staged.directory, `${name}.mp4`);
  const encoded = await media.encode({ framePattern: frames.value.framePattern, startNumber: frames.value.startNumber, fps: video.fps,
    audioPath: soundtrack.value.path, profile: video.codecProfile, outputPath });
  if (!encoded.ok) {
    return encoded;
  }
  const checked = await fileFindings(request, { outputPath, name, staged });
  if (!checked.ok) {
    return checked;
  }
  return writeManifest(request, { directory: staged.directory, name, file: outputPath, checkedFrames: frames.value.frameCount,
    findings: [...soundtrack.value.findings, ...checked.value] });
}

async function prepareProject(request: PreviewJob, staged: Staged, project: string): Promise<Outcome<string>> {
  const { files, media } = request.toolbox;
  await files.ensureDirectory(project);
  await files.writeText(files.join(project, "index.html"), staged.composition.html);
  await files.copyTimelineLibrary(project);
  await files.writeBytes(files.join(project, SANS_FONT_FILE), request.font.bytes);
  for (const plate of staged.composition.plates) {
    const timeline = staged.plan.scenes[plate.sceneIndex]?.timeline;
    const directory = staged.plates.directories[plate.sceneIndex] ?? "";
    const assembled = await media.assemblePlate({ directory, files: timeline?.frames.map((frame) => frame.file) ?? [],
      fps: timeline?.fps ?? 30, outputPath: files.join(project, plate.file) });
    if (!assembled.ok) {
      return assembled;
    }
  }
  return { ok: true, value: project };
}

async function fileFindings(request: PreviewJob, context: { outputPath: string; name: string; staged: Staged }): Promise<Outcome<readonly Finding[]>> {
  const { files, media } = request.toolbox;
  const { outputPath, name, staged } = context;
  const probe = await media.probe(outputPath);
  if (!probe.ok) {
    return probe;
  }
  const frameIndex = Math.round(staged.plan.posterSeconds * (request.job.slot.video?.fps ?? 30));
  for (const [suffix, longSide] of [["poster", null], [`poster-${POSTER_PREVIEW_LONG_SIDE}`, POSTER_PREVIEW_LONG_SIDE]] as const) {
    const still = await media.extractStill({ videoPath: outputPath, frameIndex, longSide, outputPath: files.join(staged.directory, `${name}.${suffix}.png`) });
    if (!still.ok) {
      return still;
    }
  }
  const profile = request.job.slot.video!.codecProfile;
  return { ok: true, value: [
    ...auditVideo({ slot: request.job.slot, target: name, probe: probe.value }),
    ...auditDelivery({ profile, target: name, probe: probe.value }),
  ] };
}

type ManifestBody = { readonly directory: string; readonly name: string; readonly file: string | null; readonly checkedFrames: number; readonly findings: readonly Finding[] };

async function writeManifest(request: PreviewJob, body: ManifestBody): Promise<Outcome<Manifest>> {
  const { files } = request.toolbox;
  const sha256 = body.file ? await files.sha256(body.file) : null;
  const manifest = manifestOf({ piece: body.name, job: request.job, sha256, file: body.file, checkedFrames: body.checkedFrames, findings: body.findings });
  await files.writeText(files.join(body.directory, `${body.name}.audit.json`), `${JSON.stringify(manifest, null, 2)}\n`);
  return { ok: true, value: manifest };
}
