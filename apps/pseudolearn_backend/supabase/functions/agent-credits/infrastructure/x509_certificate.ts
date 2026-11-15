import {
  childrenOf,
  containsBytes,
  encodedObjectIdentifier,
  objectIdentifierOf,
  readNode,
  SignedDataError,
  timeOf,
} from "./der_reader.ts";

type CurveName = "P-256" | "P-384";
type HashName = "SHA-256" | "SHA-384";

interface Curve {
  readonly name: CurveName;
  readonly size: number;
}

type Bytes = Uint8Array<ArrayBuffer>;

export interface Certificate {
  readonly der: Bytes;
  readonly tbs: Bytes;
  readonly spki: Bytes;
  readonly curve: Curve;
  readonly signatureHash: HashName;
  readonly signature: Bytes;
  readonly notBefore: number;
  readonly notAfter: number;
}

const curves: Readonly<Record<string, Curve>> = {
  "1.2.840.10045.3.1.7": { name: "P-256", size: 32 },
  "1.3.132.0.34": { name: "P-384", size: 48 },
};

const signatureHashes: Readonly<Record<string, HashName>> = {
  "1.2.840.10045.4.3.2": "SHA-256",
  "1.2.840.10045.4.3.3": "SHA-384",
};

const explicitVersionTag = 0xa0;

export function parseCertificate(der: Bytes): Certificate {
  const [tbsNode, algorithmNode, signatureNode] = childrenOf(der, readNode(der, 0));
  if (!tbsNode || !algorithmNode || !signatureNode) throw new SignedDataError("x509_structure");
  const fields = childrenOf(der, tbsNode);
  const offset = fields[0]?.tag === explicitVersionTag ? 1 : 0;
  const validity = fields[offset + 3];
  const spkiNode = fields[offset + 5];
  if (!validity || !spkiNode) throw new SignedDataError("x509_structure");
  const [notBefore, notAfter] = childrenOf(der, validity);
  const [keyAlgorithm] = childrenOf(der, spkiNode);
  const curveNode = keyAlgorithm ? childrenOf(der, keyAlgorithm)[1] : undefined;
  const curve = curveNode ? curves[objectIdentifierOf(der, curveNode)] : undefined;
  const algorithm = childrenOf(der, algorithmNode)[0];
  const signatureHash = algorithm ? signatureHashes[objectIdentifierOf(der, algorithm)] : undefined;
  if (!notBefore || !notAfter || !curve || !signatureHash) {
    throw new SignedDataError("x509_unsupported");
  }
  return {
    der,
    tbs: der.subarray(tbsNode.start, tbsNode.end),
    spki: der.subarray(spkiNode.start, spkiNode.end),
    curve,
    signatureHash,
    signature: der.subarray(signatureNode.contentStart + 1, signatureNode.end),
    notBefore: timeOf(der, notBefore),
    notAfter: timeOf(der, notAfter),
  };
}

export function hasExtension(certificate: Certificate, dottedIdentifier: string): boolean {
  return containsBytes(certificate.tbs, encodedObjectIdentifier(dottedIdentifier));
}

export function publicKeyOf(certificate: Certificate): Promise<CryptoKey> {
  return crypto.subtle.importKey(
    "spki",
    certificate.spki,
    { name: "ECDSA", namedCurve: certificate.curve.name },
    false,
    ["verify"],
  );
}

export async function isSignedBy(subject: Certificate, issuer: Certificate): Promise<boolean> {
  return crypto.subtle.verify(
    { name: "ECDSA", hash: subject.signatureHash },
    await publicKeyOf(issuer),
    rawSignatureOf(subject.signature, issuer.curve.size),
    subject.tbs,
  );
}

export function rawSignatureOf(signature: Bytes, size: number): Bytes {
  const [r, s] = childrenOf(signature, readNode(signature, 0));
  if (!r || !s) throw new SignedDataError("ecdsa_signature");
  const output = new Uint8Array(size * 2);
  [r, s].forEach((node, index) => {
    let integer = signature.subarray(node.contentStart, node.end);
    while (integer.length > size && integer[0] === 0) integer = integer.subarray(1);
    if (integer.length > size) throw new SignedDataError("ecdsa_signature");
    output.set(integer, index * size + (size - integer.length));
  });
  return output;
}
