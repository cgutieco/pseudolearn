use crate::code::DiagnosticCode;
use pseudolearn_source::Span;
use std::collections::BTreeMap;

#[derive(Clone, Copy, Debug, Eq, Hash, Ord, PartialEq, PartialOrd)]
pub enum DiagnosticClass {
    Lexical,
    Syntactic,
    Semantic,
    Resource,
    Runtime,
    Internal,
}

impl DiagnosticClass {
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Lexical => "lexical",
            Self::Syntactic => "syntax",
            Self::Semantic => "semantic",
            Self::Resource => "resource",
            Self::Runtime => "runtime",
            Self::Internal => "internal",
        }
    }
}

#[derive(Clone, Copy, Debug, Eq, Hash, Ord, PartialEq, PartialOrd)]
pub enum DiagnosticSeverity {
    Error,
    Warning,
    Information,
}

impl DiagnosticSeverity {
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Error => "error",
            Self::Warning => "advertencia",
            Self::Information => "informacion",
        }
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Diagnostic {
    pub code: DiagnosticCode,
    pub class: DiagnosticClass,
    pub severity: DiagnosticSeverity,
    pub span: Span,
    pub related: Vec<Span>,
    pub arguments: BTreeMap<String, String>,
}

impl Diagnostic {
    pub fn new(code: DiagnosticCode, span: Span) -> Self {
        Self {
            code,
            class: code.default_class(),
            severity: code.severity("estricto"),
            span,
            related: Vec::new(),
            arguments: BTreeMap::new(),
        }
    }

    pub fn with_severity(mut self, severity: DiagnosticSeverity) -> Self {
        self.severity = severity;
        self
    }

    pub fn with_argument(mut self, key: &str, value: &str) -> Self {
        self.arguments.insert(key.to_owned(), value.to_owned());
        self
    }

    pub fn with_related(mut self, span: Span) -> Self {
        self.related.push(span);
        self
    }
}
