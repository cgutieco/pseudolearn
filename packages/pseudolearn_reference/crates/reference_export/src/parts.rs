use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, Deserialize, Eq, PartialEq, Serialize)]
#[serde(deny_unknown_fields)]
pub struct PartDefinition {
    pub id: String,
    #[serde(rename = "numero")]
    pub number: String,
    #[serde(rename = "prefijo")]
    pub prefix: String,
    #[serde(rename = "titulo")]
    pub title: String,
    #[serde(rename = "resumen")]
    pub summary: String,
}

pub fn parse_parts(text: &str) -> Result<Vec<PartDefinition>, String> {
    serde_json::from_str(text).map_err(|error| format!("invalid parts file: {error}"))
}

pub fn section_prefix(number: &str) -> &str {
    number.split('.').next().unwrap_or(number)
}
