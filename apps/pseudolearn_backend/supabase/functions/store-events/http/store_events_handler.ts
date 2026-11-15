import { AgentError } from "../../agent-responses/domain/agent_error.ts";
import { asAgentError, errorResponse } from "../../agent-responses/http/agent_envelope.ts";
import { maxBodyBytes } from "../../agent-responses/http/agent_request.ts";
import {
  handleStoreEvents,
  type StoreEventsDependencies,
} from "../application/store_events_service.ts";
import type { StoreEventReader } from "../domain/store_event.ts";

export interface StoreRoute {
  readonly reader: StoreEventReader;
  readonly signatureHeader: string | null;
}

export interface StoreEventsSetup {
  readonly routes: ReadonlyMap<string, StoreRoute>;
  readonly dependencies: StoreEventsDependencies | null;
}

export type StoreEventsLog = (entry: Record<string, unknown>) => void;

export function createStoreEventsHandler(
  setup: StoreEventsSetup,
  log: StoreEventsLog,
): (request: Request) => Promise<Response> {
  return async (request) => {
    const name = new URL(request.url).pathname.replace(/\/+$/, "").split("/").pop() ?? "";
    try {
      if (request.method !== "POST") throw new AgentError("method_not_allowed");
      const route = setup.routes.get(name);
      if (route === undefined) throw new AgentError("not_found");
      if (setup.dependencies === null) throw new AgentError("misconfigured");
      const body = await request.text();
      if (new TextEncoder().encode(body).length > maxBodyBytes) {
        throw new AgentError("payload_too_large");
      }
      const signature = route.signatureHeader === null
        ? null
        : request.headers.get(route.signatureHeader);
      const events = await route.reader.read(body, signature);
      const outcomes = await handleStoreEvents(events, setup.dependencies);
      log({ event: "store_event", store: name, outcomes });
      return Response.json({ outcomes }, { status: 200 });
    } catch (error) {
      const failure = asAgentError(error);
      log({ event: "store_event", store: name, code: failure.code });
      return errorResponse(failure, null);
    }
  };
}
