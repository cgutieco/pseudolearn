use crate::completion_types::CompletionEntry;
use crate::cursor_context::CursorContext;

pub fn mark_inline(entries: &mut [CompletionEntry], context: &CursorContext) {
    if context.prefix.is_empty() {
        mark_closer(entries);
    } else {
        mark_sole_match(entries, &context.prefix);
    }
}

fn mark_closer(entries: &mut [CompletionEntry]) {
    if let Some(first) = entries.first_mut()
        && first.detail_key.as_deref() == Some("close_block")
    {
        first.inline = true;
    }
}

fn mark_sole_match(entries: &mut [CompletionEntry], prefix: &str) {
    if let [only] = entries
        && only.label != prefix
        && only.bilingual_origin.is_none()
    {
        only.inline = true;
    }
}
