import * as vscode from "vscode";
import type { Projection } from "../contracts/worker_transport";
import { object, text } from "../application/wire_projection";

export interface FileHandle { uri: vscode.Uri; writable: boolean; readable: boolean; confined?: string }

export const MAX_FILE_BYTES = 1048576;

export const failedEffect = (code = "permiso_denegado", uncertain = false) => ({
  outcome: uncertain ? "uncertain" : "failed", value: { code, uncertain },
});
export const committedEffect = (kind: string, value: unknown) => ({ outcome: "committed", value: { kind, value } });

export function errorCode(error: unknown): string | undefined {
  return typeof error === "object" && error !== null && "code" in error && typeof error.code === "string" ? error.code : undefined;
}

const PROVIDER_CODES: Record<string, string> = {
  FileNotFound: "no_encontrado", FileExists: "ya_existe", FileNotADirectory: "ruta_invalida",
  FileIsADirectory: "ruta_invalida", NoPermissions: "permiso_denegado",
};

export function providerFailure(error: unknown, uncertain = false): unknown {
  const code = PROVIDER_CODES[errorCode(error) ?? ""];
  return code ? failedEffect(code) : failedEffect("interrumpido", uncertain);
}

export function resolve(parent: vscode.Uri, path: string): vscode.Uri {
  if (/^[a-zA-Z][a-zA-Z0-9+.-]*:/.test(path)) return vscode.Uri.parse(path);
  return path.startsWith("/") ? parent.with({ path }) : vscode.Uri.joinPath(parent, path);
}

export function relativePath(path: string): boolean {
  return path.length > 0 && !path.startsWith("/") && !path.includes("\\")
    && !path.includes(":") && !path.split("/").includes("..");
}

export async function noLinks(directory: vscode.Uri, path: string): Promise<boolean> {
  let current = directory;
  const parts = [".", ...path.split("/").filter((part) => part !== "." && part !== "")];
  for (const part of parts) {
    current = vscode.Uri.joinPath(current, part);
    try {
      if (((await vscode.workspace.fs.stat(current)).type & vscode.FileType.SymbolicLink) !== 0) return false;
    } catch (error) {
      if (errorCode(error) === "FileNotFound") return true;
      throw error;
    }
  }
  return true;
}

export function argumentBytes(argument: Projection | undefined): Uint8Array {
  const value = object(argument);
  return value.kind === "text" ? new TextEncoder().encode(text(value.value))
    : Uint8Array.from((value.value as string[]).map((entry) => Number(entry)));
}
