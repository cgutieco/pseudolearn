import * as vscode from "vscode";
import type { Projection } from "../contracts/worker_transport";
import { containsUri } from "../application/uri_authority";
import { numeric } from "../application/canonical_arguments";
import { object, text } from "../application/wire_projection";
import { appendOperation, directoryOperation, isDirectoryOperation } from "./browser_directory_ops";
import {
  FileHandle, MAX_FILE_BYTES, argumentBytes, committedEffect, errorCode, failedEffect,
  noLinks, relativePath, resolve,
} from "./browser_file_support";

export { committedEffect, failedEffect };

export function capability(value: Projection | undefined): unknown {
  return Object.fromEntries(Object.entries(object(value)).map(([key, token]) => [key, numeric(text(token))]));
}

function tokenKey(value: Projection | undefined): string {
  const token = object(value);
  return `${token.slot}:${token.generation}`;
}

export class BrowserFileHost {
  private readonly handles = new Map<string, FileHandle>();

  constructor(private readonly root?: string) {}

  async perform(effect: Record<string, Projection>): Promise<unknown> {
    try { return await this.dispatch(effect); }
    catch (error) { return failedEffect(errorCode(error) === "FileNotFound" ? "no_encontrado" : "interrumpido"); }
  }

  clear(): void { this.handles.clear(); }

  private async dispatch(effect: Record<string, Projection>): Promise<unknown> {
    const operation = text(effect.operation);
    if (operation === "request_directory") return this.directory(effect);
    const receiver = this.handles.get(tokenKey(effect.receiver));
    if (!receiver) return failedEffect("capacidad_cerrada");
    if (operation === "directory_close" || operation === "file_close") {
      this.handles.delete(tokenKey(effect.receiver));
      return committedEffect("boolean", true);
    }
    if (operation === "file_open" || operation === "directory_derive") return this.open(effect, receiver);
    if (isDirectoryOperation(operation)) return directoryOperation(effect, receiver);
    const writing = operation.startsWith("file_write_") || operation.startsWith("file_append_");
    if (writing && !receiver.writable) return failedEffect();
    if (operation.startsWith("file_append_")) return appendOperation(effect, receiver.uri);
    return writing ? this.write(effect, receiver.uri) : this.read(operation, receiver.uri);
  }

  private async directory(effect: Record<string, Projection>): Promise<unknown> {
    const base = this.root ?? vscode.workspace.workspaceFolders?.[0]?.uri.toString();
    if (!base) return failedEffect("no_encontrado");
    const path = text(object((effect.arguments as Projection[])[0]).value);
    const uri = resolve(vscode.Uri.parse(base), path);
    if (((await vscode.workspace.fs.stat(uri)).type & vscode.FileType.Directory) === 0) return failedEffect("ruta_invalida");
    return this.register(effect, { uri, writable: true, readable: true });
  }

  private async open(effect: Record<string, Projection>, parent: FileHandle): Promise<unknown> {
    const argumentsList = effect.arguments as Projection[];
    const relative = text(object(argumentsList[0]).value);
    const deriving = effect.operation === "directory_derive";
    const uri = resolve(parent.uri, relative);
    if (relative.includes("\0") || (parent.confined && !containsUri(parent.confined, uri.toString()))) return failedEffect("ruta_invalida");
    if ((parent.confined || deriving) && !relativePath(relative)) return failedEffect("ruta_invalida");
    if ((parent.confined || deriving) && !await noLinks(parent.uri, relative)) return failedEffect();
    const mode = text(object(argumentsList[1]).value);
    const writable = ["escritura", "write", "read_write", "lectura_escritura"].includes(mode);
    if (writable && !parent.writable) return failedEffect();
    if (deriving) {
      if (((await vscode.workspace.fs.stat(uri)).type & vscode.FileType.Directory) === 0) return failedEffect("ruta_invalida");
    } else if (writable) { await vscode.workspace.fs.writeFile(uri, new Uint8Array()); }
    else { await vscode.workspace.fs.stat(uri); }
    const readable = ["lectura", "read", "read_write", "lectura_escritura"].includes(mode);
    return this.register(effect, { uri, writable, readable, confined: deriving ? uri.toString() : parent.confined });
  }

  private register(effect: Record<string, Projection>, handle: FileHandle): unknown {
    if (this.handles.size >= 4096) return failedEffect("limite_excedido");
    this.handles.set(tokenKey(effect.result_capability), handle);
    return committedEffect("capability", capability(effect.result_capability));
  }

  private async read(operation: string, uri: vscode.Uri): Promise<unknown> {
    if (!["file_read_text", "file_read_bytes"].includes(operation)) return failedEffect("peticion_invalida");
    if ((await vscode.workspace.fs.stat(uri)).size > 1048576) return failedEffect("limite_excedido");
    const bytes = await vscode.workspace.fs.readFile(uri);
    try { return operation === "file_read_text" ? committedEffect("text", new TextDecoder("utf-8", { fatal: true }).decode(bytes))
      : committedEffect("bytes", Array.from(bytes)); }
    catch { return failedEffect("utf8_invalido"); }
  }

  private async write(effect: Record<string, Projection>, uri: vscode.Uri): Promise<unknown> {
    const bytes = argumentBytes((effect.arguments as Projection[])[0]);
    if (bytes.length > MAX_FILE_BYTES) return failedEffect("limite_excedido");
    try { await vscode.workspace.fs.writeFile(uri, bytes); return committedEffect("integer", bytes.length); }
    catch { return failedEffect("interrumpido", true); }
  }
}
