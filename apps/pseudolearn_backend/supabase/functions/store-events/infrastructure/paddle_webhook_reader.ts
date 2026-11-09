import { AgentError } from "../../agent-responses/domain/agent_error.ts";
import { paddleEventOf, type PaddlePrices } from "../domain/paddle_event.ts";
import type { StoreEvent, StoreEventReader } from "../domain/store_event.ts";

const toleranceSeconds = 300;
const millisecondsPerSecond = 1_000;

export class PaddleWebhookReader implements StoreEventReader {
  constructor(
    private readonly secret: string,
    private readonly prices: PaddlePrices,
    private readonly now: () => number = Date.now,
  ) {}

  async read(body: string, signature: string | null): Promise<readonly StoreEvent[]> {
    const { timestamp, hashes } = partsOf(signature ?? "");
    const age = Math.abs(this.now() / millisecondsPerSecond - Number(timestamp));
    if (timestamp === null || !Number.isFinite(age) || age > toleranceSeconds) {
      throw new AgentError("invalid_signature");
    }
    const expected = await this.hashOf(`${timestamp}:${body}`);
    if (!hashes.some((hash) => sameText(hash, expected))) throw new AgentError("invalid_signature");
    try {
      return [paddleEventOf(JSON.parse(body), this.prices)];
    } catch {
      throw new AgentError("invalid_request", "json");
    }
  }

  private async hashOf(message: string): Promise<string> {
    const encoder = new TextEncoder();
    const key = await crypto.subtle.importKey(
      "raw",
      encoder.encode(this.secret),
      { name: "HMAC", hash: "SHA-256" },
      false,
      ["sign"],
    );
    const digest = new Uint8Array(await crypto.subtle.sign("HMAC", key, encoder.encode(message)));
    return Array.from(digest, (byte) => byte.toString(16).padStart(2, "0")).join("");
  }
}

function partsOf(signature: string): { timestamp: string | null; hashes: string[] } {
  const pairs = signature.split(";").map((pair) => pair.trim().split("="));
  const timestamp = pairs.find(([name]) => name === "ts")?.[1] ?? null;
  const hashes = pairs.filter(([name]) => name === "h1").map(([, value]) => value ?? "");
  return { timestamp, hashes };
}

function sameText(left: string, right: string): boolean {
  if (left.length !== right.length) return false;
  let difference = 0;
  for (let index = 0; index < left.length; index++) {
    difference |= left.charCodeAt(index) ^ right.charCodeAt(index);
  }
  return difference === 0;
}
