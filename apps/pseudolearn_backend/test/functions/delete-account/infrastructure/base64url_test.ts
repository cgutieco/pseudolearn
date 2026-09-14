import { assertEquals } from "@std/assert";
import {
  decodeBase64UrlText,
  encodeBase64Url,
  encodeBase64UrlText,
} from "../../../../supabase/functions/delete-account/infrastructure/base64url.ts";

Deno.test("round trips text through URL-safe base64 without padding", () => {
  for (const text of ["", "a", "ab", "abc", "ñandú?>>", '{"sub":"x"}']) {
    const encoded = encodeBase64UrlText(text);
    assertEquals(/[+/=]/.test(encoded), false);
    assertEquals(decodeBase64UrlText(encoded), text);
  }
});

Deno.test("encodes bytes that need URL-safe substitutions", () => {
  assertEquals(encodeBase64Url(new Uint8Array([251, 255])), "-_8");
});

Deno.test("returns null for invalid base64 or invalid UTF-8", () => {
  assertEquals(decodeBase64UrlText("@@@"), null);
  assertEquals(decodeBase64UrlText(encodeBase64Url(new Uint8Array([0xff, 0xfe]))), null);
});
