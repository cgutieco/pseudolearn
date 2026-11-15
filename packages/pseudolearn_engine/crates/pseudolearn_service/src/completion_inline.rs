use crate::block_matching::{build_block_map, openers_before};
use crate::completion::{CompletionEntry, CompletionQuery};
use crate::cursor_context::CursorContext;
use crate::typing_lines::line_end;

pub fn mark_inline(
    entries: &mut Vec<CompletionEntry>,
    context: &CursorContext,
    query: &CompletionQuery<'_>,
) {
    if entries
        .iter()
        .any(|entry| entry.detail_key.as_deref() == Some("close_block"))
        && !missing_closer(query, context)
    {
        entries.retain(|entry| entry.detail_key.as_deref() != Some("close_block"));
    }
    let prefix = &context.prefix;
    if prefix.chars().count() < 2 {
        return;
    }
    let text = query.source.as_str();
    let cursor = context.prefix_start.saturating_add(prefix.len());
    if !text
        .get(cursor..line_end(text, cursor))
        .is_some_and(|tail| tail.trim().is_empty())
    {
        return;
    }
    if let [only] = entries.as_mut_slice()
        && query.profile.fold_word(&only.label) != query.profile.fold_word(prefix)
        && query
            .profile
            .fold_word(&only.label)
            .starts_with(&query.profile.fold_word(prefix))
        && only.bilingual_origin.is_none()
    {
        only.inline = true;
    }
}

fn missing_closer(query: &CompletionQuery<'_>, context: &CursorContext) -> bool {
    let map = build_block_map(query.tree, query.source.as_str());
    openers_before(query.tree, context.prefix_start)
        .last()
        .and_then(|token| map.opener_at(*token))
        .is_some_and(|opener| !opener.closed)
}
