use crate::lsp_protocol::lsp_range_from_offsets_with_index;
use pseudolearn_source::LineIndex;
use serde_json::Value;
use std::collections::BTreeMap;

#[derive(Default)]
pub(crate) struct LineIndexCache {
    by_source: BTreeMap<u32, LineIndex>,
}

impl LineIndexCache {
    pub(crate) fn range(&mut self, source_id: u32, text: &str, span: (usize, usize)) -> Value {
        let index = self
            .by_source
            .entry(source_id)
            .or_insert_with(|| LineIndex::build(text));
        lsp_range_from_offsets_with_index(text, span.0, span.1, index)
    }
}
