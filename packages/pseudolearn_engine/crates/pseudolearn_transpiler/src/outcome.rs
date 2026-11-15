use pseudolearn_source::Span;

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Blocker {
    pub construct: String,
    pub span: Span,
}

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct Transpilation {
    pub code: String,
    pub line_origins: Vec<Option<Span>>,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum TranspileOutcome {
    Code(Transpilation),
    Unavailable(Vec<Blocker>),
}
