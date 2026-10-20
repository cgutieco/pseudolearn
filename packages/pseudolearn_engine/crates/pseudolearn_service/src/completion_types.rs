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

#[derive(Clone, Debug, Default, PartialEq, Eq, Serialize, Deserialize)]
pub enum CompletionAction {
    #[default]
    Plain,
    Template {
        construction: String,
    },
    Call {
        parameters: Vec<String>,
    },
}

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct CompletionEntry {
    pub label: String,
    pub kind: CompletionKind,
    pub detail: Option<String>,
    pub insert_text: Option<String>,
    pub bilingual_origin: Option<String>,
    #[serde(default)]
    pub detail_key: Option<String>,
    #[serde(default)]
    pub detail_arguments: Vec<String>,
    #[serde(default)]
    pub inline: bool,
    #[serde(default)]
    pub action: CompletionAction,
}

pub struct CompletionQuery<'query> {
    pub source: &'query SourceText,
    pub tree: &'query SyntaxTree,
    pub analysis: Option<&'query ServiceAnalysis>,
    pub position: Position,
    pub profile: Profile,
}
