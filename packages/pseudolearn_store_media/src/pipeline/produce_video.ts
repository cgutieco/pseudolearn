import type { Catalog } from "../catalog/catalog_types.ts";
import type { Voice } from "../audio/score.ts";
import type { Finding } from "../audit/finding.ts";
import { auditContentRules } from "../audit/content_rules_audit.ts";
import { auditDelivery } from "../audit/delivery_audit.ts";
import { auditLoopSeam, type SeamFrames } from "../audit/loop_seam_audit.ts";
import { auditFrameCoverage, auditSafeArea } from "../audit/safe_area_audit.ts";
import { auditLexicon } from "../audit/text_audit.ts";
import { auditVideo } from "../audit/video_audit.ts";
import type { Composition } from "../compose/composition.ts";
import type { Storyboard } from "../story/storyboard.ts";
import { manifestOf, type Manifest } from "./manifest.ts";
import type { Outcome, Toolbox } from "./ports.ts";
import type { Job } from "./render_plan.ts";
import { needsSafeAreaReview, produceSafeAreaReview } from "./safe_area_review.ts";
import { produceSoundtrack } from "./soundtrack.ts";

export type ProjectAsset = { readonly name: string; readonly bytes: Uint8Array };

export type VideoRequest = {
  readonly toolbox: Toolbox;
  readonly catalog: Catalog;
  readonly job: Job;
  readonly composition: Composition;
  readonly storyboard: Storyboard;
  readonly voice: Voice;
  readonly assets?: readonly ProjectAsset[];
  readonly findings?: readonly Finding[];
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
  const soundtrack = await soundtrackFor(request, directory);
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
  const review = needsSafeAreaReview(job.slot)
    ? await produceSafeAreaReview({ toolbox, slot: job.slot, directory, frames: frames.value, fps: video.fps })
    : { ok: true as const, value: "" };
  if (!review.ok) {
    return review;
  }
  return writeManifest(request, directory, { file: outputPath, checkedFrames: frames.value.frameCount,
    findings: [...(soundtrack?.value.findings ?? []), ...findings.value] });
}

function soundtrackFor(request: VideoRequest, directory: string) {
  const video = request.job.slot.video;
  if (!video || video.audio !== "required") {
    return Promise.resolve(null);
  }
  return produceSoundtrack({ toolbox: request.toolbox, storyboard: request.storyboard, voice: request.voice,
    sampleRate: video.codecProfile.audio.sampleRate, loudness: request.catalog.loudness, directory });
}

function preRenderFindings(request: VideoRequest): readonly Finding[] {
  const { catalog, job, composition } = request;
  const fps = job.slot.video?.fps ?? 1;
  const coverage = job.slot.rules.includes("key-info-centered")
    ? auditFrameCoverage(composition.id, { durationSeconds: composition.durationSeconds, fps }, composition.layout)
    : [];
  return [
    ...(request.findings ?? []),
    ...coverage,
    ...auditSafeArea(composition.id, { slot: job.slot, frames: composition.layout, profiles: job.slot.viewportProfiles }),
    ...auditLexicon(catalog, job.slot.store, composition.texts),
    ...auditContentRules(composition.id, { slot: job.slot, frames: composition.layout, texts: composition.texts, html: composition.html }),
  ];
}

async function renderFrames(request: VideoRequest, directory: string, fps: number) {
  const { files } = request.toolbox;
  const projectDirectory = files.join(directory, "project");
  await files.ensureDirectory(projectDirectory);
  await files.writeText(files.join(projectDirectory, "index.html"), request.composition.html);
  await files.copyTimelineLibrary(projectDirectory);
  for (const asset of request.assets ?? []) {
    await files.writeBytes(files.join(projectDirectory, asset.name), asset.bytes);
  }
  return request.toolbox.frames.renderFrames({ projectDirectory, framesDirectory: files.join(directory, "frames"), fps });
}

async function postRenderFindings(request: VideoRequest, outputPath: string, frameCount: number): Promise<Outcome<readonly Finding[]>> {
  const { media } = request.toolbox;
  const probe = await media.probe(outputPath);
  const loops = request.job.slot.rules.includes("seamless-loop");
  const seam = loops ? await sampleSeam(request, outputPath, frameCount) : { ok: true as const, value: null };
  if (!probe.ok || !seam.ok) {
    return { ok: false, error: [probe, seam].map((step) => (step.ok ? "" : step.error)).join(" ").trim() };
  }
  const target = request.composition.id;
  const profile = request.job.slot.video?.codecProfile;
  return { ok: true, value: [
    ...auditVideo({ slot: request.job.slot, target, probe: probe.value }),
    ...(profile ? auditDelivery({ profile, target, probe: probe.value }) : []),
    ...(seam.value ? auditLoopSeam(target, seam.value) : []),
  ] };
}

async function sampleSeam(request: VideoRequest, outputPath: string, frameCount: number): Promise<Outcome<SeamFrames>> {
  const indices = [0, 1, 2, frameCount - 3, frameCount - 2, frameCount - 1].map((index) => Math.max(0, index));
  const sampled: Uint8Array[] = [];
  for (const index of indices) {
    const frame = await request.toolbox.media.sampleFrame(outputPath, index);
    if (!frame.ok) {
      return frame;
    }
    sampled.push(frame.value);
  }
  const [first, second, third, antepenultimate, penultimate, last] = sampled as [Uint8Array, Uint8Array, Uint8Array, Uint8Array, Uint8Array, Uint8Array];
  return { ok: true, value: { first, second, third, antepenultimate, penultimate, last } };
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
