use crate::TokenCategory;
use serde::ser::SerializeSeq;
use serde::{Serialize, Serializer};

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Token {
    pub text: String,
    pub category: Option<TokenCategory>,
}

impl Serialize for Token {
    fn serialize<Target: Serializer>(
        &self,
        serializer: Target,
    ) -> Result<Target::Ok, Target::Error> {
        let length = if self.category.is_some() { 2 } else { 1 };
        let mut sequence = serializer.serialize_seq(Some(length))?;
        sequence.serialize_element(&self.text)?;
        if let Some(category) = self.category {
            sequence.serialize_element(&category)?;
        }
        sequence.end()
    }
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
#[serde(tag = "type", rename_all = "snake_case")]
pub enum Run {
    Text {
        text: String,
    },
    Strong {
        text: String,
    },
    Emphasis {
        text: String,
    },
    Code {
        tokens: Vec<Token>,
    },
    Slot {
        text: String,
    },
    Link {
        section: String,
        text: String,
    },
    Term {
        term: String,
        text: String,
    },
    Definition {
        term: String,
        text: String,
    },
    SpecLink {
        section: String,
        #[serde(skip_serializing_if = "Option::is_none")]
        anchor: Option<String>,
        text: String,
    },
    LessonLink {
        lesson: String,
        text: String,
    },
}

impl Run {
    pub fn plain_text(&self) -> String {
        match self {
            Self::Text { text }
            | Self::Strong { text }
            | Self::Emphasis { text }
            | Self::Slot { text }
            | Self::Link { text, .. }
            | Self::Term { text, .. }
            | Self::Definition { text, .. }
            | Self::SpecLink { text, .. }
            | Self::LessonLink { text, .. } => text.clone(),
            Self::Code { tokens } => tokens.iter().map(|token| token.text.as_str()).collect(),
        }
    }
}
