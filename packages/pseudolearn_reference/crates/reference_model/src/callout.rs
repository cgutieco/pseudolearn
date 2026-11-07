use serde::Serialize;

#[derive(Clone, Copy, Debug, Eq, Hash, Ord, PartialEq, PartialOrd, Serialize)]
#[serde(rename_all = "snake_case")]
pub enum CalloutKind {
    Phrase,
    Limit,
    Teachers,
    Inside,
    Analogy,
    Note,
    Parts,
    Errors,
    Summary,
    SeeAlso,
}

impl CalloutKind {
    pub fn from_directive(name: &str) -> Option<Self> {
        let kind = match name {
            "frase" => Self::Phrase,
            "limite" => Self::Limit,
            "docentes" => Self::Teachers,
            "por-dentro" => Self::Inside,
            "analogia" => Self::Analogy,
            "nota" => Self::Note,
            "partes" => Self::Parts,
            "errores" => Self::Errors,
            "resumen" => Self::Summary,
            "vease" => Self::SeeAlso,
            _ => return None,
        };
        Some(kind)
    }

    pub fn directive(self) -> &'static str {
        match self {
            Self::Phrase => "frase",
            Self::Limit => "limite",
            Self::Teachers => "docentes",
            Self::Inside => "por-dentro",
            Self::Analogy => "analogia",
            Self::Note => "nota",
            Self::Parts => "partes",
            Self::Errors => "errores",
            Self::Summary => "resumen",
            Self::SeeAlso => "vease",
        }
    }

    pub fn collapsible(self) -> bool {
        matches!(self, Self::Teachers | Self::Inside)
    }
}
