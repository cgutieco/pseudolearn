export interface DapScenario {
  entry: string;
  breakpoint: { path: string; line: number };
  input: string;
  expression: string;
  files: Record<string, string>;
}

export const scenario: DapScenario;
export function prepare(directory: string): Promise<void>;
export function exercise(client: unknown, directory: string): Promise<{ expression: string } & Record<string, unknown>>;
