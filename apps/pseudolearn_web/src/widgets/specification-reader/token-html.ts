import { codeTone } from '@entities/specification/model/code-tone';
import type { CodeToken, FormPiece } from '@entities/specification/model/specification';

const HTML_ESCAPES: Readonly<Record<string, string>> = {
  '&': '&amp;',
  '<': '&lt;',
  '>': '&gt;',
  '"': '&quot;',
  "'": '&#39;',
};

export function escapeHtml(text: string): string {
  return text.replace(/[&<>"']/g, (character) => HTML_ESCAPES[character] ?? character);
}

function span(className: string, text: string): string {
  return `<span class="${className}">${escapeHtml(text)}</span>`;
}

export function tokensHtml(tokens: readonly CodeToken[]): string {
  return tokens
    .map(([text, category]) => span(`code__token code__token--${codeTone(category)}`, text))
    .join('');
}

function pieceHtml(piece: FormPiece): string {
  if (piece.type === 'token') return tokensHtml([piece.token]);
  if (piece.type === 'slot') return span('code__slot', `«${piece.text}»`);
  return span('code__optional', piece.text);
}

export function formLineHtml(pieces: readonly FormPiece[]): string {
  return pieces.map(pieceHtml).join('');
}

export function codeLinesHtml(lines: readonly string[]): string {
  return lines.map((line) => `<span class="code__line">${line}</span>`).join('\n');
}
