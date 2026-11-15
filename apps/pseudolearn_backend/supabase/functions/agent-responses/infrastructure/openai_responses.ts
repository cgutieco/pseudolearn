import type { ModelGateway, ModelReply } from "../domain/ports.ts";
import { type Fetcher, modelTimeoutMilliseconds } from "./fetcher.ts";

export const responsesUrl = "https://api.openai.com/v1/responses";

export class OpenAiResponses implements ModelGateway {
  constructor(private readonly apiKey: string, private readonly fetcher: Fetcher) {}

  async respond(body: Record<string, unknown>): Promise<ModelReply> {
    const response = await this.fetcher(responsesUrl, {
      method: "POST",
      headers: { authorization: `Bearer ${this.apiKey}`, "content-type": "application/json" },
      body: JSON.stringify(body),
      signal: AbortSignal.timeout(modelTimeoutMilliseconds),
    });
    const text = await response.text();
    return {
      status: response.status,
      body: text,
      json: parsed(text),
      retryAfter: response.headers.get("retry-after"),
    };
  }
}

function parsed(text: string): unknown {
  try {
    return JSON.parse(text);
  } catch {
    return null;
  }
}
