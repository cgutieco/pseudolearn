import { isRouteLesson } from '@entities/learning-route/model/route-contents';
import { isSpecificationSubject } from '@entities/specification/model/specification-parts';

export const GENERAL_SUBJECT = 'general-question';

export const APP_AREA_IDS = [
  'editor',
  'diagrams',
  'tasks',
  'trace-table',
  'equivalent-code',
  'route',
  'progress',
  'nodo',
  'specification',
  'library',
  'settings',
  'general',
] as const;

export function isKnownSubject(candidate: string): boolean {
  return candidate === GENERAL_SUBJECT || isRouteLesson(candidate) || isSpecificationSubject(candidate);
}

export function isAppArea(candidate: string): boolean {
  return (APP_AREA_IDS as readonly string[]).includes(candidate);
}
