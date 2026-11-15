import { describe, expect, it } from "vitest";
import { frameCount, frameTime, missingFrames, sampleEveryFrame } from "../../src/layout/frame_sampling.ts";

const clock = { durationSeconds: 2, fps: 30 };
const lockup = [{ name: "lockup", rect: { x: 0, y: 0, width: 1, height: 1 }, essential: true }];

describe("frame sampling", () => {
  it("counts and times every frame of the loop, the loop end excluded", () => {
    expect(frameCount(clock)).toBe(60);
    expect(frameTime(clock, 59)).toBeCloseTo(59 / 30, 9);
  });

  it("asks the composition for the elements of each frame", () => {
    const times: number[] = [];
    const layout = sampleEveryFrame(clock, (time) => {
      times.push(time);
      return lockup;
    });
    expect(layout).toHaveLength(60);
    expect(times[1]).toBeCloseTo(1 / 30, 9);
    expect(missingFrames(clock, layout)).toEqual([]);
  });

  it("names the frames a sparse layout leaves unchecked", () => {
    const sparse = [{ timeSeconds: 0, elements: lockup }, { timeSeconds: 1, elements: lockup }];
    const missing = missingFrames({ durationSeconds: 0.1, fps: 30 }, sparse);
    expect(missing).toEqual([1, 2]);
  });

  it("handles a zero-length clock", () => {
    expect(sampleEveryFrame({ durationSeconds: 0, fps: 30 }, () => lockup)).toEqual([]);
    expect(missingFrames({ durationSeconds: 0, fps: 30 }, [])).toEqual([]);
  });
});
