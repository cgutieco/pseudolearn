import type { LoudnessMeasure } from "../audit/loop_audit.ts";
import type { VideoProbe } from "../audit/video_audit.ts";
import type { EncodeRequest, MediaToolkit, Outcome } from "../pipeline/ports.ts";
import { encoderArguments, flattenArguments, frameSampleArguments, loudnessArguments, probeArguments } from "./ffmpeg_arguments.ts";
import { parseLoudness, parseProbe } from "./ffmpeg_reports.ts";
import { failureOf, runProcess } from "./process_runner.ts";

export const SAMPLE_WIDTH = 600;

export function ffmpegToolkit(): MediaToolkit {
  return { encode, probe, measureLoudness, sampleFrame, flattenImage };
}

async function encode(request: EncodeRequest): Promise<Outcome<string>> {
  const result = await runProcess("ffmpeg", encoderArguments(request));
  return result.code === 0 ? { ok: true, value: request.outputPath } : { ok: false, error: failureOf("ffmpeg", result) };
}

async function probe(path: string): Promise<Outcome<VideoProbe>> {
  const result = await runProcess("ffprobe", probeArguments(path));
  return result.code === 0 ? parseProbe(result.stdout.toString("utf8")) : { ok: false, error: failureOf("ffprobe", result) };
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
