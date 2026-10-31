import * as vscode from "vscode";
import { LanguageClient, type Middleware } from "vscode-languageclient/node";
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

export interface LanguageServerOptions {
  profile: "es" | "en";
  strictness: "strict" | "flexible";
  locale: "es" | "en";
}

export class VscodeLanguageClientFactory implements LanguageClientFactoryPort {
  constructor(private readonly options: LanguageServerOptions) {}

  create(executable: string): LanguageClientPort {
    const client = new LanguageClient(
      "pseudolearn",
      "PseudoLearn",
      { command: executable, args: ["lsp"], options: { env: {} } },
      {
        documentSelector: [{ scheme: "file", language: "pseudolearn" }],
        initializationOptions: this.options,
        middleware: {
          provideRenameEdits: async (...[document, position, newName, token, next]: RenameRequest) => {
            await materializeWorkspaceSources();
            return next(document, position, newName, token);
          },
        },
      },
    );
    return {
      start: () => client.start(),
      stop: (timeoutMilliseconds) => client.stop(timeoutMilliseconds),
      explain: (request) => explain(client, request),
    };
  }
}

const materializationBatchSize = 64;

type RenameRequest = Parameters<NonNullable<Middleware["provideRenameEdits"]>>;

async function materializeWorkspaceSources(): Promise<void> {
  const sources = await vscode.workspace.findFiles("**/*.pseudo", "**/node_modules/**");
  for (let start = 0; start < sources.length; start += materializationBatchSize) {
    const batch = sources.slice(start, start + materializationBatchSize);
    await Promise.all(batch.map((source) => vscode.workspace.openTextDocument(source)));
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
