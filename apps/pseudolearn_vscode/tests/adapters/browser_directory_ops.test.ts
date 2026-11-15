import { beforeEach, describe, expect, it, vi } from "vitest";

vi.mock("vscode", async () => (await import("./memory_vscode")).createMemoryVscode());

import { memory } from "./memory_vscode";
import { BrowserFileHost } from "../../src/adapters/browser_file_host";
import { compareCodePoints } from "../../src/adapters/browser_directory_ops";

const token = (slot: number, kind: number) => ({ slot: String(slot), generation: "1", rights: "3", kind: String(kind) });
const text = (value: string) => ({ kind: "text", value });
let host: BrowserFileHost;

const run = (operation: string, receiver: number, ...values: string[]) =>
  host.perform({ operation, receiver: token(receiver, 2), arguments: values.map(text) });
const derive = (parent: number, path: string, mode: string, slot: number) =>
  host.perform({ operation: "directory_derive", receiver: token(parent, 2), result_capability: token(slot, 2), arguments: [text(path), text(mode)] });
const bytes = (value: string) => new TextEncoder().encode(value);
const failed = (code: string, uncertain = false) => ({ outcome: uncertain ? "uncertain" : "failed", value: { code, uncertain } });
const done = (kind: string, value: unknown) => ({ outcome: "committed", value: { kind, value } });

beforeEach(async () => {
  memory.entries.clear();
  memory.fault.next = undefined;
  for (const path of ["/root", "/root/sub", "/root/empty"]) memory.entries.set(path, "dir");
  memory.entries.set("/root/a", bytes("one"));
  memory.entries.set("/root/sub/inner", bytes("x"));
  memory.entries.set("/outside", bytes("secret"));
  host = new BrowserFileHost("memfs://host/root");
  await host.perform({ operation: "request_directory", result_capability: token(1, 2), arguments: [text(".")] });
});

describe("Browser directory operations", () => {
  it("lists names ordered by code point rather than UTF-16 unit", async () => {
    for (const name of ["b", "a", "C", "～", "\u{1F600}"]) memory.entries.set(`/root/empty/${name}`, bytes("x"));
    expect(await run("directory_list", 1, "empty")).toEqual(done("text_list", ["C", "a", "b", "～", "\u{1F600}"]));
    expect(compareCodePoints("\u{1F600}", "～")).toBeGreaterThan(0);
    expect(compareCodePoints("a", "a")).toBe(0);
    expect(compareCodePoints("a", "ab")).toBeLessThan(0);
  });
  it("reports empty, absent and file listings", async () => {
    expect(await run("directory_list", 1, "empty")).toEqual(done("text_list", []));
    expect(await run("directory_list", 1, "absent")).toEqual(failed("no_encontrado"));
    expect(await run("directory_list", 1, "a")).toEqual(failed("ruta_invalida"));
  });
  it("tells files, directories and absent paths apart", async () => {
    expect(await run("directory_exists", 1, "a")).toEqual(done("boolean", true));
    expect(await run("directory_exists", 1, "sub")).toEqual(done("boolean", true));
    expect(await run("directory_exists", 1, "absent")).toEqual(done("boolean", false));
    expect(await run("directory_is_directory", 1, "sub")).toEqual(done("boolean", true));
    expect(await run("directory_is_directory", 1, "a")).toEqual(done("boolean", false));
    expect(await run("directory_is_directory", 1, "absent")).toEqual(done("boolean", false));
  });
});

describe("Browser directory mutations", () => {
  it("creates one level and refuses existing, orphan and file-parent paths", async () => {
    expect(await run("directory_create", 1, "n")).toEqual(done("boolean", true));
    expect(memory.entries.get("/root/n")).toBe("dir");
    expect(await run("directory_create", 1, "n")).toEqual(failed("ya_existe"));
    expect(await run("directory_create", 1, "a")).toEqual(failed("ya_existe"));
    expect(await run("directory_create", 1, "p/n")).toEqual(failed("no_encontrado"));
    expect(await run("directory_create", 1, "a/n")).toEqual(failed("ruta_invalida"));
    expect(memory.entries.has("/root/p")).toBe(false);
  });
  it("deletes files and empty directories but never recursively", async () => {
    expect(await run("directory_delete", 1, "a")).toEqual(done("boolean", true));
    expect(await run("directory_delete", 1, "empty")).toEqual(done("boolean", true));
    expect(await run("directory_delete", 1, "sub")).toEqual(failed("peticion_invalida"));
    expect(memory.entries.has("/root/sub/inner")).toBe(true);
    expect(await run("directory_delete", 1, "absent")).toEqual(failed("no_encontrado"));
    expect(await run("directory_delete", 1, ".")).toEqual(failed("ruta_invalida"));
  });
  it("renames without overwriting and names each cause", async () => {
    memory.entries.set("/root/b", bytes("two"));
    expect(await run("directory_rename", 1, "a", "b")).toEqual(failed("ya_existe"));
    expect(await run("directory_rename", 1, "zz", "c")).toEqual(failed("no_encontrado"));
    expect(await run("directory_rename", 1, "a", "q/c")).toEqual(failed("no_encontrado"));
    expect(await run("directory_rename", 1, "a", "b/c")).toEqual(failed("ruta_invalida"));
    expect(await run("directory_rename", 1, "sub", "sub/n")).toEqual(failed("ruta_invalida"));
    expect(await run("directory_rename", 1, ".", "r")).toEqual(failed("ruta_invalida"));
    expect(await run("directory_rename", 1, "a", "c")).toEqual(done("boolean", true));
    expect(memory.entries.has("/root/a")).toBe(false);
    expect(await run("directory_rename", 1, "sub", "moved")).toEqual(done("boolean", true));
    expect(memory.entries.has("/root/moved/inner")).toBe(true);
  });
});

