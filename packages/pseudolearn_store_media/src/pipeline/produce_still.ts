import type { Catalog } from "../catalog/catalog_types.ts";
import type { Finding } from "../audit/finding.ts";
import { auditContentRules } from "../audit/content_rules_audit.ts";
import { auditImage } from "../audit/image_audit.ts";
import { auditSafeArea } from "../audit/safe_area_audit.ts";
import { auditLexicon } from "../audit/text_audit.ts";
import type { Composition } from "../compose/composition.ts";
import { manifestOf, type Manifest } from "./manifest.ts";
import type { Outcome, Toolbox } from "./ports.ts";
import type { ProjectAsset } from "./produce_video.ts";
import type { Job } from "./render_plan.ts";

export type StillJob = {
  readonly toolbox: Toolbox;
  readonly catalog: Catalog;
  readonly job: Job;
  readonly composition: Composition;
  readonly assets: readonly ProjectAsset[];
  readonly findings: readonly Finding[];
  readonly outputRoot: string;
};

export async function produceStill(request: StillJob): Promise<Outcome<Manifest>> {
  const { toolbox, job, composition, catalog } = request;
  const { files } = toolbox;
  const directory = files.join(request.outputRoot, job.directory);
  await files.ensureDirectory(directory);
  const early = [
    ...request.findings,
    ...auditSafeArea(composition.id, { slot: job.slot, frames: composition.layout, profiles: job.slot.viewportProfiles }),
    ...auditLexicon(catalog, job.slot.store, composition.texts),
    ...auditContentRules(composition.id, { slot: job.slot, frames: composition.layout, texts: composition.texts, html: composition.html }),
  ];
  if (early.length > 0 || job.slot.video) {
    return writeManifest(request, { directory, file: null, findings: early });
  }
  const project = files.join(directory, "project");
  await files.writeText(files.join(project, "index.html"), composition.html);
  await files.copyTimelineLibrary(project);
  for (const asset of request.assets) {
    await files.writeBytes(files.join(project, asset.name), asset.bytes);
  }
  const rendered = await toolbox.frames.renderFrames({ projectDirectory: project, framesDirectory: files.join(directory, "frames"), fps: 1 });
  if (!rendered.ok) {
    return rendered;
  }
  const outputPath = files.join(directory, `${composition.id}.png`);
  const first = rendered.value.framePattern.replace("%06d", String(rendered.value.startNumber).padStart(6, "0"));
  const flattened = await toolbox.media.flattenImage(first, outputPath);
  if (!flattened.ok) {
    return flattened;
  }
  return writeManifest(request, { directory, file: outputPath, findings: auditImage({ slot: job.slot, target: composition.id, bytes: await files.readBytes(outputPath) }) });
}

type ManifestBody = { readonly directory: string; readonly file: string | null; readonly findings: readonly Finding[] };

async function writeManifest(request: StillJob, body: ManifestBody): Promise<Outcome<Manifest>> {
  const { files } = request.toolbox;
  const sha256 = body.file ? await files.sha256(body.file) : null;
  const manifest = manifestOf({ piece: request.composition.id, job: request.job, sha256, file: body.file, checkedFrames: body.file ? 1 : 0, findings: body.findings });
  await files.writeText(files.join(body.directory, `${request.composition.id}.audit.json`), `${JSON.stringify(manifest, null, 2)}\n`);
  return { ok: true, value: manifest };
}
