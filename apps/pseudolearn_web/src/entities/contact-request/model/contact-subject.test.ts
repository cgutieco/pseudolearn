import { describe, expect, it } from 'vitest';
import { routeLessons } from '@entities/learning-route/model/route-contents';
import { APP_AREA_IDS, GENERAL_SUBJECT, isAppArea, isKnownSubject } from './contact-subject';

describe('isKnownSubject', () => {
  it('accepts a lesson of the route, a part of the specification and the general question', () => {
    expect(isKnownSubject(routeLessons('es')[0]?.id ?? '')).toBe(true);
    expect(isKnownSubject('spec:parte-1')).toBe(true);
    expect(isKnownSubject(GENERAL_SUBJECT)).toBe(true);
  });

  it('rejects the retired curriculum modules and empty values', () => {
    expect(isKnownSubject('CON-A1')).toBe(false);
    expect(isKnownSubject('spec-objects')).toBe(false);
    expect(isKnownSubject('')).toBe(false);
  });
});

describe('isAppArea', () => {
  it('knows the tasks view and Nodo', () => {
    expect(isAppArea('tasks')).toBe(true);
    expect(isAppArea('nodo')).toBe(true);
  });

  it('rejects the retired knowledge base area', () => {
    expect(isAppArea('knowledge')).toBe(false);
    expect(APP_AREA_IDS).not.toContain('class-diagram');
  });
});
