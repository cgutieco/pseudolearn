type Entry = Uint8Array | "dir" | "link";

export const memory = {
  entries: new Map<string, Entry>(),
  fault: { next: undefined as Error | undefined },
};

export const fail = (code: string) => Object.assign(new Error(code), { code });

export function normalize(path: string): string {
  const parts: string[] = [];
  for (const part of path.split("/")) {
    if (part === "..") parts.pop();
    else if (part !== "" && part !== ".") parts.push(part);
  }
  return `/${parts.join("/")}`;
}

const descendants = (path: string) => [...memory.entries.keys()]
  .filter((key) => key !== path && key.startsWith(`${path === "/" ? "" : path}/`));

const kind = (value: Entry) => (value === "dir" ? 2 : value === "link" ? 64 : 1);

class FakeUri {
  constructor(readonly path: string) {}
  toString() { return ["memfs:", "", "host"].join("/") + this.path; }
  with(change: { path: string }) { return new FakeUri(change.path); }
}

function check(): void {
  const error = memory.fault.next;
  memory.fault.next = undefined;
  if (error) throw error;
}

async function stat(uri: FakeUri) {
  check();
  const value = memory.entries.get(uri.path);
  if (value === undefined) throw fail("FileNotFound");
  return { type: kind(value), size: value instanceof Uint8Array ? value.length : 0 };
}

async function readDirectory(uri: FakeUri) {
  return descendants(uri.path)
    .filter((key) => !key.slice(uri.path.length + 1).includes("/"))
    .map((key) => [key.slice(uri.path.length + 1), kind(memory.entries.get(key) ?? "dir")]);
}

async function readFile(uri: FakeUri) {
  const value = memory.entries.get(uri.path);
  if (!(value instanceof Uint8Array)) throw fail("FileNotFound");
  return value;
}

async function rename(from: FakeUri, to: FakeUri) {
  check();
  for (const key of [from.path, ...descendants(from.path)]) {
    const value = memory.entries.get(key) as Entry;
    memory.entries.delete(key);
    memory.entries.set(to.path + key.slice(from.path.length), value);
  }
}

const mutate = (action: (uri: FakeUri, bytes: Uint8Array) => void) => async (uri: FakeUri, bytes: Uint8Array) => {
  check();
  action(uri, bytes);
};

export function createMemoryVscode() {
  return {
    FileType: { File: 1, Directory: 2, SymbolicLink: 64 },
    Uri: {
      parse: (value: string) => new FakeUri(normalize(value.replace("memfs://host", ""))),
      joinPath: (base: FakeUri, ...parts: string[]) => new FakeUri(normalize([base.path, ...parts].join("/"))),
    },
    workspace: { fs: {
      stat, readDirectory, readFile, rename,
      writeFile: mutate((uri, bytes) => memory.entries.set(uri.path, bytes)),
      createDirectory: mutate((uri) => memory.entries.set(uri.path, "dir")),
      delete: mutate((uri) => memory.entries.delete(uri.path)),
    } },
  };
}
