import { isRecord } from "../../agent-responses/domain/credits.ts";
import {
  appleIntermediateMarker,
  appleReceiptSignerMarker,
  appleRootCertificateG3,
} from "./apple_root_certificate.ts";
import { SignedDataError } from "./der_reader.ts";
import {
  type Certificate,
  hasExtension,
  isSignedBy,
  parseCertificate,
  publicKeyOf,
} from "./x509_certificate.ts";

export interface SignedDataOptions {
  readonly trustedRoots?: readonly string[];
  readonly now?: () => number;
}

const chainLength = 3;

export class AppleSignedDataVerifier {
  private readonly roots: readonly Uint8Array<ArrayBuffer>[];
  private readonly now: () => number;

  constructor(options: SignedDataOptions = {}) {
    this.roots = (options.trustedRoots ?? [appleRootCertificateG3]).map(bytesOfBase64);
    this.now = options.now ?? Date.now;
  }

  async payloadOf(jws: string): Promise<Record<string, unknown>> {
    const parts = jws.split(".");
    if (parts.length !== 3) throw new SignedDataError("jws_format");
    const [encodedHeader, encodedPayload, encodedSignature] = parts;
    const header = jsonOf(bytesOfBase64Url(encodedHeader));
    if (header.alg !== "ES256" || !Array.isArray(header.x5c)) {
      throw new SignedDataError("jws_header");
    }
    const chain = header.x5c.map((entry) => {
      if (typeof entry !== "string") throw new SignedDataError("jws_x5c");
      return parseCertificate(bytesOfBase64(entry));
    });
    await this.verifyChain(chain);
    const valid = await crypto.subtle.verify(
      { name: "ECDSA", hash: "SHA-256" },
      await publicKeyOf(chain[0]),
      bytesOfBase64Url(encodedSignature),
      new TextEncoder().encode(`${encodedHeader}.${encodedPayload}`),
    );
    if (!valid) throw new SignedDataError("jws_signature");
    return jsonOf(bytesOfBase64Url(encodedPayload));
  }

  private async verifyChain(chain: readonly Certificate[]): Promise<void> {
    if (chain.length !== chainLength) throw new SignedDataError("chain_length");
    const [leaf, intermediate, root] = chain;
    if (!this.roots.some((trusted) => sameBytes(trusted, root.der))) {
      throw new SignedDataError("chain_root");
    }
    if (!hasExtension(intermediate, appleIntermediateMarker)) {
      throw new SignedDataError("chain_intermediate_marker");
    }
    if (!hasExtension(leaf, appleReceiptSignerMarker)) {
      throw new SignedDataError("chain_leaf_marker");
    }
    const now = this.now();
    if (chain.some((certificate) => now < certificate.notBefore || now > certificate.notAfter)) {
      throw new SignedDataError("chain_validity");
    }
    if (!(await isSignedBy(leaf, intermediate)) || !(await isSignedBy(intermediate, root))) {
      throw new SignedDataError("chain_signature");
    }
  }
}

function jsonOf(bytes: Uint8Array): Record<string, unknown> {
  try {
    const value: unknown = JSON.parse(new TextDecoder().decode(bytes));
    if (isRecord(value)) return value;
  } catch {
    throw new SignedDataError("jws_json");
  }
  throw new SignedDataError("jws_json");
}

function bytesOfBase64(value: string): Uint8Array<ArrayBuffer> {
  try {
    return Uint8Array.from(atob(value), (character) => character.charCodeAt(0));
  } catch {
    throw new SignedDataError("jws_base64");
  }
}

function bytesOfBase64Url(value: string): Uint8Array<ArrayBuffer> {
  const base64 = value.replace(/-/g, "+").replace(/_/g, "/");
  return bytesOfBase64(base64 + "=".repeat((4 - (base64.length % 4)) % 4));
}

function sameBytes(left: Uint8Array, right: Uint8Array): boolean {
  if (left.length !== right.length) return false;
  let difference = 0;
  for (let index = 0; index < left.length; index++) difference |= left[index] ^ right[index];
  return difference === 0;
}
