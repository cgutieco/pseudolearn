#[derive(Clone, Debug, Eq, PartialEq)]
pub enum Inline {
    Text(String),
    Strong(String),
    Emphasis(String),
    Code(String),
    Slot(String),
    Link { section: String, text: String },
    Term { term: String, text: String },
}
