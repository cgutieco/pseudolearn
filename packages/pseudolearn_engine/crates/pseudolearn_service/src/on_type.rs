use crate::block_matching::build_block_map;
use crate::document_session::DocumentSession;
use crate::insertion::TextChange;
use crate::on_type_enter::enter_plan;
use crate::on_type_pairs::pair_plan;
use crate::on_type_realign::realign_change;
use crate::template_render::DEFAULT_INDENT_UNIT;
use crate::typing_lines::{line_start, token_end};
use crate::typing_plan::{Plan, TypingContext, shift_of, shifted};
use pseudolearn_source::SourceText;
use pseudolearn_syntax::parse_source;

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct OnTypeOutcome {
    pub edits: Vec<TextChange>,
    pub cursor: usize,
}

pub fn on_type(document: &DocumentSession, cursor: usize, typed: char) -> OnTypeOutcome {
    let context = TypingContext {
        document,
        cursor,
        unit: DEFAULT_INDENT_UNIT,
        blocks: build_block_map(&document.tree, document.text()),
    };
    let candidates = plans_for(&context, typed);
    for plan in candidates {
        if !plan.edits.is_empty() && keeps_syntax(document, &plan) {
            return OnTypeOutcome {
                edits: plan.edits,
                cursor: plan.cursor,
            };
        }
    }
    OnTypeOutcome {
        edits: Vec::new(),
        cursor,
    }
}

fn plans_for(context: &TypingContext<'_>, typed: char) -> Vec<Plan> {
    match typed {
        '\n' => vec![enter_plan(context, true), enter_plan(context, false)],
        ' ' | ';' => vec![boundary_plan(context)],
        '(' | '[' | ')' | ']' | '"' | '\'' => vec![pair_plan(context, typed)],
        _ => Vec::new(),
    }
}

fn boundary_plan(context: &TypingContext<'_>) -> Plan {
    let cursor = context.cursor;
    let text = context.text();
    let start = line_start(text, cursor.saturating_sub(1));
    let Some(change) = realign_change(context, start) else {
        return Plan::untouched(cursor);
    };
    let first = crate::on_type_realign::first_token_of(context, start);
    let word_end = first.map(|token| token_end(&context.document.tree, token));
    let typed_right_after_word = word_end.is_some_and(|ending| {
        matches!(
            text.get(ending..cursor.saturating_sub(1)),
            Some("") | Some(":")
        )
    });
    if !typed_right_after_word {
        return Plan::untouched(cursor);
    }
    let moved = shifted(cursor, shift_of(&change));
    Plan {
        edits: vec![change],
        cursor: moved,
    }
}

pub fn apply_changes(text: &str, edits: &[TextChange]) -> String {
    let mut ordered: Vec<&TextChange> = edits.iter().collect();
    ordered.sort_by_key(|change| std::cmp::Reverse(change.start_utf8));
    let mut result = text.to_owned();
    for change in ordered {
        let head = result.get(..change.start_utf8).unwrap_or("").to_owned();
        let tail = result.get(change.end_utf8..).unwrap_or("").to_owned();
        result = format!("{head}{}{tail}", change.text);
    }
    result
}

fn keeps_syntax(document: &DocumentSession, plan: &Plan) -> bool {
    let after = SourceText::new(apply_changes(document.text(), &plan.edits));
    let (_, diagnostics) = parse_source(&after, document.profile);
    diagnostics.len() <= document.syntax_diagnostics.len()
}
