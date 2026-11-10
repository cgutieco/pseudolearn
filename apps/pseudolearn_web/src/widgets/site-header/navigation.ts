import { SITE } from '@shared/config/site';
import type { Locale } from '@shared/i18n/locales';
import type { TranslationKey } from '@shared/i18n/translator';
import { ROUTES, localizePath } from '@shared/i18n/routes';

export interface NavigationLink {
  readonly labelKey: TranslationKey;
  readonly href: string;
  readonly path: string;
}

const PRIMARY_PAGES: readonly { labelKey: TranslationKey; path: string }[] = [
  { labelKey: 'nav.language', path: ROUTES.language },
  { labelKey: 'nav.learn', path: ROUTES.learn },
  { labelKey: 'nav.nodo', path: ROUTES.nodo },
  { labelKey: 'nav.specification', path: ROUTES.specification },
];

export function buildNavigation(locale: Locale): readonly NavigationLink[] {
  return PRIMARY_PAGES.map(({ labelKey, path }) => ({ labelKey, path, href: localizePath(path, locale) }));
}

export function downloadLink(locale: Locale): NavigationLink {
  return { labelKey: 'nav.download', path: ROUTES.download, href: localizePath(ROUTES.download, locale) };
}

export function isCurrentSection(currentPath: string, linkPath: string): boolean {
  return currentPath === linkPath || currentPath.startsWith(`${linkPath}/`);
}

export interface FooterColumn {
  readonly titleKey: TranslationKey;
  readonly links: readonly { labelKey: TranslationKey; href: string }[];
}

export function buildFooterColumns(locale: Locale): readonly FooterColumn[] {
  const page = (path: string) => localizePath(path, locale);
  return [
    {
      titleKey: 'footer.columnProduct',
      links: [
        { labelKey: 'nav.language', href: page(ROUTES.language) },
        { labelKey: 'nav.learn', href: page(ROUTES.learn) },
        { labelKey: 'nav.nodo', href: page(ROUTES.nodo) },
        { labelKey: 'nav.download', href: page(ROUTES.download) },
      ],
    },
    {
      titleKey: 'footer.columnReference',
      links: [
        { labelKey: 'nav.specification', href: page(ROUTES.specification) },
        { labelKey: 'nav.versions', href: page(ROUTES.versions) },
        { labelKey: 'footer.linkAgents', href: SITE.agentSheetPath },
      ],
    },
    {
      titleKey: 'footer.columnSupport',
      links: [
        { labelKey: 'nav.contact', href: page(ROUTES.contact) },
        { labelKey: 'footer.linkPrivacy', href: page(ROUTES.privacy) },
        { labelKey: 'footer.linkTerms', href: page(ROUTES.terms) },
      ],
    },
  ];
}
