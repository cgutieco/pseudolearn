use crate::block_matching::BlockMap;
use crate::insertion::TextChange;
use crate::typing_lines::{indent_of, indent_width, line_code_tokens, line_end};
use crate::typing_plan::{TypingContext, replacement};
use pseudolearn_syntax::TokenKind;

pub fn expected_indent(context: &TypingContext<'_>, line_start: usize) -> Option<String> {
    let first = first_token_of(context, line_start)?;
    realigned_indent(&context.blocks, context, first)
}

pub fn first_token_of(context: &TypingContext<'_>, line_start: usize) -> Option<usize> {
    let end = line_end(context.text(), line_start);
    line_code_tokens(&context.document.tree, line_start, end)
        .first()
        .filter(|token| matches!(token.kind, TokenKind::Keyword(_)))
        .map(|token| token.index)
}

fn realigned_indent(
    blocks: &BlockMap,
    context: &TypingContext<'_>,
    token: usize,
) -> Option<String> {
    let (fact, extra) = blocks.anchor_of(token)?;
    let base = indent_of(context.text(), fact.line_start);
    Some(format!("{base}{}", context.unit.repeat(extra)))
}

pub fn realign_change(context: &TypingContext<'_>, line_start: usize) -> Option<TextChange> {
    let wanted = expected_indent(context, line_start)?;
    let width = indent_width(context.text(), line_start);
    replacement(
        context.text(),
        line_start,
        line_start.saturating_add(width),
        &wanted,
    )
}
