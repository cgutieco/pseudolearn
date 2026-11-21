import { rm } from "node:fs/promises";
import { join } from "node:path";
import { isAccepted } from "../pipeline/manifest.ts";
import { produceAppIcon } from "../pipeline/produce_app_icon.ts";
import { planJobs } from "../pipeline/render_plan.ts";
import { ffmpegToolkit } from "../render/ffmpeg_toolkit.ts";
import { hyperframesRenderer } from "../render/hyperframes_renderer.ts";
import { nodeFileStore } from "../render/node_file_store.ts";
import type { CommandContext } from "./main.ts";

export async function runIcon(context: CommandContext): Promise<number> {
  const files = nodeFileStore();
  const plan = planJobs({ catalog: context.catalog, slotIds: context.slotIds, languages: context.languages.slice(0, 1) });
  const jobs = plan.jobs.filter((job) => job.slot.kind === "app-icon");
  const outputRoot = join(context.packageRoot, "build", "icon");
  let failures = 0;
  for (const job of jobs) {
    const outcome = await produceAppIcon({ toolbox: { frames: hyperframesRenderer(), media: ffmpegToolkit(), files }, catalog: context.catalog, job, outputRoot });
    await rm(join(outputRoot, job.directory, "frames"), { recursive: true, force: true });
    if (!outcome.ok) {
      context.write(`${job.slot.id}: ${outcome.error}`);
      failures += 1;
      continue;
    }
    context.write(`${job.slot.id}: ${outcome.value.file ?? "not rendered"} ${isAccepted(outcome.value) ? "accepted" : "rejected"}`);
    outcome.value.findings.forEach((entry) => context.write(`  ${entry.rule} ${entry.target}: ${entry.message}`));
    failures += isAccepted(outcome.value) ? 0 : 1;
  }
  return failures === 0 && jobs.length > 0 ? 0 : 1;
}
