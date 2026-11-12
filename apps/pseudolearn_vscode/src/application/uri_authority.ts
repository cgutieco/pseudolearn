
function components(value: string): { scheme: string; authority: string; parts: string[] } | undefined {
  const match = /^([a-zA-Z][a-zA-Z0-9+.-]*):(?:\/\/([^/]*))?(\/[^?#]*)$/.exec(value);
  if (!match || /%2f|%5c/i.test(value)) return undefined;
  try {
    const parts = (match[3] ?? "/").split("/").filter(Boolean).map(decodeURIComponent);
    if (parts.some((part) => part === "." || part === ".." || part.includes("\\") || part.includes("\0"))) return undefined;
    return { scheme: match[1]!.toLowerCase(), authority: match[2] ?? "", parts };
  } catch {
    return undefined;
  }
}

export function containsUri(root: string, candidate: string): boolean {
  const parent = components(root);
  const child = components(candidate);
  return parent !== undefined && child !== undefined && parent.scheme === child.scheme
    && parent.authority === child.authority && child.parts.length >= parent.parts.length
    && parent.parts.every((part, index) => part === child.parts[index]);
}
