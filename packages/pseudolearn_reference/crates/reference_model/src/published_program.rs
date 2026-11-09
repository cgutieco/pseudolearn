use crate::{Run, Token};
use serde::Serialize;

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
#[serde(tag = "type", rename_all = "snake_case")]
pub enum FormSegment {
    Token { token: Token },
    Slot { text: String },
    Optional { text: String },
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
pub struct AnatomyPart {
    pub tokens: Vec<Token>,
    pub label: Vec<Run>,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
pub struct PublishedDiagnostic {
    pub code: String,
    pub severity: String,
    pub line: u64,
    pub column: u64,
    pub message: String,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
pub struct ProgramBlock {
    pub id: String,
    pub title: String,
    pub source: String,
    pub lines: Vec<Vec<Token>>,
    pub executed: bool,
    #[serde(skip_serializing_if = "Vec::is_empty")]
    pub inputs: Vec<String>,
    pub output: String,
    pub termination: String,
    pub diagnostics: Vec<PublishedDiagnostic>,
}
