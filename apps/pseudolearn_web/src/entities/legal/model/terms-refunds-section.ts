import type { LegalSection } from './legal-document';

export const TERMS_REFUNDS_SECTION: LegalSection = {
  id: 'reembolsos',
  number: '09',
  titleKey: 'terms.section.refunds.title',
  leadKey: 'terms.section.refunds.lead',
  items: [
    'terms.section.refunds.itemPaddle',
    'terms.section.refunds.itemAppStore',
    'terms.section.refunds.itemCancel',
    'terms.section.refunds.itemConsumerLaw',
  ],
};
