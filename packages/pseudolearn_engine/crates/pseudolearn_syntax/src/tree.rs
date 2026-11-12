use crate::tokens::Tokens;
use pseudolearn_source::Span;
use std::ops::Range;

include!(concat!(env!("OUT_DIR"), "/generated_syntax.rs"));

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct SyntaxNode {
    pub kind: NodeKind,
    pub first_token: u32,
    pub subtree_size: u32,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct SyntaxTree {
    pub nodes: Vec<SyntaxNode>,
    pub has_errors: bool,
    pub tokens: Tokens,
    pub ending_tokens: Vec<u32>,
    pub operator_tokens: Vec<Option<u32>>,
    pub child_ranges: Vec<Range<usize>>,
    pub children: Vec<usize>,
}

impl SyntaxTree {
    pub fn node_count(&self) -> usize {
        self.nodes.len()
    }

    pub fn node(&self, index: usize) -> Option<&SyntaxNode> {
        self.nodes.get(index)
    }

    pub fn span_for_node(&self, index: usize) -> Option<Span> {
        let node = self.nodes.get(index)?;
        let first = usize::try_from(node.first_token).ok()?;
        let ending = usize::try_from(*self.ending_tokens.get(index)?).ok()?;
        let first_span = self.tokens.span(first)?;
        let ending_span = self.tokens.span(ending)?;
        (first_span.source_id == ending_span.source_id).then_some(Span::in_source(
            first_span.source_id,
            first_span.start,
            ending_span.ending,
        ))
    }

    pub fn child_indices(&self, index: usize) -> &[usize] {
        self.child_ranges
            .get(index)
            .and_then(|range| self.children.get(range.clone()))
            .unwrap_or(&[])
    }
}
