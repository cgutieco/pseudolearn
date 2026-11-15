import type { Catalog } from "../catalog/catalog_types.ts";
import { CALIBRATION_VOICE } from "../audio/score.ts";
import { buildCalibration } from "../compose/calibration.ts";
import { calibrationStoryboard } from "../story/calibration_storyboard.ts";
import type { Manifest } from "./manifest.ts";
import type { Outcome, Toolbox } from "./ports.ts";
import { produceVideo } from "./produce_video.ts";
import type { Job } from "./render_plan.ts";

export type CalibrationJob = {
  readonly toolbox: Toolbox;
  readonly catalog: Catalog;
  readonly job: Job;
  readonly guides: boolean;
  readonly outputRoot: string;
};

export function produceCalibration(request: CalibrationJob): Promise<Outcome<Manifest>> {
  const { job } = request;
  const storyboard = calibrationStoryboard(job.slot);
  const composition = buildCalibration({
    slot: job.slot,
    durationSeconds: storyboard.durationSeconds,
    beats: storyboard.beats,
    guides: request.guides,
  });
  return produceVideo({
    toolbox: request.toolbox,
    catalog: request.catalog,
    job,
    composition,
    storyboard,
    voice: CALIBRATION_VOICE,
    outputRoot: request.outputRoot,
  });
}
