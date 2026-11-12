import { existsSync, readFileSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { runWhenInvokedDirectly } from './lib/cli.mjs';

const WEB_MODEL = 'src/entities/nodo-plan/model/nodo-plans.ts';
const BACKEND_CREDITS = '../pseudolearn_backend/supabase/functions/agent-responses/domain/credits.ts';

const PAIRS = [
  { backend: 'trialDays', web: /trial:\s*\{\s*days:\s*(\d+)/, label: 'trial.days' },
  { backend: 'trialCredits', web: /trial:\s*\{[^}]*credits:\s*(\d+)/, label: 'trial.credits' },
  { backend: 'planCredits', web: /monthly:\s*\{\s*credits:\s*(\d+)/, label: 'monthly.credits' },
  { backend: 'topUpCredits', web: /topUp:\s*\{\s*credits:\s*(\d+)/, label: 'topUp.credits' },
];

export function collectPlanConstantViolations(rootDirectory, backendPath = BACKEND_CREDITS) {
  const backendFile = resolve(rootDirectory, backendPath);
  const webFile = join(rootDirectory, WEB_MODEL);
  if (!existsSync(backendFile) || !existsSync(webFile)) {
    return [
      violation(WEB_MODEL, 'No se encuentra el archivo del backend o el del modelo web que deben coincidir.'),
    ];
  }
  const backend = readFileSync(backendFile, 'utf8');
  const web = readFileSync(webFile, 'utf8');
  return PAIRS.flatMap((pair) => compare(pair, backend, web));
}

function compare(pair, backend, web) {
  const expected = new RegExp(`export const ${pair.backend}\\s*=\\s*(\\d[\\d_]*)`).exec(backend);
  const actual = pair.web.exec(web);
  if (expected === null || actual === null) {
    return [violation(WEB_MODEL, `No se puede leer ${pair.label} en uno de los dos lados.`)];
  }
  const backendValue = Number(expected[1].replaceAll('_', ''));
  if (backendValue === Number(actual[1])) return [];
  return [
    violation(
      WEB_MODEL,
      `${pair.label} vale ${actual[1]} en la web y ${backendValue} en el backend (${pair.backend}); la web publica lo que el backend cobra.`,
    ),
  ];
}

function violation(file, message) {
  return { file, rule: 'FE-PLAN-CONSTANTS', message };
}

runWhenInvokedDirectly('check:plan-constants', collectPlanConstantViolations, import.meta.url);
