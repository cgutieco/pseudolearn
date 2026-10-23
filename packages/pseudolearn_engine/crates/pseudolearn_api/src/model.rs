use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;

#[derive(Clone, Debug, Deserialize, Eq, PartialEq, Serialize)]
pub struct AnalyzeRequest {
    pub program: String,
    pub profile: String,
    pub strictness: String,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub source: Option<ApiSourceIdentity>,
}

#[derive(Clone, Copy, Debug, Deserialize, Eq, PartialEq, Serialize)]
pub struct ApiSourceIdentity {
    #[serde(with = "decimal_u64")]
    pub project_id: u64,
    #[serde(with = "decimal_u64")]
    pub revision_id: u64,
    pub source_id: u32,
}

impl ApiSourceIdentity {
    pub fn is_valid(self) -> bool {
        self.project_id != 0 && self.revision_id != 0 && self.source_id != 0
    }
}

mod decimal_u64 {
    use serde::{Deserialize, Deserializer, Serializer};

    pub fn serialize<SerializerType>(
        value: &u64,
        serializer: SerializerType,
    ) -> Result<SerializerType::Ok, SerializerType::Error>
    where
        SerializerType: Serializer,
    {
        serializer.serialize_str(&value.to_string())
    }

    pub fn deserialize<'deserialize, DeserializerType>(
        deserializer: DeserializerType,
    ) -> Result<u64, DeserializerType::Error>
    where
        DeserializerType: Deserializer<'deserialize>,
    {
        let text = String::deserialize(deserializer)?;
        let value = text.parse::<u64>().map_err(serde::de::Error::custom)?;
        if value.to_string() != text {
            return Err(serde::de::Error::custom("non-canonical unsigned integer"));
        }
        Ok(value)
    }
}

#[derive(Clone, Debug, Deserialize, Eq, PartialEq, Serialize)]
pub struct ApiPosition {
    pub line: u32,
    pub column: u32,
}

#[derive(Clone, Copy, Debug, Deserialize, Eq, PartialEq, Serialize)]
#[serde(rename_all = "snake_case")]
pub enum ApiHelpCoordinateUnit {
    UnicodeScalar,
    Utf16,
}

#[derive(Clone, Copy, Debug, Deserialize, Eq, PartialEq, Serialize)]
#[serde(rename_all = "snake_case")]
pub enum ApiHelpDetail {
    Summary,
    Full,
}

#[derive(Clone, Debug, Deserialize, Eq, PartialEq, Serialize)]
pub struct ApiHelpQueryPosition {
    pub line: u32,
    pub column: u32,
    pub unit: ApiHelpCoordinateUnit,
}

#[derive(Clone, Debug, Deserialize, Eq, PartialEq, Serialize)]
pub struct ApiHelpQueryRequest {
    pub resource: u64,
    pub revision: String,
    pub position: ApiHelpQueryPosition,
    pub language: String,
    pub detail: ApiHelpDetail,
}

#[derive(Clone, Debug, Deserialize, Eq, PartialEq, Serialize)]
pub struct ApiHelpQueryResponse {
    pub revision: String,
    pub language: String,
    pub detail: ApiHelpDetail,
    pub position: ApiHelpQueryPosition,
    pub resolution: Option<ApiHelpResolution>,
    pub help: Option<ApiHelpEntry>,
    pub card: Option<ApiHelpCard>,
}

#[derive(Clone, Debug, Deserialize, Eq, PartialEq, Serialize)]
pub struct ApiHelpPart {
    pub identity: String,
    pub text: String,
}

#[derive(Clone, Debug, Deserialize, Eq, PartialEq, Serialize)]
pub struct ApiHelpExample {
    pub specification: String,
    pub version: String,
    pub case: String,
    pub profile: String,
    pub strictness: String,
    pub kind: String,
    pub label: String,
}

#[derive(Clone, Debug, Deserialize, Eq, PartialEq, Serialize)]
pub struct ApiHelpCard {
    pub id: String,
    pub title: String,
    pub summary: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub purpose: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub parts: Option<Vec<ApiHelpPart>>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub constraints: Option<Vec<String>>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub common_errors: Option<Vec<String>>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub examples: Option<Vec<ApiHelpExample>>,
}

#[derive(Clone, Debug, Deserialize, Eq, PartialEq, Serialize)]
pub struct ApiHelpIdentity {
    pub kind: String,
    pub id: String,
    pub role: String,
}

#[derive(Clone, Debug, Deserialize, Eq, PartialEq, Serialize)]
pub struct ApiHelpSymbol {
    pub category: String,
    pub identifier: String,
}

#[derive(Clone, Debug, Deserialize, Eq, PartialEq, Serialize)]
pub struct ApiHelpResolution {
    pub identity: Option<ApiHelpIdentity>,
    pub symbol: Option<ApiHelpSymbol>,
    pub certainty: String,
    pub lexical_range: ApiSpan,
    pub enclosing_range: Option<ApiSpan>,
}

#[derive(Clone, Debug, Deserialize, Eq, PartialEq, Serialize)]
pub struct ApiHelpEntry {
    pub category: String,
    pub identifier: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub type_name: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub is_inferred: Option<bool>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub is_intrinsic: Option<bool>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub signature: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub description: Option<String>,
}

#[derive(Clone, Debug, Deserialize, Eq, PartialEq, Serialize)]
pub struct ApiSpan {
    pub start: ApiPosition,
    pub end: ApiPosition,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub source: Option<ApiSourceIdentity>,
}

impl ApiSpan {
    pub fn new(start: ApiPosition, end: ApiPosition) -> Self {
        Self {
            start,
            end,
            source: None,
        }
    }

    pub fn in_source(
        start: ApiPosition,
        end: ApiPosition,
        source: Option<ApiSourceIdentity>,
    ) -> Self {
        Self { start, end, source }
    }
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
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub source: Option<ApiSourceIdentity>,
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
