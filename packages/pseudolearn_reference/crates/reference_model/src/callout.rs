use serde::Serialize;

#[derive(Clone, Copy, Debug, Eq, Hash, Ord, PartialEq, PartialOrd, Serialize)]
#[serde(rename_all = "snake_case")]
pub enum CalloutKind {
    Phrase,
    Limit,
    Inside,
    Analogy,
    Note,
    Parts,
    Errors,
    Summary,
    SeeAlso,
    Problem,
    Attempt,
    Answer,
    Brief,
    Roles,
    Paradigm,
    Recall,
    SpecLinks,
    Deepen,
    Practice,
    Next,
    Statement,
    Restriction,
    Hints,
    Variant,
    Explanation,
}

const DIRECTIVES: [(CalloutKind, &str); 25] = [
    (CalloutKind::Phrase, "frase"),
    (CalloutKind::Limit, "limite"),
    (CalloutKind::Inside, "por-dentro"),
    (CalloutKind::Analogy, "analogia"),
    (CalloutKind::Note, "nota"),
    (CalloutKind::Parts, "partes"),
    (CalloutKind::Errors, "errores"),
    (CalloutKind::Summary, "resumen"),
    (CalloutKind::SeeAlso, "vease"),
    (CalloutKind::Problem, "problema"),
    (CalloutKind::Attempt, "intento"),
    (CalloutKind::Answer, "respuesta"),
    (CalloutKind::Brief, "ficha"),
    (CalloutKind::Roles, "roles"),
    (CalloutKind::Paradigm, "paradigma"),
    (CalloutKind::Recall, "recuerda"),
    (CalloutKind::SpecLinks, "especificacion"),
    (CalloutKind::Deepen, "profundizar"),
    (CalloutKind::Practice, "practica"),
    (CalloutKind::Next, "siguiente"),
    (CalloutKind::Statement, "enunciado"),
    (CalloutKind::Restriction, "restriccion"),
    (CalloutKind::Hints, "pistas"),
    (CalloutKind::Variant, "variante"),
    (CalloutKind::Explanation, "explicacion"),
];

impl CalloutKind {
    pub fn from_directive(name: &str) -> Option<Self> {
        DIRECTIVES
            .iter()
            .find(|(_, directive)| *directive == name)
            .map(|(kind, _)| *kind)
    }

    pub fn directive(self) -> &'static str {
        DIRECTIVES
            .iter()
            .find(|(kind, _)| *kind == self)
            .map_or("", |(_, directive)| directive)
    }

    pub fn collapsible(self) -> bool {
        matches!(self, Self::Inside | Self::Deepen)
    }

    pub fn route_only(self) -> bool {
        matches!(
            self,
            Self::Problem
                | Self::Attempt
                | Self::Answer
                | Self::Brief
                | Self::Roles
                | Self::Paradigm
                | Self::Recall
                | Self::SpecLinks
                | Self::Deepen
                | Self::Practice
                | Self::Next
                | Self::Statement
                | Self::Restriction
                | Self::Hints
                | Self::Variant
                | Self::Explanation
        )
    }
}
