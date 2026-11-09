import type { CodeToken, Runs } from './specification';

export function tokensText(tokens: readonly CodeToken[]): string {
  return tokens.map(([text]) => text).join('');
}

export function runsText(runs: Runs): string {
  return runs.map((run) => (run.type === 'code' ? tokensText(run.tokens) : run.text)).join('');
}
