import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { request } from "node:https";
import { startHttpFixture } from "./http-fixture.mjs";

let fixture;

beforeAll(async () => { fixture = await startHttpFixture(); });
afterAll(() => fixture.close());

function secureStatus(path) {
  return new Promise((resolve, reject) => {
    request(`${fixture.https}${path}`, { rejectUnauthorized: false }, (response) => {
      response.resume();
      response.on("end", () => resolve(response.statusCode));
    }).on("error", reject).end();
  });
}

describe("HTTP and TLS fixture", () => {
  it("serves the body with CORS and counts each hit", async () => {
    const response = await fetch(`${fixture.http}/ok`);
    expect(await response.text()).toBe("ok");
    expect(response.headers.get("access-control-allow-origin")).toBe("*");
    expect(fixture.hits["/ok"]).toBe(1);
  });

  it("omits CORS permission, redirects and drops connections on demand", async () => {
    expect((await fetch(`${fixture.http}/nocors`)).headers.get("access-control-allow-origin")).toBeNull();
    expect((await fetch(`${fixture.http}/redirect`, { redirect: "manual" })).status).toBe(302);
    await expect(fetch(`${fixture.http}/drop`)).rejects.toThrow();
  });

  it("answers over TLS with a self-signed certificate and rejects unknown paths", async () => {
    expect(await secureStatus("/ok")).toBe(200);
    expect(await secureStatus("/missing")).toBe(404);
  });
});
