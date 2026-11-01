export type Step = { scenario: string; step: string };

export class Recorder {
  readonly steps: Step[] = [];
  constructor(private scenario = "") {}

  within(scenario: string): this {
    this.scenario = scenario;
    return this;
  }

  check(condition: unknown, step: string): void {
    if (!condition) throw new Error(`${this.scenario}: step failed: ${step}`);
    this.steps.push({ scenario: this.scenario, step });
    console.log(`STEP ${this.scenario}: ${step}`);
  }

  equal(actual: unknown, expected: unknown, step: string): void {
    this.check(JSON.stringify(actual) === JSON.stringify(expected), `${step} (expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)})`);
  }
}
