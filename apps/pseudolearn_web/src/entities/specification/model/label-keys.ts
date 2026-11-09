import type { TranslationKey } from '@shared/i18n/translator';
import type { CalloutKind, ProgramTermination } from './specification';

export const CALLOUT_KEYS: Readonly<Record<CalloutKind, TranslationKey>> = {
  phrase: 'specification.callout.phrase',
  limit: 'specification.callout.limit',
  inside: 'specification.callout.inside',
  analogy: 'specification.callout.analogy',
  note: 'specification.callout.note',
  parts: 'specification.callout.parts',
  errors: 'specification.callout.errors',
};

export const TERMINATION_KEYS: Readonly<Record<ProgramTermination, TranslationKey>> = {
  completed: 'specification.termination.completed',
  failed: 'specification.termination.failed',
  awaiting_input: 'specification.termination.awaitingInput',
  '': 'specification.termination.notExecuted',
};
