use crate::arguments::{ArgumentKind, DiagnosticArgument, DiagnosticType, TypeName};
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
    pub arguments: BTreeMap<String, DiagnosticArgument>,
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
        let argument = match self.code.argument_kind(key) {
            Some(ArgumentKind::Token) => DiagnosticArgument::Token(value.to_owned()),
            Some(ArgumentKind::Type) => DiagnosticArgument::Type(DiagnosticType {
                name: TypeName::Named(value.to_owned()),
                rank: 0,
            }),
            Some(ArgumentKind::Term) => DiagnosticArgument::Term(value.to_owned()),
            _ => DiagnosticArgument::Lexeme(value.to_owned()),
        };
        self.arguments.insert(key.to_owned(), argument);
        self
    }

    pub fn with_number(mut self, key: &str, value: impl Into<serde_json::Number>) -> Self {
        self.arguments
            .insert(key.to_owned(), DiagnosticArgument::Number(value.into()));
        self
    }

    pub fn with_related(mut self, span: Span) -> Self {
        self.related.push(span);
        self
    }
}
