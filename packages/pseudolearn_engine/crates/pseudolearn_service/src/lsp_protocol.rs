use serde::{Deserialize, Serialize};

#[derive(Clone, Copy, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct LspPosition {
    pub line: u32,
    pub character: u32,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct LspRange {
    pub start: LspPosition,
    pub end: LspPosition,
}

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct LspLocation {
    pub uri: String,
    pub range: LspRange,
}

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct LspDiagnostic {
    pub range: LspRange,
    pub severity: Option<u32>,
    pub message: String,
    pub source: Option<String>,
}

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct TextDocumentIdentifier {
    pub uri: String,
}

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct VersionedTextDocumentIdentifier {
    pub uri: String,
    pub version: i32,
}

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct TextDocumentEntry {
    pub uri: String,
    #[serde(rename = "languageId")]
    pub language_id: String,
    pub version: i32,
    pub text: String,
}

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct TextDocumentContentChangeEvent {
    pub range: Option<LspRange>,
    pub text: String,
}

pub fn parse_lsp_position(message: &serde_json::Value) -> crate::navigation::Position {
    let line = message
        .pointer("/params/position/line")
        .and_then(serde_json::Value::as_u64)
        .unwrap_or(0);
    let character = message
        .pointer("/params/position/character")
        .and_then(serde_json::Value::as_u64)
        .unwrap_or(0);
    crate::navigation::Position {
        line: u32::try_from(line.saturating_add(1)).unwrap_or(1),
        column: u32::try_from(character.saturating_add(1)).unwrap_or(1),
    }
}

pub fn map_completion_kind_code(kind: crate::completion::CompletionKind) -> u64 {
    match kind {
        crate::completion::CompletionKind::Keyword => 14,
        crate::completion::CompletionKind::Type => 7,
        crate::completion::CompletionKind::Variable => 6,
        crate::completion::CompletionKind::Function => 3,
        crate::completion::CompletionKind::Method => 2,
        crate::completion::CompletionKind::Field => 5,
        crate::completion::CompletionKind::Class => 7,
        crate::completion::CompletionKind::Snippet => 15,
    }
}
