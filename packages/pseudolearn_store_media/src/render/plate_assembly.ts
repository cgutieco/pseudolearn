import { mkdir, rm, symlink } from "node:fs/promises";
import { dirname, join, resolve } from "node:path";
import type { Outcome, PlateAssemblyRequest } from "../pipeline/ports.ts";
import { plateAssemblyArguments } from "./ffmpeg_arguments.ts";
import { failureOf, runProcess } from "./process_runner.ts";

export async function assemblePlate(request: PlateAssemblyRequest): Promise<Outcome<string>> {
  if (request.files.length === 0) {
    return { ok: false, error: `the plate in ${request.directory} has no frames` };
  }
  const sequence = `${request.outputPath}.frames`;
  await rm(sequence, { recursive: true, force: true });
  await mkdir(sequence, { recursive: true });
  await mkdir(dirname(request.outputPath), { recursive: true });
  for (const [index, file] of request.files.entries()) {
    await symlink(resolve(request.directory, file), join(sequence, `frame_${String(index + 1).padStart(6, "0")}.png`));
  }
  const result = await runProcess("ffmpeg", plateAssemblyArguments(join(sequence, "frame_%06d.png"), request.fps, request.outputPath));
  await rm(sequence, { recursive: true, force: true });
  return result.code === 0 ? { ok: true, value: request.outputPath } : { ok: false, error: failureOf("ffmpeg", result) };
}
