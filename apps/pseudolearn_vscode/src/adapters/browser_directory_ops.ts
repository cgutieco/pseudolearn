import * as vscode from "vscode";
import type { Projection } from "../contracts/worker_transport";
import { containsUri } from "../application/uri_authority";
import { object, text } from "../application/wire_projection";
import {
  FileHandle, MAX_FILE_BYTES, argumentBytes, committedEffect, errorCode, failedEffect,
  noLinks, providerFailure, relativePath, resolve,
} from "./browser_file_support";

const MUTATIONS = new Set(["directory_delete", "directory_rename", "directory_create"]);
const QUERIES = new Set(["directory_exists", "directory_is_directory", "directory_list"]);

export const isDirectoryOperation = (operation: string): boolean => MUTATIONS.has(operation) || QUERIES.has(operation);

type Targets = vscode.Uri[];
type Operation = (targets: Targets, root: vscode.Uri) => Promise<unknown>;

async function statOrUndefined(uri: vscode.Uri): Promise<vscode.FileStat | undefined> {
  try { return await vscode.workspace.fs.stat(uri); }
  catch (error) { if (errorCode(error) === "FileNotFound") return undefined; throw error; }
}

const isDirectory = (stat: vscode.FileStat | undefined): boolean => stat !== undefined && (stat.type & vscode.FileType.Directory) !== 0;

function parentOf(uri: vscode.Uri): vscode.Uri {
  const cut = uri.path.lastIndexOf("/");
  return uri.with({ path: cut > 0 ? uri.path.slice(0, cut) : "/" });
}

export function compareCodePoints(left: string, right: string): number {
  const first = Array.from(left, (character) => character.codePointAt(0) ?? 0);
  const second = Array.from(right, (character) => character.codePointAt(0) ?? 0);
  const shared = Math.min(first.length, second.length);
  for (let index = 0; index < shared; index += 1) {
    if (first[index] !== second[index]) return first[index] - second[index];
  }
  return first.length - second.length;
}

async function target(parent: FileHandle, path: string): Promise<vscode.Uri | undefined | null> {
  if (path.includes("\0")) return undefined;
  const uri = resolve(parent.uri, path);
  if (!parent.confined) return uri;
  if (!relativePath(path) || !containsUri(parent.confined, uri.toString())) return undefined;
  return await noLinks(parent.uri, path) ? uri : null;
}

const OPERATIONS: Record<string, Operation> = {
  directory_exists: async ([uri]) => committedEffect("boolean", await statOrUndefined(uri) !== undefined),
  directory_is_directory: async ([uri]) => committedEffect("boolean", isDirectory(await statOrUndefined(uri))),
  directory_list: async ([uri]) => {
    const stat = await statOrUndefined(uri);
    if (!stat) return failedEffect("no_encontrado");
    if (!isDirectory(stat)) return failedEffect("ruta_invalida");
    const entries = await vscode.workspace.fs.readDirectory(uri);
    return committedEffect("text_list", entries.map(([name]) => name).sort(compareCodePoints));
  },
  directory_delete: async ([uri], root) => {
    if (uri.toString() === root.toString()) return failedEffect("ruta_invalida");
    const stat = await statOrUndefined(uri);
    if (!stat) return failedEffect("no_encontrado");
    if (isDirectory(stat) && (await vscode.workspace.fs.readDirectory(uri)).length > 0) return failedEffect("peticion_invalida");
    await vscode.workspace.fs.delete(uri, { recursive: false, useTrash: false });
    return committedEffect("boolean", true);
  },
  directory_rename: async ([from, to], root) => {
    if (from.toString() === root.toString() || to.toString() === root.toString()) return failedEffect("ruta_invalida");
    if (!await statOrUndefined(from)) return failedEffect("no_encontrado");
    if (await statOrUndefined(to)) return failedEffect("ya_existe");
    if (to.path.startsWith(`${from.path}/`)) return failedEffect("ruta_invalida");
    const parent = await statOrUndefined(parentOf(to));
    if (!parent) return failedEffect("no_encontrado");
    if (!isDirectory(parent)) return failedEffect("ruta_invalida");
    await vscode.workspace.fs.rename(from, to, { overwrite: false });
    return committedEffect("boolean", true);
  },
  directory_create: async ([uri]) => {
    if (await statOrUndefined(uri)) return failedEffect("ya_existe");
    const parent = await statOrUndefined(parentOf(uri));
    if (!parent) return failedEffect("no_encontrado");
    if (!isDirectory(parent)) return failedEffect("ruta_invalida");
    await vscode.workspace.fs.createDirectory(uri);
    return committedEffect("boolean", true);
  },
};

export async function directoryOperation(effect: Record<string, Projection>, parent: FileHandle): Promise<unknown> {
  const operation = text(effect.operation);
  const mutating = MUTATIONS.has(operation);
  if (mutating ? !parent.writable : !parent.readable) return failedEffect();
  const targets: Targets = [];
  for (const argument of effect.arguments as Projection[]) {
    const uri = await target(parent, text(object(argument).value));
    if (uri === null) return failedEffect();
    if (uri === undefined) return failedEffect("ruta_invalida");
    targets.push(uri);
  }
  try { return await OPERATIONS[operation](targets, parent.uri); }
  catch (error) { return providerFailure(error, mutating); }
}

export async function appendOperation(effect: Record<string, Projection>, uri: vscode.Uri): Promise<unknown> {
  const bytes = argumentBytes((effect.arguments as Projection[])[0]);
  try {
    const current = (await statOrUndefined(uri)) ? await vscode.workspace.fs.readFile(uri) : new Uint8Array();
    if (current.length + bytes.length > MAX_FILE_BYTES) return failedEffect("limite_excedido");
    const combined = new Uint8Array(current.length + bytes.length);
    combined.set(current);
    combined.set(bytes, current.length);
    await vscode.workspace.fs.writeFile(uri, combined);
    return committedEffect("integer", bytes.length);
  } catch { return failedEffect("interrumpido", true); }
}
