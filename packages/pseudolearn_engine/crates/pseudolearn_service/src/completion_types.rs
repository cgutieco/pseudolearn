use crate::navigation::Position;
use pseudolearn_lexicon::Profile;
use pseudolearn_semantic::ServiceAnalysis;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::SyntaxTree;
use serde::{Deserialize, Serialize};

#[derive(Clone, Copy, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub enum CompletionKind {
    Keyword,
    Type,
    Variable,
    Function,
    Method,
    Field,
    Class,
    Snippet,
}

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct CompletionEntry {
    pub label: String,
    pub kind: CompletionKind,
    pub detail: Option<String>,
    pub insert_text: Option<String>,
    pub bilingual_origin: Option<String>,
}

pub struct CompletionQuery<'query> {
    pub source: &'query SourceText,
    pub tree: &'query SyntaxTree,
    pub analysis: Option<&'query ServiceAnalysis>,
    pub position: Position,
    pub profile: Profile,
}
