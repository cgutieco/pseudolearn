use crate::SectionKind;
use serde::Deserialize;

#[derive(Clone, Copy, Debug, Eq, Hash, Ord, PartialEq, PartialOrd)]
pub enum Profile {
    Spanish,
    English,
}

impl Profile {
    pub fn code(self) -> &'static str {
        match self {
            Self::Spanish => "es",
            Self::English => "en",
        }
    }

    pub fn from_code(code: &str) -> Option<Self> {
        match code {
            "es" => Some(Self::Spanish),
            "en" => Some(Self::English),
            _ => None,
        }
    }

    pub fn all() -> [Self; 2] {
        [Self::Spanish, Self::English]
    }
}

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct RailRequest {
    pub production: String,
    pub contextual: Vec<Option<String>>,
}

#[derive(Clone, Debug, Deserialize, Eq, PartialEq)]
#[serde(deny_unknown_fields)]
pub struct SectionHeader {
    pub id: String,
    #[serde(rename = "numero")]
    pub number: String,
    #[serde(rename = "tipo")]
    pub kind: SectionKind,
    #[serde(rename = "titulo")]
    pub title: String,
    #[serde(rename = "anclas", default)]
    pub anchors: Vec<String>,
    #[serde(rename = "fichas", default)]
    pub cards: Vec<String>,
    #[serde(rename = "diagnosticos", default)]
    pub diagnostics: Vec<String>,
    #[serde(rename = "terminos", default)]
    pub terms: Vec<String>,
}
