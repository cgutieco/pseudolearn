import * as vscode from "vscode";
import { LanguageClient, type Middleware } from "vscode-languageclient/browser";
import { BrowserMessageReader, BrowserMessageWriter } from "vscode-languageserver-protocol/browser";
import type { ApiPort, Projection } from "../contracts/worker_transport";
import { encodeArguments, numeric } from "../application/canonical_arguments";
import { answerValue, boundedNumber, object, text } from "../application/wire_projection";
import { maximumPendingNotifications } from "../application/worker_protocol";

const numericFields = new Set(["line", "character", "code", "kind", "version", "triggerKind", "insertTextFormat",
  "insertTextMode", "start", "length", "parameter", "activeSignature", "activeParameter", "severity"]);

function restoreLsp(value: Projection, key = ""): unknown {
  if (Array.isArray(value)) return value.map((entry) => restoreLsp(entry, key === "data" ? "kind" : key));
  if (value !== null && typeof value === "object") {
    return Object.fromEntries(Object.entries(value).map(([name, entry]) => [name, restoreLsp(entry, name)]));
  }
  return typeof value === "string" && numericFields.has(key) && /^-?[0-9]+$/.test(value)
    ? boundedNumber(value) : value;
}

export class BrowserLanguageService {
  readonly client: LanguageClient;
  private resource = "";
  private readonly cancelled = new Set<string>();
  private queue = Promise.resolve();
  private pending = 0;

  constructor(private readonly api: ApiPort, options: { profile: string; strictness: string; locale: string }) {
    const channel = new MessageChannel();
    channel.port2.onmessage = (event) => this.enqueue(event.data, channel.port2);
    this.client = new LanguageClient("pseudolearn", "PseudoLearn", async () => {
      this.resource = text(answerValue(await api.call("create_lsp", "{}")).resource);
      return { reader: new BrowserMessageReader(channel.port1), writer: new BrowserMessageWriter(channel.port1) };
    }, { documentSelector: [{ language: "pseudolearn" }], initializationOptions: options,
      middleware: { provideRenameEdits: async (...parameters: Parameters<NonNullable<Middleware["provideRenameEdits"]>>) => {
        const [document, position, name, token, next] = parameters;
        const files = await vscode.workspace.findFiles("**/*.pseudo", "**/node_modules/**");
        for (let start = 0; start < files.length; start += 64) {
          await Promise.all(files.slice(start, start + 64).map((uri) => vscode.workspace.openTextDocument(uri)));
        }
        return next(document, position, name, token);
      } } });
  }

  async snapshot(parameters: unknown): Promise<void> {
    await this.client.sendNotification("pseudolearn/workspaceSnapshot", parameters);
  }

  async close(): Promise<void> {
    await this.client.stop(2000).catch(() => undefined);
    if (this.resource) await this.api.call("release", encodeArguments({ resource: numeric(this.resource) })).catch(() => undefined);
    this.api.close();
  }

  private enqueue(message: Record<string, unknown>, port: MessagePort): void {
    if (message.method === "$/cancelRequest") this.cancelled.add(JSON.stringify((message.params as { id: unknown }).id));
    if (++this.pending > maximumPendingNotifications) {
      this.api.close();
      void vscode.window.showErrorMessage("PseudoLearn: language queue overflow; restart the server.");
      return;
    }
    this.queue = this.queue.then(() => this.dispatch(message, port)).finally(() => { this.pending -= 1; });
    this.queue = this.queue.catch(() => { this.api.close(); });
  }

  private async dispatch(message: Record<string, unknown>, port: MessagePort): Promise<void> {
    const key = JSON.stringify(message.id);
    if (message.id !== undefined && this.cancelled.delete(key)) return this.cancelledReply(message.id, port);
    const response = answerValue(await this.api.call("lsp_message", encodeArguments({ resource: numeric(this.resource), message })));
    for (const projected of response.messages as Projection[]) {
      const restored = restoreLsp(projected) as Record<string, unknown>;
      if (object(projected).id !== undefined) restored.id = message.id;
      if (restored.id !== undefined && this.cancelled.delete(key)) this.cancelledReply(restored.id, port);
      else port.postMessage(restored);
    }
  }

  private cancelledReply(id: unknown, port: MessagePort): void {
    port.postMessage({ jsonrpc: "2.0", id, error: { code: -32800, message: "Request cancelled" } });
  }
}