describe("Browser directory authority", () => {
  it("confines derived capabilities and refuses links", async () => {
    expect(await derive(1, "sub", "read_write", 2)).toMatchObject({ outcome: "committed" });
    for (const path of ["../a", "/outside", "a\\b", "c:x", "x/../../a"]) {
      for (const operation of ["directory_exists", "directory_list", "directory_delete", "directory_create"]) {
        expect(await run(operation, 2, path), `${operation} ${path}`).toEqual(failed("ruta_invalida"));
      }
      expect(await run("directory_rename", 2, "inner", path)).toEqual(failed("ruta_invalida"));
    }
    memory.entries.set("/root/sub/link", "link");
    expect(await run("directory_exists", 2, "link")).toEqual(failed("permiso_denegado"));
    expect(memory.entries.has("/outside")).toBe(true);
  });
  it("separates read and write authority", async () => {
    await derive(1, "sub", "read", 2);
    await derive(1, "sub", "write", 3);
    expect(await run("directory_exists", 2, "inner")).toEqual(done("boolean", true));
    for (const operation of ["directory_create", "directory_delete"]) expect(await run(operation, 2, "n")).toEqual(failed("permiso_denegado"));
    expect(await run("directory_rename", 2, "inner", "n")).toEqual(failed("permiso_denegado"));
    expect(await run("directory_exists", 3, "inner")).toEqual(failed("permiso_denegado"));
    expect(await run("directory_create", 3, "n")).toEqual(done("boolean", true));
  });
  it("rejects closed capabilities", async () => {
    await host.perform({ operation: "directory_close", receiver: token(1, 2) });
    expect(await run("directory_exists", 1, "a")).toEqual(failed("capacidad_cerrada"));
  });
  it("keeps provider uncertainty only for mutations", async () => {
    memory.fault.next = new Error("provider disconnected");
    expect(await run("directory_exists", 1, "a")).toEqual(failed("interrumpido"));
    memory.fault.next = new Error("provider disconnected");
    expect(await run("directory_create", 1, "n")).toEqual(failed("interrumpido", true));
    memory.fault.next = Object.assign(new Error("exists"), { code: "FileExists" });
    expect(await run("directory_create", 1, "m")).toEqual(failed("ya_existe"));
  });
});

describe("Browser file append", () => {
  const open = (name: string, mode: string) => host.perform({ operation: "file_open", receiver: token(1, 2), result_capability: token(5, 3),
    arguments: [text(name), text(mode)] });
  const append = (operation: string, value: Record<string, unknown>) => host.perform({ operation, receiver: token(5, 3), arguments: [value as never] });
  it("adds text and bytes at the end of the current content", async () => {
    await open("n", "write");
    expect(await append("file_append_text", text("é"))).toEqual(done("integer", 2));
    expect(await append("file_append_bytes", { kind: "bytes", value: ["121"] })).toEqual(done("integer", 1));
    expect(new TextDecoder().decode(memory.entries.get("/root/n") as Uint8Array)).toBe("éy");
  });
  it("denies read-only files, closed files and oversized content", async () => {
    await open("a", "read");
    expect(await append("file_append_text", text("z"))).toEqual(failed("permiso_denegado"));
    await open("n", "write");
    memory.entries.set("/root/n", new Uint8Array(1048576));
    expect(await append("file_append_text", text("z"))).toEqual(failed("limite_excedido"));
    await host.perform({ operation: "file_close", receiver: token(5, 3) });
    expect(await append("file_append_text", text("z"))).toEqual(failed("capacidad_cerrada"));
  });
  it("reports uncertainty when the provider fails while writing", async () => {
    await open("n", "write");
    memory.fault.next = new Error("provider disconnected");
    expect(await append("file_append_text", text("z"))).toEqual(failed("interrumpido", true));
  });
});
