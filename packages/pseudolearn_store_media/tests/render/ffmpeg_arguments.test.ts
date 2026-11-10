import { describe, expect, it } from "vitest";
import { encoderArguments, frameSampleArguments, loudnessArguments, probeArguments } from "../../src/render/ffmpeg_arguments.ts";
import { slot } from "../support/catalog.ts";

function valueAfter(args: readonly string[], flag: string): string | undefined {
  const index = args.indexOf(flag);
  return index < 0 ? undefined : args[index + 1];
}

const previewProfile = slot("apple.iphone.app-preview").video!.codecProfile;
const trailerProfile = slot("microsoft.trailer").video!.codecProfile;

describe("encoderArguments", () => {
  it("encodes an Apple preview as H.264 High 4.0 with AAC 256 kbps", () => {
    const args = encoderArguments({ framePattern: "f/frame_%06d.png", startNumber: 1, fps: 30, audioPath: "a.wav", profile: previewProfile, outputPath: "o.mp4" });
    expect(valueAfter(args, "-profile:v")).toBe("high");
    expect(valueAfter(args, "-level:v")).toBe("4.0");
    expect(valueAfter(args, "-b:v")).toBe("11M");
    expect(valueAfter(args, "-b:a")).toBe("256k");
    expect(valueAfter(args, "-start_number")).toBe("1");
    expect(valueAfter(args, "-color_primaries")).toBe("bt709");
    expect(args.at(-1)).toBe("o.mp4");
    expect(args).not.toContain("-g");
  });

  it("closes the GOP at half the frame rate for the Microsoft trailer", () => {
    const args = encoderArguments({ framePattern: "p", startNumber: 0, fps: 30, audioPath: "a.wav", profile: trailerProfile, outputPath: "t.mp4" });
    expect(valueAfter(args, "-g")).toBe("15");
    expect(valueAfter(args, "-bf")).toBe("2");
    expect(args).toContain("+cgop");
    expect(valueAfter(args, "-b:a")).toBe("384k");
  });

  it("drops the audio stream when there is no soundtrack", () => {
    const args = encoderArguments({ framePattern: "p", startNumber: 0, fps: 30, audioPath: null, profile: previewProfile, outputPath: "s.mp4" });
    expect(args).toContain("-an");
    expect(args).not.toContain("-c:a");
    expect(args.filter((value) => value === "-i")).toHaveLength(1);
  });
});

describe("helper arguments", () => {
  it("samples one frame as raw RGB at the review width", () => {
    const args = frameSampleArguments("v.mp4", 449, 600);
    expect(valueAfter(args, "-vf")).toBe("select=eq(n\\,449),scale=600:-2:flags=area");
    expect(valueAfter(args, "-pix_fmt")).toBe("rgb24");
  });

  it("measures loudness with true peak and probes as JSON", () => {
    expect(loudnessArguments("a.wav")).toContain("ebur128=peak=true");
    expect(probeArguments("v.mp4")).toContain("json");
  });
});
