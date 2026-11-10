import { join } from "node:path";
import { isAccepted } from "../pipeline/manifest.ts";
import { produceCalibration } from "../pipeline/produce_calibration.ts";
import { planJobs } from "../pipeline/render_plan.ts";
import { ffmpegToolkit } from "../render/ffmpeg_toolkit.ts";
import { hyperframesRenderer } from "../render/hyperframes_renderer.ts";
import { nodeFileStore } from "../render/node_file_store.ts";
import type { CommandContext } from "./main.ts";

export async function runCalibrate(context: CommandContext): Promise<number> {
  const plan = planJobs({ catalog: context.catalog, slotIds: context.slotIds, languages: context.languages });
  const jobs = plan.jobs.filter((job) => job.slot.video !== null);
  if (context.slotIds.length === 0 || jobs.length === 0 || plan.unknownSlots.length > 0) {
    context.write("calibrate needs at least one known --slot of a video kind");
    return 2;
  }
  const toolbox = { frames: hyperframesRenderer(), media: ffmpegToolkit(), files: nodeFileStore() };
  let failures = 0;
  for (const job of jobs) {
    const outcome = await produceCalibration({ toolbox, catalog: context.catalog, job, guides: context.guides,
      outputRoot: join(context.packageRoot, "build", "calibration") });
    if (!outcome.ok) {
      context.write(`${job.slot.id} ${job.language}: ${outcome.error}`);
      failures += 1;
      continue;
    }
    const manifest = outcome.value;
    context.write(`${manifest.slot} ${manifest.language}: ${manifest.file ?? "not rendered"} ${isAccepted(manifest) ? "accepted" : "rejected"}`);
    manifest.findings.forEach((entry) => context.write(`  ${entry.rule} ${entry.target}: ${entry.message}`));
    failures += isAccepted(manifest) ? 0 : 1;
  }
  return failures === 0 ? 0 : 1;
}
