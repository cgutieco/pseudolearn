import type { LoudnessMeasure } from "../audit/loop_audit.ts";
import type { VideoProbe } from "../audit/video_audit.ts";
import type { EncodeRequest, MediaToolkit, Outcome, StillRequest } from "../pipeline/ports.ts";
import { encoderArguments, flattenArguments, frameSampleArguments, frameTypeArguments, loudnessArguments, probeArguments, stillArguments } from "./ffmpeg_arguments.ts";
import { parseFrameTypes, parseLoudness, parseProbe } from "./ffmpeg_reports.ts";
import { readMp4Layout } from "./mp4_layout.ts";
import { assemblePlate } from "./plate_assembly.ts";
import { failureOf, runProcess } from "./process_runner.ts";

export const SAMPLE_WIDTH = 600;

export function ffmpegToolkit(): MediaToolkit {
  return { encode, probe, measureLoudness, sampleFrame, flattenImage, assemblePlate, extractStill };
}

async function encode(request: EncodeRequest): Promise<Outcome<string>> {
  const result = await runProcess("ffmpeg", encoderArguments(request));
  return result.code === 0 ? { ok: true, value: request.outputPath } : { ok: false, error: failureOf("ffmpeg", result) };
}

async function probe(path: string): Promise<Outcome<VideoProbe>> {
  const result = await runProcess("ffprobe", probeArguments(path));
  const parsed = result.code === 0 ? parseProbe(result.stdout.toString("utf8")) : { ok: false as const, error: failureOf("ffprobe", result) };
  if (!parsed.ok) {
    return parsed;
  }
  const frames = await runProcess("ffprobe", frameTypeArguments(path));
  if (frames.code !== 0) {
    return { ok: false, error: failureOf("ffprobe", frames) };
  }
  const layout = await readMp4Layout(path);
  if (!layout.ok) {
    return layout;
  }
  const structure = { ...parseFrameTypes(frames.stdout.toString("utf8")), ...layout.value };
  return { ok: true, value: { ...parsed.value, delivery: { ...parsed.value.delivery, structure } } };
}

async function measureLoudness(path: string): Promise<Outcome<LoudnessMeasure>> {
  const result = await runProcess("ffmpeg", loudnessArguments(path));
  return result.code === 0 ? parseLoudness(result.stderr) : { ok: false, error: failureOf("ffmpeg", result) };
}

async function sampleFrame(path: string, frameIndex: number): Promise<Outcome<Uint8Array>> {
  const result = await runProcess("ffmpeg", frameSampleArguments(path, frameIndex, SAMPLE_WIDTH));
  if (result.code !== 0) {
    return { ok: false, error: failureOf("ffmpeg", result) };
  }
  if (result.stdout.length === 0) {
    return { ok: false, error: `frame ${frameIndex} does not exist in ${path}` };
  }
  return { ok: true, value: new Uint8Array(result.stdout) };
}

async function flattenImage(inputPath: string, outputPath: string): Promise<Outcome<string>> {
  const result = await runProcess("ffmpeg", flattenArguments(inputPath, outputPath));
  return result.code === 0 ? { ok: true, value: outputPath } : { ok: false, error: failureOf("ffmpeg", result) };
}

async function extractStill(request: StillRequest): Promise<Outcome<string>> {
  const result = await runProcess("ffmpeg", stillArguments(request));
  return result.code === 0 ? { ok: true, value: request.outputPath } : { ok: false, error: failureOf("ffmpeg", result) };
}
