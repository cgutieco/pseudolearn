use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;

#[derive(Clone, Debug, Deserialize, Eq, PartialEq, Serialize)]
pub struct AnalyzeRequest {
    pub program: String,
    pub profile: String,
    pub strictness: String,
}

#[derive(Clone, Debug, Deserialize, Eq, PartialEq, Serialize)]
pub struct ApiSpan {
    pub start: u32,
    pub ending: u32,
}

#[derive(Clone, Debug, Deserialize, Eq, PartialEq, Serialize)]
pub struct ApiDiagnostic {
    pub code: String,
    pub class: String,
    pub severity: String,
    pub message: String,
    pub span: ApiSpan,
    pub arguments: BTreeMap<String, String>,
    pub related: Vec<ApiSpan>,
}

#[derive(Clone, Debug, Deserialize, Eq, PartialEq, Serialize)]
pub struct AnalyzeResponse {
    pub kind: String,
    pub tree: bool,
    pub diagnostics: Vec<ApiDiagnostic>,
}

impl AnalyzeResponse {
    pub fn new(tree: bool, diagnostics: Vec<ApiDiagnostic>) -> Self {
        Self {
            kind: "analyze".to_owned(),
            tree,
            diagnostics,
        }
    }
}
