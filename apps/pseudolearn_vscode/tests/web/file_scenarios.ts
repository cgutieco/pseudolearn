import { BrowserEffectHost } from "../../src/adapters/browser_effect_host";
import type { Projection } from "../../src/contracts/worker_transport";
import { Recorder } from "./check";
import { directoryEffect, openEffect, readEffect, writeEffect, type Resolution } from "./effects";
import type { MemoryProvider } from "./memory_provider";

const perform = async (host: BrowserEffectHost, effect: unknown): Promise<Resolution> =>
  await host.perform(effect as Record<string, Projection>) as Resolution;

async function opened(provider: MemoryProvider, writable: boolean, mode: string, relative = "data.txt") {
  const host = new BrowserEffectHost({ root: "pseudolearn-fixture://files/root" });
  await perform(host, directoryEffect());
  await perform(host, { effect_seq: writable ? "derive-write" : "derive-read", operation: "directory_derive",
    receiver: { slot: "1", generation: "1", rights: "3", kind: "2" },
    result_capability: { slot: "1", generation: "1", rights: writable ? "3" : "1", kind: "2" },
    arguments: [{ kind: "text", value: "." }, { kind: "text", value: writable ? "read_write" : "read" }] });
  const file = await perform(host, openEffect(relative, mode));
  return { host, file, provider };
}

async function commitAndReject(recorder: Recorder, provider: MemoryProvider): Promise<void> {
  recorder.within("file save");
  const { host } = await opened(provider, true, "escritura");
  const committed = await perform(host, writeEffect("saved ñ"));
  recorder.equal([committed.outcome, provider.text("/root/data.txt")], ["committed", "saved ñ"], "write is committed after the provider confirms it");
  provider.faults.rejectWrites = true;
  const attempts = provider.writeAttempts();
  const rejected = await perform(host, writeEffect("lost"));
  recorder.equal([rejected.outcome, rejected.value.uncertain], ["uncertain", true], "rejected save is reported uncertain");
  recorder.equal([provider.writeAttempts() - attempts, provider.text("/root/data.txt")], [1, "saved ñ"], "rejected save is attempted once and never retried");
  provider.faults.rejectWrites = false;
}

async function disconnectAndDeny(recorder: Recorder, provider: MemoryProvider): Promise<void> {
  recorder.within("file provider disconnect");
  const reader = await opened(provider, true, "lectura");
  provider.faults.disconnectReads = true;
  const read = await perform(reader.host, readEffect());
  recorder.equal([read.outcome, read.value.code], ["failed", "no_encontrado"], "disconnect during a read fails without data");
  provider.faults.disconnectReads = false;
  const attempts = provider.writeAttempts();
  const readonly = await opened(provider, false, "escritura");
  recorder.equal(readonly.file.outcome, "failed", "read-only handle refuses write handles");
  const escape = await opened(provider, true, "escritura", "../escape.txt");
  recorder.equal([escape.file.outcome, escape.file.value.code], ["failed", "ruta_invalida"], "root escape is refused");
  recorder.equal(provider.writeAttempts(), attempts, "refused operations never reach the provider");
}

export async function runFileScenarios(recorder: Recorder, provider: MemoryProvider): Promise<void> {
  provider.seed("/root/data.txt", "seed");
  await commitAndReject(recorder, provider);
  await disconnectAndDeny(recorder, provider);
}
