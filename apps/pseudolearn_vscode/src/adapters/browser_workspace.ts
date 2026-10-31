import * as vscode from "vscode";
import type { ApiPort } from "../contracts/worker_transport";
import { containsUri } from "../application/uri_authority";
import { encodeArguments } from "../application/canonical_arguments";
import { answerValue, object, text } from "../application/wire_projection";

interface Source { path: string; source_id: number; text: string }
interface Manifest { location: string; text: string }

export interface BrowserSnapshot {
  project: { project_id: string; revision_id: string; manifests: Manifest[]; files: Source[] };
  packages: unknown[];
  uris: Record<string, string>;
  entries: string[];
}

export class BrowserWorkspace {
  private revision = 0;
  constructor(private readonly api: ApiPort, private readonly root: vscode.Uri) {}

  async read(): Promise<BrowserSnapshot> {
    const files: Source[] = [];
    const manifests: Manifest[] = [];
    const uris: Record<string, string> = {};
    let totalBytes = 0;
    for (const uri of await this.enumerate(this.root)) {
      const content = await vscode.workspace.fs.readFile(uri);
      if (content.length > 1048576) throw new Error("Workspace file exceeds 1 MiB");
      totalBytes += content.length;
      if (totalBytes > 33554432) throw new Error("Workspace snapshot exceeds 32 MiB");
      const path = uri.path.slice(this.root.path.replace(/\/$/, "").length + 1);
      const source = new TextDecoder("utf-8", { fatal: true }).decode(content);
      if (path.endsWith(".pseudo")) {
        files.push({ path, source_id: files.length + 1, text: source });
        uris[path] = uri.toString();
      } else manifests.push({ location: path, text: source });
    }
    const resolved = await this.resolve(manifests);
    return { project: { project_id: "1", revision_id: String(++this.revision), manifests, files },
      uris, ...resolved };
  }

  lspParameters(snapshot: BrowserSnapshot, options: unknown): unknown {
    return { project: { project_id: 1, revision_id: Number(snapshot.project.revision_id),
      files: snapshot.project.files, packages: snapshot.packages }, uris: snapshot.uris, options };
  }

  private async enumerate(root: vscode.Uri, depth = 0): Promise<vscode.Uri[]> {
    if (depth > 64) throw new Error("Workspace directory depth exceeds 64");
    const result: vscode.Uri[] = [];
    for (const [name, kind] of await vscode.workspace.fs.readDirectory(root)) {
      if (["node_modules", ".git", "target", ".artifacts"].includes(name)) continue;
      if ((kind & vscode.FileType.SymbolicLink) !== 0) throw new Error("Workspace symbolic links are not supported");
      const uri = vscode.Uri.joinPath(root, name);
      if (!containsUri(this.root.toString(), uri.toString())) throw new Error("Workspace URI escape");
      if (kind === vscode.FileType.Directory) result.push(...await this.enumerate(uri, depth + 1));
      else if (name.endsWith(".pseudo") || name === "pseudolearn.toml") result.push(uri);
      if (result.length > 4096) throw new Error("Workspace file limit exceeded");
    }
    return result.sort((left, right) => left.toString().localeCompare(right.toString(), "en"));
  }

  private async resolve(manifests: Manifest[]): Promise<{ packages: unknown[]; entries: string[] }> {
    const packages: unknown[] = [];
    const entries: string[] = [];
    for (const manifest of manifests) {
      const response = answerValue(await this.api.call("resolve_manifest", encodeArguments({ manifest: manifest.text, location: manifest.location })));
      if (response.configuration === null) throw new Error("Invalid PseudoLearn manifest");
      const configuration = object(response.configuration);
      const declaration = object(configuration.package);
      const dependencies = Object.fromEntries((configuration.dependencies as Record<string, string>[])
        .map((entry) => [entry.alias, entry.package]));
      const packageEntries = object(declaration.entries).value as string[];
      packages.push({ name: text(object(declaration.name).value), root: text(object(declaration.root).value),
        kind: text(object(declaration.kind).value), entries: packageEntries, dependencies });
      entries.push(...packageEntries);
    }
    return { packages, entries };
  }
}
