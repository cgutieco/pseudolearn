import type { Catalog } from "../catalog/catalog_types.ts";
import type { Voice } from "../audio/score.ts";
import type { Finding } from "../audit/finding.ts";
import { auditLoop } from "../audit/loop_audit.ts";
import { auditSafeArea } from "../audit/safe_area_audit.ts";
import { auditLexicon } from "../audit/text_audit.ts";
import { auditVideo } from "../audit/video_audit.ts";
import type { Composition } from "../compose/composition.ts";
import type { ViewportProfile } from "../layout/crop_projection.ts";
import type { Storyboard } from "../story/storyboard.ts";
import { manifestOf, type Manifest } from "./manifest.ts";
import type { Outcome, Toolbox } from "./ports.ts";
import type { Job } from "./render_plan.ts";
import { produceSoundtrack } from "./soundtrack.ts";

export type VideoRequest = {
  readonly toolbox: Toolbox;
  readonly catalog: Catalog;
  readonly job: Job;
  readonly composition: Composition;
  readonly storyboard: Storyboard;
  readonly voice: Voice;
  readonly profiles: readonly ViewportProfile[];
  readonly outputRoot: string;
};

export async function produceVideo(request: VideoRequest): Promise<Outcome<Manifest>> {
  const { toolbox, job, composition } = request;
  const video = job.slot.video;
  if (!video) {
    return { ok: false, error: `${job.slot.id} is not a video slot` };
  }
  const directory = toolbox.files.join(request.outputRoot, job.directory);
  const early = preRenderFindings(request);
  if (early.length > 0) {
    return writeManifest(request, directory, { file: null, checkedFrames: 0, findings: early });
  }
  const frames = await renderFrames(request, directory, video.fps);
  if (!frames.ok) {
    return frames;
  }
  const soundtrack = video.audio === "required"
    ? await produceSoundtrack({ toolbox, storyboard: request.storyboard, voice: request.voice,
      sampleRate: video.codecProfile.audio.sampleRate, loudness: request.catalog.loudness, directory })
    : null;
  if (soundtrack && !soundtrack.ok) {
    return soundtrack;
  }
  const outputPath = toolbox.files.join(directory, `${composition.id}.mp4`);
  const encoded = await toolbox.media.encode({ framePattern: frames.value.framePattern, startNumber: frames.value.startNumber, fps: video.fps,
    audioPath: soundtrack?.value.path ?? null, profile: video.codecProfile, outputPath });
  if (!encoded.ok) {
    return encoded;
  }
  const findings = await postRenderFindings(request, outputPath, frames.value.frameCount);
  if (!findings.ok) {
    return findings;
  }
  return writeManifest(request, directory, { file: outputPath, checkedFrames: frames.value.frameCount,
    findings: [...(soundtrack?.value.findings ?? []), ...findings.value] });
}

function preRenderFindings(request: VideoRequest): readonly Finding[] {
  const { catalog, job, composition, profiles } = request;
  return [
    ...auditSafeArea(composition.id, { slot: job.slot, frames: composition.layout, profiles }),
    ...auditLexicon(catalog, job.slot.store, composition.texts),
  ];
}

async function renderFrames(request: VideoRequest, directory: string, fps: number) {
  const { files } = request.toolbox;
  const projectDirectory = files.join(directory, "project");
  await files.ensureDirectory(projectDirectory);
  await files.writeText(files.join(projectDirectory, "index.html"), request.composition.html);
  await files.copyTimelineLibrary(projectDirectory);
  return request.toolbox.frames.renderFrames({ projectDirectory, framesDirectory: files.join(directory, "frames"), fps });
}

async function postRenderFindings(request: VideoRequest, outputPath: string, frameCount: number): Promise<Outcome<readonly Finding[]>> {
  const { media } = request.toolbox;
  const probe = await media.probe(outputPath);
  const first = await media.sampleFrame(outputPath, 0);
  const last = await media.sampleFrame(outputPath, frameCount - 1);
  if (!probe.ok || !first.ok || !last.ok) {
    return { ok: false, error: [probe, first, last].map((step) => (step.ok ? "" : step.error)).join(" ").trim() };
  }
  const target = request.composition.id;
  return { ok: true, value: [
    ...auditVideo({ slot: request.job.slot, target, probe: probe.value }),
    ...auditLoop(target, first.value, last.value),
  ] };
}

type ManifestBody = { readonly file: string | null; readonly checkedFrames: number; readonly findings: readonly Finding[] };

async function writeManifest(request: VideoRequest, directory: string, body: ManifestBody): Promise<Outcome<Manifest>> {
  const { files } = request.toolbox;
  const sha256 = body.file ? await files.sha256(body.file) : null;
  const manifest = manifestOf({ piece: request.composition.id, job: request.job, sha256, ...body });
  await files.ensureDirectory(directory);
  await files.writeText(files.join(directory, `${request.composition.id}.audit.json`), `${JSON.stringify(manifest, null, 2)}\n`);
  return { ok: true, value: manifest };
}
