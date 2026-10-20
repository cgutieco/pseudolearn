use crate::block_layout::is_opener;
use crate::completion_keywords::closing_keyword;
use crate::insertion::TextChange;
use crate::on_type_realign::{expected_indent, realign_change};
use crate::spelling::keyword_spelling;
use crate::typing_lines::{
    indent_of, indent_width, is_blank, line_code_tokens, line_end, line_start, previous_line_start,
};
use crate::typing_plan::{Plan, TypingContext, replacement, shift_of, shifted};
use pseudolearn_lexicon::KeywordKind;
use pseudolearn_syntax::TokenKind;

pub fn enter_plan(context: &TypingContext<'_>, terminate: bool) -> Plan {
    let text = context.text();
    let cursor = context.cursor;
    if cursor == 0 || text.as_bytes().get(cursor.saturating_sub(1)) != Some(&b'\n') {
        return Plan::untouched(cursor);
    }
    let current = line_start(text, cursor);
    let Some(previous) = previous_line_start(text, current) else {
        return Plan::untouched(cursor);
    };
    let mut edits: Vec<TextChange> = Vec::new();
    edits.extend(realign_change(context, previous));
    if terminate {
        edits.extend(terminator_change(context, previous));
    }
    let shift: isize = edits.iter().map(shift_of).sum();
    let indent = next_indent(context, previous);
    finish_line(context, (current, shift), &indent, edits)
}

fn next_indent(context: &TypingContext<'_>, previous: usize) -> String {
    let text = context.text();
    if is_blank(text, previous) {
        return indent_of(text, previous).to_owned();
    }
    let base =
        expected_indent(context, previous).unwrap_or_else(|| indent_of(text, previous).to_owned());
    format!("{base}{}", extra_indent(context, previous))
}

fn extra_indent(context: &TypingContext<'_>, previous: usize) -> String {
    let end = line_end(context.text(), previous);
    let tokens = line_code_tokens(&context.document.tree, previous, end);
    let opens = match tokens.first().map(|token| token.kind) {
        Some(TokenKind::Keyword(kind)) => is_opener(kind) || kind == KeywordKind::ElseKeyword,
        _ => false,
    };
    let labelled = tokens.last().map(|token| token.kind) == Some(TokenKind::Colon);
    if opens || labelled {
        context.unit.to_owned()
    } else {
        String::new()
    }
}

fn finish_line(
    context: &TypingContext<'_>,
    current: (usize, isize),
    indent: &str,
    mut edits: Vec<TextChange>,
) -> Plan {
    let text = context.text();
    let (start, shift) = current;
    let end = line_end(text, start);
    let width = indent_width(text, start);
    let tail_blank = text
        .get(start.saturating_add(width)..end)
        .is_some_and(|tail| tail.trim().is_empty());
    let cursor = shifted(start, shift).saturating_add(indent.len());
    match closer_for(context, start, tail_blank) {
        Some(closer) => {
            let value = format!("{indent}\n{closer}");
            edits.extend(replacement(text, start, end, &value));
        }
        None => edits.extend(replacement(
            text,
            start,
            start.saturating_add(width),
            indent,
        )),
    }
    Plan { edits, cursor }
}

fn closer_for(context: &TypingContext<'_>, current: usize, tail_blank: bool) -> Option<String> {
    let text = context.text();
    let previous = previous_line_start(text, current)?;
    let end = line_end(text, previous);
    let first = line_code_tokens(&context.document.tree, previous, end)
        .into_iter()
        .next()?;
    let fact = context.blocks.opener_at(first.index)?;
    if fact.closed || !tail_blank || fact.kind == KeywordKind::Repeat {
        return None;
    }
    let word = keyword_spelling(closing_keyword(fact.kind), context.document.profile);
    Some(format!("{}{word}", indent_of(text, fact.line_start)))
}

fn terminator_change(context: &TypingContext<'_>, previous: usize) -> Option<TextChange> {
    if !context.document.strict {
        return None;
    }
    let end = line_end(context.text(), previous);
    let tokens = line_code_tokens(&context.document.tree, previous, end);
    let (first, last) = (tokens.first()?, tokens.last()?);
    if !is_statement_lead(first.kind) || is_unfinished(last.kind) {
        return None;
    }
    let after = crate::typing_lines::token_end(&context.document.tree, last.index);
    Some(TextChange {
        start_utf8: after,
        end_utf8: after,
        text: ";".to_owned(),
    })
}

fn is_statement_lead(kind: TokenKind) -> bool {
    matches!(
        kind,
        TokenKind::Identifier
            | TokenKind::Keyword(
                KeywordKind::Write
                    | KeywordKind::Read
                    | KeywordKind::Declare
                    | KeywordKind::Dimension
                    | KeywordKind::ReturnKeyword
                    | KeywordKind::ThisObject
            )
    )
}

fn is_unfinished(kind: TokenKind) -> bool {
    matches!(
        kind,
        TokenKind::Semicolon
            | TokenKind::Colon
            | TokenKind::Plus
            | TokenKind::Minus
            | TokenKind::Star
            | TokenKind::Slash
            | TokenKind::Power
            | TokenKind::Modulo
            | TokenKind::IntegerDivision
            | TokenKind::Equal
            | TokenKind::NotEqual
            | TokenKind::Less
            | TokenKind::LessEqual
            | TokenKind::Greater
            | TokenKind::GreaterEqual
            | TokenKind::LogicalAnd
            | TokenKind::LogicalOr
            | TokenKind::LogicalNot
            | TokenKind::Assignment
            | TokenKind::LeftParenthesis
            | TokenKind::LeftBracket
            | TokenKind::Comma
            | TokenKind::Dot
            | TokenKind::Keyword(
                KeywordKind::And | KeywordKind::Or | KeywordKind::Not | KeywordKind::Modulo
            )
    )
}
