import { LanguageClient, TransportKind } from "vscode-languageclient/node";
import type {
  ExplainAnswer,
  ExplainRequest,
  LanguageClientFactoryPort,
  LanguageClientPort,
} from "../contracts/language_client";

const contentModified = -32801;

interface ExplainResult {
  contents?: { value?: unknown };
}

export class VscodeLanguageClientFactory implements LanguageClientFactoryPort {
  create(executable: string): LanguageClientPort {
    const client = new LanguageClient(
      "pseudolearn",
      "PseudoLearn",
      { command: executable, args: ["lsp"], transport: TransportKind.stdio, options: { env: {} } },
      { documentSelector: [{ scheme: "file", language: "pseudolearn" }] },
    );
    return {
      start: () => client.start(),
      stop: (timeoutMilliseconds) => client.stop(timeoutMilliseconds),
      explain: (request) => explain(client, request),
    };
  }
}

async function explain(client: LanguageClient, request: ExplainRequest): Promise<ExplainAnswer> {
  try {
    const result = await client.sendRequest<ExplainResult | null>("workspace/executeCommand", {
      command: "pseudolearn.explain",
      arguments: [
        {
          uri: request.uri,
          version: request.version,
          position: { line: request.line, character: request.character },
          format: "plaintext",
        },
      ],
    });
    const text = result?.contents?.value;
    return typeof text === "string" && text !== "" ? { kind: "help", text } : { kind: "none" };
  } catch (error) {
    const code = (error as { code?: number }).code;
    if (code === contentModified) {
      return { kind: "stale" };
    }
    throw error;
  }
}
