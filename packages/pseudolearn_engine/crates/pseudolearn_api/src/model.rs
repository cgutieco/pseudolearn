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
pub struct ApiToken {
    pub kind: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub keyword: Option<String>,
    pub span: ApiSpan,
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
    pub tokens: Vec<ApiToken>,
    pub schema: Vec<ApiUnit>,
}

impl AnalyzeResponse {
    pub fn new(tree: bool, diagnostics: Vec<ApiDiagnostic>, tokens: Vec<ApiToken>) -> Self {
        Self {
            kind: "analyze".to_owned(),
            tree,
            diagnostics,
            tokens,
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

#[derive(Clone, Debug, Deserialize, Eq, PartialEq, Serialize)]
pub struct IrRequest {
    #[serde(default)]
    pub program_ir: String,
    #[serde(default)]
    pub program: String,
    pub profile: String,
    pub strictness: String,
}

#[derive(Clone, Debug, Deserialize, Eq, PartialEq, Serialize)]
pub struct IrOutcome {
    pub accepted: bool,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub violated_rule: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub reprint: Option<String>,
}

#[derive(Clone, Debug, Deserialize, Eq, PartialEq, Serialize)]
pub struct IrResponse {
    pub kind: String,
    pub ir: IrOutcome,
}

impl IrResponse {
    pub fn accepted(reprint: String) -> Self {
        Self {
            kind: "ir".to_owned(),
            ir: IrOutcome {
                accepted: true,
                violated_rule: None,
                reprint: Some(reprint),
            },
        }
    }

    pub fn rejected(violated_rule: String) -> Self {
        Self {
            kind: "ir".to_owned(),
            ir: IrOutcome {
                accepted: false,
                violated_rule: Some(violated_rule),
                reprint: None,
            },
        }
    }
}
