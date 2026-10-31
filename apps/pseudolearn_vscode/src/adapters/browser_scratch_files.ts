import * as vscode from "vscode";

export const scratchRoot = "pseudolearn-memory://scratch/program";

interface Entry { type: vscode.FileType; bytes: Uint8Array; modified: number }

function lookup(entries: Map<string, Entry>, uri: vscode.Uri): Entry {
  const entry = entries.get(uri.path);
  if (!entry) throw vscode.FileSystemError.FileNotFound(uri);
  return entry;
}

function write(entries: Map<string, Entry>, uri: vscode.Uri, bytes: Uint8Array, options: { create: boolean; overwrite: boolean }): void {
  const current = entries.get(uri.path);
  if (!current && !options.create) throw vscode.FileSystemError.FileNotFound(uri);
  if (current && !options.overwrite) throw vscode.FileSystemError.FileExists(uri);
  if (current?.type === vscode.FileType.Directory) throw vscode.FileSystemError.FileIsADirectory(uri);
  const total = [...entries.values()].reduce((sum, entry) => sum + entry.bytes.length, 0) - (current?.bytes.length ?? 0) + bytes.length;
  if (bytes.length > 1048576 || total > 8388608 || entries.size >= 4096) throw vscode.FileSystemError.Unavailable("Scratch storage limit reached");
  if (!uri.path.startsWith("/program/") || uri.authority !== "scratch") throw vscode.FileSystemError.NoPermissions(uri);
  entries.set(uri.path, { type: vscode.FileType.File, bytes: bytes.slice(), modified: Date.now() });
}

function directory(entries: Map<string, Entry>, uri: vscode.Uri): [string, vscode.FileType][] {
  const prefix = `${uri.path}/`;
  return [...entries].filter(([path]) => path.startsWith(prefix) && !path.slice(prefix.length).includes("/"))
    .map(([path, entry]) => [path.slice(prefix.length), entry.type]);
}

export function registerScratchFiles(): vscode.Disposable {
  const entries = new Map<string, Entry>([["/program", { type: vscode.FileType.Directory, bytes: new Uint8Array(), modified: Date.now() }]]);
  const changed = new vscode.EventEmitter<vscode.FileChangeEvent[]>();
  const provider: vscode.FileSystemProvider = {
    onDidChangeFile: changed.event,
    watch: () => ({ dispose: () => undefined }),
    stat: (uri) => { const entry = lookup(entries, uri); return { type: entry.type, size: entry.bytes.length, ctime: 0, mtime: entry.modified }; },
    readDirectory: (uri) => directory(entries, uri),
    createDirectory: (uri) => { entries.set(uri.path, { type: vscode.FileType.Directory, bytes: new Uint8Array(), modified: Date.now() }); },
    readFile: (uri) => lookup(entries, uri).bytes.slice(),
    writeFile: (uri, bytes, options) => { write(entries, uri, bytes, options); changed.fire([{ type: vscode.FileChangeType.Changed, uri }]); },
    delete: (uri) => { lookup(entries, uri); entries.delete(uri.path); changed.fire([{ type: vscode.FileChangeType.Deleted, uri }]); },
    rename: (source, destination, options) => { const entry = lookup(entries, source); write(entries, destination, entry.bytes, { create: true, overwrite: options.overwrite }); entries.delete(source.path); },
  };
  return vscode.Disposable.from(vscode.workspace.registerFileSystemProvider("pseudolearn-memory", provider, { isCaseSensitive: true }), changed);
}
