import { NETWORK_CAPABILITIES, performFetch } from "../../../../packages/pseudolearn_engine/crates/pseudolearn_wasm/browser/fetch_host.mjs";
import type { BrowserHostContext } from "../contracts/host_capabilities";
import type { Projection } from "../contracts/worker_transport";
import { object, text } from "../application/wire_projection";
import { numeric } from "../application/canonical_arguments";
import { BrowserFileHost, committedEffect, failedEffect, capability } from "./browser_file_host";
import { toFetchEffect } from "./browser_fetch_effect";

export { NETWORK_CAPABILITIES };

export class BrowserEffectHost {
  private readonly abort = new AbortController();
  private readonly files: BrowserFileHost;
  private readonly resolved = new Set<string>();

  constructor(readonly context: BrowserHostContext = {}) {
    this.files = new BrowserFileHost(context.root);
  }

  async perform(effect: Record<string, Projection>): Promise<unknown> {
    const sequence = text(effect.effect_seq);
    if (this.abort.signal.aborted || this.resolved.has(sequence)) return failedEffect("interrumpido");
    if (this.resolved.size >= 65536) return failedEffect("limite_excedido");
    this.resolved.add(sequence);
    const operation = text(effect.operation);
    if (operation === "request_directory") return this.files.perform(effect);
    if (operation.startsWith("request_") || operation === "network_restrict") return committedEffect("capability", capability(effect.result_capability));
    if (operation === "network_send") return performFetch(toFetchEffect(effect), { signal: this.abort.signal });
    if (operation === "network_close") return committedEffect("boolean", true);
    if (operation === "arguments_values") return committedEffect("text_list", this.context.args ?? []);
    if (operation === "clock_now") return clock();
    if (operation === "clock_local_now") return localClock();
    if (operation === "environment_get") return failedEffect("permiso_denegado");
    if (operation === "timer_wait") return this.wait(effect);
    if (operation === "console_write") return committedEffect("integer", new TextEncoder().encode(text(object((effect.arguments as Projection[])[0]).value)).length);
    return this.files.perform(effect);
  }

  close(): void {
    this.abort.abort();
    this.files.clear();
    this.resolved.clear();
  }

  private async wait(effect: Record<string, Projection>): Promise<unknown> {
    const nanos = Number(text(object((effect.arguments as Projection[])[0]).value));
    if (!Number.isSafeInteger(nanos) || nanos < 0) return failedEffect("tiempo_agotado");
    const start = performance.now();
    while ((performance.now() - start) * 1_000_000 < nanos) {
      if (this.abort.signal.aborted) return failedEffect("interrumpido");
      await new Promise<void>((resolve) => setTimeout(resolve, Math.min(10, Math.ceil(nanos / 1_000_000))));
    }
    return this.abort.signal.aborted ? failedEffect("interrumpido") : clock();
  }
}

function clock(): unknown {
  return committedEffect("integer", numeric((BigInt(Date.now()) * 1_000_000n).toString()));
}

function localClock(): unknown {
  const milliseconds = Date.now();
  const offsetMinutes = Math.trunc(-new Date(milliseconds).getTimezoneOffset());
  return committedEffect("date_time", {
    nanos: numeric((BigInt(milliseconds) * 1_000_000n).toString()),
    offset_seconds: offsetMinutes * 60 + 0,
  });
}
