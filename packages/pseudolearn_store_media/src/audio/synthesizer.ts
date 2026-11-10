import type { Beat } from "../story/storyboard.ts";
import { frequencyOf, loopLockedFrequency, type Score } from "./score.ts";

export type StereoSignal = {
  readonly sampleRate: number;
  readonly left: Float32Array;
  readonly right: Float32Array;
};

const TAU = 2 * Math.PI;
const ATTACK_SECONDS = 0.006;
const TAIL_DECAYS = 6;
const OVERTONES: readonly (readonly [number, number])[] = [[1, 1], [2, 0.32], [3, 0.12], [4.2, 0.05]];

export function synthesize(score: Score): StereoSignal {
  const length = Math.round(score.durationSeconds * score.sampleRate);
  const signal = { sampleRate: score.sampleRate, left: new Float32Array(length), right: new Float32Array(length) };
  addPad(signal, score);
  for (const beat of score.beats) {
    addCue(signal, score, beat);
  }
  return signal;
}

function addPad(signal: StereoSignal, score: Score): void {
  const { voice, durationSeconds, sampleRate } = score;
  const tones = voice.padDegrees.map((degree) => loopLockedFrequency(frequencyOf(voice, degree, 0), durationSeconds));
  const swell = loopLockedFrequency(1 / 8, durationSeconds);
  const gain = voice.padGain / Math.max(tones.length, 1);
  for (let index = 0; index < signal.left.length; index += 1) {
    const time = index / sampleRate;
    const breath = 0.8 + 0.2 * Math.sin(TAU * swell * time);
    let left = 0;
    let right = 0;
    tones.forEach((frequency, voiceIndex) => {
      const detune = 1 / durationSeconds;
      left += Math.sin(TAU * frequency * time + voiceIndex);
      right += Math.sin(TAU * (frequency + detune) * time + voiceIndex);
    });
    signal.left[index] = (signal.left[index] ?? 0) + gain * breath * left;
    signal.right[index] = (signal.right[index] ?? 0) + gain * breath * right;
  }
}

function addCue(signal: StereoSignal, score: Score, beat: Beat): void {
  const { voice, sampleRate } = score;
  const frequency = frequencyOf(voice, beat.degree, voice.cueOctave);
  const tailSamples = Math.round(voice.cueDecaySeconds * TAIL_DECAYS * sampleRate);
  const start = Math.round(beat.atSeconds * sampleRate);
  const pan = panFor(beat.degree, voice.stereoWidth);
  const gain = voice.cueGain * beat.weight * (beat.kind === "resolve" ? 1.2 : 1);
  const partner = beat.kind === "resolve" ? frequencyOf(voice, beat.degree + 3, voice.cueOctave) : 0;
  const length = signal.left.length;
  for (let offset = 0; offset < tailSamples; offset += 1) {
    const time = offset / sampleRate;
    const envelope = Math.min(1, time / ATTACK_SECONDS) * Math.exp(-time / voice.cueDecaySeconds);
    const tone = bell(frequency, time) + (partner > 0 ? 0.6 * bell(partner, time) : 0);
    const sample = gain * envelope * tone;
    const position = (start + offset) % length;
    signal.left[position] = (signal.left[position] ?? 0) + sample * pan.left;
    signal.right[position] = (signal.right[position] ?? 0) + sample * pan.right;
  }
}

function bell(frequency: number, time: number): number {
  return OVERTONES.reduce((sum, [ratio, amount]) => sum + amount * Math.sin(TAU * frequency * ratio * time), 0);
}

function panFor(degree: number, width: number): { left: number; right: number } {
  const position = ((((degree % 5) + 5) % 5) / 4 - 0.5) * width;
  const angle = (position + 1) * (Math.PI / 4);
  return { left: Math.cos(angle), right: Math.sin(angle) };
}
