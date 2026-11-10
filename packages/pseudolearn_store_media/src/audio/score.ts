import type { Beat, Storyboard } from "../story/storyboard.ts";

export type Voice = {
  readonly rootHz: number;
  readonly scale: readonly number[];
  readonly padDegrees: readonly number[];
  readonly padGain: number;
  readonly cueGain: number;
  readonly cueDecaySeconds: number;
  readonly cueOctave: number;
  readonly stereoWidth: number;
};

export type Score = {
  readonly sampleRate: number;
  readonly durationSeconds: number;
  readonly voice: Voice;
  readonly beats: readonly Beat[];
};

export const CALIBRATION_VOICE: Voice = {
  rootHz: 146.83,
  scale: [0, 2, 4, 7, 9, 12, 14, 16, 19, 21],
  padDegrees: [0, 2, 4],
  padGain: 0.2,
  cueGain: 0.14,
  cueDecaySeconds: 0.45,
  cueOctave: 1,
  stereoWidth: 0.6,
};

export const PREVIEW_VOICE: Voice = {
  rootHz: 130.81,
  scale: [0, 2, 4, 7, 9, 12, 14, 16, 19, 21],
  padDegrees: [0, 4, 7],
  padGain: 0.16,
  cueGain: 0.11,
  cueDecaySeconds: 0.7,
  cueOctave: 2,
  stereoWidth: 0.5,
};

export function scoreFor(storyboard: Storyboard, voice: Voice, sampleRate: number): Score {
  return { sampleRate, durationSeconds: storyboard.durationSeconds, voice, beats: storyboard.beats };
}

export function frequencyOf(voice: Voice, degree: number, octave: number): number {
  const length = voice.scale.length;
  const wrapped = ((degree % length) + length) % length;
  const lapSemitones = 12 * Math.ceil((Math.max(0, ...voice.scale) + 1) / 12);
  const semitones = (voice.scale[wrapped] ?? 0) + lapSemitones * Math.floor(degree / length) + 12 * octave;
  return voice.rootHz * 2 ** (semitones / 12);
}

export function loopLockedFrequency(frequency: number, durationSeconds: number): number {
  return Math.max(1, Math.round(frequency * durationSeconds)) / durationSeconds;
}
