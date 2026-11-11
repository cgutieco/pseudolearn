import { describe, expect, it } from "vitest";
import { configurationDiffers } from "../../src/application/configuration_change";
import type { ResolvedExtensionConfiguration } from "../../src/contracts/extension_configuration";

const base: ResolvedExtensionConfiguration = { profile: "es", interfaceLanguage: "es", serverPath: "/bin/pseudo" };

describe("configurationDiffers", () => {
  it("detects a vocabulary profile change", () => {
    expect(configurationDiffers(base, { ...base, profile: "en" })).toBe(true);
  });

  it("detects an interface language change", () => {
    expect(configurationDiffers(base, { ...base, interfaceLanguage: "en" })).toBe(true);
  });

  it("detects a server path change", () => {
    expect(configurationDiffers(base, { ...base, serverPath: "/other/pseudo" })).toBe(true);
  });

  it("ignores an event that leaves every resolved value equal", () => {
    expect(configurationDiffers(base, { ...base })).toBe(false);
  });

  it("treats an empty server path as a distinct value", () => {
    expect(configurationDiffers(base, { ...base, serverPath: "" })).toBe(true);
  });
});
