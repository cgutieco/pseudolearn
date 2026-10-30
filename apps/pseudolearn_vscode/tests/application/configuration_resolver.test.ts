import { expect, it } from "vitest";
import { resolveConfiguration } from "../../src/application/configuration_resolver";
import type { ExtensionConfigurationPort } from "../../src/contracts/extension_configuration";

function configuration(): ExtensionConfigurationPort {
  return {
    profile: { globalValue: "es", workspaceValue: "en" },
    strictness: { globalValue: "strict", workspaceValue: "flexible" },
    interfaceLanguage: { globalValue: "en" },
    serverPath: {},
    workspaceTrusted: true,
    development: false,
    bundledServerPath: "/extension/bin/pseudo",
    isAbsolutePath: (path) => path.startsWith("/"),
  };
}

it("resolves workspace options and personal interface language", () => {
    const result = resolveConfiguration(configuration());
    expect(result).toEqual({
      ok: true,
      value: {
        profile: "en",
        strictness: "flexible",
        interfaceLanguage: "en",
        serverPath: "/extension/bin/pseudo",
      },
    });
});

it("rejects unsupported profile and strictness values", () => {
    const invalidProfile = configuration();
    invalidProfile.profile.workspaceValue = "fr";
    expect(resolveConfiguration(invalidProfile)).toMatchObject({
      ok: false,
      failure: "invalidProfile",
    });

    const invalidStrictness = configuration();
    invalidStrictness.strictness.workspaceValue = "loose";
    expect(resolveConfiguration(invalidStrictness)).toMatchObject({
      ok: false,
      failure: "invalidStrictness",
    });
});

it("rejects workspace executable selection", () => {
    const input = configuration();
    input.serverPath.workspaceValue = "/workspace/pseudo";
    expect(resolveConfiguration(input)).toMatchObject({
      ok: false,
      failure: "workspaceServerPath",
    });
});

it("rejects a relative user executable path", () => {
    const input = configuration();
    input.development = true;
    input.serverPath.globalValue = "./pseudo";
    expect(resolveConfiguration(input)).toMatchObject({
      ok: false,
      failure: "serverPathMustBeAbsolute",
    });
});

it("rejects user overrides in Restricted Mode", () => {
    const input = configuration();
    input.development = true;
    input.workspaceTrusted = false;
    input.serverPath.globalValue = "/development/pseudo";
    expect(resolveConfiguration(input)).toMatchObject({
      ok: false,
      failure: "serverPathRestrictedMode",
    });
});

it("rejects an executable override after workspace trust is revoked", () => {
    const input = configuration();
    input.development = true;
    input.serverPath.globalValue = "/development/pseudo";
    expect(resolveConfiguration(input)).toMatchObject({ ok: true });

    input.workspaceTrusted = false;
    expect(resolveConfiguration(input)).toMatchObject({
      ok: false,
      failure: "serverPathRestrictedMode",
    });
});

it("rejects user overrides outside development", () => {
    const input = configuration();
    input.serverPath.globalValue = "/development/pseudo";
    expect(resolveConfiguration(input)).toMatchObject({
      ok: false,
      failure: "serverPathDevelopmentOnly",
    });
});

it("rejects workspace interface language", () => {
    const input = configuration();
    input.interfaceLanguage.workspaceValue = "es";
    expect(resolveConfiguration(input)).toMatchObject({
      ok: false,
      failure: "workspaceInterfaceLanguage",
    });
});
