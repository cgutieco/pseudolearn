use crate::block_matching::BlockMap;
use crate::document_session::DocumentSession;
use crate::insertion::TextChange;

pub struct TypingContext<'doc> {
    pub document: &'doc DocumentSession,
    pub cursor: usize,
    pub unit: &'doc str,
    pub blocks: BlockMap,
}

impl TypingContext<'_> {
    pub fn text(&self) -> &str {
        self.document.text()
    }
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Plan {
    pub edits: Vec<TextChange>,
    pub cursor: usize,
}

impl Plan {
    pub fn untouched(cursor: usize) -> Plan {
        Plan {
            edits: Vec::new(),
            cursor,
        }
    }
}

pub fn replacement(text: &str, start: usize, end: usize, value: &str) -> Option<TextChange> {
    let current = text.get(start..end)?;
    (current != value).then(|| TextChange {
        start_utf8: start,
        end_utf8: end,
        text: value.to_owned(),
    })
}

pub fn shift_of(change: &TextChange) -> isize {
    let added = isize::try_from(change.text.len()).unwrap_or(0);
    let removed = isize::try_from(change.end_utf8.saturating_sub(change.start_utf8)).unwrap_or(0);
    added.saturating_sub(removed)
}

pub fn shifted(offset: usize, shift: isize) -> usize {
    offset.saturating_add_signed(shift)
}
