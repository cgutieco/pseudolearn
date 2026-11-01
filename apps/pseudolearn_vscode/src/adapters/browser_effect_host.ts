import { NETWORK_CAPABILITIES, performFetch } from "../../../../packages/pseudolearn_engine/crates/pseudolearn_wasm/browser/fetch_host.mjs";
import type { BrowserGrants } from "../contracts/host_capabilities";
import type { Projection } from "../contracts/worker_transport";
import { object, text } from "../application/wire_projection";
import { numeric } from "../application/canonical_arguments";
import { BrowserFileHost, committedEffect, failedEffect } from "./browser_file_host";
import { toFetchEffect } from "./browser_fetch_effect";

export { NETWORK_CAPABILITIES };

export class BrowserEffectHost {
  private readonly abort = new AbortController();
  private readonly files: BrowserFileHost;
  private readonly resolved = new Set<string>();

  constructor(readonly grants: BrowserGrants) {
    this.files = new BrowserFileHost(grants.files);
  }

  async perform(effect: Record<string, Projection>): Promise<unknown> {
    const sequence = text(effect.effect_seq);
    if (this.abort.signal.aborted || this.resolved.has(sequence)) return failedEffect("interrumpido");
    if (this.resolved.size >= 65536) return failedEffect("limite_excedido");
    this.resolved.add(sequence);
    if (effect.operation === "request_network") {
      if (this.grants.origins.length === 0) return failedEffect();
      const capability = Object.fromEntries(Object.entries(object(effect.result_capability))
        .map(([name, value]) => [name, numeric(text(value))]));
      return committedEffect("capability", capability);
    }
    if (effect.operation === "network_send") {
      return performFetch(toFetchEffect(effect), { allowedOrigins: this.grants.origins, signal: this.abort.signal });
    }
    return this.files.perform(effect);
  }

  close(): void {
    this.abort.abort();
    this.files.clear();
    this.resolved.clear();
  }
}
