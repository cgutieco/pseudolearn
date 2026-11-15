import { ROUTES } from '@shared/i18n/routes';

const SECTION_ID = /^([a-z0-9-]+)\.([a-z0-9-]+)$/;

export interface SectionAddress {
  readonly area: string;
  readonly topic: string;
}

export function sectionAddress(id: string): SectionAddress | null {
  const match = SECTION_ID.exec(id);
  if (match === null) return null;
  const [, area = '', topic = ''] = match;
  return { area, topic };
}

export function sectionIdOf(address: SectionAddress): string {
  return `${address.area}.${address.topic}`;
}

export function sectionSlug(id: string): string {
  const address = sectionAddress(id);
  return address === null ? id : `${address.area}/${address.topic}`;
}

export function sectionPath(id: string): string {
  return `${ROUTES.specification}/${sectionSlug(id)}`;
}
