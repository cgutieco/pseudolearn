export function encodeBase64Url(bytes: Uint8Array): string {
  let binary = "";
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary).replaceAll("+", "-").replaceAll("/", "_").replaceAll("=", "");
}

export function encodeBase64UrlText(text: string): string {
  return encodeBase64Url(new TextEncoder().encode(text));
}

export function decodeBase64UrlText(encoded: string): string | null {
  const bytes = decodeBase64UrlBytes(encoded);
  if (bytes === null) return null;
  try {
    return new TextDecoder("utf-8", { fatal: true }).decode(bytes);
  } catch {
    return null;
  }
}

export function decodeBase64UrlBytes(encoded: string): Uint8Array | null {
  try {
    const padded = encoded.replaceAll("-", "+").replaceAll("_", "/")
      .padEnd(Math.ceil(encoded.length / 4) * 4, "=");
    return Uint8Array.from(atob(padded), (character) => character.charCodeAt(0));
  } catch {
    return null;
  }
}
