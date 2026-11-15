import type { LoudnessTarget } from "../catalog/catalog_types.ts";
import { scoreFor, type Voice } from "../audio/score.ts";
import { gainToTarget, withGain } from "../audio/signal_level.ts";
import { synthesize } from "../audio/synthesizer.ts";
import { encodeWav } from "../audio/wav_encoder.ts";
import { auditLoudness } from "../audit/loop_audit.ts";
import type { Finding } from "../audit/finding.ts";
import type { Storyboard } from "../story/storyboard.ts";
import type { Outcome, Toolbox } from "./ports.ts";

export type SoundtrackRequest = {
  readonly toolbox: Toolbox;
  readonly storyboard: Storyboard;
  readonly voice: Voice;
  readonly sampleRate: number;
  readonly loudness: LoudnessTarget;
  readonly directory: string;
};

export type Soundtrack = { readonly path: string; readonly findings: readonly Finding[] };

export async function produceSoundtrack(request: SoundtrackRequest): Promise<Outcome<Soundtrack>> {
  const { toolbox, storyboard, voice, sampleRate, loudness, directory } = request;
  const { files, media } = toolbox;
  const signal = synthesize(scoreFor(storyboard, voice, sampleRate));
  const draftPath = files.join(directory, "soundtrack-draft.wav");
  await files.writeBytes(draftPath, encodeWav(signal));
  const draft = await media.measureLoudness(draftPath);
  if (!draft.ok) {
    return draft;
  }
  const plan = gainToTarget({
    measuredLufs: draft.value.integratedLufs,
    targetLufs: loudness.integratedLufs,
    measuredTruePeakDb: draft.value.truePeakDb,
    ceilingDb: loudness.truePeakDb - 0.2,
  });
  const path = files.join(directory, "soundtrack.wav");
  await files.writeBytes(path, encodeWav(withGain(signal, plan.gainDb)));
  const final = await media.measureLoudness(path);
  if (!final.ok) {
    return final;
  }
  return { ok: true, value: { path, findings: auditLoudness("soundtrack.wav", final.value, loudness) } };
}
