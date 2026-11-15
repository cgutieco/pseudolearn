import { readdir, rm } from "node:fs/promises";
import { join } from "node:path";
import { createRenderJob, executeRenderJob } from "@hyperframes/producer";
import type { FrameRenderer, FrameRenderRequest, Outcome, RenderedFrames } from "../pipeline/ports.ts";

const FRAME_NAME = /^frame_(\d{6})\.png$/u;

export function silenceTelemetry(environment: NodeJS.ProcessEnv): void {
  environment["HYPERFRAMES_NO_TELEMETRY"] = "1";
  environment["DO_NOT_TRACK"] = "1";
}

export function hyperframesRenderer(): FrameRenderer {
  return { renderFrames };
}

async function renderFrames(request: FrameRenderRequest): Promise<Outcome<RenderedFrames>> {
  await rm(request.framesDirectory, { recursive: true, force: true });
  try {
    const job = createRenderJob({ fps: request.fps, quality: "high", format: "png-sequence", videoFrameFormat: "png" });
    await executeRenderJob(job, request.projectDirectory, request.framesDirectory);
  } catch (error) {
    return { ok: false, error: `HyperFrames could not render ${request.projectDirectory}: ${String(error)}` };
  }
  return framesIn(request.framesDirectory);
}

export async function framesIn(directory: string): Promise<Outcome<RenderedFrames>> {
  const numbers = (await readdir(directory))
    .map((name) => FRAME_NAME.exec(name)?.[1])
    .filter((value): value is string => value !== undefined)
    .map(Number)
    .sort((first, second) => first - second);
  const startNumber = numbers[0];
  if (startNumber === undefined) {
    return { ok: false, error: `no frames were written to ${directory}` };
  }
  const contiguous = numbers.every((value, index) => value === startNumber + index);
  if (!contiguous) {
    return { ok: false, error: `frames in ${directory} are not contiguous` };
  }
  return { ok: true, value: { framePattern: join(directory, "frame_%06d.png"), startNumber, frameCount: numbers.length } };
}
