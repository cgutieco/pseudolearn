#![forbid(unsafe_code)]

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub(crate) enum ReadKind {
    Integer,
    Real,
    Boolean,
    Character,
    Text,
}

impl ReadKind {
    pub(crate) const fn event_name(self) -> &'static str {
        match self {
            Self::Integer => "entero",
            Self::Real => "real",
            Self::Boolean => "logico",
            Self::Character => "caracter",
            Self::Text => "cadena",
        }
    }

    pub(crate) const fn diagnostic_name(self) -> &'static str {
        match self {
            Self::Integer => "Entero",
            Self::Real => "Real",
            Self::Boolean => "Logico",
            Self::Character => "Caracter",
            Self::Text => "Cadena",
        }
    }
}
