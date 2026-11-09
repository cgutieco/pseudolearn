import {
  findSection,
  orderedSections,
  specificationEdition,
} from '@entities/specification/model/specification-catalog';
import { sectionAddress, sectionPath } from '@entities/specification/model/section-address';
import { markdownLabels } from '@entities/specification/model/markdown-labels';
import {
  contentsMarkdown,
  sectionMarkdown,
  type DocumentContext,
} from '@entities/specification/model/section-markdown';
import type {
  ContentsPart,
  ContentsSection,
  SpecificationSection,
} from '@entities/specification/model/specification';
import { SITE } from '@shared/config/site';
import { LOCALES, type Locale } from '@shared/i18n/locales';
import { ROUTES, localizePath } from '@shared/i18n/routes';
import { useTranslations } from '@shared/i18n/translator';

const MARKDOWN_EXTENSION = '.md';
const CONTENTS_MARKDOWN = '/index.md';
const MARKDOWN_HEADERS = { 'content-type': 'text/markdown; charset=utf-8' };

export interface SectionRouteProps {
  readonly sectionId: string;
}

export interface SectionContext {
  readonly section: SpecificationSection;
  readonly part: ContentsPart;
  readonly previous: ContentsSection | undefined;
  readonly next: ContentsSection | undefined;
}

export function sectionStaticPaths(locale: Locale) {
  return orderedSections(locale).flatMap((entry) => {
    const address = sectionAddress(entry.id);
    return address === null ? [] : [{ params: { ...address }, props: { sectionId: entry.id } }];
  });
}

export function sectionContext(locale: Locale, sectionId: string): SectionContext {
  const section = findSection(locale, sectionId);
  const part = specificationEdition(locale).contents.find((candidate) =>
    candidate.sections.some((entry) => entry.id === sectionId),
  );
  if (section === undefined || part === undefined)
    throw new Error(`Unknown specification section: ${sectionId}`);
  const ordered = orderedSections(locale);
  const position = ordered.findIndex((entry) => entry.id === sectionId);
  return { section, part, previous: ordered[position - 1], next: ordered[position + 1] };
}

export function sectionMarkdownPath(locale: Locale, sectionId: string): string {
  return `${localizePath(sectionPath(sectionId), locale)}${MARKDOWN_EXTENSION}`;
}

export function contentsMarkdownPath(locale: Locale): string {
  return `${localizePath(ROUTES.specification, locale)}${CONTENTS_MARKDOWN}`;
}

function absolute(path: string): string {
  return new URL(path, SITE.url).href;
}

function documentContext(locale: Locale, pagePath: string): DocumentContext {
  return {
    labels: markdownLabels(useTranslations(locale)),
    sectionHref: (id) => absolute(sectionMarkdownPath(locale, id)),
    pageUrl: absolute(pagePath),
  };
}

export function sectionMarkdownResponse(locale: Locale, sectionId: string): Response {
  const { section } = sectionContext(locale, sectionId);
  const context = documentContext(locale, localizePath(sectionPath(sectionId), locale));
  return new Response(sectionMarkdown(section, context), { headers: MARKDOWN_HEADERS });
}

export function contentsMarkdownResponse(locale: Locale): Response {
  const { t } = useTranslations(locale);
  const context = documentContext(locale, localizePath(ROUTES.specification, locale));
  const heading = { title: t('specification.seoTitle'), lead: t('specification.hero.lead') };
  return new Response(contentsMarkdown(specificationEdition(locale).contents, heading, context), {
    headers: MARKDOWN_HEADERS,
  });
}

export function specificationSitemapPaths(): readonly string[] {
  return orderedSections(LOCALES[0]).map((entry) => sectionPath(entry.id));
}

export function specificationAgentLinks(): readonly string[] {
  return LOCALES.map((locale) => {
    const { t } = useTranslations(locale);
    return `- [${t('specification.seoTitle')}](${contentsMarkdownPath(locale)}): ${t('specification.seoDescription')}`;
  });
}
