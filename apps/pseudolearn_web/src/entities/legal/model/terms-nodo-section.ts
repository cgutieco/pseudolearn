import type { LegalSection } from './legal-document';

export const TERMS_NODO_SECTION: LegalSection = {
  id: 'nodo',
  number: '08',
  titleKey: 'terms.section.nodo.title',
  leadKey: 'terms.section.nodo.lead',
  items: [
    'terms.section.nodo.itemOptional',
    'terms.section.nodo.itemCredits',
    'terms.section.nodo.itemRenewal',
    'terms.section.nodo.itemCancel',
    'terms.section.nodo.itemAccuracy',
    'terms.section.nodo.itemAge',
  ],
};
