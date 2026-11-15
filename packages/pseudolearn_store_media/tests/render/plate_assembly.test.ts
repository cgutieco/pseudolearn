import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { assemblePlate } from "../../src/render/plate_assembly.ts";
import { runProcess } from "../../src/render/process_runner.ts";

let directory = "";
const COLORS = { a: "0x102030", b: "0x405060", c: "0x708090" };

beforeAll(async () => {
  directory = mkdtempSync(join(tmpdir(), "plate-assembly-"));
  for (const [name, color] of Object.entries(COLORS)) {
    const made = await runProcess("ffmpeg", ["-hide_banner", "-loglevel", "error", "-f", "lavfi", "-i", `color=c=${color}:s=16x16`,
      "-frames:v", "1", "-pix_fmt", "rgb24", join(directory, `${name}.png`)]);
    expect(made.code).toBe(0);
  }
});

afterAll(() => {
  rmSync(directory, { recursive: true, force: true });
});

async function firstPixelPerFrame(path: string): Promise<readonly string[]> {
  const result = await runProcess("ffmpeg", ["-hide_banner", "-loglevel", "error", "-i", path, "-vf", "crop=1:1:0:0,format=rgb24", "-f", "rawvideo", "pipe:1"]);
  const hex = result.stdout.toString("hex");
  return hex.match(/.{6}/gu) ?? [];
}

describe("assemblePlate", () => {
  it("keeps every recorded frame in order, repeats included, without loss", async () => {
    const output = join(directory, "plate.mp4");
    const assembled = await assemblePlate({ directory, files: ["a.png", "a.png", "b.png", "c.png", "b.png"], fps: 30, outputPath: output });
    expect(assembled).toEqual({ ok: true, value: output });
    const expected = await Promise.all(["a", "a", "b", "c", "b"].map(async (name) => (await firstPixelPerFrame(join(directory, `${name}.png`)))[0]));
    expect(await firstPixelPerFrame(output)).toEqual(expected);
  });

  it("refuses an empty plate and reports a missing frame as a value", async () => {
    expect(await assemblePlate({ directory, files: [], fps: 30, outputPath: join(directory, "empty.mp4") }))
      .toEqual({ ok: false, error: `the plate in ${directory} has no frames` });
    expect((await assemblePlate({ directory, files: ["missing.png"], fps: 30, outputPath: join(directory, "missing.mp4") })).ok).toBe(false);
  });
});
