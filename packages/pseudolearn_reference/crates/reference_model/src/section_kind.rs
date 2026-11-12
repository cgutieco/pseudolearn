use serde::{Deserialize, Serialize};

#[derive(Clone, Copy, Debug, Deserialize, Eq, Hash, PartialEq, Serialize)]
pub enum SectionKind {
    #[serde(rename = "concepto")]
    Concept,
    #[serde(rename = "construccion")]
    Construction,
    #[serde(rename = "tipo")]
    Type,
    #[serde(rename = "motor")]
    Engine,
    #[serde(rename = "apendice")]
    Appendix,
}

impl SectionKind {
    pub fn minimum_programs(self) -> usize {
        match self {
            Self::Concept => 1,
            Self::Construction | Self::Type => 2,
            Self::Engine | Self::Appendix => 0,
        }
    }

    pub fn requires_form(self) -> bool {
        matches!(self, Self::Construction | Self::Type)
    }

    pub fn requires_parts(self) -> bool {
        matches!(self, Self::Construction)
    }

    pub fn requires_how_it_works(self) -> bool {
        matches!(
            self,
            Self::Concept | Self::Construction | Self::Type | Self::Engine
        )
    }

    pub fn requires_errors(self) -> bool {
        matches!(self, Self::Construction | Self::Type)
    }

    pub fn requires_inside(self) -> bool {
        matches!(self, Self::Construction | Self::Type)
    }

    pub fn requires_limit(self) -> bool {
        matches!(self, Self::Type)
    }
}
