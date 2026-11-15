import { planJobs } from "../pipeline/render_plan.ts";
import type { CommandContext } from "./main.ts";

export async function runPlan(context: CommandContext): Promise<number> {
  const plan = planJobs({ catalog: context.catalog, slotIds: context.slotIds, languages: context.languages });
  for (const job of plan.jobs) {
    const { slot } = job;
    const media = slot.video ? `video ${slot.video.fps} fps ${slot.video.duration.min}–${slot.video.duration.max}s audio:${slot.video.audio}` : "image";
    context.write(`${slot.id}\t${job.language}\t${job.locales.join(",")}\t${slot.width}×${slot.height}\t${media}\t≤${slot.maxCount}`);
  }
  for (const unknown of plan.unknownSlots) {
    context.write(`unknown slot ${unknown}`);
  }
  return plan.unknownSlots.length === 0 ? 0 : 1;
}
