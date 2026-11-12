import { describe, expect, it } from 'vitest';
import { readEdition } from './read-edition';
import { contentsFixture, sectionFixture } from '../testing/specification-fixtures';

const files = (...ids: readonly string[]) =>
  Object.fromEntries(ids.map((id) => [`sections/${id}.json`, sectionFixture(id)]));

describe('readEdition', () => {
  it('reads a consistent edition without problems', () => {
    const reading = readEdition(contentsFixture('a.one', 'a.two'), files('a.one', 'a.two'));
    expect(reading.problems).toEqual([]);
    expect([...reading.edition.sections.keys()]).toEqual(['a.one', 'a.two']);
    expect(reading.edition.contents[0]?.sections.map((entry) => entry.id)).toEqual(['a.one', 'a.two']);
  });

  it('rejects missing or empty contents', () => {
    expect(readEdition(undefined, {}).problems).toEqual([{ rule: 'SPEC-CONTENTS-EMPTY', path: 'toc.json' }]);
    expect(readEdition([], {}).problems.map((problem) => problem.rule)).toEqual(['SPEC-CONTENTS-EMPTY']);
  });

  it('reports listed sections without a file and files nobody lists', () => {
    const reading = readEdition(contentsFixture('a.one', 'a.two'), files('a.one', 'a.three'));
    expect(reading.problems).toEqual([
      { rule: 'SPEC-SECTION-MISSING', path: 'a.two' },
      { rule: 'SPEC-SECTION-UNLISTED', path: 'a.three' },
    ]);
  });

  it('reports malformed section files', () => {
    const reading = readEdition(contentsFixture('a.one'), {
      ...files('a.one'),
      'sections/broken.json': { id: 'broken' },
      'sections/null.json': null,
    });
    expect(reading.problems).toEqual([
      { rule: 'SPEC-SECTION-SHAPE', path: 'sections/broken.json' },
      { rule: 'SPEC-SECTION-SHAPE', path: 'sections/null.json' },
    ]);
  });

  it('reports ids that cannot become a web address', () => {
    const reading = readEdition(contentsFixture('sinpunto'), files('sinpunto'));
    expect(reading.problems).toEqual([{ rule: 'SPEC-SECTION-ID', path: 'sinpunto' }]);
  });

  it('reports links to sections outside the edition', () => {
    const linking = sectionFixture('a.one', [
      { type: 'paragraph', runs: [{ type: 'link', section: 'a.ghost', text: '9.9' }] },
    ]);
    const reading = readEdition(contentsFixture('a.one'), { 'sections/a.one.json': linking });
    expect(reading.problems).toEqual([{ rule: 'SPEC-LINK-BROKEN', path: 'a.one -> a.ghost' }]);
  });
});
