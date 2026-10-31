import * as vscode from "vscode";
import type { FileGrant } from "../contracts/host_capabilities";
import type { Projection } from "../contracts/worker_transport";
import { authorizeFile } from "../application/uri_authority";
import { numeric } from "../application/canonical_arguments";
import { object, text } from "../application/wire_projection";

export const failedEffect = (code = "permiso_denegado", uncertain = false) => ({
  outcome: uncertain ? "uncertain" : "failed", value: { code, uncertain },
});
export const committedEffect = (kind: string, value: unknown) => ({ outcome: "committed", value: { kind, value } });

function capability(value: Projection | undefined): unknown {
  return Object.fromEntries(Object.entries(object(value)).map(([key, token]) => [key, numeric(text(token))]));
}

function tokenKey(value: Projection | undefined): string {
  const token = object(value);
  return `${token.slot}:${token.generation}`;
}

export class BrowserFileHost {
  private readonly handles = new Map<string, { uri: vscode.Uri; writable: boolean }>();

  constructor(private readonly grant: FileGrant | undefined) {}

  async perform(effect: Record<string, Projection>): Promise<unknown> {
    const operation = text(effect.operation);
    if (operation === "request_directory") return this.directory(effect);
    const receiver = this.handles.get(tokenKey(effect.receiver));
    if (!receiver || !this.grant) return failedEffect();
    if (operation === "directory_close" || operation === "file_close") {
      this.handles.delete(tokenKey(effect.receiver));
      return committedEffect("boolean", true);
    }
    if (operation === "file_open") return this.open(effect, receiver.uri);
    const writing = operation.startsWith("file_write_");
    if (!authorizeFile(this.grant, receiver.uri.toString(), writing) || (writing && !receiver.writable)) return failedEffect();
    return writing ? this.write(effect, receiver.uri) : this.read(operation, receiver.uri);
  }

  clear(): void { this.handles.clear(); }

  private directory(effect: Record<string, Projection>): unknown {
    if (!this.grant?.confined) return failedEffect();
    if (object((effect.arguments as Projection[])[0]).value !== "root") return failedEffect("no_encontrado");
    if (this.handles.size >= 4096) return failedEffect("limite_excedido");
    this.handles.set(tokenKey(effect.result_capability), { uri: vscode.Uri.parse(this.grant.root), writable: this.grant.writable });
    return committedEffect("capability", capability(effect.result_capability));
  }

  private async open(effect: Record<string, Projection>, directory: vscode.Uri): Promise<unknown> {
    const argumentsList = effect.arguments as Projection[];
    const relative = text(object(argumentsList[0]).value);
    if (relative.split(/[\\/]/).some((part) => part === ".." || part === "." || part === "")) return failedEffect("ruta_invalida");
    const uri = vscode.Uri.joinPath(directory, relative);
    const mode = text(object(argumentsList[1]).value);
    const writable = ["escritura", "write", "read_write", "lectura_escritura"].includes(mode);
    if (!authorizeFile(this.grant, uri.toString(), writable)) return failedEffect();
    try {
      const status = await vscode.workspace.fs.stat(uri);
      if ((status.type & vscode.FileType.SymbolicLink) !== 0) return failedEffect("ruta_invalida");
    } catch {
      if (!writable) return failedEffect("no_encontrado");
    }
    this.handles.set(tokenKey(effect.result_capability), { uri, writable });
    return committedEffect("capability", capability(effect.result_capability));
  }

  private async read(operation: string, uri: vscode.Uri): Promise<unknown> {
    if (!["file_read_text", "file_read_bytes"].includes(operation)) return failedEffect("peticion_invalida");
    try {
      if ((await vscode.workspace.fs.stat(uri)).size > 1048576) return failedEffect("limite_excedido");
      const bytes = await vscode.workspace.fs.readFile(uri);
      return operation === "file_read_text" ? committedEffect("text", new TextDecoder("utf-8", { fatal: true }).decode(bytes))
        : committedEffect("bytes", Array.from(bytes));
    } catch { return failedEffect("interrumpido"); }
  }

  private async write(effect: Record<string, Projection>, uri: vscode.Uri): Promise<unknown> {
    const argument = object((effect.arguments as Projection[])[0]);
    const bytes = argument.kind === "text" ? new TextEncoder().encode(text(argument.value))
      : Uint8Array.from((argument.value as string[]).map((value) => Number(value)));
    if (bytes.length > 1048576) return failedEffect("limite_excedido");
    try {
      await vscode.workspace.fs.writeFile(uri, bytes);
      return committedEffect("integer", bytes.length);
    } catch { return failedEffect("interrumpido", true); }
  }
}
