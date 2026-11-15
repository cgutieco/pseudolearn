import { BrowserEffectHost } from "../../src/adapters/browser_effect_host";
import type { Projection } from "../../src/contracts/worker_transport";
import { Recorder } from "./check";
import { networkEffect, type Resolution } from "./effects";

export interface Fixture { http: string; https: string }

const perform = async (host: BrowserEffectHost, effect: unknown): Promise<Resolution> =>
  await host.perform(effect as Record<string, Projection>) as Resolution;

async function hits(fixture: Fixture): Promise<Record<string, number>> {
  return await (await fetch(`${fixture.http}/__hits`)).json() as Record<string, number>;
}

export async function probeTls(fixture: Fixture): Promise<"accepted" | "untrusted"> {
  const host = new BrowserEffectHost({ });
  const probe = await perform(host, networkEffect(`${fixture.https}/ok`));
  host.close();
  return probe.outcome === "committed" ? "accepted" : "untrusted";
}

async function unrestricted(recorder: Recorder, origin: string, fixture: Fixture): Promise<void> {
  recorder.within("http without configuration");
  const host = new BrowserEffectHost();
  const before = (await hits(fixture))["/ok"] ?? 0;
  const answer = await perform(host, networkEffect(origin + "/ok"));
  recorder.equal([answer.outcome, answer.value.value?.status, answer.value.value?.body],
    ["committed", 200, [111, 107]], "destination needs no configuration");
  recorder.equal((await hits(fixture))["/ok"], before + 1, "one physical request is sent");
}

async function limitsAndRedirects(recorder: Recorder, origin: string, fixture: Fixture): Promise<void> {
  recorder.within("http body, redirect and deadline");
  const host = new BrowserEffectHost({ });
  const big = await perform(host, networkEffect(`${origin}/big`, { effective_response_limit: "8" }));
  recorder.equal([big.outcome, big.value.code], ["failed", "limite_excedido"], "oversized body exceeds the decoded limit");
  const empty = await perform(host, networkEffect(`${origin}/empty`));
  recorder.equal(empty.value.value?.body, [], "empty body keeps zero length");
  const before = (await hits(fixture))["/ok"] ?? 0;
  const redirect = await perform(host, networkEffect(`${origin}/redirect`));
  recorder.equal([redirect.outcome, redirect.value.value?.status], ["committed", 200], "browser follows its platform redirect behavior");
  recorder.equal((await hits(fixture))["/ok"] ?? 0, before + 1, "browser follows the redirect once");
  const slow = await perform(host, networkEffect(`${origin}/slow`, { effective_timeout_nanos: "100000000" }));
  recorder.equal([slow.outcome, slow.value.code], ["failed", "tiempo_agotado"], "deadline maps to timeout");
  const status = await perform(host, networkEffect(`${origin}/status-500`));
  recorder.equal([status.outcome, status.value.value?.status], ["committed", 500], "status 500 is a response, not a transport error");
}

async function abortAndDisconnect(recorder: Recorder, origin: string): Promise<void> {
  recorder.within("http abort and disconnect");
  const reading = new BrowserEffectHost({ });
  const read = perform(reading, networkEffect(`${origin}/hang`));
  await new Promise((resolve) => setTimeout(resolve, 150));
  reading.close();
  const aborted = await read;
  recorder.equal([aborted.outcome, aborted.value.code, aborted.value.uncertain], ["failed", "interrumpido", false], "aborting a read in flight is a plain interruption");
  const mutating = new BrowserEffectHost({ });
  const post = perform(mutating, networkEffect(`${origin}/hang`, { method: "POST", body: ["1"] }));
  await new Promise((resolve) => setTimeout(resolve, 150));
  mutating.close();
  const uncertain = await post;
  recorder.equal([uncertain.outcome, uncertain.value.uncertain], ["uncertain", true], "aborting a sent mutation stays uncertain");
  const closed = await perform(mutating, networkEffect(`${origin}/ok`));
  recorder.equal(closed.value.code, "interrumpido", "a closed host dispatches nothing");
  const host = new BrowserEffectHost({ });
  const dropped = await perform(host, networkEffect(`${origin}/drop`));
  recorder.equal([dropped.outcome, dropped.value.code], ["failed", "conexion_fallida"], "server disconnect is a connection failure");
  const crossOrigin = await perform(host, networkEffect(`${origin}/nocors`));
  recorder.equal([crossOrigin.outcome, crossOrigin.value.code], ["failed", "conexion_fallida"], "missing CORS permission is indistinguishable from a connection failure");
}

export async function runHttpScenarios(recorder: Recorder, fixture: Fixture, tls: "accepted" | "untrusted"): Promise<void> {
  const origin = tls === "accepted" ? fixture.https : fixture.http;
  if (tls === "untrusted") {
    const untrusted = await perform(new BrowserEffectHost({ }), networkEffect(`${fixture.https}/ok`));
    recorder.within("tls");
    recorder.equal([untrusted.outcome, ["conexion_fallida", "tiempo_agotado"].includes(untrusted.value.code ?? "")], ["failed", true], "an untrusted certificate fails as an ordinary transport error");
  }
  await unrestricted(recorder, origin, fixture);
  await limitsAndRedirects(recorder, origin, fixture);
  await abortAndDisconnect(recorder, origin);
}
