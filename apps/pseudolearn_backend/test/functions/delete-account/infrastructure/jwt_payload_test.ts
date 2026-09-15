import { assertEquals } from "@std/assert";
import {
  decodeJwtPayload,
  isRecord,
} from "../../../../supabase/functions/delete-account/infrastructure/jwt_payload.ts";
import { unsignedJwt } from "../../../support/fake_fetcher.ts";

Deno.test("decodes the payload of a three segment token", () => {
  assertEquals(decodeJwtPayload(unsignedJwt({ sub: "s", aud: "a" })), { sub: "s", aud: "a" });
});

Deno.test("returns null for malformed tokens", () => {
  for (const token of ["", "a.b", "a.b.c.d", "a.!!!.c", `a.${btoa("[1]")}.c`, `a.${btoa("{")}.c`]) {
    assertEquals(decodeJwtPayload(token), null, token);
  }
});

Deno.test("isRecord accepts only plain objects", () => {
  assertEquals(isRecord({}), true);
  assertEquals(isRecord([]), false);
  assertEquals(isRecord(null), false);
  assertEquals(isRecord("x"), false);
});
