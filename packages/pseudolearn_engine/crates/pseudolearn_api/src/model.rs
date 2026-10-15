use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;

#[derive(Clone, Debug, Deserialize, Eq, PartialEq, Serialize)]
pub struct AnalyzeRequest {
    pub program: String,
    pub profile: String,
    pub strictness: String,
}

#[derive(Clone, Debug, Deserialize, Eq, PartialEq, Serialize)]
pub struct ApiPosition {
    pub line: u32,
    pub column: u32,
}

#[derive(Clone, Debug, Deserialize, Eq, PartialEq, Serialize)]
pub struct ApiSpan {
    pub start: ApiPosition,
    pub end: ApiPosition,
}

#[derive(Clone, Debug, Deserialize, Eq, PartialEq, Serialize)]
pub struct ApiDiagnostic {
    pub code: String,
    pub class: String,
    pub severity: String,
    pub message: String,
    pub span: ApiSpan,
    pub arguments: BTreeMap<String, serde_json::Value>,
    pub related: Vec<ApiSpan>,
}

#[derive(Clone, Debug, Deserialize, Eq, PartialEq, Serialize)]
pub struct AnalyzeResponse {
    pub kind: String,
    pub tree: bool,
    pub diagnostics: Vec<ApiDiagnostic>,
    pub schema: Vec<ApiUnit>,
}

impl AnalyzeResponse {
    pub fn new(tree: bool, diagnostics: Vec<ApiDiagnostic>) -> Self {
        Self {
            kind: "analyze".to_owned(),
            tree,
            diagnostics,
            schema: Vec::new(),
        }
    }
}

#[derive(Clone, Debug, Deserialize, Eq, PartialEq, Serialize)]
pub struct ApiUnit {
    pub kind: String,
    pub name: String,
    pub span: ApiSpan,
}
