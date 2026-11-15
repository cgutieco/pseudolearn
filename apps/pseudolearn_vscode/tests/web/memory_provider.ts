import * as vscode from "vscode";

export interface ProviderFaults {
  rejectWrites: boolean;
  disconnectReads: boolean;
}

export interface MemoryProvider {
  faults: ProviderFaults;
  writes: string[];
  writeAttempts: () => number;
  seed: (path: string, text: string) => void;
  text: (path: string) => string | undefined;
  provider: vscode.FileSystemProvider;
}

function children(files: Map<string, Uint8Array>, uri: vscode.Uri): [string, boolean][] {
  const prefix = uri.path === "/" ? "/" : `${uri.path}/`;
  const names = new Map<string, boolean>();
  for (const path of files.keys()) {
    if (!path.startsWith(prefix)) continue;
    const rest = path.slice(prefix.length).split("/");
    names.set(rest[0]!, rest.length === 1);
  }
  return [...names];
}

export function createMemoryProvider(): MemoryProvider {
  const files = new Map<string, Uint8Array>();
  const faults: ProviderFaults = { rejectWrites: false, disconnectReads: false };
  const writes: string[] = [];
  let attempts = 0;
  const changes = new vscode.EventEmitter<vscode.FileChangeEvent[]>();
  const provider: vscode.FileSystemProvider = {
    onDidChangeFile: changes.event,
    watch: () => new vscode.Disposable(() => undefined),
    stat: (uri) => {
      const bytes = files.get(uri.path);
      if (bytes) return { type: vscode.FileType.File, ctime: 0, mtime: 0, size: bytes.length };
      if (children(files, uri).length > 0 || uri.path === "/") return { type: vscode.FileType.Directory, ctime: 0, mtime: 0, size: 0 };
      throw vscode.FileSystemError.FileNotFound(uri);
    },
    readDirectory: (uri) => children(files, uri).map(([name, file]): [string, vscode.FileType] =>
      [name, file ? vscode.FileType.File : vscode.FileType.Directory]),
    createDirectory: () => undefined,
    readFile: (uri) => {
      if (faults.disconnectReads) throw vscode.FileSystemError.FileNotFound(uri);
      const bytes = files.get(uri.path);
      if (!bytes) throw vscode.FileSystemError.FileNotFound(uri);
      return bytes.slice();
    },
    writeFile: (uri, content) => {
      attempts += 1;
      if (faults.rejectWrites) throw vscode.FileSystemError.NoPermissions(uri);
      writes.push(uri.path);
      files.set(uri.path, content.slice());
      changes.fire([{ type: vscode.FileChangeType.Changed, uri }]);
    },
    delete: (uri) => { files.delete(uri.path); },
    rename: () => { throw new Error("Rename is not part of the fixture provider"); },
  };
  return {
    faults, writes, provider, writeAttempts: () => attempts,
    seed: (path, text) => { files.set(path, new TextEncoder().encode(text)); },
    text: (path) => { const bytes = files.get(path); return bytes === undefined ? undefined : new TextDecoder().decode(bytes); },
  };
}

export function registerMemoryProvider(scheme: string): { provider: MemoryProvider; registration: vscode.Disposable } {
  const memory = createMemoryProvider();
  return { provider: memory, registration: vscode.workspace.registerFileSystemProvider(scheme, memory.provider, { isCaseSensitive: true }) };
}
