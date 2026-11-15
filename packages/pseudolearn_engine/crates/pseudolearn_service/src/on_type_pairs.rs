use crate::cursor_context::{CursorKind, analyze_cursor};
use crate::insertion::TextChange;
use crate::typing_plan::{Plan, TypingContext};
use pseudolearn_source::SourceText;
use pseudolearn_syntax::parse_source;

pub fn pair_plan(context: &TypingContext<'_>, typed: char) -> Plan {
    let text = context.text();
    let cursor = context.cursor;
    let untouched = Plan::untouched(cursor);
    let Some(before) = cursor.checked_sub(typed.len_utf8()) else {
        return untouched;
    };
    let next = text.get(cursor..).and_then(|tail| tail.chars().next());
    let inside = inside_literal_or_comment(context, before);
    if is_closer(typed) && next == Some(typed) && (typed_without_quote(typed) || inside) {
        return overtype(cursor, typed);
    }
    let closing = matching_closer(typed);
    match closing {
        Some(closer) if !inside && !next.is_some_and(is_identifier_glyph) => {
            insert_pair(cursor, closer)
        }
        _ => untouched,
    }
}

fn typed_without_quote(typed: char) -> bool {
    matches!(typed, ')' | ']')
}

fn is_closer(typed: char) -> bool {
    matches!(typed, ')' | ']' | '"' | '\'')
}

fn matching_closer(typed: char) -> Option<char> {
    match typed {
        '(' => Some(')'),
        '[' => Some(']'),
        '"' => Some('"'),
        '\'' => Some('\''),
        _ => None,
    }
}

fn is_identifier_glyph(glyph: char) -> bool {
    glyph.is_alphanumeric() || glyph == '_'
}

fn overtype(cursor: usize, typed: char) -> Plan {
    Plan {
        edits: vec![TextChange {
            start_utf8: cursor,
            end_utf8: cursor.saturating_add(typed.len_utf8()),
            text: String::new(),
        }],
        cursor,
    }
}

fn insert_pair(cursor: usize, closer: char) -> Plan {
    Plan {
        edits: vec![TextChange {
            start_utf8: cursor,
            end_utf8: cursor,
            text: closer.to_string(),
        }],
        cursor,
    }
}

fn inside_literal_or_comment(context: &TypingContext<'_>, before: usize) -> bool {
    let text = context.text();
    let (Some(head), Some(tail)) = (text.get(..before), text.get(context.cursor..)) else {
        return false;
    };
    let previous = SourceText::new(format!("{head}{tail}"));
    let (tree, _) = parse_source(&previous, context.document.profile);
    analyze_cursor(&tree, &previous, before).kind == CursorKind::Inert
}
