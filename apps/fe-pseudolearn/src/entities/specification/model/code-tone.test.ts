import { describe, expect, it } from 'vitest';
import { codeTone } from './code-tone';

describe('codeTone', () => {
  it('colours types like structured keywords and booleans like numbers', () => {
    expect(codeTone('type')).toBe('structured');
    expect(codeTone('literalBoolean')).toBe('number');
    expect(codeTone('comment')).toBe('muted');
  });

  it('treats a token without category as plain text', () => {
    expect(codeTone(undefined)).toBe('plain');
  });
});
