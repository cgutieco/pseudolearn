import { describe, expect, it } from "vitest";
import { agentInstructionFiles, instructionsReport } from "../../src/application/agent_instructions";
import { mcpProviderId, mcpServerLaunch } from "../../src/application/mcp_server_definition";

describe("MCP server definition", () => {
  it("launches the bundled binary in mcp mode with the interface language", () => {
    expect(mcpServerLaunch("/opt/pseudo", "en")).toEqual({
      label: "PseudoLearn",
      command: "/opt/pseudo",
      args: ["mcp"],
      env: { PSEUDO_IDIOMA: "en" },
    });
    expect(mcpProviderId).toBe("pseudolearn.mcp");
  });

  it("keeps an empty server path instead of inventing one", () => {
    expect(mcpServerLaunch("", "es").command).toBe("");
  });
});

describe("Agent instruction templates", () => {
  it("writes AGENTS.md and the Copilot instructions with the same rules", () => {
    const files = agentInstructionFiles("es");
    expect(files.map((file) => file.path.join("/"))).toEqual(["AGENTS.md", ".github/copilot-instructions.md"]);
    expect(files[0]?.text).toBe(files[1]?.text);
    expect(files[0]?.text).toContain("empiezan en 0");
  });

  it("is available in English and reports what it created", () => {
    expect(agentInstructionFiles("en")[0]?.text).toContain("Arrays start at 0.");
    expect(instructionsReport(2, 0, "en")).toBe("PseudoLearn agent instructions: 2 created, 0 already present.");
    expect(instructionsReport(0, 2, "es")).toContain("2 ya existían");
  });
});
