import type { DocumentsPort } from "../contracts/editor_documents";
import type { RunTarget } from "../contracts/editor_run";

export function hasUnsavedChanges(documents: DocumentsPort, target: RunTarget): boolean {
  const unsaved = documents.unsavedPaths();
  if (target.kind === "file") {
    return unsaved.includes(target.path);
  }
  const prefix = target.directory.endsWith("/") ? target.directory : `${target.directory}/`;
  return unsaved.some((path) => path.startsWith(prefix));
}
