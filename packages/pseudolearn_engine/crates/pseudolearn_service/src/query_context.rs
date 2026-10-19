use crate::symbol_index::SymbolIndex;
use pseudolearn_lexicon::Profile;
use pseudolearn_semantic::ServiceAnalysis;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::{SyntaxTree, TokenKind};

pub struct QueryContext<'query> {
    pub tree: &'query SyntaxTree,
    pub source: &'query SourceText,
    pub analysis: &'query ServiceAnalysis,
    pub index: &'query SymbolIndex,
    pub profile: Profile,
}

impl QueryContext<'_> {
    pub fn token_at(&self, offset: usize) -> Option<usize> {
        let mut fallback = None;
        for slot in 0..self.tree.tokens.token_count() {
            let (Some(kind), Some(span)) =
                (self.tree.tokens.kind(slot), self.tree.tokens.span(slot))
            else {
                continue;
            };
            if kind.is_trivia() || kind == TokenKind::EndOfFile {
                continue;
            }
            let start = usize::try_from(span.start).unwrap_or(usize::MAX);
            let ending = usize::try_from(span.ending).unwrap_or(usize::MAX);
            if start <= offset && offset < ending {
                return Some(slot);
            }
            if ending == offset {
                fallback = Some(slot);
            }
        }
        fallback
    }

    pub fn token_text(&self, slot: usize) -> &str {
        self.tree
            .tokens
            .text(self.source.as_str(), slot)
            .unwrap_or("")
    }
}
