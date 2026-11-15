#[derive(Clone, Debug, Eq, PartialEq)]
pub enum Inline {
    Text(String),
    Strong(String),
    Emphasis(String),
    Code(String),
    Slot(String),
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
        anchor: Option<String>,
        text: String,
    },
    LessonLink {
        lesson: String,
        text: String,
    },
}
