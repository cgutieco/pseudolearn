import type { StereoSignal } from "./synthesizer.ts";

export function samplePeakDb(signal: StereoSignal): number {
  let peak = 0;
  for (const channel of [signal.left, signal.right]) {
    for (const sample of channel) {
      peak = Math.max(peak, Math.abs(sample));
    }
  }
  return peak === 0 ? Number.NEGATIVE_INFINITY : 20 * Math.log10(peak);
}

export function withGain(signal: StereoSignal, gainDb: number): StereoSignal {
  const factor = 10 ** (gainDb / 20);
  return {
    sampleRate: signal.sampleRate,
    left: signal.left.map((sample) => sample * factor),
    right: signal.right.map((sample) => sample * factor),
  };
}

export type GainPlan = { readonly gainDb: number; readonly limitedByPeak: boolean };

export type GainRequest = {
  readonly measuredLufs: number;
  readonly targetLufs: number;
  readonly measuredTruePeakDb: number;
  readonly ceilingDb: number;
};

export function gainToTarget(request: GainRequest): GainPlan {
  const wanted = request.targetLufs - request.measuredLufs;
  const allowed = request.ceilingDb - request.measuredTruePeakDb;
  return wanted <= allowed ? { gainDb: wanted, limitedByPeak: false } : { gainDb: allowed, limitedByPeak: true };
}
