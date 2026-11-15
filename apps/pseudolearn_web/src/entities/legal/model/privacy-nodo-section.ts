import type { LegalSection } from './legal-document';

export const PRIVACY_NODO_SECTION: LegalSection = {
  id: 'nodo',
  number: '04',
  titleKey: 'privacy.section.nodo.title',
  leadKey: 'privacy.section.nodo.lead',
  cards: [
    {
      titleKey: 'privacy.section.nodo.sentTitle',
      textKey: 'privacy.section.nodo.sentText',
    },
    {
      titleKey: 'privacy.section.nodo.providerTitle',
      textKey: 'privacy.section.nodo.providerText',
    },
    {
      titleKey: 'privacy.section.nodo.keptTitle',
      textKey: 'privacy.section.nodo.keptText',
    },
    {
      titleKey: 'privacy.section.nodo.paymentsTitle',
      textKey: 'privacy.section.nodo.paymentsText',
    },
  ],
  callout: {
    titleKey: 'privacy.section.nodo.calloutTitle',
    textKey: 'privacy.section.nodo.calloutText',
  },
};
