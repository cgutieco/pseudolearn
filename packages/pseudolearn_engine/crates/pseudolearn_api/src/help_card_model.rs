use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, Deserialize, Eq, PartialEq, Serialize)]
pub struct ApiHelpPart {
    pub kind: String,
    pub identity: String,
    pub name: String,
    pub text: String,
}

#[derive(Clone, Debug, Deserialize, Eq, PartialEq, Serialize)]
pub struct ApiHelpFormSegment {
    pub kind: String,
    pub text: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub slot: Option<String>,
    pub joined: bool,
}

#[derive(Clone, Debug, Deserialize, Eq, PartialEq, Serialize)]
pub struct ApiHelpFormLine {
    pub indent: u8,
    pub segments: Vec<ApiHelpFormSegment>,
}

#[derive(Clone, Debug, Deserialize, Eq, PartialEq, Serialize)]
pub struct ApiHelpProgram {
    pub source: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub output: Option<String>,
}

#[derive(Clone, Debug, Deserialize, Eq, PartialEq, Serialize)]
pub struct ApiHelpCommonError {
    pub text: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub program: Option<ApiHelpProgram>,
}

#[derive(Clone, Debug, Deserialize, Eq, PartialEq, Serialize)]
pub struct ApiHelpExample {
    pub specification: String,
    pub version: String,
    pub case: String,
    pub kind: String,
    pub note: String,
    pub program: ApiHelpProgram,
}

#[derive(Clone, Debug, Deserialize, Eq, PartialEq, Serialize)]
pub struct ApiHelpCard {
    pub id: String,
    pub title: String,
    pub summary: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub category: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub form: Option<Vec<ApiHelpFormLine>>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub parts: Option<Vec<ApiHelpPart>>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub result: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub rules: Option<Vec<String>>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub common_errors: Option<Vec<ApiHelpCommonError>>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub examples: Option<Vec<ApiHelpExample>>,
}
