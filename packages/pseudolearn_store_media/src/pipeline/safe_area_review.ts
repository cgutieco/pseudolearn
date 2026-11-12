import type { Slot } from "../catalog/catalog_types.ts";
import { buildSafeAreaReview, type ReviewSample } from "../compose/safe_area_review.ts";
import type { Outcome, RenderedFrames, Toolbox } from "./ports.ts";

export const REVIEW_FRACTIONS = [0, 0.25, 0.5, 0.75] as const;
export const REVIEW_FILE = "safe-area-review.png";

export type SafeAreaReviewJob = {
  readonly toolbox: Toolbox;
  readonly slot: Slot;
  readonly directory: string;
  readonly frames: RenderedFrames;
  readonly fps: number;
};

export function needsSafeAreaReview(slot: Slot): boolean {
  return slot.rules.includes("key-info-centered") && slot.store === "app-store";
}

export function reviewFrameIndices(frameCount: number): readonly number[] {
  const indices = REVIEW_FRACTIONS.map((fraction) => Math.min(frameCount - 1, Math.round(fraction * frameCount)));
  return [...new Set(indices)].filter((index) => index >= 0);
}

export async function produceSafeAreaReview(job: SafeAreaReviewJob): Promise<Outcome<string>> {
  const { files } = job.toolbox;
  const project = files.join(job.directory, "review");
  await files.ensureDirectory(project);
  const samples: ReviewSample[] = [];
  for (const index of reviewFrameIndices(job.frames.frameCount)) {
    const image = `frame-${index}.png`;
    const source = frameFile(job.frames, index);
    await files.writeBytes(files.join(project, image), await files.readBytes(source));
    samples.push({ timeSeconds: index / job.fps, image });
  }
  const composition = buildSafeAreaReview({ slot: job.slot, samples });
  await files.writeText(files.join(project, "index.html"), composition.html);
  await files.copyTimelineLibrary(project);
  const rendered = await job.toolbox.frames.renderFrames({ projectDirectory: project, framesDirectory: files.join(project, "frames"), fps: 1 });
  if (!rendered.ok) {
    return rendered;
  }
  return job.toolbox.media.flattenImage(frameFile(rendered.value, 0), files.join(job.directory, REVIEW_FILE));
}

function frameFile(frames: RenderedFrames, index: number): string {
  return frames.framePattern.replace("%06d", String(frames.startNumber + index).padStart(6, "0"));
}
