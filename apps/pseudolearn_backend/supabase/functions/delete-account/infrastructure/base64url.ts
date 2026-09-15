export function encodeBase64Url(bytes: Uint8Array): string {
  let binary = "";
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary).replaceAll("+", "-").replaceAll("/", "_").replaceAll("=", "");
}

export function encodeBase64UrlText(text: string): string {
  return encodeBase64Url(new TextEncoder().encode(text));
}

export function decodeBase64UrlText(encoded: string): string | null {
  try {
    const padded = encoded.replaceAll("-", "+").replaceAll("_", "/")
      .padEnd(Math.ceil(encoded.length / 4) * 4, "=");
    const binary = atob(padded);
    const bytes = Uint8Array.from(binary, (character) => character.charCodeAt(0));
    return new TextDecoder("utf-8", { fatal: true }).decode(bytes);
  } catch {
    return null;
  }
}
